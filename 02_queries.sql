-- Query 1: event coverage (source raw table, NOT Flipkart production)
SELECT COUNT(*) AS event_rows,COUNT(DISTINCT user_session) AS observed_sessions,
 COUNT(DISTINCT user_id) AS observed_users,COUNT(*)-COUNT(user_session) AS null_session_rows
FROM raw_events;
-- Query 2: event composition
SELECT event_type, COUNT(*) AS events FROM valid_events GROUP BY event_type ORDER BY events DESC;
-- Query 3: date span
SELECT MIN(event_at) first_observed_utc,MAX(event_at) last_observed_utc FROM valid_events;
-- Query 4: missing data
SELECT SUM(event_at IS NULL) invalid_timestamps, SUM(user_session IS NULL) missing_sessions,
 SUM(product_id IS NULL) missing_products,SUM(unit_price IS NULL) missing_or_invalid_prices FROM valid_events;
-- Query 5: session funnel (no invented output)
WITH session_flags AS (
 SELECT user_session, MAX(event_type='view') has_view,MAX(event_type='cart') has_cart,
 MAX(event_type='purchase') has_purchase,MAX(event_type='remove_from_cart') has_remove
 FROM valid_events WHERE user_session IS NOT NULL GROUP BY user_session)
SELECT COUNT(*) sessions, SUM(has_view) view_sessions,SUM(has_cart) cart_sessions,
 SUM(has_purchase) purchase_sessions,SUM(has_cart=1 AND has_purchase=0) cart_no_purchase_sessions,
 ROUND(100.0*SUM(has_cart=1 AND has_purchase=0)/NULLIF(SUM(has_cart),0),2) cart_no_purchase_pct,
 ROUND(100.0*SUM(has_purchase)/NULLIF(COUNT(*),0),2) session_conversion_pct FROM session_flags;
-- Query 6: funnel by first event UTC month; sessions spanning months are assigned first seen month
WITH session_flags AS (
 SELECT user_session, MIN(event_at) first_at,MAX(event_type='cart') carted,MAX(event_type='purchase') bought
 FROM valid_events WHERE user_session IS NOT NULL GROUP BY user_session)
SELECT DATE_FORMAT(first_at,'%Y-%m') cohort_month, COUNT(*) sessions,SUM(carted) carts,SUM(bought) purchases,
 SUM(carted=1 AND bought=0) carts_without_purchase
FROM session_flags WHERE first_at IS NOT NULL GROUP BY cohort_month ORDER BY cohort_month;
-- Query 7: categorical cart events (events, not sessions; repeat carting possible)
SELECT COALESCE(category_code,'[uncoded]') category,COUNT(*) cart_events FROM valid_events
WHERE event_type='cart' GROUP BY category ORDER BY cart_events DESC LIMIT 20;
-- Query 8: observed purchases by brand (purchase events, not orders)
SELECT COALESCE(brand,'[unknown]') brand,COUNT(*) purchase_events FROM valid_events
WHERE event_type='purchase' GROUP BY brand ORDER BY purchase_events DESC LIMIT 20;
-- Query 9: average recorded price by event type
SELECT event_type,ROUND(AVG(unit_price),2) mean_unit_price, MIN(unit_price) min_unit_price,MAX(unit_price) max_unit_price
FROM valid_events GROUP BY event_type;
-- Query 10: daily event trends
SELECT DATE(event_at) event_day, SUM(event_type='view') views,SUM(event_type='cart') carts,
SUM(event_type='purchase') purchases FROM valid_events WHERE event_at IS NOT NULL
GROUP BY DATE(event_at) ORDER BY event_day;
-- Query 11: sessions involving cart removal
SELECT COUNT(DISTINCT user_session) removal_sessions FROM valid_events
WHERE event_type='remove_from_cart' AND user_session IS NOT NULL;
-- Query 12: product cart-to-purchase event counts (NOT literal product conversion)
SELECT product_id, SUM(event_type='cart') cart_events,SUM(event_type='purchase') purchase_events
FROM valid_events WHERE product_id IS NOT NULL GROUP BY product_id HAVING cart_events >= 10
ORDER BY cart_events DESC LIMIT 30;
-- Query 13: session sequence with window functions
SELECT user_session, event_at,event_type,
ROW_NUMBER() OVER(PARTITION BY user_session ORDER BY event_at,event_id) event_sequence
FROM valid_events WHERE user_session IS NOT NULL LIMIT 100;
-- Query 14: cart sessions with no observed purchase, for diagnostic drill-down
WITH flags AS (SELECT user_session,MAX(event_type='cart') carted,MAX(event_type='purchase') purchased
FROM valid_events WHERE user_session IS NOT NULL GROUP BY user_session)
SELECT user_session FROM flags WHERE carted=1 AND purchased=0 LIMIT 100;
-- Query 15: validation of exact raw duplicates (no event ID)
SELECT event_time,event_type,product_id,user_session,COUNT(*) occurrences FROM raw_events
GROUP BY event_time,event_type,product_id,user_session HAVING COUNT(*)>1 ORDER BY occurrences DESC LIMIT 30;
-- Query 16: high-level funnel drop-off (aggregate session flags)
WITH f AS (SELECT user_session,MAX(event_type='view') v,MAX(event_type='cart') c,MAX(event_type='purchase') p
FROM valid_events WHERE user_session IS NOT NULL GROUP BY user_session)
SELECT SUM(v) view_sessions,SUM(v=1 AND c=0) view_without_cart,
SUM(c) cart_sessions,SUM(c=1 AND p=0) cart_without_purchase FROM f;
-- All queries require real input and execution in MySQL 8. Query result screenshots are pending.
