-- ============================================================
--  MOVIE / OTT STREAMING DATABASE SCHEMA
--  Compatible with: MySQL 8+ / PostgreSQL 13+
--  Description: Full schema for a Netflix/Prime-style platform
-- ============================================================

-- ─────────────────────────────────────────
--  USERS & SUBSCRIPTIONS
-- ─────────────────────────────────────────

CREATE TABLE users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100)        NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255)        NOT NULL,
    date_of_birth DATE,
    country       VARCHAR(100)        DEFAULT 'India',
    is_active     BOOLEAN             DEFAULT TRUE,
    created_at    DATETIME            DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME            DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE subscription_plans (
    plan_id       INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(50)    NOT NULL,   -- Basic, Standard, Premium
    price_monthly DECIMAL(8,2)   NOT NULL,
    max_screens   TINYINT        NOT NULL,   -- simultaneous streams
    video_quality VARCHAR(20)    NOT NULL,   -- SD, HD, 4K
    has_downloads BOOLEAN        DEFAULT FALSE,
    description   TEXT
);

CREATE TABLE subscriptions (
    subscription_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id         INT      NOT NULL,
    plan_id         INT      NOT NULL,
    started_at      DATE     NOT NULL,
    expires_at      DATE     NOT NULL,
    is_active       BOOLEAN  DEFAULT TRUE,
    auto_renew      BOOLEAN  DEFAULT TRUE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (plan_id) REFERENCES subscription_plans(plan_id)
);

-- ─────────────────────────────────────────
--  CONTENT CATALOG
-- ─────────────────────────────────────────

CREATE TABLE genres (
    genre_id  INT AUTO_INCREMENT PRIMARY KEY,
    name      VARCHAR(50) UNIQUE NOT NULL   -- Action, Drama, Comedy ...
);

CREATE TABLE languages (
    language_id INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(50) UNIQUE NOT NULL,
    code        CHAR(5)            NOT NULL   -- en, hi, ta, ml ...
);

CREATE TABLE content (
    content_id     INT AUTO_INCREMENT PRIMARY KEY,
    title          VARCHAR(255)  NOT NULL,
    type           ENUM('movie','series','documentary','short') NOT NULL,
    description    TEXT,
    release_year   YEAR,
    duration_mins  SMALLINT,                  -- for movies/shorts
    maturity_rating VARCHAR(10)  DEFAULT 'U', -- U, U/A 13+, A
    language_id    INT,
    country_origin VARCHAR(100),
    thumbnail_url  VARCHAR(500),
    trailer_url    VARCHAR(500),
    is_active      BOOLEAN       DEFAULT TRUE,
    created_at     DATETIME      DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (language_id) REFERENCES languages(language_id)
);

-- Many-to-many: content ↔ genres
CREATE TABLE content_genres (
    content_id INT NOT NULL,
    genre_id   INT NOT NULL,
    PRIMARY KEY (content_id, genre_id),
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE,
    FOREIGN KEY (genre_id)   REFERENCES genres(genre_id)    ON DELETE CASCADE
);

-- TV Series: seasons and episodes
CREATE TABLE seasons (
    season_id  INT AUTO_INCREMENT PRIMARY KEY,
    content_id INT         NOT NULL,
    season_no  TINYINT     NOT NULL,
    title      VARCHAR(150),
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE
);

CREATE TABLE episodes (
    episode_id    INT AUTO_INCREMENT PRIMARY KEY,
    season_id     INT          NOT NULL,
    episode_no    TINYINT      NOT NULL,
    title         VARCHAR(255) NOT NULL,
    description   TEXT,
    duration_mins SMALLINT     NOT NULL,
    thumbnail_url VARCHAR(500),
    FOREIGN KEY (season_id) REFERENCES seasons(season_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  CAST & CREW
-- ─────────────────────────────────────────

CREATE TABLE people (
    person_id   INT AUTO_INCREMENT PRIMARY KEY,
    full_name   VARCHAR(150) NOT NULL,
    birth_date  DATE,
    nationality VARCHAR(100),
    bio         TEXT,
    photo_url   VARCHAR(500)
);

CREATE TABLE content_cast (
    cast_id    INT AUTO_INCREMENT PRIMARY KEY,
    content_id INT         NOT NULL,
    person_id  INT         NOT NULL,
    role       ENUM('actor','director','producer','writer','composer') NOT NULL,
    character_name VARCHAR(150),            -- for actors
    billing_order  TINYINT DEFAULT 99,      -- 1 = top billed
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE,
    FOREIGN KEY (person_id)  REFERENCES people(person_id)   ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  USER INTERACTIONS
-- ─────────────────────────────────────────

-- Watch history (per movie or per episode)
CREATE TABLE watch_history (
    history_id     INT AUTO_INCREMENT PRIMARY KEY,
    user_id        INT      NOT NULL,
    content_id     INT      NOT NULL,
    episode_id     INT      DEFAULT NULL,  -- NULL for movies
    watched_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    watch_duration_mins SMALLINT DEFAULT 0,
    completed      BOOLEAN  DEFAULT FALSE,
    FOREIGN KEY (user_id)    REFERENCES users(user_id)      ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE,
    FOREIGN KEY (episode_id) REFERENCES episodes(episode_id) ON DELETE SET NULL
);

-- Ratings (1–5 stars)
CREATE TABLE ratings (
    rating_id  INT AUTO_INCREMENT PRIMARY KEY,
    user_id    INT     NOT NULL,
    content_id INT     NOT NULL,
    score      TINYINT NOT NULL CHECK (score BETWEEN 1 AND 5),
    rated_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_rating (user_id, content_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)      ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE
);

-- Watchlist / My List
CREATE TABLE watchlist (
    watchlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT      NOT NULL,
    content_id   INT      NOT NULL,
    added_at     DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_watchlist (user_id, content_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)      ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE
);

-- Reviews (text, with spoiler flag)
CREATE TABLE reviews (
    review_id    INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT      NOT NULL,
    content_id   INT      NOT NULL,
    body         TEXT     NOT NULL,
    has_spoiler  BOOLEAN  DEFAULT FALSE,
    likes_count  INT      DEFAULT 0,
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_review (user_id, content_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)      ON DELETE CASCADE,
    FOREIGN KEY (content_id) REFERENCES content(content_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  INDEXES
-- ─────────────────────────────────────────

CREATE INDEX idx_content_type      ON content(type);
CREATE INDEX idx_content_year      ON content(release_year);
CREATE INDEX idx_watch_user        ON watch_history(user_id);
CREATE INDEX idx_watch_content     ON watch_history(content_id);
CREATE INDEX idx_ratings_content   ON ratings(content_id);
CREATE INDEX idx_cast_content      ON content_cast(content_id);
CREATE INDEX idx_cast_person       ON content_cast(person_id);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id);
