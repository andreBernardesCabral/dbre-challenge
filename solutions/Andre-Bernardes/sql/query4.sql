-- Query 4: Recent Bet Count by Status
SELECT
    status,
    COUNT(*) as count
FROM bets
WHERE placed_at >= NOW() - INTERVAL '1 hour'
GROUP BY status;