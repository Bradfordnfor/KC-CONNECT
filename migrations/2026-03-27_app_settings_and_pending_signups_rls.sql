-- Create app_settings table (key-value store for admin-configurable settings)
CREATE TABLE IF NOT EXISTS app_settings (
  key TEXT PRIMARY KEY,
  value JSONB NOT NULL,
  description TEXT,
  updated_by UUID REFERENCES users(id),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed default settings
INSERT INTO app_settings (key, value, description)
VALUES
  ('subscription_fee', '1000', 'Monthly subscription fee in XAF'),
  ('maintenance_mode', 'false', 'Put app in maintenance mode for all non-admin users')
ON CONFLICT (key) DO NOTHING;

-- RLS on app_settings: only admins can read/write
ALTER TABLE app_settings ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Admins can manage app settings"
  ON app_settings
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
  )
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
  );

-- ─── pending_signups RLS ────────────────────────────────────────────────────
-- Allow anonymous users to insert signup requests
ALTER TABLE pending_signups ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public can insert signup requests"
  ON pending_signups
  FOR INSERT
  TO anon
  WITH CHECK (true);

-- Allow anonymous users to read their own pending signup (for OTP verification)
CREATE POLICY "Public can read pending signups"
  ON pending_signups
  FOR SELECT
  TO anon
  USING (true);

-- Allow authenticated admins full access
CREATE POLICY "Admins can manage pending signups"
  ON pending_signups
  FOR ALL
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM users
      WHERE users.id = auth.uid()
        AND users.role = 'admin'
    )
  );

-- Allow the service role (Edge Functions) to do everything
CREATE POLICY "Service role full access to pending signups"
  ON pending_signups
  FOR ALL
  TO service_role
  USING (true)
  WITH CHECK (true);
