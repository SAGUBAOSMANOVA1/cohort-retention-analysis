SELECT
    o.order_id,
    c.customer_unique_id,
    o.order_purchase_timestamp
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered';