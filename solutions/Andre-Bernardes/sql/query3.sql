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
GROUP BY u.id, u.name
HAVING COUNT(*) >= 5
ORDER BY total_wagered DESC
LIMIT 20;