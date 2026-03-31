-- Event reminder notifications via pg_cron
-- Runs every hour and sends notifications to registered users for events
-- happening in ~24 hours or ~1 hour.
--
-- Prerequisites: enable pg_cron extension in Supabase Dashboard
--   Dashboard → Database → Extensions → search "pg_cron" → enable

-- Enable pg_cron (run once if not already enabled)
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Create the reminder function
CREATE OR REPLACE FUNCTION send_event_reminders()
RETURNS void AS $$
DECLARE
  rec RECORD;
BEGIN
  -- 24-hour reminder: events starting between 23h50m and 24h10m from now
  FOR rec IN
    SELECT
      er.user_id,
      e.id        AS event_id,
      e.title,
      e.start_date,
      e.meeting_link
    FROM event_registrations er
    JOIN events e ON e.id = er.event_id
    WHERE er.status = 'registered'
      AND e.start_date BETWEEN (NOW() + INTERVAL '23 hours 50 minutes')
                           AND (NOW() + INTERVAL '24 hours 10 minutes')
  LOOP
    INSERT INTO notifications (user_id, title, message, type, priority, is_read, created_at)
    VALUES (
      rec.user_id,
      'Event Tomorrow: ' || rec.title,
      'Reminder: "' || rec.title || '" starts tomorrow at '
        || TO_CHAR(rec.start_date AT TIME ZONE 'UTC', 'HH12:MI AM')
        || ' UTC.'
        || CASE WHEN rec.meeting_link IS NOT NULL THEN ' Open the app to join.' ELSE '' END,
      'event',
      'high',
      false,
      NOW()
    )
    ON CONFLICT DO NOTHING;
  END LOOP;

  -- 1-hour reminder: events starting between 50m and 70m from now
  FOR rec IN
    SELECT
      er.user_id,
      e.id        AS event_id,
      e.title,
      e.start_date,
      e.meeting_link
    FROM event_registrations er
    JOIN events e ON e.id = er.event_id
    WHERE er.status = 'registered'
      AND e.start_date BETWEEN (NOW() + INTERVAL '50 minutes')
                           AND (NOW() + INTERVAL '70 minutes')
  LOOP
    INSERT INTO notifications (user_id, title, message, type, priority, is_read, created_at)
    VALUES (
      rec.user_id,
      'Starting Soon: ' || rec.title,
      '"' || rec.title || '" starts in about 1 hour.'
        || CASE WHEN rec.meeting_link IS NOT NULL THEN ' Open the app to join.' ELSE '' END,
      'event',
      'high',
      false,
      NOW()
    )
    ON CONFLICT DO NOTHING;
  END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Schedule the function to run every hour
SELECT cron.schedule(
  'event-reminders',       -- job name
  '0 * * * *',             -- every hour at :00
  'SELECT send_event_reminders();'
);
