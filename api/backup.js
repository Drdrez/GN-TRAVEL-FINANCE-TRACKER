import { supabase } from './lib/supabase.js';
import { pushToSheet } from './lib/googleSheets.js';

export default async function handler(req, res) {
  // CORS & Methods
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST,OPTIONS');
  
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  try {
    // 1. Fetch ALL data from Supabase
    const { data: incomeData } = await supabase.from('income_records').select('*').order('date');
    const { data: expenseData } = await supabase.from('expense_records').select('*').order('date');
    const { data: cashData } = await supabase.from('cash_accounts').select('*');

    // 2. Format Income Data for Sheets
    const incomeRows = [
      ['ID', 'Date', 'Client', 'Service', 'Pricing', 'Gross', 'Net', 'Status', 'Ref ID'], // Header
      ...incomeData.map(r => [r.id, r.date, r.client_name, r.service_type, r.pricing_model, r.gross, r.net, r.status, r.ref_id])
    ];

    // 3. Format Expense Data for Sheets
    const expenseRows = [
      ['ID', 'Date', 'Vendor', 'Category', 'Type', 'Amount', 'Payment', 'Status'], // Header
      ...expenseData.map(r => [r.id, r.date, r.vendor, r.category, r.type, r.amount, r.payment, r.status])
    ];

    // 4. Format Cash Data for Sheets
    const cashRows = [
      ['ID', 'Month', 'Account', 'Institution', 'Balance'], // Header
      ...cashData.map(r => [r.id, r.month, r.account_name, r.institution, r.balance])
    ];

    // 5. Push to Google Sheets (Parallel execution for speed)
    await Promise.all([
      pushToSheet('Income_Backup', incomeRows),
      pushToSheet('Expenses_Backup', expenseRows),
      pushToSheet('Cash_Backup', cashRows)
    ]);

    return res.status(200).json({ success: true, message: 'Backup complete!' });

  } catch (error) {
    console.error('Backup failed:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
}