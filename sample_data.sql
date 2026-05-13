-- ============================================================
--  MOVIE STREAMING SAMPLE DATA
--  Run this AFTER schema.sql
-- ============================================================

-- ─────────────────────────────────────────
--  SUBSCRIPTION PLANS
-- ─────────────────────────────────────────

INSERT INTO subscription_plans (name, price_monthly, max_screens, video_quality, has_downloads, description) VALUES
('Basic',    149.00, 1, 'SD',  FALSE, 'Standard definition on 1 screen'),
('Standard', 499.00, 2, 'HD',  TRUE,  'Full HD on 2 screens with downloads'),
('Premium',  699.00, 4, '4K',  TRUE,  '4K Ultra HD on 4 screens with downloads');

-- ─────────────────────────────────────────
--  USERS
-- ─────────────────────────────────────────

INSERT INTO users (full_name, email, password_hash, date_of_birth, country) VALUES
('Arjun Mehta',    'arjun@example.com',   'hash_1', '1995-04-12', 'India'),
('Priya Nair',     'priya@example.com',   'hash_2', '1998-09-23', 'India'),
('Karthik Raj',    'karthik@example.com', 'hash_3', '1992-01-05', 'India'),
('Meena Iyer',     'meena@example.com',   'hash_4', '2000-07-17', 'India'),
('Ravi Kumar',     'ravi@example.com',    'hash_5', '1990-11-30', 'India'),
('Sneha Pillai',   'sneha@example.com',   'hash_6', '1997-03-08', 'India');

-- ─────────────────────────────────────────
--  SUBSCRIPTIONS
-- ─────────────────────────────────────────

INSERT INTO subscriptions (user_id, plan_id, started_at, expires_at, is_active) VALUES
(1, 3, '2024-01-01', '2025-01-01', TRUE),
(2, 2, '2024-02-15', '2025-02-15', TRUE),
(3, 1, '2024-03-01', '2025-03-01', TRUE),
(4, 2, '2024-01-20', '2025-01-20', TRUE),
(5, 3, '2024-04-10', '2025-04-10', TRUE),
(6, 1, '2023-12-01', '2024-12-01', FALSE);

-- ─────────────────────────────────────────
--  GENRES
-- ─────────────────────────────────────────

INSERT INTO genres (name) VALUES
('Action'),('Drama'),('Comedy'),('Thriller'),('Horror'),
('Romance'),('Sci-Fi'),('Documentary'),('Animation'),('Crime');

-- ─────────────────────────────────────────
--  LANGUAGES
-- ─────────────────────────────────────────

INSERT INTO languages (name, code) VALUES
('English', 'en'),
('Hindi',   'hi'),
('Tamil',   'ta'),
('Telugu',  'te'),
('Malayalam','ml');

-- ─────────────────────────────────────────
--  CONTENT
-- ─────────────────────────────────────────

INSERT INTO content (title, type, description, release_year, duration_mins, maturity_rating, language_id, country_origin, thumbnail_url) VALUES
-- Movies
('Inception',             'movie',  'A thief who steals secrets through dream-sharing technology.',              2010, 148, 'U/A 13+', 1, 'USA',   'https://cdn.stream.com/inception.jpg'),
('Interstellar',          'movie',  'Explorers travel through a wormhole near Saturn.',                         2014, 169, 'U/A 13+', 1, 'USA',   'https://cdn.stream.com/interstellar.jpg'),
('3 Idiots',              'movie',  'Two friends search for their long-lost companion.',                        2009, 170, 'U',       2, 'India', 'https://cdn.stream.com/3idiots.jpg'),
('Vikram',                'movie',  'A special agent investigates a masked vigilante group.',                   2022, 174, 'A',       3, 'India', 'https://cdn.stream.com/vikram.jpg'),
('RRR',                   'movie',  'Two Indian revolutionaries before the independence struggle.',              2022, 187, 'U/A 13+', 4, 'India', 'https://cdn.stream.com/rrr.jpg'),
('Drishyam 2',            'movie',  'A man fights to protect his family from the law.',                        2022, 147, 'U/A 13+', 5, 'India', 'https://cdn.stream.com/drishyam2.jpg'),
('The Dark Knight',       'movie',  'Batman faces the Joker, a criminal mastermind.',                          2008, 152, 'U/A 13+', 1, 'USA',   'https://cdn.stream.com/darknight.jpg'),
('Parasite',              'movie',  'A poor family schemes to become employed by a wealthy household.',         2019, 132, 'A',       1, 'Korea', 'https://cdn.stream.com/parasite.jpg'),
-- Series
('Breaking Bad',          'series', 'A chemistry teacher turned methamphetamine producer.',                    2008, NULL,'A',       1, 'USA',   'https://cdn.stream.com/breakingbad.jpg'),
('Mirzapur',              'series', 'The story of crime and power in the heartland of India.',                 2018, NULL,'A',       2, 'India', 'https://cdn.stream.com/mirzapur.jpg'),
('Scam 1992',             'series', 'The rise and fall of stockbroker Harshad Mehta.',                        2020, NULL,'U/A 13+', 2, 'India', 'https://cdn.stream.com/scam1992.jpg'),
-- Documentary
('Our Planet',            'documentary','A nature documentary series narrated by David Attenborough.',         2019, 50,  'U',       1, 'UK',   'https://cdn.stream.com/ourplanet.jpg');

-- ─────────────────────────────────────────
--  CONTENT GENRES  (many-to-many)
-- ─────────────────────────────────────────

INSERT INTO content_genres (content_id, genre_id) VALUES
(1,  7),(1,  4),   -- Inception: Sci-Fi, Thriller
(2,  7),(2,  2),   -- Interstellar: Sci-Fi, Drama
(3,  3),(3,  2),   -- 3 Idiots: Comedy, Drama
(4,  1),(4, 10),   -- Vikram: Action, Crime
(5,  1),(5,  2),   -- RRR: Action, Drama
(6,  4),(6,  2),   -- Drishyam 2: Thriller, Drama
(7,  1),(7,  4),   -- Dark Knight: Action, Thriller
(8,  4),(8,  2),   -- Parasite: Thriller, Drama
(9, 10),(9,  4),   -- Breaking Bad: Crime, Thriller
(10,10),(10, 1),   -- Mirzapur: Crime, Action
(11, 2),(11,10),   -- Scam 1992: Drama, Crime
(12, 8);           -- Our Planet: Documentary

-- ─────────────────────────────────────────
--  SEASONS & EPISODES
-- ─────────────────────────────────────────

INSERT INTO seasons (content_id, season_no, title) VALUES
(9,  1, 'Breaking Bad Season 1'),
(9,  2, 'Breaking Bad Season 2'),
(10, 1, 'Mirzapur Season 1'),
(11, 1, 'Scam 1992 Season 1');

INSERT INTO episodes (season_id, episode_no, title, description, duration_mins) VALUES
-- Breaking Bad S1
(1, 1, 'Pilot',                 'Walter White receives a terminal cancer diagnosis.',          58),
(1, 2, 'Cat''s in the Bag',     'Walt and Jesse deal with an unexpected situation.',           48),
(1, 3, 'And the Bag''s in the River','Walt and Jesse face consequences.',                      48),
-- Breaking Bad S2
(2, 1, 'Seven Thirty-Seven',    'Walt and Jesse face a new threat.',                           47),
(2, 2, 'Down',                  'Jesse hits rock bottom.',                                     47),
-- Mirzapur S1
(3, 1, 'Jhandu',                'Two brothers get caught up in the criminal underworld.',      56),
(3, 2, 'Gooda',                 'The Tripathi family consolidates power.',                     52),
(3, 3, 'Waqt',                  'Loyalties are tested in Mirzapur.',                           54),
-- Scam 1992 S1
(4, 1, 'The Pied Piper',        'Harshad Mehta begins his journey in the stock market.',       55),
(4, 2, 'Bulls & Bears',         'Harshad learns the rules of Dalal Street.',                   52),
(4, 3, 'Amitabh of the Market', 'Harshad''s reputation begins to rise.',                      50);

-- ─────────────────────────────────────────
--  PEOPLE (cast & crew)
-- ─────────────────────────────────────────

INSERT INTO people (full_name, birth_date, nationality) VALUES
('Christopher Nolan', '1970-07-30', 'British-American'),
('Leonardo DiCaprio', '1974-11-11', 'American'),
('Matthew McConaughey','1969-11-04','American'),
('Aamir Khan',        '1965-03-14', 'Indian'),
('Kamal Haasan',      '1954-11-07', 'Indian'),
('Jr. NTR',           '1983-05-20', 'Indian'),
('Ram Charan',        '1985-03-27', 'Indian'),
('Mohanlal',          '1960-05-21', 'Indian'),
('Bryan Cranston',    '1956-03-07', 'American'),
('Pratik Gandhi',     '1980-04-06', 'Indian'),
('S. S. Rajamouli',   '1973-10-10', 'Indian');

-- ─────────────────────────────────────────
--  CONTENT CAST
-- ─────────────────────────────────────────

INSERT INTO content_cast (content_id, person_id, role, character_name, billing_order) VALUES
-- Inception
(1, 1, 'director', NULL, 1),
(1, 2, 'actor', 'Dom Cobb', 1),
-- Interstellar
(2, 1, 'director', NULL, 1),
(2, 3, 'actor', 'Cooper', 1),
-- 3 Idiots
(3, 4, 'actor', 'Rancho', 1),
-- Vikram
(4, 5, 'actor', 'Arun Kumar', 1),
-- RRR
(5, 11, 'director', NULL, 1),
(5, 6, 'actor', 'Komaram Bheem', 1),
(5, 7, 'actor', 'Alluri Sitarama Raju', 2),
-- Drishyam 2
(6, 8, 'actor', 'Georgekutty', 1),
-- Breaking Bad
(9, 9, 'actor', 'Walter White', 1),
-- Scam 1992
(11, 10, 'actor', 'Harshad Mehta', 1);

-- ─────────────────────────────────────────
--  WATCH HISTORY
-- ─────────────────────────────────────────

INSERT INTO watch_history (user_id, content_id, episode_id, watched_at, watch_duration_mins, completed) VALUES
(1, 1,  NULL, '2024-03-10 20:00:00', 148, TRUE),
(1, 2,  NULL, '2024-03-15 21:00:00', 169, TRUE),
(1, 9,  1,    '2024-03-20 19:30:00', 58,  TRUE),
(1, 9,  2,    '2024-03-20 21:00:00', 48,  TRUE),
(2, 3,  NULL, '2024-02-20 18:00:00', 170, TRUE),
(2, 5,  NULL, '2024-03-01 20:00:00', 187, TRUE),
(2, 10, 6,    '2024-03-10 21:00:00', 56,  TRUE),
(3, 7,  NULL, '2024-04-05 20:30:00', 152, TRUE),
(3, 8,  NULL, '2024-04-10 19:00:00', 132, TRUE),
(3, 11, 9,    '2024-04-15 21:00:00', 55,  TRUE),
(4, 4,  NULL, '2024-03-25 20:00:00', 174, TRUE),
(4, 6,  NULL, '2024-04-02 19:00:00', 147, TRUE),
(5, 1,  NULL, '2024-02-14 20:00:00', 100, FALSE),
(5, 9,  1,    '2024-03-05 20:00:00', 58,  TRUE),
(5, 9,  2,    '2024-03-05 22:00:00', 48,  TRUE),
(6, 12, NULL, '2024-01-10 18:00:00', 50,  TRUE);

-- ─────────────────────────────────────────
--  RATINGS
-- ─────────────────────────────────────────

INSERT INTO ratings (user_id, content_id, score) VALUES
(1, 1,  5),(1, 2,  5),(1, 9,  5),
(2, 3,  5),(2, 5,  5),(2, 10, 4),
(3, 7,  5),(3, 8,  5),(3, 11, 5),
(4, 4,  4),(4, 6,  5),
(5, 1,  4),(5, 9,  5),
(6, 12, 5);

-- ─────────────────────────────────────────
--  WATCHLIST
-- ─────────────────────────────────────────

INSERT INTO watchlist (user_id, content_id) VALUES
(1, 4),(1, 5),(1, 11),
(2, 1),(2, 7),(2, 9),
(3, 3),(3, 5),(3, 6),
(4, 2),(4, 9),(4, 10),
(5, 3),(5, 6);

-- ─────────────────────────────────────────
--  REVIEWS
-- ─────────────────────────────────────────

INSERT INTO reviews (user_id, content_id, body, has_spoiler) VALUES
(1, 1,  'Mind-bending masterpiece. The ending still keeps me up at night.', FALSE),
(1, 2,  'Nolan does it again. The science and emotion are perfectly balanced.', FALSE),
(2, 3,  'All Izz Well! A film that touches your heart every single time.', FALSE),
(2, 5,  'RRR is a visual spectacle unlike anything Indian cinema has produced.', FALSE),
(3, 7,  'The Dark Knight is not just a superhero film — it is a crime epic.', FALSE),
(3, 8,  'Parasite is a masterclass in suspense. Deserves every award it won.', FALSE),
(4, 6,  'Mohanlal carries this film entirely on his shoulders. Brilliant.', FALSE),
(5, 9,  'Best TV series ever made. The transformation of Walter White is unmatched.', FALSE),
(3, 11, 'Pratik Gandhi IS Harshad Mehta. Riveting from episode one.', FALSE);
