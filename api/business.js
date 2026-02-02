import { supabase } from './lib/supabase.js';

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  if (!supabase) {
    return res.status(503).json({ success: false, error: 'Database not configured' });
  }

  try {
    if (req.method === 'GET') {
      const { data, error } = await supabase.from('business_config').select('columns, business_data, dashboard_expenses').eq('id', 1).single();
      if (error && error.code !== 'PGRST116') throw error;

      const columns = data?.columns || ['Service A', 'Service B'];
      const businessData = data?.business_data || {};
      const dashboardExpenses = data?.dashboard_expenses || {};

      return res.status(200).json({
        success: true,
        data: { columns, businessData, dashboardExpenses }
      });
    }

    if (req.method === 'POST' || req.method === 'PUT') {
      const { columns, businessData, dashboardExpenses } = req.body;

      const row = {
        id: 1,
        updated_at: new Date().toISOString()
      };
      if (columns !== undefined) row.columns = columns;
      if (businessData !== undefined) row.business_data = businessData;
      if (dashboardExpenses !== undefined) row.dashboard_expenses = dashboardExpenses;

      const { error } = await supabase.from('business_config').upsert(row, { onConflict: 'id' });
      if (error) throw error;

      return res.status(200).json({ success: true, message: 'Business data saved' });
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (error) {
    console.error('Business API Error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
}
