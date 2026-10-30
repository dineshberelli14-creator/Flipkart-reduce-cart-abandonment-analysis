# Flipkart-inspired Conversion Dashboard | Implementation specification (not built PBIX)

Data source: run Python notebook, import `python/session_metrics.csv`. Label dashboard clearly: **Public REES46 proxy events, not Flipkart data**.

### Suggested visuals
1. KPI card: observed sessions = DISTINCTCOUNT(session_metrics[user_session]).
2. KPI card: cart sessions = CALCULATE(DISTINCTCOUNT(session_metrics[user_session]),session_metrics[cart]=TRUE()).
3. KPI card: purchase sessions = CALCULATE(DISTINCTCOUNT(session_metrics[user_session]),session_metrics[purchase]=TRUE()).
4. KPI card: cart without purchase percent = DIVIDE([Cart No Purchase Sessions],[Cart Sessions]).
5. Funnel bars: view/cart/purchase sessions (from notebook actual computed outputs).
6. Trends: daily event counts from genuine raw event source, with explicit event vs session labels.
7. Product/category visuals where event keys available; slicers for event date, product category, and brand.

### DAX (on session_metrics table)
```dax
Observed Sessions = DISTINCTCOUNT(session_metrics[user_session])
Cart Sessions = CALCULATE([Observed Sessions], session_metrics[cart] = TRUE())
Purchase Sessions = CALCULATE([Observed Sessions], session_metrics[purchase] = TRUE())
Cart No Purchase Sessions = CALCULATE([Observed Sessions],session_metrics[cart_without_purchase] = TRUE())
Observed Cart No Purchase % = DIVIDE([Cart No Purchase Sessions], [Cart Sessions])
Session Purchase % = DIVIDE([Purchase Sessions], [Observed Sessions])
```

**TO BE COMPLETED**: actual PBIX/screenshots and cross-tool reconciliation. This proxy cannot measure checkout error, shipping fees, discount response, or Flipkart conversion outcomes.
