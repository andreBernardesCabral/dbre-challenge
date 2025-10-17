--1 - Criar tabela pai particionada
CREATE TABLE bets_part (LIKE bets INCLUDING ALL) PARTITION BY RANGE (placed_at);

-- 2 - Criar partições mensais
CREATE TABLE bets_2025_10 PARTITION OF bets_part	FOR VALUES FROM ('2025-10-01') TO ('2025-11-01');
CREATE TABLE bets_2025_11 PARTITION OF bets_part	FOR VALUES FROM ('2025-11-01') TO ('2025-12-01');
CREATE TABLE bets_2025_12 PARTITION OF bets_part	FOR VALUES FROM ('2025-12-01') TO ('2026-01-01');
CREATE TABLE bets_2026_01 PARTITION OF bets_part	FOR VALUES FROM ('2026-01-01') TO ('2026-02-01');
--- ... repetindo para meses seguintes

-- 3 - Migrar dados antigos para as partições
-- (Necessário dependendo do cenário, com INSERT INTO..SELECT ou COPY)

-- 4 - Criar índices em cada partição conforme necessário
CREATE INDEX idx_bets_2025_10_placed_at ON bets_2025_10(placed_at);
CREATE INDEX idx_bets_2025_11_placed_at ON bets_2025_11(placed_at);
CREATE INDEX idx_bets_2025_12_placed_at ON bets_2025_12(placed_at);
CREATE INDEX idx_bets_2026_01_placed_at ON bets_2025_01(placed_at);
--- ... repetindo para meses seguintes também nos indices	