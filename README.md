# Wholesale Order Data Quality & Sales Analytics

An end-to-end analysis of 1,067,371 order lines from a UK online retailer whose customers are largely wholesalers. The project profiles and cleans the raw data, loads it into a SQL database, and reports on sales and customers in Power BI.

**Status: in progress.** The data profiling and cleaning is complete. The data is loaded into PostgreSQL, and the SQL analysis is underway. The dashboard is next.

## Progress

| Stage                                     | Tools                      | Status      |
| ----------------------------------------- | -------------------------- | ----------- |
| Data profiling and quality report         | Python (pandas)            | Done        |
| Data cleaning with a log of rejected rows | Python (pandas)            | Done        |
| Database design, load and verification    | PostgreSQL, SQL            | Done        |
| Sales analysis                            | SQL                        | In progress |
| Dashboard                                 | Power BI, Power Query, DAX | Planned     |

## Data quality findings so far

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

## SQL analysis so far

**Monthly revenue** (`sql/03_monthly_revenue.sql`)

- Revenue rises sharply each autumn, from about £670,000 in August 2010 to £1.43 million in November 2010, as wholesale customers stock up before Christmas. The increase comes mainly from more orders rather than larger ones.
- December 2011 contains only 9 days of data, so it is not comparable with full months.
- These figures are gross sales, before cancellations.

**Top products by revenue** (`sql/04_top_products.sql`)

- Two products in the first top-10 list were each driven by a single very large order that was later cancelled: 80,995 units of a paper craft item and 74,215 units of a storage jar.
- Because sales and cancellations are stored in separate tables, product rankings are recalculated as net sales, combining both tables so that cancellations are subtracted. Both products drop out of the net top 10.
- On a net basis, the top product by revenue is the Regency cakestand.

## Repository layout

- `notebooks/` holds the analysis notebooks, starting with `01_explore.ipynb`
- `notebooks/02_clean.ipynb` applies the cleaning rules and saves the clean tables
- `reports/` holds the data quality and cleaning summaries
- `sql/01_create_tables.sql` defines the database tables
- `sql/02_verify_load.sql` checks the loaded row counts
- `sql/03_monthly_revenue.sql` calculates revenue and orders by month
- `sql/04_top_products.sql` ranks products by revenue, investigates outliers, and recalculates the ranking on net sales

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

## Data source

Chen, D. (2012). Online Retail II [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D. Licensed under CC BY 4.0.
