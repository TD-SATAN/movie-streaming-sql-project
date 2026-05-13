-- ============================================================
--  E-COMMERCE DATABASE SCHEMA
--  Compatible with: MySQL 8+ / PostgreSQL 13+
--  Author: Your Name
--  Description: Full schema for an e-commerce platform
-- ============================================================

-- ─────────────────────────────────────────
--  USERS & ADDRESSES
-- ─────────────────────────────────────────

CREATE TABLE users (
    user_id       INT AUTO_INCREMENT PRIMARY KEY,
    full_name     VARCHAR(100)        NOT NULL,
    email         VARCHAR(150) UNIQUE NOT NULL,
    password_hash VARCHAR(255)        NOT NULL,
    phone         VARCHAR(20),
    role          ENUM('customer','admin') DEFAULT 'customer',
    is_active     BOOLEAN             DEFAULT TRUE,
    created_at    DATETIME            DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME            DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE addresses (
    address_id   INT AUTO_INCREMENT PRIMARY KEY,
    user_id      INT          NOT NULL,
    label        VARCHAR(50)  DEFAULT 'Home',   -- Home, Work, Other
    street       VARCHAR(255) NOT NULL,
    city         VARCHAR(100) NOT NULL,
    state        VARCHAR(100) NOT NULL,
    postal_code  VARCHAR(20)  NOT NULL,
    country      VARCHAR(100) NOT NULL DEFAULT 'India',
    is_default   BOOLEAN      DEFAULT FALSE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  PRODUCT CATALOG
-- ─────────────────────────────────────────

CREATE TABLE categories (
    category_id   INT AUTO_INCREMENT PRIMARY KEY,
    name          VARCHAR(100) NOT NULL,
    parent_id     INT          DEFAULT NULL,   -- self-referencing for sub-categories
    description   TEXT,
    created_at    DATETIME     DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(category_id) ON DELETE SET NULL
);

CREATE TABLE brands (
    brand_id    INT AUTO_INCREMENT PRIMARY KEY,
    name        VARCHAR(100) UNIQUE NOT NULL,
    country     VARCHAR(100),
    website     VARCHAR(255)
);

CREATE TABLE products (
    product_id    INT AUTO_INCREMENT PRIMARY KEY,
    category_id   INT            NOT NULL,
    brand_id      INT,
    name          VARCHAR(255)   NOT NULL,
    description   TEXT,
    base_price    DECIMAL(10,2)  NOT NULL,
    stock_qty     INT            DEFAULT 0,
    sku           VARCHAR(100)   UNIQUE NOT NULL,
    is_active     BOOLEAN        DEFAULT TRUE,
    created_at    DATETIME       DEFAULT CURRENT_TIMESTAMP,
    updated_at    DATETIME       DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(category_id),
    FOREIGN KEY (brand_id)    REFERENCES brands(brand_id) ON DELETE SET NULL
);

CREATE TABLE product_images (
    image_id    INT AUTO_INCREMENT PRIMARY KEY,
    product_id  INT          NOT NULL,
    image_url   VARCHAR(500) NOT NULL,
    is_primary  BOOLEAN      DEFAULT FALSE,
    sort_order  INT          DEFAULT 0,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  DISCOUNTS & COUPONS
-- ─────────────────────────────────────────

CREATE TABLE coupons (
    coupon_id       INT AUTO_INCREMENT PRIMARY KEY,
    code            VARCHAR(50) UNIQUE NOT NULL,
    discount_type   ENUM('percentage','fixed') NOT NULL,
    discount_value  DECIMAL(10,2)      NOT NULL,
    min_order_value DECIMAL(10,2)      DEFAULT 0,
    max_uses        INT                DEFAULT NULL,
    used_count      INT                DEFAULT 0,
    valid_from      DATE               NOT NULL,
    valid_until     DATE               NOT NULL,
    is_active       BOOLEAN            DEFAULT TRUE
);

-- ─────────────────────────────────────────
--  ORDERS
-- ─────────────────────────────────────────

CREATE TABLE orders (
    order_id         INT AUTO_INCREMENT PRIMARY KEY,
    user_id          INT            NOT NULL,
    address_id       INT            NOT NULL,
    coupon_id        INT            DEFAULT NULL,
    subtotal         DECIMAL(10,2)  NOT NULL,
    discount_amount  DECIMAL(10,2)  DEFAULT 0.00,
    tax_amount       DECIMAL(10,2)  DEFAULT 0.00,
    shipping_amount  DECIMAL(10,2)  DEFAULT 0.00,
    total_amount     DECIMAL(10,2)  NOT NULL,
    status           ENUM('pending','confirmed','shipped','delivered','cancelled','returned')
                                    DEFAULT 'pending',
    payment_method   ENUM('credit_card','debit_card','upi','net_banking','cod') NOT NULL,
    notes            TEXT,
    ordered_at       DATETIME       DEFAULT CURRENT_TIMESTAMP,
    delivered_at     DATETIME       DEFAULT NULL,
    FOREIGN KEY (user_id)    REFERENCES users(user_id),
    FOREIGN KEY (address_id) REFERENCES addresses(address_id),
    FOREIGN KEY (coupon_id)  REFERENCES coupons(coupon_id) ON DELETE SET NULL
);

CREATE TABLE order_items (
    item_id      INT AUTO_INCREMENT PRIMARY KEY,
    order_id     INT           NOT NULL,
    product_id   INT           NOT NULL,
    quantity     INT           NOT NULL DEFAULT 1,
    unit_price   DECIMAL(10,2) NOT NULL,   -- price at time of order
    total_price  DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (order_id)   REFERENCES orders(order_id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- ─────────────────────────────────────────
--  PAYMENTS
-- ─────────────────────────────────────────

CREATE TABLE payments (
    payment_id         INT AUTO_INCREMENT PRIMARY KEY,
    order_id           INT            NOT NULL UNIQUE,
    amount             DECIMAL(10,2)  NOT NULL,
    status             ENUM('pending','success','failed','refunded') DEFAULT 'pending',
    transaction_ref    VARCHAR(255),
    paid_at            DATETIME       DEFAULT NULL,
    FOREIGN KEY (order_id) REFERENCES orders(order_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  REVIEWS
-- ─────────────────────────────────────────

CREATE TABLE reviews (
    review_id    INT AUTO_INCREMENT PRIMARY KEY,
    product_id   INT      NOT NULL,
    user_id      INT      NOT NULL,
    rating       TINYINT  NOT NULL CHECK (rating BETWEEN 1 AND 5),
    title        VARCHAR(150),
    body         TEXT,
    is_verified  BOOLEAN  DEFAULT FALSE,   -- verified purchase
    created_at   DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_review (product_id, user_id),
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id)    REFERENCES users(user_id)    ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  WISHLIST
-- ─────────────────────────────────────────

CREATE TABLE wishlists (
    wishlist_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id     INT      NOT NULL,
    product_id  INT      NOT NULL,
    added_at    DATETIME DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_wishlist (user_id, product_id),
    FOREIGN KEY (user_id)    REFERENCES users(user_id)    ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(product_id) ON DELETE CASCADE
);

-- ─────────────────────────────────────────
--  INDEXES  (for performance)
-- ─────────────────────────────────────────

CREATE INDEX idx_products_category  ON products(category_id);
CREATE INDEX idx_products_brand     ON products(brand_id);
CREATE INDEX idx_orders_user        ON orders(user_id);
CREATE INDEX idx_orders_status      ON orders(status);
CREATE INDEX idx_order_items_order  ON order_items(order_id);
CREATE INDEX idx_order_items_prod   ON order_items(product_id);
CREATE INDEX idx_reviews_product    ON reviews(product_id);
