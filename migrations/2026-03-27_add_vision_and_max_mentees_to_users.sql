-- Migration: Add alumni-specific columns to users table
-- Run this in the Supabase SQL editor

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS vision TEXT,
  ADD COLUMN IF NOT EXISTS max_mentees INTEGER DEFAULT 3;

-- Add a comment to document the purpose
COMMENT ON COLUMN users.vision IS 'Alumni vision statement displayed on their profile';
COMMENT ON COLUMN users.max_mentees IS 'Maximum number of active mentees an alumni will accept (default 3)';
