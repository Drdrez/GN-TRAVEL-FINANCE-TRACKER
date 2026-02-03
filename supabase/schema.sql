
-- 1. INCOME RECORDS
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

-- 2. EXPENSE RECORDS
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

-- 3. CASH ACCOUNTS
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

-- 4. CASH MOVEMENT (Fixes the missing rows issue)
CREATE TABLE IF NOT EXISTS cash_movement (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  data JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Ensure the single row exists so the frontend can read/write to it
INSERT INTO cash_movement (id, data) VALUES (1, '{}')
ON CONFLICT (id) DO NOTHING;

-- 5. BUSINESS CONFIG
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

-- 6. PAYROLL RECORDS
CREATE TABLE IF NOT EXISTS payroll_records (
  id TEXT PRIMARY KEY,
  payout_date DATE,
  employee_name TEXT DEFAULT '',
  role_position TEXT DEFAULT '',
  project_client TEXT DEFAULT '',
  employment_type TEXT DEFAULT 'Part-Time',
  pay_period TEXT DEFAULT '',
  rate NUMERIC DEFAULT 0,
  total_hours NUMERIC DEFAULT 0,
  base_pay NUMERIC DEFAULT 0,
  bonus_incentives NUMERIC DEFAULT 0,
  deductions NUMERIC DEFAULT 0,
  total_payout NUMERIC DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 7. ENABLE SECURITY (RLS)
ALTER TABLE income_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_movement ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_config ENABLE ROW LEVEL SECURITY;
ALTER TABLE payroll_records ENABLE ROW LEVEL SECURITY;

-- 8. ALLOW ACCESS POLICIES
CREATE POLICY "Allow all income" ON income_records FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all expense" ON expense_records FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all cash_accounts" ON cash_accounts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all cash_movement" ON cash_movement FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all business_config" ON business_config FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Allow all payroll" ON payroll_records FOR ALL USING (true) WITH CHECK (true);
}
