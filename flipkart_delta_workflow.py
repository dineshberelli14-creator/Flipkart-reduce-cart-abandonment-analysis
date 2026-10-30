# Databricks PySpark notebook source - EXECUTION PENDING; do not claim Delta table already exists.
from pyspark.sql import functions as F
path='/FileStore/flipkart/ecommerce_events_raw.csv' # upload genuine REES46 file here
raw=spark.read.option('header',True).option('inferSchema',True).csv(path)
required={'event_time','event_type','user_session','product_id'}
assert required.issubset(set(raw.columns)),f'Missing expected fields: {required-set(raw.columns)}'
print('Input rows:',raw.count())
raw.groupBy('event_type').count().show()
valid=raw.filter(F.col('user_session').isNotNull())
flags=valid.groupBy('user_session').agg(
 F.max(F.when(F.col('event_type')=='view',1).otherwise(0)).alias('has_view'),
 F.max(F.when(F.col('event_type')=='cart',1).otherwise(0)).alias('has_cart'),
 F.max(F.when(F.col('event_type')=='purchase',1).otherwise(0)).alias('has_purchase'))
flags.withColumn('cart_without_purchase',(F.col('has_cart')==1)&(F.col('has_purchase')==0)).groupBy('cart_without_purchase').count().show()
# Delta persists only if environment supports it and permissions allow it
flags.write.format('delta').mode('overwrite').saveAsTable('flipkart_behavior_session_flags')
spark.sql('DESCRIBE HISTORY flipkart_behavior_session_flags').show()
