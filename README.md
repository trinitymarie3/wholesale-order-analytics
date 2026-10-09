# Wholesale Order Data Quality & Sales Analytics

An end-to-end analysis of 1,067,371 order lines from a UK online retailer whose customers are largely wholesalers. The project profiles and cleans the raw data, loads it into a SQL database, and reports on sales and customers in Power BI.

**Status: in progress.** The data profiling is complete. Cleaning, SQL analysis, and the dashboard are underway.

## Progress

| Stage                                     | Tools                      | Status      |
| ----------------------------------------- | -------------------------- | ----------- |
| Data profiling and quality report         | Python (pandas)            | Done        |
| Data cleaning with a log of rejected rows | Python (pandas)            | In progress |
| Database and sales analysis               | PostgreSQL, SQL            | Planned     |
| Dashboard                                 | Power BI, Power Query, DAX | Planned     |

## Data quality findings so far

The raw data covers December 2009 to December 2011, with 5,942 customers in 43 countries.

| Check                     | Rows    | % of total |
| ------------------------- | ------- | ---------- |
| Missing customer ID       | 243,007 | 22.77%     |
| Exact duplicate rows      | 34,335  | 3.22%      |
| Zero or negative quantity | 22,950  | 2.15%      |
| Cancellation lines        | 19,494  | 1.83%      |
| Zero or negative price    | 6,207   | 0.58%      |
| Missing description       | 4,382   | 0.41%      |

A row can fail more than one check, so the percentages overlap. The full table is in `reports/data_quality_summary.csv`.

## Repository layout

- `notebooks/` holds the analysis notebooks, starting with `01_explore.ipynb`
- `reports/` holds output tables
- `sql/` will hold the database schema and analysis queries
- `src/` will hold the cleaning script

## How to run it

1. Download `online_retail_II.xlsx` from the [UCI Machine Learning Repository](https://archive.ics.uci.edu/dataset/502/online+retail+ii) and place it in a `data/` folder.
2. Create an environment and install the packages:

```
python -m venv .venv
.venv\Scripts\activate
pip install pandas openpyxl jupyter sqlalchemy psycopg2-binary matplotlib
```

3. Open `notebooks/01_explore.ipynb` and run the cells in order.

## Data source

Chen, D. (2012). Online Retail II [Dataset]. UCI Machine Learning Repository. https://doi.org/10.24432/C5CG6D. Licensed under CC BY 4.0.
