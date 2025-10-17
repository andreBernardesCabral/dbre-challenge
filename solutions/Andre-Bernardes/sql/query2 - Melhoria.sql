-- Query 2: Daily Settlement Report
WITH last_day_bets AS (
  SELECT placed_at::date AS bet_date, status, amount
  FROM bets
  WHERE placed_at >= CURRENT_DATE - INTERVAL '1 day'
    AND placed_at < CURRENT_DATE
)
SELECT
  bet_date,
  status,
  COUNT(*) AS bet_count,
  SUM(amount) AS total_amount,
  AVG(amount) AS avg_bet_size
FROM last_day_bets
GROUP BY bet_date, status
ORDER BY status;	