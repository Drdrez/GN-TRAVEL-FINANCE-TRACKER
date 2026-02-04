-- ==========================================
-- GN Travel Finance Tracker - Enhanced Schema
-- WITH REAL-TIME SUPPORT
-- ==========================================
-- Run this in Supabase Dashboard → SQL Editor

-- ==========================================
-- 1. CREATE TABLES
-- ==========================================

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

-- Cash movement/flow
CREATE TABLE IF NOT EXISTS cash_movement (
  id TEXT PRIMARY KEY DEFAULT 1 CHECK (id = '1'),
  data JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Business configuration (columns, dropdowns)
CREATE TABLE IF NOT EXISTS business_config (
  id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  columns JSONB DEFAULT '["Service A", "Service B"]',
  business_data JSONB DEFAULT '{}',
  dashboard_expenses JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Payroll records (if needed)
CREATE TABLE IF NOT EXISTS payroll_records (
  id TEXT PRIMARY KEY,
  month TEXT DEFAULT '',
  employee TEXT DEFAULT '',
  salary NUMERIC DEFAULT 0,
  bonus NUMERIC DEFAULT 0,
  deductions NUMERIC DEFAULT 0,
  net_pay NUMERIC DEFAULT 0,
  status TEXT DEFAULT '',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Initialize single-row tables if empty
INSERT INTO cash_movement (id, data) 
VALUES ('1', '{}') 
ON CONFLICT (id) DO NOTHING;

INSERT INTO business_config (id, columns, business_data, dashboard_expenses)
VALUES (1, '["Service A", "Service B"]', '{}', '{}')
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- 2. ENABLE ROW LEVEL SECURITY (RLS)
-- ==========================================

ALTER TABLE income_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_movement ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll_records ENABLE ROW LEVEL SECURITY;

-- ==========================================
-- 3. CREATE POLICIES (Allow All)
-- ==========================================
-- WARNING: These policies allow public access. 
-- For production, restrict to authenticated users.

-- Income
DROP POLICY IF EXISTS "Enable all access for income_records" ON income_records;
CREATE POLICY "Enable all access for income_records" ON income_records FOR ALL USING (true) WITH CHECK (true);

-- Expenses
DROP POLICY IF EXISTS "Enable all access for expense_records" ON expense_records;
CREATE POLICY "Enable all access for expense_records" ON expense_records FOR ALL USING (true) WITH CHECK (true);

-- Cash Accounts
DROP POLICY IF EXISTS "Enable all access for cash_accounts" ON cash_accounts;
CREATE POLICY "Enable all access for cash_accounts" ON cash_accounts FOR ALL USING (true) WITH CHECK (true);

-- Cash Movement
DROP POLICY IF EXISTS "Enable all access for cash_movement" ON cash_movement;
CREATE POLICY "Enable all access for cash_movement" ON cash_movement FOR ALL USING (true) WITH CHECK (true);

-- Business Config
DROP POLICY IF EXISTS "Enable all access for business_config" ON business_config;
CREATE POLICY "Enable all access for business_config" ON business_config FOR ALL USING (true) WITH CHECK (true);

-- Payroll
DROP POLICY IF EXISTS "Enable all access for payroll_records" ON payroll_records;
CREATE POLICY "Enable all access for payroll_records" ON payroll_records FOR ALL USING (true) WITH CHECK (true);

-- ==========================================
-- 4. ENABLE REAL-TIME REPLICATION
-- ==========================================

-- Add tables to the publication used by Supabase Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE income_records;
ALTER PUBLICATION supabase_realtime ADD TABLE expense_records;
ALTER PUBLICATION supabase_realtime ADD TABLE cash_accounts;
ALTER PUBLICATION supabase_realtime ADD TABLE cash_movement;
ALTER PUBLICATION supabase_realtime ADD TABLE business_config;
ALTER PUBLICATION supabase_realtime ADD TABLE payroll_records;

-- ==========================================
-- 5. CREATE UPDATED_AT TRIGGER
-- ==========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Apply triggers
DROP TRIGGER IF EXISTS update_income_updated_at ON income_records;
CREATE TRIGGER update_income_updated_at BEFORE UPDATE ON income_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_expenses_updated_at ON expense_records;
CREATE TRIGGER update_expenses_updated_at BEFORE UPDATE ON expense_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_cash_accounts_updated_at ON cash_accounts;
CREATE TRIGGER update_cash_accounts_updated_at BEFORE UPDATE ON cash_accounts FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_cash_movement_updated_at ON cash_movement;
CREATE TRIGGER update_cash_movement_updated_at BEFORE UPDATE ON cash_movement FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_business_config_updated_at ON business_config;
CREATE TRIGGER update_business_config_updated_at BEFORE UPDATE ON business_config FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_payroll_records_updated_at ON payroll_records;
CREATE TRIGGER update_payroll_records_updated_at BEFORE UPDATE ON payroll_records FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
