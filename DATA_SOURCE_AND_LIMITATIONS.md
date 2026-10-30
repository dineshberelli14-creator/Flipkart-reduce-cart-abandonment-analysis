# Flipkart Cart Abandonment and Conversion - PGDM Big Data Analytics & DBMS

## Truthfulness and scope
**Flipkart is the business case, NOT the publisher of the analytics dataset.** This is an academic proposal using public third-party REES46 cosmetics e-commerce clickstream event data as a behavioral proxy. The public source was identified but could not be downloaded in this environment. No empirical counts, conversion rates, charts or database outputs have been invented. Dataset CSV, MySQL execution, Databricks execution and PBIX dashboard are **TO BE COMPLETED**.

Free source landing page: https://rees46.com/en/datasets
Suggested behavior events dataset: https://www.kaggle.com/datasets/mkechinov/ecommerce-events-history-in-cosmetics-shop
Consult publisher/license and download instructions before redistributing.

## Required raw data
Download the public behavior-event CSV from REES46/Kaggle and put ONE full source CSV at `data/ecommerce_events_raw.csv` (or combine multiple raw CSVs only with an explicit source manifest). Expected columns: `event_time,event_type,product_id,category_id,category_code,brand,price,user_id,user_session`. See Excel contract; do not fabricate missing values.

## Metric contract
- Primary unit: user_session over the observed extraction window, counting distinct non-null sessions.
- *Observed cart abandonment proxy*: sessions with >=1 `cart` event and no `purchase` event **within the observed data window**, divided by sessions with >=1 `cart` event. This is NOT full checkout abandonment and can overstate abandonment due to right-censoring and cross-session purchases.
- Session purchase conversion: sessions with >=1 `purchase` / observed sessions; not visitor-to-order conversion.
- Payment failures, shipping cost surprises, checkout steps, user motivation and Flipkart's actual rate are not observable in REES46 events.
- Handle missing session IDs, timezone, duplicate event rows, purchase events in multiple products, observation-window effects, refunds and event instrumentation errors.

