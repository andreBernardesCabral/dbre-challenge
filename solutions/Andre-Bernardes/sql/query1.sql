-- Query 1: Active Bets for Upcoming Events
SELECT
  u.id AS user_id,
  u.name,
  b.id AS bet_id,
  b.status,
  b.amount,
  e.name AS event_name
FROM bets b
JOIN users u ON u.id = b.user_id
JOIN events e ON e.id = b.event_id
WHERE b.status = 'OPEN'
  AND e.start_time > NOW()
ORDER BY e.start_time ASC
LIMIT 100;