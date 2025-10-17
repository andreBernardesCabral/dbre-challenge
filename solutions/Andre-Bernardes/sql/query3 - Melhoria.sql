-- Query 3: User Betting Activity for Specific Day
SELECT
    u.id,
    u.name,
    COUNT(*) as bet_count,
    SUM(b.amount) as total_wagered,
    AVG(b.amount) as avg_bet
FROM bets b
JOIN users u ON u.id = b.user_id
WHERE b.placed_at >= CURRENT_DATE - INTERVAL '1 day'
  AND b.placed_at < CURRENT_DATE
  AND EXISTS (
    SELECT 1
    FROM bets b2
    WHERE b2.user_id = b.user_id
      AND b2.placed_at >= CURRENT_DATE - INTERVAL '1 day'
      AND b2.placed_at < CURRENT_DATE
    GROUP BY b2.user_id
    HAVING COUNT(*) >= 5
  )
GROUP BY u.id, u.name
ORDER BY total_wagered DESC
LIMIT 20;