# Cohort Retention Analysis

## 1. Methodology

This project analyzes customer retention using the Olist e-commerce dataset.

Only orders with `order_status = 'delivered'` were included in the retention analysis.

The cohort was defined using the customer's **first delivered purchase month**.

The customer identifier used for retention analysis was `customer_unique_id`.

Retention was calculated as:

Retention (%) = Active customers in a period / Cohort size × 100

Period 0 represents the customer's first delivered purchase month, therefore Period 0 retention is 100%.

The analysis was performed using SQL and Python. The main visualizations are:

- Cohort retention heatmap
- Average retention curve
- Cohort size bar chart


## 2. Customer ID Trap

The dataset contains both `customer_id` and `customer_unique_id`.

`customer_id` identifies a customer record associated with an order, while `customer_unique_id` represents the actual unique customer across the dataset.

For cohort retention analysis, `customer_unique_id` was used to avoid counting the same customer multiple times as different customers.

Using the wrong identifier could produce incorrect cohort sizes and retention rates.


## 3. Numeric Evidence

The delivered-order dataset contains:

- Delivered orders: **96,478**
- Unique delivered customers: **93,358**

Average retention by period:

| Period | Average Retention |
|---:|---:|
| 0 | 100.00% |
| 1 | 5.45% |
| 2 | 0.34% |
| 3 | 0.25% |
| 4 | 0.29% |
| 5 | 0.23% |
| 6 | 0.27% |
| 7 | 0.21% |
| 8 | 0.21% |
| 9 | 0.19% |
| 10 | 0.26% |
| 11 | 0.23% |
| 12 | 0.21% |
| 13 | 0.20% |
| 14 | 0.15% |
| 15 | 0.19% |
| 16 | 0.14% |
| 17 | 0.28% |
| 19 | 0.45% |
| 20 | 0.76% |

Example cohort sizes:

- 2017-08: **4,057 customers**
- 2017-11: **7,060 customers**
- 2018-01: **6,842 customers**


## 4. Insights

### Insight 1 — Q1/Q2: Delivered customer base

There were **96,478 delivered orders** and **93,358 unique delivered customers**. This shows that the analysis covers a large delivered customer base and provides the basis for cohort retention analysis.

### Insight 2 — Q4/Q5: First delivered purchase cohorts

Customers were assigned to cohorts according to their first delivered purchase month. The cohort sizes increased substantially during 2017, with the November 2017 cohort reaching approximately **7,060 customers**.

### Insight 3 — Q8: Customer activity after the first purchase

The retention analysis shows a strong decrease after Period 0. Average retention falls from **100.00% in Period 0 to 5.45% in Period 1**, and then to **0.34% in Period 2**.

This indicates that only a small proportion of customers made another delivered purchase after their first purchase.

### Insight 4 — Q9/Q10: Retention pattern

After the first month, retention remains below 1% for the later observed periods. Period 14 has an average retention of **0.15%**, while Period 20 reaches **0.76%**.

The heatmap and retention curve show that repeat purchasing is relatively low compared with the initial customer cohort size.