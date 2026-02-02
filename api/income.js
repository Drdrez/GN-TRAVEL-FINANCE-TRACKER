import { supabase } from './lib/supabase.js';

function toFrontend(row) {
  if (!row) return null;
  return {
    id: row.id,
    date: row.date,
    clientName: row.client_name,
    serviceType: row.service_type,
    pricingModel: row.pricing_model,
    gross: Number(row.gross) || 0,
    net: Number(row.net) || 0,
    paymentMode: row.payment_mode,
    status: row.status,
    refId: row.ref_id,
    notes: row.notes,
    createdAt: row.created_at,
    updatedAt: row.updated_at
  };
}

function toDb(record) {
  return {
    id: record.id,
    date: record.date || null,
    client_name: record.clientName ?? record.client_name ?? '',
    service_type: record.serviceType ?? record.service_type ?? '',
    pricing_model: record.pricingModel ?? record.pricing_model ?? '',
    gross: record.gross ?? 0,
    net: record.net ?? 0,
    payment_mode: record.paymentMode ?? record.payment_mode ?? '',
    status: record.status ?? '',
    ref_id: record.refId ?? record.ref_id ?? '',
    notes: record.notes ?? '',
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

  if (!supabase) {
    return res.status(503).json({ success: false, error: 'Database not configured' });
  }

  try {
    if (req.method === 'GET') {
      const { data, error } = await supabase.from('income_records').select('*').order('created_at', { ascending: true });
      if (error) throw error;
      const records = (data || []).map(toFrontend);
      return res.status(200).json({ success: true, data: records });
    }

    if (req.method === 'POST') {
      const record = req.body;
      record.id = record.id || Date.now().toString();
      const row = toDb(record);
      row.created_at = new Date().toISOString();

      const { data, error } = await supabase.from('income_records').insert(row).select().single();
      if (error) throw error;
      return res.status(201).json({ success: true, data: toFrontend(data) });
    }

    if (req.method === 'PUT') {
      const body = req.body;

      if (Array.isArray(body)) {
        const { data: existing } = await supabase.from('income_records').select('id');
        if (existing?.length) {
          await supabase.from('income_records').delete().in('id', existing.map(r => r.id));
        }
        if (body.length > 0) {
          const rows = body.map(r => ({ ...toDb(r), created_at: r.createdAt || new Date().toISOString() }));
          const { error } = await supabase.from('income_records').upsert(rows, { onConflict: 'id' });
          if (error) throw error;
        }
        return res.status(200).json({ success: true, data: body });
      }

      const row = toDb(body);
      const { data, error } = await supabase.from('income_records').upsert(row, { onConflict: 'id' }).select().single();
      if (error) throw error;
      return res.status(200).json({ success: true, data: toFrontend(data) });
    }

    if (req.method === 'DELETE') {
      const { id } = req.query;
      if (!id) return res.status(400).json({ success: false, error: 'Missing id' });
      const { error } = await supabase.from('income_records').delete().eq('id', id);
      if (error) throw error;
      return res.status(200).json({ success: true, message: 'Record deleted' });
    }

    return res.status(405).json({ success: false, error: 'Method not allowed' });
  } catch (error) {
    console.error('Income API Error:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
}
