# Cohort Retention Analysis on Brazilian E-Commerce

## 1. Project Overview

This project analyzes customer retention using the Olist Brazilian E-Commerce Public Dataset.

The main goal is to understand how customers behave after their first purchase and how many customers return in the following months.

The analysis was performed mainly using SQL in SQLite. Pandas was used for displaying query results and preparing visualizations.

The analysis includes:

- customer cohort identification
- monthly cohort analysis
- customer retention rates
- average retention by period
- cohort retention heatmap
- average retention curve
- cohort size comparison
- revenue by cohort and period


## 2. Data Used

The analysis uses the following Olist datasets:

- `olist_orders_dataset.csv`
- `olist_customers_dataset.csv`
- `olist_order_items_dataset.csv`
- `olist_order_reviews_dataset.csv`

The loaded data contained:

- Orders: 99,441 rows
- Customers: 99,441 rows
- Order items: 112,650 rows
- Order reviews: 99,224 rows


## 3. Customer Identification

The analysis uses `customer_unique_id` as the stable customer identifier.

`customer_id` is connected to the order-level customer record, while `customer_unique_id` represents the actual unique customer across different orders.

Using `customer_unique_id` is important for retention analysis because the goal is to identify whether the same customer returns and makes another purchase.


## 4. Cohort Definition

A customer's cohort is defined by the month of their first delivered purchase.

Only orders with:

`order_status = 'delivered'`

were included in the retention analysis.

The first purchase date was calculated using:

`MIN(order_purchase_timestamp)`

and converted to a monthly cohort using SQLite's `strftime()` function.

The analysis identified 93,358 unique customers in the delivered-order activity.


## 5. Period Number

The cohort month is treated as period 0.

For each later purchase, the number of months between the customer's cohort month and the purchase month is calculated as the period number.

For example:

- Period 0 = cohort month
- Period 1 = one month after the first purchase
- Period 2 = two months after the first purchase


## 6. Retention Calculation

For each cohort and period, active customers were counted using:

`COUNT(DISTINCT customer_unique_id)`

The retention rate was calculated as:

`active customers / cohort size × 100`

This produces the cohort retention table used for the heatmap and further analysis.


## 7. Main Retention Results

The average retention rate was:

| Period | Average Retention |
|---|---:|
| 0 | 100.00% |
| 1 | 5.45% |
| 2 | 0.34% |
| 3 | 0.25% |
| 4 | 0.29% |
| 5 | 0.23% |

The largest change occurs between period 0 and period 1.

Average retention falls from 100.00% in the cohort month to 5.45% one month later.

After period 1, the average retention rate becomes much lower and remains below 1% in the following periods shown in the analysis.


## 8. Month-1 Cohort Comparison

The month-1 retention analysis showed differences between cohorts.

The highest raw month-1 retention value was 100% for the December 2016 cohort. However, this cohort contained only one customer, so this percentage is not representative of a large customer group.

Among larger cohorts, the highest month-1 retention values were observed for cohorts such as:

- 2017-10: 0.72%
- 2017-09: 0.70%
- 2017-08: 0.69%

The lowest month-1 retention among the listed cohorts was observed for the 2017-02 cohort at 0.18%.


## 9. Cohort Size

The cohort sizes vary considerably across the dataset.

Examples include:

- 2016-09: 1 customer
- 2016-10: 262 customers
- 2017-08: 4,057 customers
- 2017-11: 7,060 customers
- 2018-01: 6,842 customers

This variation is important when interpreting retention percentages because very small cohorts can produce unstable percentages.


## 10. Revenue Analysis

Revenue was analyzed by cohort and period using the `order_items` table.

The revenue calculation uses:

`SUM(order_items.price)`

Only delivered orders were included.

The revenue analysis connects:

`orders → customers → cohort_data → order_items`

using the relevant IDs.

This allows revenue to be grouped by:

- cohort month
- period number


## 11. Visualizations

Three main visualizations were created:

### Cohort Retention Heatmap

The heatmap shows retention rates for each cohort across different periods.

Missing values in later periods represent cohorts that had not yet reached those periods within the available dataset. They should not be interpreted as zero retention.

### Average Retention Curve

The retention curve shows the sharp decrease from period 0 to period 1 and the much lower retention levels in later periods.

### Cohort Size Bar Chart

The cohort size chart shows how the number of customers varies by cohort month.


## 12. Business Insights

### Insight 1 — Strong drop after the first purchase

The largest retention drop occurs immediately after the first purchase. Average month-1 retention is only 5.45%.

This suggests that repeat purchasing within the following month was relatively limited in this dataset.


### Insight 2 — Retention varies between cohorts

Different cohorts show different month-1 retention rates.

For example, the 2017-10 cohort has 0.72% month-1 retention, while the 2017-02 cohort has 0.18%.

This indicates that customer repeat behavior was not identical across acquisition periods.


### Insight 3 — Cohort size affects interpretation

Some cohorts are very small.

For example, the 2016-12 cohort contains only one customer and has 100% month-1 retention.

Therefore, retention percentages from very small cohorts should be interpreted carefully.


### Insight 4 — Later-period retention is very low

After the first month, the average retention rate decreases to below 1% in the following periods shown in the analysis.

This indicates that long-term repeat purchasing was limited for the customers included in the delivered-order cohort analysis.


## 13. Limitations

There are several limitations to consider:

1. Only delivered orders were included in the retention analysis.
2. The dataset covers a limited historical period, so newer cohorts have fewer observable future periods.
3. Very small cohorts can produce extreme retention percentages.
4. The average retention rate is calculated as a simple average of cohort-level retention rates, so each cohort receives equal weight regardless of its size.
5. Revenue analysis uses `price` from order items and does not include `freight_value`.


## 14. Conclusion

The cohort analysis shows a significant decrease in customer retention after the initial purchase month.

The strongest drop occurs between period 0 and period 1, after which retention remains very low.

The analysis also shows that cohort size and observation period should be considered when interpreting retention results.

SQL was used as the main analytical tool, including joins, aggregation, date functions, conditional aggregation, and cohort-period calculations.