-- ============================================================
-- E-COMMERCE SALES ANALYSIS
-- SQL PORTFOLIO PROJECT
-- SQL Dialect: PostgreSQL
-- ============================================================


-- ============================================================
-- 1. DATA OVERVIEW
-- ============================================================

-- Total number of orders
SELECT COUNT(*) AS total_orders
FROM ecommerce_sales;


-- Total customers
SELECT COUNT(DISTINCT customer_id) AS total_customers
FROM ecommerce_sales;


-- Total products
SELECT COUNT(DISTINCT product_name) AS total_products
FROM ecommerce_sales;


-- Date range of the data
SELECT
    MIN(order_date) AS first_order_date,
    MAX(order_date) AS last_order_date
FROM ecommerce_sales;



-- ============================================================
-- 2. KEY BUSINESS KPIs
-- ============================================================

SELECT
    SUM(sales) AS total_revenue,
    SUM(profit) AS total_profit,
    SUM(quantity) AS units_sold,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        SUM(sales) / COUNT(DISTINCT order_id), 2
    ) AS average_order_value,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2
    ) AS profit_margin_percent
FROM ecommerce_sales
WHERE order_status <> 'Cancelled';



-- ============================================================
-- 3. REVENUE BY CATEGORY
-- ============================================================

SELECT
    category,
    SUM(sales) AS total_revenue,
    SUM(quantity) AS units_sold,
    SUM(profit) AS total_profit
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY category
ORDER BY total_revenue DESC;



-- ============================================================
-- 4. PROFIT BY CATEGORY
-- ============================================================

SELECT
    category,
    SUM(profit) AS total_profit,
    ROUND(
        SUM(profit) / NULLIF(SUM(sales), 0) * 100, 2
    ) AS profit_margin_percent
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY category
ORDER BY total_profit DESC;



-- ============================================================
-- 5. TOP 10 PRODUCTS BY REVENUE
-- ============================================================

SELECT
    product_name,
    SUM(sales) AS total_revenue,
    SUM(quantity) AS units_sold
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 10;



-- ============================================================
-- 6. TOP 10 PRODUCTS BY PROFIT
-- ============================================================

SELECT
    product_name,
    SUM(profit) AS total_profit
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY product_name
ORDER BY total_profit DESC
LIMIT 10;



-- ============================================================
-- 7. LOW-PERFORMING PRODUCTS
-- ============================================================

SELECT
    product_name,
    SUM(sales) AS total_revenue,
    SUM(quantity) AS units_sold,
    SUM(profit) AS total_profit
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY product_name
ORDER BY total_revenue ASC
LIMIT 10;



-- ============================================================
-- 8. MONTHLY SALES TREND
-- ============================================================

SELECT
    DATE_TRUNC('month', order_date)::DATE AS month,
    SUM(sales) AS monthly_revenue,
    SUM(profit) AS monthly_profit,
    SUM(quantity) AS units_sold
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;



-- ============================================================
-- 9. MONTHLY REVENUE GROWTH
-- ============================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales) AS revenue

    FROM ecommerce_sales

    WHERE order_status <> 'Cancelled'

    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT
    month,
    revenue,

    LAG(revenue) OVER (
        ORDER BY month
    ) AS previous_month_revenue,

    ROUND(
        (
            revenue -
            LAG(revenue) OVER (ORDER BY month)
        )
        /
        NULLIF(
            LAG(revenue) OVER (ORDER BY month),
            0
        ) * 100,
        2
    ) AS growth_percent

FROM monthly_sales

ORDER BY month;



-- ============================================================
-- 10. CITY-WISE PERFORMANCE
-- ============================================================

SELECT
    city,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales) AS revenue,
    SUM(profit) AS profit
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY city
ORDER BY revenue DESC;



-- ============================================================
-- 11. TOP CUSTOMERS BY REVENUE
-- ============================================================

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales) AS customer_revenue,
    SUM(profit) AS customer_profit
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY customer_id
ORDER BY customer_revenue DESC
LIMIT 20;



-- ============================================================
-- 12. REPEAT CUSTOMERS
-- ============================================================

SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS order_count,
    SUM(sales) AS total_revenue
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY customer_id
HAVING COUNT(DISTINCT order_id) > 1
ORDER BY order_count DESC;



-- ============================================================
-- 13. CUSTOMER SEGMENTATION
-- ============================================================

WITH customer_value AS (

    SELECT
        customer_id,
        SUM(sales) AS revenue

    FROM ecommerce_sales

    WHERE order_status <> 'Cancelled'

    GROUP BY customer_id
)

SELECT
    customer_id,
    revenue,

    CASE
        WHEN revenue >= 15000 THEN 'High Value'
        WHEN revenue >= 8000 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS customer_segment

FROM customer_value

ORDER BY revenue DESC;



-- ============================================================
-- 14. PAYMENT METHOD ANALYSIS
-- ============================================================

SELECT
    payment_method,
    COUNT(DISTINCT order_id) AS total_orders,
    SUM(sales) AS revenue
FROM ecommerce_sales
WHERE order_status <> 'Cancelled'
GROUP BY payment_method
ORDER BY revenue DESC;



-- ============================================================
-- 15. DISCOUNT IMPACT
-- ============================================================

SELECT
    ROUND(discount * 100, 0) AS discount_percent,
    COUNT(DISTINCT order_id) AS orders,
    SUM(sales) AS revenue,
    SUM(profit) AS profit,

    ROUND(
        SUM(profit) /
        NULLIF(SUM(sales), 0) * 100,
        2
    ) AS profit_margin_percent

FROM ecommerce_sales

WHERE order_status <> 'Cancelled'

GROUP BY discount

ORDER BY discount;



-- ============================================================
-- 16. HIGH-DISCOUNT ORDERS
-- ============================================================

SELECT
    order_id,
    product_name,
    category,
    discount,
    sales,
    profit

FROM ecommerce_sales

WHERE discount >= 0.15
AND order_status <> 'Cancelled'

ORDER BY discount DESC;



-- ============================================================
-- 17. PROFITABLE VS LOSS ORDERS
-- ============================================================

SELECT

    CASE
        WHEN profit > 0 THEN 'Profitable'
        WHEN profit < 0 THEN 'Loss'
        ELSE 'Break-even'
    END AS profit_status,

    COUNT(*) AS order_count,
    SUM(sales) AS revenue,
    SUM(profit) AS profit

FROM ecommerce_sales

WHERE order_status <> 'Cancelled'

GROUP BY

    CASE
        WHEN profit > 0 THEN 'Profitable'
        WHEN profit < 0 THEN 'Loss'
        ELSE 'Break-even'
    END;



-- ============================================================
-- 18. CATEGORY RANKING
-- ============================================================

WITH category_sales AS (

    SELECT
        category,
        SUM(sales) AS revenue

    FROM ecommerce_sales

    WHERE order_status <> 'Cancelled'

    GROUP BY category
)

SELECT
    category,
    revenue,

    RANK() OVER (
        ORDER BY revenue DESC
    ) AS revenue_rank

FROM category_sales

ORDER BY revenue_rank;



-- ============================================================
-- 19. BEST PRODUCT IN EACH CATEGORY
-- ============================================================

WITH product_sales AS (

    SELECT
        category,
        product_name,
        SUM(sales) AS revenue

    FROM ecommerce_sales

    WHERE order_status <> 'Cancelled'

    GROUP BY category, product_name
),

ranked_products AS (

    SELECT
        category,
        product_name,
        revenue,

        RANK() OVER (
            PARTITION BY category
            ORDER BY revenue DESC
        ) AS product_rank

    FROM product_sales
)

SELECT
    category,
    product_name,
    revenue

FROM ranked_products

WHERE product_rank = 1

ORDER BY category;



-- ============================================================
-- 20. RUNNING REVENUE
-- ============================================================

WITH monthly_sales AS (

    SELECT
        DATE_TRUNC('month', order_date)::DATE AS month,
        SUM(sales) AS revenue

    FROM ecommerce_sales

    WHERE order_status <> 'Cancelled'

    GROUP BY DATE_TRUNC('month', order_date)
)

SELECT
    month,
    revenue,

    SUM(revenue) OVER (
        ORDER BY month
    ) AS cumulative_revenue

FROM monthly_sales

ORDER BY month;



-- ============================================================
-- 21. ORDER STATUS ANALYSIS
-- ============================================================

SELECT
    order_status,
    COUNT(*) AS order_count,
    SUM(sales) AS order_value

FROM ecommerce_sales

GROUP BY order_status

ORDER BY order_count DESC;



-- ============================================================
-- 22. CANCELLATION RATE
-- ============================================================

SELECT

    COUNT(*) AS total_orders,

    SUM(
        CASE
            WHEN order_status = 'Cancelled'
            THEN 1
            ELSE 0
        END
    ) AS cancelled_orders,

    ROUND(

        SUM(
            CASE
                WHEN order_status = 'Cancelled'
                THEN 1
                ELSE 0
            END
        ) * 100.0 / COUNT(*),

        2

    ) AS cancellation_rate_percent

FROM ecommerce_sales;



-- ============================================================
-- 23. AVERAGE ORDER VALUE BY CITY
-- ============================================================

SELECT
    city,

    ROUND(
        SUM(sales) /
        COUNT(DISTINCT order_id),
        2
    ) AS average_order_value

FROM ecommerce_sales

WHERE order_status <> 'Cancelled'

GROUP BY city

ORDER BY average_order_value DESC;



-- ============================================================
-- 24. EXECUTIVE SUMMARY
-- ============================================================

SELECT

    SUM(
        CASE
            WHEN order_status <> 'Cancelled'
            THEN sales
            ELSE 0
        END
    ) AS total_revenue,

    SUM(
        CASE
            WHEN order_status <> 'Cancelled'
            THEN profit
            ELSE 0
        END
    ) AS total_profit,

    SUM(
        CASE
            WHEN order_status <> 'Cancelled'
            THEN quantity
            ELSE 0
        END
    ) AS units_sold,

    COUNT(
        DISTINCT CASE
            WHEN order_status <> 'Cancelled'
            THEN order_id
        END
    ) AS completed_orders,

    COUNT(
        DISTINCT CASE
            WHEN order_status <> 'Cancelled'
            THEN customer_id
        END
    ) AS active_customers

FROM ecommerce_sales;
