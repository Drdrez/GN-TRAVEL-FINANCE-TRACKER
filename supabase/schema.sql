-- GN Travel Finance Tracker - Supabase Schema
-- Run this in Supabase Dashboard → SQL Editor

-- Income records
CREATE TABLE IF NOT EXISTS income_records (
  id TEXT PRIMARY KEY,
  date DATE,
  client_name TEXT DEFAULT '',
  service_type TEXT DEFAULT '',
  pricing_model TEXT DEFAULT '',
  gross NUMERIC DEFAULT 0,
  net NUMERIC DEFAULT 0,
  payment_mode TEXT DEFAULT '',
  status TEXT DEFAULT '',
  ref_id TEXT DEFAULT '',
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Expense records
CREATE TABLE IF NOT EXISTS expense_records (
  id TEXT PRIMARY KEY,
  date DATE,
  vendor TEXT DEFAULT '',
  category TEXT DEFAULT '',
  type TEXT DEFAULT '',
  service TEXT DEFAULT '',
  amount NUMERIC DEFAULT 0,
  payment TEXT DEFAULT '',
  status TEXT DEFAULT '',
  recurring TEXT DEFAULT 'No',
  notes TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cash account balances
CREATE TABLE IF NOT EXISTS cash_accounts (
  id TEXT PRIMARY KEY,
  month TEXT DEFAULT '',
  account_name TEXT DEFAULT '',
  category TEXT DEFAULT '',
  institution TEXT DEFAULT '',
  balance NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Cash movement (one row per app - stores JSON: { "January_start": 0, "January_end": 0, ... })
CREATE TABLE IF NOT EXISTS cash_movement (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  data JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO cash_movement (id, data) VALUES (1, '{}')
ON CONFLICT (id) DO NOTHING;

-- Business config (dashboard columns, business data, expenses - single row)
CREATE TABLE IF NOT EXISTS business_config (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  columns JSONB DEFAULT '["Service A", "Service B"]',
  business_data JSONB DEFAULT '{}',
  dashboard_expenses JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO business_config (id, columns, business_data, dashboard_expenses)
VALUES (1, '["Service A", "Service B"]', '{}', '{}')
ON CONFLICT (id) DO NOTHING;

-- Enable RLS but allow all for server-side use with service role key
-- If you use anon key, add policies. With service_role key, RLS is bypassed.
ALTER TABLE income_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_movement ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_config ENABLE ROW LEVEL SECURITY;

-- Allow all operations for authenticated and anon (for server-side API using service role, these aren't needed)
-- Policy: allow all for service_role. For anon/key, add:
CREATE POLICY "Allow all for income_records" ON income_records FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for expense_records" ON expense_records FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for cash_accounts" ON cash_accounts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for cash_movement" ON cash_movement FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all for business_config" ON business_config FOR ALL USING (true) WITH CHECK (true);
