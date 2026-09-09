-- =============================================================================
-- Project: Retail Profit Margin Erosion & Commercial Discount Audit
-- File: 01_margin_leak_audit.sql
-- Description: Regional margin modeling, discount tier segmentation, and margin loss isolation.
-- Engine: Google BigQuery Standard SQL
-- =============================================================================

CREATE OR REPLACE TABLE `business-process-intelligence.operations.superstore_margin_audit` AS
WITH transactional_base AS (
  SELECT
    order_id,
    region,
    state,
    segment,
    category,
    sub_category,
    SAFE_CAST(sales AS NUMERIC) AS gross_sales,
    SAFE_CAST(quantity AS INT64) AS quantity,
    SAFE_CAST(discount AS NUMERIC) AS discount_rate,
    SAFE_CAST(profit AS NUMERIC) AS net_profit
  FROM
    `business-process-intelligence.operations.superstore_raw`
  WHERE
    order_id IS NOT NULL
    AND sales IS NOT NULL
)
SELECT
  order_id,
  region,
  state,
  segment,
  category,
  sub_category,
  gross_sales,
  quantity,
  discount_rate,
  net_profit,

  -- Profit margin ratio calculation
  SAFE_DIVIDE(net_profit, gross_sales) AS profit_margin_ratio,

  -- Commercial discount tier segmentation
  CASE
    WHEN discount_rate = 0.0 THEN 'No Discount (0%)'
    WHEN discount_rate <= 0.20 THEN 'Approved Tier (<=20%)'
    WHEN discount_rate <= 0.40 THEN 'Moderate Risk (21-40%)'
    ELSE 'High Risk Leakage (>40%)'
  END AS discount_tier,

  -- Financial performance flag
  CASE
    WHEN net_profit < 0 THEN 'Unprofitable (Margin Drain)'
    ELSE 'Profitable Transaction'
  END AS profitability_flag

FROM
  transactional_base;
