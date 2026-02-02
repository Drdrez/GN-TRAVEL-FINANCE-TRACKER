import { supabase } from './lib/supabase.js';

function toFrontendAccount(row) {
  if (!row) return null;
  return {
    id: row.id,
    month: row.month,
    accountName: row.account_name,
    category: row.category,
    institution: row.institution,
    balance: Number(row.balance) || 0,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function toDbAccount(record) {
  return {
    id: record.id,
    month: record.month ?? '',
    account_name: record.accountName ?? record.account_name ?? '',
    category: record.category ?? '',
    institution: record.institution ?? '',
    balance: record.balance ?? 0,
    updated_at: new Date().toISOString()
  };
}

export default async function handler(req, res) {
  res.setHeader('Access-Control-Allow-Credentials', true);
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET,POST,PUT,DELETE,OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  const { type } = req.query;

  if (!supabase) {
    return res.status(503).json({ success: false, error: 'Database not configured' });
  }

  try {
    if (type === 'movement') {
      if (req.method === 'GET') {
        const { data, error } = await supabase.from('cash_movement').select('data').eq('id', 1).single();
        if (error && error.code !== 'PGRST116') throw error;
        const movement = data?.data || {};
        return res.status(200).json({ success: true, data: movement });
      }
      if (req.method === 'POST' || req.method === 'PUT') {
        const movement = req.body;
        const { error } = await supabase.from('cash_movement').upsert(
          { id: 1, data: movement, updated_at: new Date().toISOString() },
          { onConflict: 'id' }
        );
        if (error) throw error;
        return res.status(200).json({ success: true, data: movement });
      }
    } else {
      if (req.method === 'GET') {
        const { data, error } = await supabase.from('cash_accounts').select('*').order('created_at', { ascending: true });
        if (error) throw error;
        const records = (data || []).map(toFrontendAccount);
        return res.status(200).json({ success: true, data: records });
      }
      if (req.method === 'POST') {
        const record = req.body;
        record.id = record.id || Date.now().toString();
        const row = toDbAccount(record);
        row.created_at = new Date().toISOString();

        const { data, error } = await supabase.from('cash_accounts').insert(row).select().single();
        if (error) throw error;
        return res.status(201).json({ success: true, data: toFrontendAccount(data) });
      }
      if (req.method === 'PUT') {
        const body = req.body;
        if (Array.isArray(body)) {
          const { data: existing } = await supabase.from('cash_accounts').select('id');
          if (existing?.length) {
            await supabase.from('cash_accounts').delete().in('id', existing.map(r => r.id));
          }
          if (body.length > 0) {
            const rows = body.map(r => ({ ...toDbAccount(r), created_at: r.createdAt || new Date().toISOString() }));
            const { error } = await supabase.from('cash_accounts').upsert(rows, { onConflict: 'id' });
            if (error) throw error;
          }
          return res.status(200).json({ success: true, data: body });
        }
        const row = toDbAccount(body);
        const { data, error } = await supabase.from('cash_accounts').upsert(row, { onConflict: 'id' }).select().single();
        if (error) throw error;
        return res.status(200).json({ success: true, data: toFrontendAccount(data) });
      }
      if (req.method === 'DELETE') {
        const { id } = req.query;
        if (!id) return res.status(400).json({ success: false, error: 'Missing id' });
        const { error } = await supabase.from('cash_accounts').delete().eq('id', id);
        if (error) throw error;
        return res.status(200).json({ success: true, message: 'Record deleted' });
      }
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (error) {
    console.error('Cash API Error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
}
