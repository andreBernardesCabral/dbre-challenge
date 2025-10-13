# DBRE Technical Challenge

Welcome! This repository contains a hands-on Database Reliability Engineering challenge. It is designed to evaluate candidates across levels.

All candidates must **fork this repository**, keep the fork **public**, and work in small commits so reviewers can see your thinking and evolution.

---

## Goals
- Diagnose and optimize SQL workloads.
- Make architectural choices across engines and persistence options.
- Design for scalability, reliability, observability, and automation.
- Communicate trade-offs clearly and document decisions.

Time guideline: 4–6 hours (you may split across days). Partial but well-reasoned solutions are welcome.

---

## Repository Structure
```text
README.md
challenge/
  task.md                 # Single challenge description (this is the spec to follow)
  dataset/                # Optional: CSVs or extra data you generate
ops/
  docker-compose.yml      # Local Postgres + pgAdmin
  Makefile                # Helpers (seed, explain, bench)
  scripts/                # Seed and query scripts
solutions/
  <your-name>/            # Your artifacts live here
    sql/
    architecture/
    automation/
    docs/
```

## Quick Start

1. Read the full setup instructions: `ops/SETUP.md`
2. Start services: `make up`
3. Seed database: `make seed`
4. Run benchmarks: `make bench`

**Note:** This environment uses hardcoded credentials for local development only. See `ops/SETUP.md` for details.

---

## How to Submit
1. **Fork** this repository and keep your fork **public**.
2. Work in small, meaningful **commits** with clear messages (e.g., "add covering index for hot query").
3. Place your artifacts under `solutions/`.
4. Add a short HOWTO in `solutions/README.md` explaining how to reproduce your results.
5. Share the link to your **public fork** with the reviewers.

Optional but appreciated:
- Use branches and pull requests in your fork to show your review mindset.
- Add lightweight ADRs (Architecture Decision Records).

---

## Rules and Expectations
- Do not include proprietary code or data from past employers.
- Reasonable simplifications are fine—call them out explicitly.
- Use plain ASCII in files; avoid smart quotes and non-ASCII characters.

Good luck and have fun!
