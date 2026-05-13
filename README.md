# Movie / OTT Streaming Database — SQL Project

A complete relational database for a Netflix/Prime Video-style streaming platform, built with **MySQL 8+**.

---

## Database Schema

### Tables

| Table | Description |
|---|---|
| `users` | Registered viewer accounts |
| `subscription_plans` | Basic / Standard / Premium tiers |
| `subscriptions` | User-plan mapping with validity |
| `genres` | Action, Drama, Thriller, etc. |
| `languages` | English, Hindi, Tamil, Telugu, Malayalam |
| `content` | Movies, series, documentaries, shorts |
| `content_genres` | Many-to-many: content ↔ genres |
| `seasons` | Seasons for TV series |
| `episodes` | Individual episodes per season |
| `people` | Actors, directors, writers |
| `content_cast` | Cast/crew mapped to content with roles |
| `watch_history` | Per-user watch sessions with completion flag |
| `ratings` | 1–5 star ratings per user per title |
| `watchlist` | User's "My List" |
| `reviews` | Text reviews with spoiler flag |

### ER Overview

```
users ──── subscriptions ──── subscription_plans
users ──── watch_history ──── content ──── content_genres ──── genres
users ──── ratings              │    └──── languages
users ──── watchlist            ├──── seasons ──── episodes
users ──── reviews              └──── content_cast ──── people
```

---

## Files

```
movie-sql/
├── schema.sql       -- CREATE TABLE statements + indexes
├── sample_data.sql  -- Realistic INSERT data (12 titles, 6 users, episodes, cast)
├── queries.sql      -- 25 queries across 6 sections
└── README.md
```

---

## Features Demonstrated

- **Normalization** — 3NF across all 15 tables
- **Self-referencing** — categories with parent-child (sub-genres possible)
- **Many-to-many** — content ↔ genres via junction table
- **Foreign keys** with `ON DELETE CASCADE / SET NULL`
- **Indexes** on frequently queried columns
- **Views** — `vw_content_catalog`, `vw_active_subscribers`
- **Stored Procedures** — recommendation engine, monthly report
- **Triggers** — auto-remove watchlist on completion, prevent duplicate subscriptions
- **Advanced SQL** — `EXISTS`, `NOT EXISTS`, `GROUP_CONCAT`, `HAVING`, `CASE WHEN`

---

## How to Run

```bash
mysql -u root -p

CREATE DATABASE movie_streaming;
USE movie_streaming;

SOURCE schema.sql;
SOURCE sample_data.sql;
SOURCE queries.sql;
```

---

## Query Highlights

| # | Query |
|---|---|
| 1 | All content with language and rating |
| 2 | All episodes of a series |
| 3 | Full cast and crew for a title |
| 4 | All content in a genre |
| 5 | A user's watchlist |
| 6 | Average rating per content |
| 7 | Top 5 most-watched titles |
| 8 | Total watch time per user (hours) |
| 9 | Completion rate per title |
| 10 | Subscribers and revenue per plan |
| 11 | Most popular genres |
| 12 | Titles released per year |
| 13–14 | View usage examples |
| 15–16 | Stored procedure usage |
| 17–18 | Trigger demonstrations |
| 19 | Director filmography on platform |
| 20 | Watchlisted but never started |
| 21 | Users who rated above platform average |
| 22 | Binge-watching detector |
| 23 | Content with zero watch history |
| 24 | Language-wise content breakdown |
| 25 | Revenue: active vs expired subscribers |

---

## Tech Stack

- **Database**: MySQL 8.0
- **SQL Concepts**: DDL, DML, JOINs, Subqueries, Aggregations, GROUP_CONCAT, EXISTS, Views, Stored Procedures, Triggers, Indexes

---

## License

MIT — free to use and modify.
