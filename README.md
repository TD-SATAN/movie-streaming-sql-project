# E-Commerce Database — SQL Project

A complete relational database design for an e-commerce platform, built with **MySQL 8+** (also compatible with minor tweaks for PostgreSQL 13+).

---

## Database Schema

### Tables

| Table | Description |
|---|---|
| `users` | Customer and admin accounts |
| `addresses` | Delivery addresses per user |
| `categories` | Product categories (supports sub-categories) |
| `brands` | Product brands |
| `products` | Product catalog with pricing and stock |
| `product_images` | Multiple images per product |
| `coupons` | Discount codes (percentage or fixed) |
| `orders` | Order header with totals and status |
| `order_items` | Line items per order |
| `payments` | Payment records per order |
| `reviews` | Ratings and reviews per product/user |
| `wishlists` | User-saved products |

### ER Diagram (overview)

```
users ─────┬──── addresses
           ├──── orders ──── order_items ──── products ──── categories
           ├──── reviews                              └──── brands
           └──── wishlists              └── coupons
                                orders ──── payments
```

---

## Files

```
ecommerce-sql/
├── schema.sql       -- CREATE TABLE statements + indexes
├── sample_data.sql  -- INSERT statements with realistic dummy data
├── queries.sql      -- 20 useful queries (basic → advanced)
└── README.md
```

---

## Features Demonstrated

- **Normalization** — 3NF design across all tables
- **Foreign keys** with `ON DELETE CASCADE / SET NULL`
- **Indexes** on high-traffic columns (user_id, status, product_id)
- **Views** — `vw_product_summary`, `vw_order_summary`
- **Stored Procedures** — place order, sales report
- **Triggers** — auto-reduce stock on order, restore on cancel
- **Advanced queries** — revenue by month, top products, coupon usage, funnel analysis

---

## How to Run

### MySQL

```bash
mysql -u root -p

CREATE DATABASE ecommerce;
USE ecommerce;

SOURCE schema.sql;
SOURCE sample_data.sql;
SOURCE queries.sql;
```

### PostgreSQL

Replace `AUTO_INCREMENT` with `SERIAL`, `ENUM` with `VARCHAR` + `CHECK`, and `DELIMITER $$` blocks with `$$` function syntax.

---

## Sample Queries Included

| # | Query |
|---|---|
| 1 | All active products with brand and category |
| 2 | All orders for a specific user |
| 3 | Full order details with product names |
| 4 | Total revenue by month |
| 5 | Top 5 best-selling products |
| 6 | Average rating per product |
| 7 | Revenue by category |
| 8 | Top customers by total spend |
| 9–10 | View usage examples |
| 11–12 | Stored procedure usage |
| 13–14 | Trigger demonstrations |
| 15 | Low stock alert |
| 16 | Customers who never ordered |
| 17 | Most wishlisted products |
| 18 | Coupon usage report |
| 19 | Order status funnel |
| 20 | Products never ordered (subquery) |

---

## Technologies

- **Database**: MySQL 8.0
- **Concepts**: DDL, DML, JOINs, Aggregations, Subqueries, Views, Stored Procedures, Triggers, Indexes

---

## License

MIT — free to use and modify.
