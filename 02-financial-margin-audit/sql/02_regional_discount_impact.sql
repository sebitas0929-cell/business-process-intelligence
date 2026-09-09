-- =============================================================================
-- Project: Retail Profit Margin Erosion & Commercial Discount Audit
-- File: 02_regional_discount_impact.sql
-- Description: Regional margin aggregation, discount correlation, and cap impact simulation.
-- Engine: Google BigQuery Standard SQL
-- =============================================================================

-- Query 1: Regional Financial Performance & Mean Discount Exposure
SELECT
  region,
  COUNT(order_id) AS total_line_items,
  ROUND(SUM(gross_sales), 2) AS total_gross_sales,
  ROUND(SUM(net_profit), 2) AS total_net_profit,
  ROUND(SAFE_DIVIDE(SUM(net_profit), SUM(gross_sales)) * 100, 2) AS profit_margin_pct,
  ROUND(AVG(discount_rate) * 100, 2) AS avg_discount_pct,
  COUNTIF(profitability_flag = 'Unprofitable (Margin Drain)') AS loss_making_orders,
  ROUND(COUNTIF(profitability_flag = 'Unprofitable (Margin Drain)') / COUNT(order_id) * 100, 2) AS unprofitable_order_ratio_pct
FROM
  `business-process-intelligence.operations.superstore_margin_audit`
GROUP BY
  region
ORDER BY
  total_net_profit ASC;

-- Query 2: Central Region Sub-Category Root Cause Drilldown
SELECT
  category,
  sub_category,
  COUNT(order_id) AS total_transactions,
  ROUND(SUM(gross_sales), 2) AS regional_sales,
  ROUND(SUM(net_profit), 2) AS regional_net_profit,
  ROUND(SAFE_DIVIDE(SUM(net_profit), SUM(gross_sales)) * 100, 2) AS subcategory_margin_pct,
  ROUND(AVG(discount_rate) * 100, 2) AS avg_commercial_discount_pct
FROM
  `business-process-intelligence.operations.superstore_margin_audit`
WHERE
  region = 'Central'
GROUP BY
  category,
  sub_category
ORDER BY
  regional_net_profit ASC;

-- Query 3: Discount Cap Simulation (Enforcing a 20% Max Discount Cap)
SELECT
  region,
  discount_tier,
  COUNT(order_id) AS impacted_order_count,
  ROUND(SUM(gross_sales), 2) AS original_sales,
  ROUND(SUM(net_profit), 2) AS current_net_profit,
  -- Simulated profit recovery assuming a strict 20% discount baseline on high-risk tiers
  ROUND(SUM(
    CASE 
      WHEN discount_rate > 0.20 THEN net_profit + (gross_sales * (discount_rate - 0.20))
      ELSE net_profit
    END
  ), 2) AS simulated_profit_under_cap
FROM
  `business-process-intelligence.operations.superstore_margin_audit`
GROUP BY
  region,
  discount_tier
ORDER BY
  region,
  discount_tier;
