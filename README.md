# Wholesale Order Data Quality & Sales Analytics

An end-to-end analysis of 1,067,371 order lines from a UK online retailer whose customers are largely wholesalers. The project profiles and cleans the raw data, loads it into a SQL database, and reports on sales and customers in Power BI.

**Status: in progress.** The data profiling and cleaning is complete. SQL analysis, and the dashboard are underway.

## Progress

| Stage                                     | Tools                      | Status      |
| ----------------------------------------- | -------------------------- | ----------- |
| Data profiling and quality report         | Python (pandas)            | Done        |
| Data cleaning with a log of rejected rows | Python (pandas)            | Done        |
| Database and sales analysis               | PostgreSQL, SQL            | In progress |
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

## Repository layout

- `notebooks/` holds the analysis notebooks, starting with `01_explore.ipynb`
- `notebooks/02_clean.ipynb` applies the cleaning rules and saves the clean tables
- `reports/` holds the data quality and cleaning summaries
- `sql/` will hold the database schema and analysis queries

## How to run it

1. Download `online_retail_II.xlsx` from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) and place it in a `data/` folder.
2. Create an environment and install the packages:

```
python -m venv .venv
.venv\Scripts\activate
pip install pandas openpyxl jupyter sqlalchemy psycopg2-binary matplotlib
```

3. Run `notebooks/01_explore.ipynb`, then `notebooks/02_clean.ipynb`. The clean tables are written to `data/`.

## Data source

Chen, D. (2012). Online Retail II [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D. Licensed under CC BY 4.0.
