-- Add admin_approved column to pending_signups
ALTER TABLE pending_signups
  ADD COLUMN IF NOT EXISTS admin_approved BOOLEAN NOT NULL DEFAULT false;

-- Add meeting_link to events (null = physical/in-person event)
ALTER TABLE events
  ADD COLUMN IF NOT EXISTS meeting_link TEXT;

-- Add file attachment columns to messages
ALTER TABLE messages
  ADD COLUMN IF NOT EXISTS message_type TEXT NOT NULL DEFAULT 'text',
  ADD COLUMN IF NOT EXISTS file_url TEXT,
  ADD COLUMN IF NOT EXISTS file_name TEXT,
  ADD COLUMN IF NOT EXISTS file_size INTEGER;
