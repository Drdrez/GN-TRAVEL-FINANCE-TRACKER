-- ==========================================
-- 1. CREATE TABLES (If they don't exist)
-- ==========================================

-- Income Table
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

-- Expenses Table
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

-- Cash Accounts Table
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

-- Cash Movement (Singleton JSON storage)
CREATE TABLE IF NOT EXISTS cash_movement (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  data JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Business Dashboard Config (Singleton JSON storage)
CREATE TABLE IF NOT EXISTS business_config (
  id INT PRIMARY KEY DEFAULT 1 CHECK (id = 1),
  columns JSONB DEFAULT '["Service A", "Service B"]',
  business_data JSONB DEFAULT '{}',
  dashboard_expenses JSONB DEFAULT '{}',
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ==========================================
-- 2. INITIALIZE DEFAULT DATA
-- ==========================================

-- Ensure the 'settings' tables have their row #1 initialized
INSERT INTO cash_movement (id, data) 
VALUES (1, '{}') 
ON CONFLICT (id) DO NOTHING;

INSERT INTO business_config (id, columns, business_data, dashboard_expenses)
VALUES (1, '["Service A", "Service B"]', '{}', '{}')
ON CONFLICT (id) DO NOTHING;

-- ==========================================
-- 3. ENABLE REALTIME BROADCASTING
-- (This is crucial for the "Live" feature)
-- ==========================================

-- Remove from publication first to avoid "already exists" errors if re-running
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS income_records;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS expense_records;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS cash_accounts;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS cash_movement;
ALTER PUBLICATION supabase_realtime DROP TABLE IF EXISTS business_config;

-- Add tables to the Realtime publication
ALTER PUBLICATION supabase_realtime ADD TABLE income_records;
ALTER PUBLICATION supabase_realtime ADD TABLE expense_records;
ALTER PUBLICATION supabase_realtime ADD TABLE cash_accounts;
ALTER PUBLICATION supabase_realtime ADD TABLE cash_movement;
ALTER PUBLICATION supabase_realtime ADD TABLE business_config;

-- ==========================================
-- 4. SECURITY POLICIES (RLS)
-- (Allows your website to Read/Write without Login)
-- ==========================================

-- Enable RLS on all tables
ALTER TABLE income_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE expense_records ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_accounts ENABLE ROW LEVEL SECURITY;
ALTER TABLE cash_movement ENABLE ROW LEVEL SECURITY;
ALTER TABLE business_config ENABLE ROW LEVEL SECURITY;

-- Delete old policies to avoid duplicates
DROP POLICY IF EXISTS "Public Access Income" ON income_records;
DROP POLICY IF EXISTS "Public Access Expense" ON expense_records;
DROP POLICY IF EXISTS "Public Access Cash" ON cash_accounts;
DROP POLICY IF EXISTS "Public Access Movement" ON cash_movement;
DROP POLICY IF EXISTS "Public Access Config" ON business_config;

-- Create "Allow All" policies for anonymous users
CREATE POLICY "Public Access Income" ON income_records FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Expense" ON expense_records FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Cash" ON cash_accounts FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Movement" ON cash_movement FOR ALL USING (true) WITH CHECK (true);
CREATE POLICY "Public Access Config" ON business_config FOR ALL USING (true) WITH CHECK (true);
