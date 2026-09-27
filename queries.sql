-- Q1. Delivered orders
SELECT COUNT(*) AS delivered_orders
FROM orders
WHERE order_status = 'delivered';


-- Q2. First delivered purchase month for each customer
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
)
SELECT
    customer_unique_id,
    MIN(order_purchase_timestamp) AS first_purchase_date,
    strftime('%Y-%m', MIN(order_purchase_timestamp)) AS cohort_month
FROM delivered_orders
GROUP BY customer_unique_id;


-- Q3. Customer activity month
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
)
SELECT DISTINCT
    customer_unique_id,
    strftime('%Y-%m', order_purchase_timestamp) AS order_month
FROM delivered_orders;


-- Q4. Calculate retention period
WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_purchase_timestamp,
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_purchase_date
    FROM delivered_orders
    GROUP BY customer_unique_id
)
SELECT DISTINCT
    d.customer_unique_id,
    strftime('%Y-%m', f.first_purchase_date) AS cohort_month,
    strftime('%Y-%m', d.order_purchase_timestamp) AS order_month,
    (
        (CAST(strftime('%Y', d.order_purchase_timestamp) AS INTEGER)
         - CAST(strftime('%Y', f.first_purchase_date) AS INTEGER)) * 12
        +
        (CAST(strftime('%m', d.order_purchase_timestamp) AS INTEGER)
         - CAST(strftime('%m', f.first_purchase_date) AS INTEGER))
    ) AS retention_month
FROM delivered_orders d
JOIN first_purchase f
    ON d.customer_unique_id = f.customer_unique_id;


-- Q5. Active customers by cohort and retention period
WITH delivered_orders AS (
    SELECT
        o.order_purchase_timestamp,
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_purchase_date
    FROM delivered_orders
    GROUP BY customer_unique_id
),
activity AS (
    SELECT DISTINCT
        d.customer_unique_id,
        strftime('%Y-%m', f.first_purchase_date) AS cohort_month,
        (
            (CAST(strftime('%Y', d.order_purchase_timestamp) AS INTEGER)
             - CAST(strftime('%Y', f.first_purchase_date) AS INTEGER)) * 12
            +
            (CAST(strftime('%m', d.order_purchase_timestamp) AS INTEGER)
             - CAST(strftime('%m', f.first_purchase_date) AS INTEGER))
        ) AS retention_month
    FROM delivered_orders d
    JOIN first_purchase f
        ON d.customer_unique_id = f.customer_unique_id
)
SELECT
    cohort_month,
    retention_month,
    COUNT(DISTINCT customer_unique_id) AS active_customers
FROM activity
GROUP BY cohort_month, retention_month
ORDER BY cohort_month, retention_month;


-- Q6. Cohort size
WITH delivered_orders AS (
    SELECT
        o.order_purchase_timestamp,
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_purchase_date
    FROM delivered_orders
    GROUP BY customer_unique_id
)
SELECT
    strftime('%Y-%m', first_purchase_date) AS cohort_month,
    COUNT(DISTINCT customer_unique_id) AS cohort_size
FROM first_purchase
GROUP BY cohort_month
ORDER BY cohort_month;


-- Q7. Retention percentage
WITH delivered_orders AS (
    SELECT
        o.order_purchase_timestamp,
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_purchase_date
    FROM delivered_orders
    GROUP BY customer_unique_id
),
activity AS (
    SELECT DISTINCT
        d.customer_unique_id,
        strftime('%Y-%m', f.first_purchase_date) AS cohort_month,
        (
            (CAST(strftime('%Y', d.order_purchase_timestamp) AS INTEGER)
             - CAST(strftime('%Y', f.first_purchase_date) AS INTEGER)) * 12
            +
            (CAST(strftime('%m', d.order_purchase_timestamp) AS INTEGER)
             - CAST(strftime('%m', f.first_purchase_date) AS INTEGER))
        ) AS retention_month
    FROM delivered_orders d
    JOIN first_purchase f
        ON d.customer_unique_id = f.customer_unique_id
),
cohort_size AS (
    SELECT
        strftime('%Y-%m', first_purchase_date) AS cohort_month,
        COUNT(DISTINCT customer_unique_id) AS cohort_size
    FROM first_purchase
    GROUP BY cohort_month
)
SELECT
    a.cohort_month,
    a.retention_month,
    COUNT(DISTINCT a.customer_unique_id) AS active_customers,
    cs.cohort_size,
    ROUND(
        COUNT(DISTINCT a.customer_unique_id) * 100.0
        / cs.cohort_size,
        2
    ) AS retention_percentage
FROM activity a
JOIN cohort_size cs
    ON a.cohort_month = cs.cohort_month
GROUP BY
    a.cohort_month,
    a.retention_month,
    cs.cohort_size
ORDER BY
    a.cohort_month,
    a.retention_month;


-- Q8. Average retention by period

SELECT
    period_number,
    ROUND(AVG(retention_rate), 2) AS average_retention
FROM retention_rates
GROUP BY period_number
ORDER BY period_number;


-- Q9. Month-1 retention by cohort

SELECT
    cohort_month,
    active_customers AS month_1_customers,
    cohort_size,
    retention_rate AS month_1_retention
FROM retention_rates
WHERE period_number = 1
ORDER BY month_1_retention DESC;
-- Q10. Revenue by cohort and retention period
-- Revenue is calculated from product prices only (freight excluded)

WITH delivered_orders AS (
    SELECT
        o.order_id,
        o.order_purchase_timestamp,
        c.customer_unique_id
    FROM orders o
    JOIN customers c
        ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
),
first_purchase AS (
    SELECT
        customer_unique_id,
        MIN(order_purchase_timestamp) AS first_purchase_date
    FROM delivered_orders
    GROUP BY customer_unique_id
)
SELECT
    strftime('%Y-%m', f.first_purchase_date) AS cohort_month,
    (
        (CAST(strftime('%Y', o.order_purchase_timestamp) AS INTEGER)
         - CAST(strftime('%Y', f.first_purchase_date) AS INTEGER)) * 12
        +
        (CAST(strftime('%m', o.order_purchase_timestamp) AS INTEGER)
         - CAST(strftime('%m', f.first_purchase_date) AS INTEGER))
    ) AS retention_month,
    ROUND(SUM(oi.price), 2) AS revenue
FROM delivered_orders o
JOIN first_purchase f
    ON o.customer_unique_id = f.customer_unique_id
JOIN order_items oi
    ON o.order_id = oi.order_id
GROUP BY
    cohort_month,
    retention_month
ORDER BY
    cohort_month,
    retention_month;