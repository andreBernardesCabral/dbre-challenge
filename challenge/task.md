# DBRE Challenge — Single Spec

This challenge uses a simplified betting domain with **users**, **events**, and **bets** stored in PostgreSQL. You can adjust the schema if it helps, but keep your examples and benchmarks consistent.

## Baseline Schema (PostgreSQL)
```sql
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
```

## Underperforming Queries

The application has several query patterns that need optimization. Candidates should test and optimize ALL queries below:

### Query 1: Active Bets for Upcoming Events (Hot Query - High Frequency)
```sql
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
```
**Use case**: Real-time dashboard showing active bets
**Frequency**: 1000+ queries/second
**Symptom**: p95 latency about 600ms despite basic indexes

### Query 2: Daily Settlement Report (Time-Range Query)
```sql
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
```
**Use case**: Finance team daily reconciliation
**Frequency**: Run once per day (automated job)
**Symptom**: Takes 300ms, blocks other queries

### Query 3: User Betting Activity for Specific Day
```sql
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
```
**Use case**: Customer analytics and high-roller identification
**Frequency**: 50 queries/minute
**Symptom**: 450ms latency

### Query 4: Recent Bet Count by Status
```sql
SELECT
    status,
    COUNT(*) as count
FROM bets
WHERE placed_at >= NOW() - INTERVAL '1 hour'
GROUP BY status;
```
**Use case**: Operations dashboard showing recent activity
**Frequency**: 500 queries/minute
**Symptom**: 180ms latency

**Note**: Each query has different access patterns and may require different optimization strategies. Candidates should analyze the execution plans and choose appropriate optimizations for each.

---

## Requirements
1. **Diagnosis and Plan**
   - Capture the execution plan and summarize key findings, document your diagnosis steps.
   - Form hypotheses for the root causes and propose measurable fixes.
2. **Optimization**
   - Provide ways to optimize queries, efficiency and performance. Explain trade-offs.
   - Demonstrate improvement with simple before/after evidence.
3. **Documentation**
   - Document assumptions, dataset generator/size, and steps to reproduce.
   - Use clear commit messages showing your iteration path.

Place results under `solutions/<your-name>/sql/` and `solutions/<your-name>/docs/`.

---

## Advanced Requirements
These items are optional for Mid, expected for Senior, and should be handled thoroughly by Staff.

4. **Store Choices and Architecture**
   - Explain when to keep data in PostgreSQL versus introducing a key-value store (e.g., Redis) or analytical store. Include data model fit, latency targets, and operational complexity.
   - Propose a simple polyglot architecture for this domain: OLTP path, cache path, analytics path. Describe consistency and freshness expectations.

5. **Scale and Reliability Plan**
   - Provide ways for sustained growth (up to multi-terabyte). Describe migration and routing.
   - Replication and HA strategy. Define RPO/RTO and how to meet them.
   - Backup and recovery strategy. Include verification steps.

6. **Observability and Automation**
   - Define SLIs/SLOs and the alerts that matter.
   - Provide scripts or IaC snippets to automate checks, bootstrap, or restore drills (pseudo-scripts are fine).

Place results under `solutions/<your-name>/architecture/` and `solutions/<your-name>/automation/`.

---

## What We Evaluate
- SQL diagnosis depth and correctness.
- Effective performance improvements with evidence.
- Soundness of architectural trade-offs across relational, key-value, and analytical stores.
- Realism of scale/HA/backup/restore plans, plus observability and automation.
- Communication quality: clear assumptions, concise docs, readable commits.
