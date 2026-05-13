-- ============================================================
--  MOVIE STREAMING — SAMPLE QUERIES
--  Run AFTER schema.sql and sample_data.sql
-- ============================================================


-- ─────────────────────────────────────────
--  SECTION 1: BASIC SELECT QUERIES
-- ─────────────────────────────────────────

-- 1. All movies with language and maturity rating
SELECT
    c.content_id,
    c.title,
    c.type,
    c.release_year,
    c.duration_mins,
    c.maturity_rating,
    l.name AS language
FROM content c
JOIN languages l ON c.language_id = l.language_id
WHERE c.is_active = TRUE
ORDER BY c.release_year DESC;


-- 2. All episodes of a series (Breaking Bad)
SELECT
    c.title         AS series,
    s.season_no,
    e.episode_no,
    e.title         AS episode_title,
    e.duration_mins
FROM content c
JOIN seasons  s ON c.content_id = s.content_id
JOIN episodes e ON s.season_id  = e.season_id
WHERE c.title = 'Breaking Bad'
ORDER BY s.season_no, e.episode_no;


-- 3. Cast and crew for a specific movie (RRR)
SELECT
    p.full_name,
    cc.role,
    cc.character_name,
    cc.billing_order
FROM content_cast cc
JOIN people  p ON cc.person_id  = p.person_id
JOIN content c ON cc.content_id = c.content_id
WHERE c.title = 'RRR'
ORDER BY cc.billing_order;


-- 4. All content in a genre (Thriller)
SELECT
    c.title,
    c.type,
    c.release_year,
    l.name AS language
FROM content c
JOIN content_genres cg ON c.content_id = cg.content_id
JOIN genres g           ON cg.genre_id  = g.genre_id
JOIN languages l        ON c.language_id = l.language_id
WHERE g.name = 'Thriller'
  AND c.is_active = TRUE;


-- 5. A user's watchlist with content details (user_id = 1)
SELECT
    c.title,
    c.type,
    c.release_year,
    c.maturity_rating,
    w.added_at
FROM watchlist w
JOIN content c ON w.content_id = c.content_id
WHERE w.user_id = 1
ORDER BY w.added_at DESC;


-- ─────────────────────────────────────────
--  SECTION 2: AGGREGATE & ANALYTICS
-- ─────────────────────────────────────────

-- 6. Average rating and total ratings per content
SELECT
    c.title,
    c.type,
    COUNT(r.rating_id)       AS total_ratings,
    ROUND(AVG(r.score), 1)   AS avg_rating
FROM content c
LEFT JOIN ratings r ON c.content_id = r.content_id
GROUP BY c.content_id, c.title, c.type
ORDER BY avg_rating DESC, total_ratings DESC;


-- 7. Top 5 most-watched content (by unique viewers)
SELECT
    c.title,
    c.type,
    COUNT(DISTINCT wh.user_id)  AS unique_viewers,
    SUM(wh.watch_duration_mins) AS total_watch_mins
FROM content c
JOIN watch_history wh ON c.content_id = wh.content_id
GROUP BY c.content_id, c.title, c.type
ORDER BY unique_viewers DESC
LIMIT 5;


-- 8. Total watch time per user (hours)
SELECT
    u.full_name,
    COUNT(wh.history_id)                              AS sessions,
    SUM(wh.watch_duration_mins)                       AS total_mins,
    ROUND(SUM(wh.watch_duration_mins) / 60.0, 1)     AS total_hours
FROM users u
JOIN watch_history wh ON u.user_id = wh.user_id
GROUP BY u.user_id, u.full_name
ORDER BY total_hours DESC;


-- 9. Content completion rate (how often users finish what they start)
SELECT
    c.title,
    COUNT(wh.history_id)                                         AS total_plays,
    SUM(wh.completed)                                            AS completions,
    ROUND(SUM(wh.completed) * 100.0 / COUNT(wh.history_id), 1) AS completion_pct
FROM content c
JOIN watch_history wh ON c.content_id = wh.content_id
GROUP BY c.content_id, c.title
ORDER BY completion_pct DESC;


-- 10. Subscribers per plan
SELECT
    sp.name         AS plan,
    sp.price_monthly,
    COUNT(s.subscription_id) AS total_subscribers,
    SUM(sp.price_monthly)    AS monthly_revenue
FROM subscription_plans sp
LEFT JOIN subscriptions s ON sp.plan_id = s.plan_id AND s.is_active = TRUE
GROUP BY sp.plan_id, sp.name, sp.price_monthly
ORDER BY monthly_revenue DESC;


-- 11. Most popular genres by watch count
SELECT
    g.name          AS genre,
    COUNT(wh.history_id) AS watch_sessions
FROM genres g
JOIN content_genres cg ON g.genre_id   = cg.genre_id
JOIN watch_history  wh ON cg.content_id = wh.content_id
GROUP BY g.genre_id, g.name
ORDER BY watch_sessions DESC;


-- 12. Content released per year
SELECT
    release_year,
    COUNT(*) AS titles_added,
    SUM(CASE WHEN type = 'movie'  THEN 1 ELSE 0 END) AS movies,
    SUM(CASE WHEN type = 'series' THEN 1 ELSE 0 END) AS series
FROM content
GROUP BY release_year
ORDER BY release_year DESC;


-- ─────────────────────────────────────────
--  SECTION 3: VIEWS
-- ─────────────────────────────────────────

-- 13. View: content catalog with ratings and genre list
CREATE OR REPLACE VIEW vw_content_catalog AS
SELECT
    c.content_id,
    c.title,
    c.type,
    c.release_year,
    c.duration_mins,
    c.maturity_rating,
    l.name                       AS language,
    GROUP_CONCAT(DISTINCT g.name ORDER BY g.name SEPARATOR ', ') AS genres,
    ROUND(AVG(r.score), 1)       AS avg_rating,
    COUNT(DISTINCT r.rating_id)  AS rating_count
FROM content c
LEFT JOIN languages     l  ON c.language_id  = l.language_id
LEFT JOIN content_genres cg ON c.content_id  = cg.content_id
LEFT JOIN genres         g  ON cg.genre_id   = g.genre_id
LEFT JOIN ratings        r  ON c.content_id  = r.content_id
WHERE c.is_active = TRUE
GROUP BY c.content_id, c.title, c.type, c.release_year, c.duration_mins, c.maturity_rating, l.name;

-- Use it:
SELECT * FROM vw_content_catalog ORDER BY avg_rating DESC;


-- 14. View: active subscriber details
CREATE OR REPLACE VIEW vw_active_subscribers AS
SELECT
    u.user_id,
    u.full_name,
    u.email,
    sp.name          AS plan,
    sp.video_quality,
    sp.max_screens,
    s.started_at,
    s.expires_at
FROM users u
JOIN subscriptions      s  ON u.user_id   = s.user_id
JOIN subscription_plans sp ON s.plan_id   = sp.plan_id
WHERE s.is_active = TRUE;

-- Use it:
SELECT * FROM vw_active_subscribers;


-- ─────────────────────────────────────────
--  SECTION 4: STORED PROCEDURES
-- ─────────────────────────────────────────

-- 15. Procedure: get personalised recommendations
--     (content the user hasn't watched, in genres they've seen most)
DELIMITER $$
CREATE PROCEDURE sp_recommendations (IN p_user_id INT)
BEGIN
    -- Top genres for the user
    CREATE TEMPORARY TABLE IF NOT EXISTS tmp_user_genres AS
    SELECT cg.genre_id, COUNT(*) AS watch_count
    FROM watch_history wh
    JOIN content_genres cg ON wh.content_id = cg.content_id
    WHERE wh.user_id = p_user_id
    GROUP BY cg.genre_id
    ORDER BY watch_count DESC
    LIMIT 3;

    -- Content in those genres not yet watched by user
    SELECT DISTINCT c.title, c.type, c.release_year, g.name AS top_genre
    FROM content c
    JOIN content_genres cg ON c.content_id = cg.content_id
    JOIN genres g           ON cg.genre_id  = g.genre_id
    JOIN tmp_user_genres tg ON cg.genre_id  = tg.genre_id
    WHERE c.content_id NOT IN (
        SELECT DISTINCT content_id FROM watch_history WHERE user_id = p_user_id
    )
    AND c.is_active = TRUE
    ORDER BY tg.watch_count DESC
    LIMIT 10;

    DROP TEMPORARY TABLE IF EXISTS tmp_user_genres;
END$$
DELIMITER ;

-- Use it:
-- CALL sp_recommendations(1);


-- 16. Procedure: monthly platform report
DELIMITER $$
CREATE PROCEDURE sp_monthly_report (IN p_year INT, IN p_month INT)
BEGIN
    SELECT
        COUNT(DISTINCT wh.user_id)             AS active_viewers,
        COUNT(wh.history_id)                   AS total_sessions,
        SUM(wh.watch_duration_mins)            AS total_watch_mins,
        ROUND(AVG(wh.watch_duration_mins), 1)  AS avg_session_mins
    FROM watch_history wh
    WHERE YEAR(wh.watched_at) = p_year
      AND MONTH(wh.watched_at) = p_month;
END$$
DELIMITER ;

-- Use it:
-- CALL sp_monthly_report(2024, 3);


-- ─────────────────────────────────────────
--  SECTION 5: TRIGGERS
-- ─────────────────────────────────────────

-- 17. Trigger: auto-remove from watchlist once user completes content
DELIMITER $$
CREATE TRIGGER trg_remove_watchlist_on_complete
AFTER UPDATE ON watch_history
FOR EACH ROW
BEGIN
    IF NEW.completed = TRUE AND OLD.completed = FALSE THEN
        DELETE FROM watchlist
        WHERE user_id    = NEW.user_id
          AND content_id = NEW.content_id;
    END IF;
END$$
DELIMITER ;


-- 18. Trigger: prevent duplicate active subscriptions
DELIMITER $$
CREATE TRIGGER trg_one_active_subscription
BEFORE INSERT ON subscriptions
FOR EACH ROW
BEGIN
    DECLARE active_count INT;
    SELECT COUNT(*) INTO active_count
    FROM subscriptions
    WHERE user_id = NEW.user_id AND is_active = TRUE;

    IF active_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'User already has an active subscription.';
    END IF;
END$$
DELIMITER ;


-- ─────────────────────────────────────────
--  SECTION 6: ADVANCED QUERIES
-- ─────────────────────────────────────────

-- 19. Directors and how many films they've directed on the platform
SELECT
    p.full_name    AS director,
    COUNT(*)       AS films_directed,
    GROUP_CONCAT(c.title ORDER BY c.release_year SEPARATOR ', ') AS titles
FROM content_cast cc
JOIN people  p ON cc.person_id  = p.person_id
JOIN content c ON cc.content_id = c.content_id
WHERE cc.role = 'director'
GROUP BY p.person_id, p.full_name
ORDER BY films_directed DESC;


-- 20. Content in watchlist that the user still hasn't started
SELECT
    u.full_name,
    c.title,
    c.type,
    w.added_at AS added_to_watchlist
FROM watchlist w
JOIN users   u ON w.user_id    = u.user_id
JOIN content c ON w.content_id = c.content_id
WHERE NOT EXISTS (
    SELECT 1 FROM watch_history wh
    WHERE wh.user_id    = w.user_id
      AND wh.content_id = w.content_id
)
ORDER BY u.full_name, w.added_at;


-- 21. Users who rated content higher than the platform average
SELECT
    u.full_name,
    c.title,
    r.score                          AS user_rating,
    ROUND(AVG(r2.score), 1)          AS platform_avg
FROM ratings r
JOIN users   u  ON r.user_id    = u.user_id
JOIN content c  ON r.content_id = c.content_id
JOIN ratings r2 ON r.content_id = r2.content_id
GROUP BY r.rating_id, u.full_name, c.title, r.score
HAVING r.score > platform_avg
ORDER BY c.title;


-- 22. Binge-watching detector: users who watched 3+ episodes in one day
SELECT
    u.full_name,
    c.title   AS series,
    DATE(wh.watched_at)        AS binge_date,
    COUNT(wh.history_id)       AS episodes_watched
FROM watch_history wh
JOIN users   u ON wh.user_id    = u.user_id
JOIN content c ON wh.content_id = c.content_id
WHERE wh.episode_id IS NOT NULL
GROUP BY u.user_id, u.full_name, c.content_id, c.title, DATE(wh.watched_at)
HAVING episodes_watched >= 3;


-- 23. Content with no watch history (never streamed)
SELECT c.title, c.type, c.release_year
FROM content c
LEFT JOIN watch_history wh ON c.content_id = wh.content_id
WHERE wh.history_id IS NULL
  AND c.is_active = TRUE;


-- 24. Language-wise content breakdown
SELECT
    l.name          AS language,
    COUNT(c.content_id)                                         AS total_titles,
    SUM(CASE WHEN c.type = 'movie'  THEN 1 ELSE 0 END)         AS movies,
    SUM(CASE WHEN c.type = 'series' THEN 1 ELSE 0 END)         AS series,
    ROUND(AVG(r.score), 1)                                      AS avg_rating
FROM languages l
LEFT JOIN content c ON l.language_id = c.language_id
LEFT JOIN ratings r ON c.content_id  = r.content_id
GROUP BY l.language_id, l.name
ORDER BY total_titles DESC;


-- 25. Revenue summary: active vs expired subscriptions
SELECT
    CASE WHEN s.is_active THEN 'Active' ELSE 'Expired' END AS status,
    COUNT(*)                AS subscribers,
    SUM(sp.price_monthly)  AS monthly_revenue
FROM subscriptions s
JOIN subscription_plans sp ON s.plan_id = sp.plan_id
GROUP BY s.is_active;
