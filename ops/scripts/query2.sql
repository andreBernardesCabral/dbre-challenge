-- Query 2: Daily Settlement Report
SELECT
    DATE(placed_at) as bet_date,
    status,
    COUNT(*) as bet_count,
    SUM(amount) as total_amount,
    AVG(amount) as avg_bet_size
FROM bets
WHERE placed_at >= CURRENT_DATE - INTERVAL '1 day'
  AND placed_at < CURRENT_DATE
GROUP BY DATE(placed_at), status
ORDER BY status;

