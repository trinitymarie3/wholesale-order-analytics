# Wholesale Order Data Quality & Sales Analytics

An end-to-end analysis of 1,067,371 order lines from a UK online retailer whose customers are largely wholesalers. The project profiles and cleans the raw data, loads it into a SQL database, and reports on sales and customers in Power BI.

**Status: in progress.** Data profiling, cleaning and the SQL analysis are complete. The Power BI dashboard is next. The Power BI dashboard is next.

## Progress

| Stage                                     | Tools                      | Status      |
| ----------------------------------------- | -------------------------- | ----------- |
| Data profiling and quality report         | Python (pandas)            | Done        |
| Data cleaning with a log of rejected rows | Python (pandas)            | Done        |
| Database design, load and verification    | PostgreSQL, SQL            | Done        |
| Sales analysis                            | SQL                        | Done        |
| Dashboard                                 | Power BI, Power Query, DAX | In progress |

## Data quality findings

The raw data covers December 2009 to December 2011, with 5,942 customers in 43 countries. 290,777 rows (27.24%) had at least one issue.

| Check                     | Rows    | % of total |
| ------------------------- | ------- | ---------- |
| Missing customer ID       | 243,007 | 22.77%     |
| Exact duplicate rows      | 34,335  | 3.22%      |
| Zero or negative quantity | 22,950  | 2.15%      |
| Cancellation lines        | 19,494  | 1.83%      |
| Zero or negative price    | 6,207   | 0.58%      |
| Missing description       | 4,382   | 0.41%      |

A row can fail more than one check, so the percentages overlap. The full table is in `reports/data_quality_summary.csv`.

Investigating the issues showed that:

- The 3,457 negative-quantity lines that were not cancellations were stock adjustments (damaged, missing, or discarded items), all with a zero price and no customer.
- Lines with no customer ID account for 13.1% of revenue, so they are kept in sales totals and excluded only from customer-level analysis.
- 27 stock codes are fees and adjustments rather than products (postage, carriage, discounts, bank charges, Amazon fees, gift vouchers, test entries).

## Cleaning rules

Every row is assigned exactly one outcome. Rules are checked in order, and the first rule that applies decides where the row goes.

| Order | Rule                                             | Outcome      |
| ----- | ------------------------------------------------ | ------------ |
| 1     | Exact duplicate of an earlier row                | Rejected     |
| 2     | Stock code is a fee or adjustment, not a product | Rejected     |
| 3     | Invoice starts with C                            | Cancellation |
| 4     | Zero or negative quantity (stock adjustment)     | Rejected     |
| 5     | Zero or negative price                           | Rejected     |
| —     | Everything else                                  | Sales        |

Missing customer IDs and descriptions do not reject a row: the sale still happened.

## Cleaning results

| Outcome                    | Rows      | % of total |
| -------------------------- | --------- | ---------- |
| Sales                      | 1,003,355 | 94.00%     |
| Rejected: duplicate        | 34,335    | 3.22%      |
| Cancellation               | 17,915    | 1.68%      |
| Rejected: non-product code | 5,804     | 0.54%      |
| Rejected: stock adjustment | 3,390     | 0.32%      |
| Rejected: bad price        | 2,572     | 0.24%      |

The outcome counts reconcile to the 1,067,371 input rows, and each saved file was reloaded to confirm its row count. The full table is in `reports/cleaning_summary.csv`.

## Database

The clean sales and cancellation lines are loaded into two PostgreSQL tables with the same nine columns. Column types are set explicitly: invoice numbers are stored as text because cancellations contain a letter, money columns use exact `NUMERIC`, and missing customer IDs are stored as `NULL` rather than a placeholder value.

| Table           | Rows      |
| --------------- | --------- |
| `sales`         | 1,003,355 |
| `cancellations` | 17,915    |

## SQL analysis

**Monthly revenue** (`sql/03_monthly_revenue.sql`)

- Revenue rises sharply each autumn, from about £670,000 in August 2010 to £1.43 million in November 2010, as wholesale customers stock up before Christmas. The increase comes mainly from more orders rather than larger ones.
- December 2011 contains only 9 days of data, so it is not comparable with full months.
- These figures are gross sales, before cancellations.

**Top products by revenue** (`sql/04_top_products.sql`)

- Two products in the first top-10 list were each driven by a single very large order that was later cancelled: 80,995 units of a paper craft item and 74,215 units of a storage jar.
- Because sales and cancellations are stored in separate tables, product rankings are recalculated as net sales, combining both tables so that cancellations are subtracted. Both products drop out of the net top 10.
- On a net basis, the top product by revenue is the Regency cakestand.

**Revenue by country** (`sql/05_revenue_by_country.sql`)

- On a net basis, the United Kingdom accounts for 85.4% of revenue (£16.2 million). No other country reaches 4%: the next largest are Ireland (3.2%), the Netherlands (2.9%), Germany (2.0%) and France (1.6%).
- The business is therefore highly concentrated in its home market, which is a strength but also a risk. The established international customers are the clearest area for growth.

**Repeat customers** (`sql/06_repeat_customers.sql`)

This analysis covers the 5,852 customers with a customer ID in the sales data, using gross sales.

| Customer type      | Customers | % of customers | Revenue     | % of revenue |
| ------------------ | --------- | -------------- | ----------- | ------------ |
| One-time (1 order) | 1,618     | 27.65%         | £556,000    | about 3%     |
| Repeat (2+ orders) | 4,234     | 72.35%         | £16,512,568 | about 97%    |

- 72% of customers placed more than one order, and they generated about 97% of revenue from identified customers. A repeat customer spent about £3,900 on average, against about £344 for a one-time customer.
- Customers who first ordered near the end of the data had little time to return, so the one-time share is likely slightly overstated.

## Repository layout

- `notebooks/` holds the analysis notebooks, starting with `01_explore.ipynb`
- `notebooks/02_clean.ipynb` applies the cleaning rules and saves the clean tables
- `reports/` holds the data quality and cleaning summaries
- `sql/01_create_tables.sql` defines the database tables
- `sql/02_verify_load.sql` checks the loaded row counts
- `sql/03_monthly_revenue.sql` calculates revenue and orders by month
- `sql/04_top_products.sql` ranks products by revenue, investigates outliers, and recalculates the ranking on net sales
- `sql/05_revenue_by_country.sql` calculates net revenue and its share by country
- `sql/06_repeat_customers.sql` compares one-time and repeat customers

## How to run it

1. Download `online_retail_II.xlsx` from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) and place it in a `data/` folder.
2. Create an environment and install the packages:

```
python -m venv .venv
.venv\Scripts\activate
pip install pandas openpyxl jupyter sqlalchemy psycopg2-binary matplotlib
```

3. Run `notebooks/01_explore.ipynb`, then `notebooks/02_clean.ipynb`. The clean tables are written to `data/`.

4. In PostgreSQL, create a database, run `sql/01_create_tables.sql`, and import the clean sales and cancellations CSV files into the two tables. Then run the remaining SQL files in order.

## How this project was built

I used Claude (Anthropic's AI assistant) as a tutor and reviewer throughout this project.

- **Planning:** Claude helped scope the project, choose the dataset and tools based on current data analyst internship postings, and plan the stages.
- **Learning:** for each new concept (pandas filtering, cleaning rules, SQL grouping, subqueries, window functions), Claude explained it with a worked example on a separate problem. I then wrote the code for this project myself.
- **Code:** the initial setup and exploration notebook (`01_explore.ipynb`) were written with substantial help from Claude. The cleaning notebook (`02_clean.ipynb`) and all SQL queries were written by me, with Claude reviewing them and pointing out errors to fix.
- **Checking results:** Claude suggested ways to validate the outputs, such as reconciling row counts and comparing totals against independently calculated figures. I ran these checks and investigated anything that didn't match, including the single cancelled orders that distorted the top-products ranking.
- **Documentation:** Claude drafted this README from my results, which I reviewed and edited.

All numbers in this repository come from code I ran on the dataset.

## Data source

Chen, D. (2012). Online Retail II [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D. Licensed under CC BY 4.0.
