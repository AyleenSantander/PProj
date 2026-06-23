# Adventure Works — Product Sales \& Profitability Dashboard (Power BI)

An interactive two-page Power BI report analyzing product sales, profitability, and year-over-year growth for **Adventure Works**, a fictional bicycle and accessories retailer. The report turns transactional sales data into a single view that answers the questions a sales or finance leader actually asks: *What are we selling, what's making money, and where are we leaking margin?*

Built as part of my Business Intelligence \& Data Analytics portfolio and PL-300 (Power BI Data Analyst) preparation.



## Business Question

Revenue alone doesn't tell you whether a business is healthy. This dashboard was built to separate **volume** from **value** — to show which categories drive sales versus which actually drive profit, and to track whether the business is growing year over year.

## Dataset

* **Source:** Adventure Works sample database (Microsoft's standard retail demo dataset)
* **Grain:** One row per product sales transaction
* **Scope:** Bikes, Components, Clothing, and Accessories across multiple subcategories
* **Volume:** 6,560 units sold, \~$3.5M in revenue

## Tools \& Techniques

* **Power BI Desktop** — data model, visuals, page layout
* **Power Query (M)** — data cleaning and shaping
* **DAX** — measures for Revenue, Profit, Units Sold, and **Revenue YoY %** (time-intelligence with `SAMEPERIODLASTYEAR` / `DATEADD`)
* **Star schema modeling** — fact (sales) related to dimension tables (Product, Category, Date)
* Visual types: KPI cards, donut chart, bar/column charts, combo (line + column) chart, and a detail table



## Dashboard Overview

### Page 1 — Product Performance

At-a-glance KPIs and a breakdown of *what* is selling.

|KPI|Value|
|-|-|
|Units Sold|7K|
|Profit|$45.81K|
|Revenue|$3.51M|
|Revenue YoY %|+20.73%|

* **Units Sold by Product Color** (donut) — shows color mix of demand
* **Top 5 Products** (column) — highest-selling individual products by total sales

### Page 2 — Profitability Detail

The *why behind the money* — sales vs. profit by category, subcategory depth, and a product-level table.

* **Total Sales and Profit by Category** (combo chart) — sales as columns, profit as a line
* **Total Sales by Subcategory** (bar) — ranked contribution of each subcategory
* **Product table** — units sold and total sales per product, with grand totals



## Key Insights

**1. Bikes drive revenue but lose money.**
Bikes generate \~$2.9M (roughly 83% of total revenue) yet post a **negative profit of about –$10K**. This is the headline finding: the highest-revenue category is a margin drain, likely a low-margin or loss-leader play.

**2. Components are the real profit engine.**
On just \~$0.6M in sales, Components return **+$47K in profit** — the most profitable category by a wide margin. Clothing (+$7K) and Accessories (+$3K) are small but profitable.

**3. Demand is concentrated.**
Mountain Bikes ($1.31M) and Road Bikes ($1.20M) alone account for the majority of sales. The Top 5 products are *all* black Mountain-100/Mountain-200 models, led by the Mountain-200 Black, 38 at $150K.

**4. Black dominates the color mix.**
Black makes up **39.7%** of all units sold — more than Red (15.6%), Silver (13.3%), and Yellow (12.8%) combined are close behind, but black is the clear preference.

**5. The business is growing.**
Revenue is up **20.73% year over year**, indicating healthy top-line momentum.

### So what?

The data suggests Adventure Works should **protect Component sales and revisit Bike pricing/cost structure**, since the category carrying the business on revenue is the one eroding profit. Strong YoY growth makes this a good moment to fix margin before scaling further.





*Created by Ayleen Santander — Business Intelligence \& Data Analytics portfolio.*

