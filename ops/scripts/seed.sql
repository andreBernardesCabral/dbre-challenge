-- Schema (idempotent)
CREATE TABLE IF NOT EXISTS users (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS events (
  id BIGSERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  start_time TIMESTAMPTZ NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('SCHEDULED','LIVE','FINISHED')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS bets (
  id BIGSERIAL PRIMARY KEY,
  user_id BIGINT NOT NULL REFERENCES users(id),
  event_id BIGINT NOT NULL REFERENCES events(id),
  status TEXT NOT NULL CHECK (status IN ('OPEN','SETTLED','CASHED_OUT','CANCELLED')),
  amount NUMERIC(12,2) NOT NULL,
  placed_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bets_status ON bets(status);
CREATE INDEX IF NOT EXISTS idx_events_start_time ON events(start_time);

-- Synthetic data (10x scale for better performance analysis)
-- Insert users: 200,000 (10x)
INSERT INTO users(name)
SELECT 'user_' || g
FROM generate_series(1, 200000) g
ON CONFLICT DO NOTHING;

-- Events: 800,000 (10x)
-- Distribution: 60% future (SCHEDULED), 20% LIVE, 20% past (FINISHED)
-- This ensures the hot query has plenty of future events to test with
INSERT INTO events(name, start_time, status)
SELECT
  'event_' || g,
  CASE 
    WHEN random() < 0.6 THEN NOW() + (random() * INTERVAL '30 days')  -- 60% future events
    WHEN random() < 0.8 THEN NOW() - (random() * INTERVAL '2 hours')  -- 20% ongoing
    ELSE NOW() - (random() * INTERVAL '30 days')                      -- 20% past events
  END,
  CASE
    WHEN random() < 0.6 THEN 'SCHEDULED'
    WHEN random() < 0.8 THEN 'LIVE'
    ELSE 'FINISHED'
  END
FROM generate_series(1, 800000) g
ON CONFLICT DO NOTHING;

-- Bets: 4,000,000 (10x)
-- Distribution: 40% OPEN, 40% SETTLED, 10% CASHED_OUT, 10% CANCELLED
-- Higher percentage of OPEN bets ensures the hot query has data to work with
INSERT INTO bets(user_id, event_id, status, amount, placed_at)
SELECT
  (1 + trunc(random() * (SELECT MAX(id) FROM users))::bigint),
  (1 + trunc(random() * (SELECT MAX(id) FROM events))::bigint),
  CASE
    WHEN random() < 0.4 THEN 'OPEN'
    WHEN random() < 0.8 THEN 'SETTLED'
    WHEN random() < 0.9 THEN 'CASHED_OUT'
    ELSE 'CANCELLED'
  END,
  round((random()*1000)::numeric, 2),
  NOW() - (random()*INTERVAL '7 days')
FROM generate_series(1, 4000000);

-- Run ANALYZE only (VACUUM can be done separately if needed)
ANALYZE users;
ANALYZE events;
ANALYZE bets;
