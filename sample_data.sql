-- ============================================================
--  E-COMMERCE SAMPLE DATA
--  Run this AFTER schema.sql
-- ============================================================

-- ─────────────────────────────────────────
--  USERS
-- ─────────────────────────────────────────

INSERT INTO users (full_name, email, password_hash, phone, role) VALUES
('Arjun Sharma',   'arjun@example.com',   'hashed_pw_1', '9876543210', 'customer'),
('Priya Nair',     'priya@example.com',   'hashed_pw_2', '9876543211', 'customer'),
('Karthik Raj',    'karthik@example.com', 'hashed_pw_3', '9876543212', 'customer'),
('Meena Iyer',     'meena@example.com',   'hashed_pw_4', '9876543213', 'customer'),
('Ravi Kumar',     'ravi@example.com',    'hashed_pw_5', '9876543214', 'customer'),
('Admin User',     'admin@store.com',     'hashed_pw_6', '9000000000', 'admin');

-- ─────────────────────────────────────────
--  ADDRESSES
-- ─────────────────────────────────────────

INSERT INTO addresses (user_id, label, street, city, state, postal_code, country, is_default) VALUES
(1, 'Home', '12 Anna Nagar',    'Chennai',   'Tamil Nadu',    '600040', 'India', TRUE),
(2, 'Home', '45 MG Road',       'Bangalore', 'Karnataka',     '560001', 'India', TRUE),
(3, 'Work', '7 IT Park, Hinjewadi', 'Pune',  'Maharashtra',   '411057', 'India', TRUE),
(4, 'Home', '88 Salt Lake',     'Kolkata',   'West Bengal',   '700064', 'India', TRUE),
(5, 'Home', '3 Lajpat Nagar',   'Delhi',     'Delhi',         '110024', 'India', TRUE);

-- ─────────────────────────────────────────
--  CATEGORIES
-- ─────────────────────────────────────────

INSERT INTO categories (name, parent_id, description) VALUES
('Electronics',      NULL, 'All electronic devices and accessories'),
('Fashion',          NULL, 'Clothing, footwear and accessories'),
('Home & Kitchen',   NULL, 'Home appliances and kitchen products'),
('Books',            NULL, 'Physical and digital books'),
('Smartphones',      1,    'Mobile phones and accessories'),
('Laptops',          1,    'Laptops and notebooks'),
('Men''s Clothing',  2,    'T-shirts, shirts, trousers for men'),
('Women''s Clothing',2,    'Tops, kurtis, dresses for women');

-- ─────────────────────────────────────────
--  BRANDS
-- ─────────────────────────────────────────

INSERT INTO brands (name, country, website) VALUES
('Samsung',  'South Korea', 'https://samsung.com'),
('Apple',    'USA',         'https://apple.com'),
('OnePlus',  'China',       'https://oneplus.com'),
('Dell',     'USA',         'https://dell.com'),
('HP',       'USA',         'https://hp.com'),
('Levi''s',  'USA',         'https://levis.com'),
('Prestige', 'India',       'https://prestige.com');

-- ─────────────────────────────────────────
--  PRODUCTS
-- ─────────────────────────────────────────

INSERT INTO products (category_id, brand_id, name, description, base_price, stock_qty, sku) VALUES
(5, 1, 'Samsung Galaxy S24',      '6.2" AMOLED, 8GB RAM, 256GB',         74999.00, 50,  'SAM-S24-256'),
(5, 2, 'Apple iPhone 15',         '6.1" Super Retina XDR, 128GB',       79999.00, 30,  'APL-IP15-128'),
(5, 3, 'OnePlus 12R',             '6.78" AMOLED, 100W charging',         42999.00, 80,  'OP-12R-256'),
(6, 4, 'Dell Inspiron 15',        'Intel i5, 16GB RAM, 512GB SSD',       65000.00, 25,  'DEL-INS15-I5'),
(6, 5, 'HP Pavilion 14',          'AMD Ryzen 5, 8GB RAM, 256GB SSD',     55000.00, 40,  'HP-PAV14-R5'),
(7, 6, 'Levi''s 511 Slim Jeans',  'Slim fit, stretch denim, 32W 32L',     3999.00, 200, 'LEV-511-3232'),
(8, 6, 'Levi''s Women Hoodie',    'Cotton blend, regular fit',            2499.00, 150, 'LEV-WH-M'),
(3, 7, 'Prestige Electric Kettle','1.5L, 1500W, auto shut-off',           1299.00, 300, 'PRE-KET-15L'),
(4, NULL,'Clean Code - Robert C. Martin', 'Software craftsmanship guide', 599.00,  500, 'BK-CLEAN-CODE'),
(4, NULL,'SQL in 10 Minutes',     'Beginner-friendly SQL guide',          499.00,  500, 'BK-SQL-10MIN');

-- ─────────────────────────────────────────
--  PRODUCT IMAGES
-- ─────────────────────────────────────────

INSERT INTO product_images (product_id, image_url, is_primary, sort_order) VALUES
(1, 'https://cdn.store.com/products/samsung-s24-1.jpg', TRUE,  1),
(1, 'https://cdn.store.com/products/samsung-s24-2.jpg', FALSE, 2),
(2, 'https://cdn.store.com/products/iphone15-1.jpg',    TRUE,  1),
(3, 'https://cdn.store.com/products/oneplus12r-1.jpg',  TRUE,  1),
(4, 'https://cdn.store.com/products/dell-ins15-1.jpg',  TRUE,  1),
(6, 'https://cdn.store.com/products/levis511-1.jpg',    TRUE,  1);

-- ─────────────────────────────────────────
--  COUPONS
-- ─────────────────────────────────────────

INSERT INTO coupons (code, discount_type, discount_value, min_order_value, max_uses, valid_from, valid_until) VALUES
('WELCOME10',  'percentage', 10.00, 500.00,   NULL, '2024-01-01', '2025-12-31'),
('FLAT500',    'fixed',      500.00, 2000.00,  200, '2024-01-01', '2025-06-30'),
('SUMMER20',   'percentage', 20.00, 1000.00,  100, '2024-04-01', '2024-06-30');

-- ─────────────────────────────────────────
--  ORDERS
-- ─────────────────────────────────────────

INSERT INTO orders (user_id, address_id, coupon_id, subtotal, discount_amount, tax_amount, shipping_amount, total_amount, status, payment_method, ordered_at, delivered_at) VALUES
(1, 1, 1,  74999.00, 7499.90, 6074.91, 0.00,  73574.01, 'delivered',  'credit_card', '2024-02-10 10:00:00', '2024-02-14 15:00:00'),
(2, 2, NULL,42999.00, 0.00,    3869.91, 99.00, 46967.91, 'delivered',  'upi',         '2024-03-05 14:30:00', '2024-03-09 11:00:00'),
(3, 3, 2,  65000.00, 500.00,  5805.00, 0.00,  70305.00, 'shipped',    'net_banking',  '2024-04-12 09:00:00', NULL),
(4, 4, NULL, 3999.00, 0.00,    359.91, 49.00,  4407.91, 'delivered',  'cod',          '2024-04-20 17:00:00', '2024-04-24 12:00:00'),
(5, 5, NULL,  599.00, 0.00,     53.91, 49.00,   701.91, 'pending',    'upi',          '2024-05-01 08:00:00', NULL),
(1, 1, NULL,55000.00, 0.00,   4950.00, 0.00,  59950.00, 'confirmed',  'debit_card',   '2024-05-10 11:00:00', NULL);

-- ─────────────────────────────────────────
--  ORDER ITEMS
-- ─────────────────────────────────────────

INSERT INTO order_items (order_id, product_id, quantity, unit_price, total_price) VALUES
(1, 1,  1, 74999.00, 74999.00),
(2, 3,  1, 42999.00, 42999.00),
(3, 4,  1, 65000.00, 65000.00),
(4, 6,  1,  3999.00,  3999.00),
(5, 9,  1,   599.00,   599.00),
(6, 5,  1, 55000.00, 55000.00),
(4, 8,  1,  1299.00,  1299.00);

-- ─────────────────────────────────────────
--  PAYMENTS
-- ─────────────────────────────────────────

INSERT INTO payments (order_id, amount, status, transaction_ref, paid_at) VALUES
(1, 73574.01, 'success',  'TXN20240210ABC', '2024-02-10 10:02:00'),
(2, 46967.91, 'success',  'TXN20240305XYZ', '2024-03-05 14:31:00'),
(3, 70305.00, 'success',  'TXN20240412DEF', '2024-04-12 09:01:00'),
(4, 4407.91,  'success',  'TXN20240420COD', '2024-04-24 12:00:00'),
(5,  701.91,  'pending',  NULL,              NULL),
(6, 59950.00, 'success',  'TXN20240510GHI', '2024-05-10 11:01:00');

-- ─────────────────────────────────────────
--  REVIEWS
-- ─────────────────────────────────────────

INSERT INTO reviews (product_id, user_id, rating, title, body, is_verified) VALUES
(1, 1, 5, 'Excellent phone!',      'Battery life and camera are outstanding. Worth every rupee.',        TRUE),
(3, 2, 4, 'Great value',           'Fast charging is a game changer. Slight heating under heavy load.', TRUE),
(4, 3, 5, 'Perfect for work',      'Fast SSD, solid build quality. Delivery was also quick.',           TRUE),
(6, 4, 4, 'Good fit',              'True to size. Fabric quality is premium for this price.',           TRUE),
(9, 5, 5, 'Must read for devs',    'Changed the way I write code. Highly recommend.',                   TRUE),
(3, 1, 4, 'Good but gets warm',    'Camera quality impressed me but heats up during gaming.',           FALSE);

-- ─────────────────────────────────────────
--  WISHLIST
-- ─────────────────────────────────────────

INSERT INTO wishlists (user_id, product_id) VALUES
(1, 2),
(1, 5),
(2, 1),
(3, 7),
(4, 10),
(5, 3);
