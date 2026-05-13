-- ============================================================
--  E-COMMERCE SAMPLE QUERIES
--  Run AFTER schema.sql and sample_data.sql
-- ============================================================


-- ─────────────────────────────────────────
--  SECTION 1: BASIC SELECT QUERIES
-- ─────────────────────────────────────────

-- 1. All active products with brand and category
SELECT
    p.product_id,
    p.name         AS product,
    c.name         AS category,
    b.name         AS brand,
    p.base_price,
    p.stock_qty
FROM products p
JOIN categories c ON p.category_id = c.category_id
LEFT JOIN brands b ON p.brand_id = b.brand_id
WHERE p.is_active = TRUE
ORDER BY p.base_price DESC;


-- 2. All orders for a specific user (user_id = 1) with status
SELECT
    o.order_id,
    o.total_amount,
    o.status,
    o.payment_method,
    o.ordered_at
FROM orders o
WHERE o.user_id = 1
ORDER BY o.ordered_at DESC;


-- 3. Full order details — items, prices, product names
SELECT
    o.order_id,
    u.full_name    AS customer,
    p.name         AS product,
    oi.quantity,
    oi.unit_price,
    oi.total_price,
    o.status
FROM orders o
JOIN users      u  ON o.user_id    = u.user_id
JOIN order_items oi ON o.order_id  = oi.order_id
JOIN products   p  ON oi.product_id = p.product_id
ORDER BY o.order_id, p.name;


-- ─────────────────────────────────────────
--  SECTION 2: AGGREGATE & ANALYTICS
-- ─────────────────────────────────────────

-- 4. Total revenue by month
SELECT
    DATE_FORMAT(o.ordered_at, '%Y-%m') AS month,
    COUNT(o.order_id)                  AS total_orders,
    SUM(o.total_amount)                AS revenue
FROM orders o
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY month
ORDER BY month;


-- 5. Top 5 best-selling products (by quantity sold)
SELECT
    p.name          AS product,
    SUM(oi.quantity) AS units_sold,
    SUM(oi.total_price) AS total_revenue
FROM order_items oi
JOIN products p ON oi.product_id = p.product_id
JOIN orders   o ON oi.order_id   = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY p.product_id, p.name
ORDER BY units_sold DESC
LIMIT 5;


-- 6. Average rating and review count per product
SELECT
    p.name             AS product,
    COUNT(r.review_id) AS total_reviews,
    ROUND(AVG(r.rating), 1) AS avg_rating
FROM products p
LEFT JOIN reviews r ON p.product_id = r.product_id
GROUP BY p.product_id, p.name
ORDER BY avg_rating DESC;


-- 7. Revenue by category
SELECT
    c.name              AS category,
    COUNT(DISTINCT o.order_id) AS orders,
    SUM(oi.total_price) AS revenue
FROM categories c
JOIN products    p  ON c.category_id = p.category_id
JOIN order_items oi ON p.product_id  = oi.product_id
JOIN orders      o  ON oi.order_id   = o.order_id
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY c.category_id, c.name
ORDER BY revenue DESC;


-- 8. Top customers by total spend
SELECT
    u.user_id,
    u.full_name,
    COUNT(o.order_id)   AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM users u
JOIN orders o ON u.user_id = o.user_id
WHERE o.status NOT IN ('cancelled', 'returned')
GROUP BY u.user_id, u.full_name
ORDER BY total_spent DESC
LIMIT 10;


-- ─────────────────────────────────────────
--  SECTION 3: VIEWS
-- ─────────────────────────────────────────

-- 9. View: product summary (name, brand, category, avg rating, stock)
CREATE OR REPLACE VIEW vw_product_summary AS
SELECT
    p.product_id,
    p.name                       AS product_name,
    c.name                       AS category,
    b.name                       AS brand,
    p.base_price,
    p.stock_qty,
    ROUND(AVG(r.rating), 1)      AS avg_rating,
    COUNT(r.review_id)           AS review_count
FROM products p
LEFT JOIN categories c ON p.category_id = c.category_id
LEFT JOIN brands     b ON p.brand_id    = b.brand_id
LEFT JOIN reviews    r ON p.product_id  = r.product_id
WHERE p.is_active = TRUE
GROUP BY p.product_id, p.name, c.name, b.name, p.base_price, p.stock_qty;

-- Use it:
SELECT * FROM vw_product_summary ORDER BY avg_rating DESC;


-- 10. View: order summary with customer and payment info
CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
    o.order_id,
    u.full_name          AS customer,
    o.total_amount,
    o.status             AS order_status,
    pay.status           AS payment_status,
    o.payment_method,
    o.ordered_at,
    o.delivered_at
FROM orders  o
JOIN users    u   ON o.user_id   = u.user_id
LEFT JOIN payments pay ON o.order_id = pay.order_id;

-- Use it:
SELECT * FROM vw_order_summary WHERE order_status = 'delivered';


-- ─────────────────────────────────────────
--  SECTION 4: STORED PROCEDURES
-- ─────────────────────────────────────────

-- 11. Procedure: place a new order
DELIMITER $$
CREATE PROCEDURE sp_place_order (
    IN  p_user_id        INT,
    IN  p_address_id     INT,
    IN  p_payment_method VARCHAR(20),
    OUT p_order_id       INT
)
BEGIN
    DECLARE v_subtotal DECIMAL(10,2) DEFAULT 0;

    -- Create the order shell
    INSERT INTO orders (user_id, address_id, subtotal, total_amount, status, payment_method)
    VALUES (p_user_id, p_address_id, 0, 0, 'pending', p_payment_method);

    SET p_order_id = LAST_INSERT_ID();

    SELECT p_order_id AS new_order_id;
END$$
DELIMITER ;


-- 12. Procedure: get sales report for a date range
DELIMITER $$
CREATE PROCEDURE sp_sales_report (
    IN p_start_date DATE,
    IN p_end_date   DATE
)
BEGIN
    SELECT
        DATE(o.ordered_at)  AS sale_date,
        COUNT(o.order_id)   AS orders,
        SUM(o.total_amount) AS revenue,
        AVG(o.total_amount) AS avg_order_value
    FROM orders o
    WHERE DATE(o.ordered_at) BETWEEN p_start_date AND p_end_date
      AND o.status NOT IN ('cancelled', 'returned')
    GROUP BY sale_date
    ORDER BY sale_date;
END$$
DELIMITER ;

-- Use it:
-- CALL sp_sales_report('2024-01-01', '2024-12-31');


-- ─────────────────────────────────────────
--  SECTION 5: TRIGGERS
-- ─────────────────────────────────────────

-- 13. Trigger: reduce stock when an order item is inserted
DELIMITER $$
CREATE TRIGGER trg_reduce_stock
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE products
    SET stock_qty = stock_qty - NEW.quantity
    WHERE product_id = NEW.product_id;
END$$
DELIMITER ;


-- 14. Trigger: restore stock when an order is cancelled
DELIMITER $$
CREATE TRIGGER trg_restore_stock_on_cancel
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'cancelled' AND OLD.status != 'cancelled' THEN
        UPDATE products p
        JOIN order_items oi ON p.product_id = oi.product_id
        SET p.stock_qty = p.stock_qty + oi.quantity
        WHERE oi.order_id = NEW.order_id;
    END IF;
END$$
DELIMITER ;


-- ─────────────────────────────────────────
--  SECTION 6: ADVANCED QUERIES
-- ─────────────────────────────────────────

-- 15. Products low on stock (less than 30 units)
SELECT name, stock_qty, sku
FROM products
WHERE stock_qty < 30 AND is_active = TRUE
ORDER BY stock_qty ASC;


-- 16. Customers who have never placed an order
SELECT u.user_id, u.full_name, u.email
FROM users u
LEFT JOIN orders o ON u.user_id = o.user_id
WHERE o.order_id IS NULL AND u.role = 'customer';


-- 17. Most wishlisted products (potential demand)
SELECT
    p.name,
    COUNT(w.user_id) AS wishlist_count
FROM wishlists w
JOIN products p ON w.product_id = p.product_id
GROUP BY p.product_id, p.name
ORDER BY wishlist_count DESC;


-- 18. Coupon usage report
SELECT
    c.code,
    c.discount_type,
    c.discount_value,
    COUNT(o.order_id)      AS times_used,
    SUM(o.discount_amount) AS total_discount_given
FROM coupons c
LEFT JOIN orders o ON c.coupon_id = o.coupon_id
GROUP BY c.coupon_id, c.code, c.discount_type, c.discount_value
ORDER BY times_used DESC;


-- 19. Revenue funnel: orders by status
SELECT
    status,
    COUNT(*)            AS count,
    SUM(total_amount)   AS value
FROM orders
GROUP BY status
ORDER BY FIELD(status,'pending','confirmed','shipped','delivered','cancelled','returned');


-- 20. Subquery — products that have NEVER been ordered
SELECT product_id, name, stock_qty
FROM products
WHERE product_id NOT IN (
    SELECT DISTINCT product_id FROM order_items
)
AND is_active = TRUE;
