-- Migration: Add career description column to users table for alumni profiles
-- Run this in the Supabase SQL editor

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS career TEXT;

COMMENT ON COLUMN users.career IS 'Alumni career description paragraph (e.g. "Currently a Full Stack Developer at INOFIXZ...")';
