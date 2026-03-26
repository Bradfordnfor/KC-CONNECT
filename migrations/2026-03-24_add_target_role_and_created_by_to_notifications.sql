-- Migration: Add target_role and created_by to notifications table for admin broadcast support
ALTER TABLE notifications
ADD COLUMN target_role text;

ALTER TABLE notifications
ADD COLUMN created_by uuid REFERENCES users(id);
