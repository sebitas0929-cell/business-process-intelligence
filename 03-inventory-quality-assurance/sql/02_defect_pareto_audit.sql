-- =============================================================================
-- Project: Reverse Logistics, Defect Rate & Quality Assurance Audit
-- File: 02_defect_pareto_audit.sql
-- Description: Pareto analysis of returns, financial scrap impact, and vendor defect clusters.
-- Engine: Google BigQuery Standard SQL
-- =============================================================================

-- Query 1: Pareto Distribution of Operational Return Losses by Reason
SELECT
  return_reason,
  COUNT(order_id) AS total_returned_items,
  ROUND(SUM(total_operational_loss), 2) AS total_loss_usd,
  ROUND(
    SUM(total_operational_loss) / 
    SUM(SUM(total_operational_loss)) OVER() * 100, 
    2
  ) AS loss_share_pct
FROM
  `business-process-intelligence.operations.returns_cleaned`
WHERE
  return_status = 'SI'
GROUP BY
  return_reason
ORDER BY
  total_loss_usd DESC;

-- Query 2: Product Category Return Exposure & Scrap Rate
SELECT
  product_category,
  COUNT(order_id) AS total_orders,
  COUNTIF(return_status = 'SI') AS returned_orders,
  ROUND(COUNTIF(return_status = 'SI') / COUNT(order_id) * 100, 2) AS return_rate_pct,
  ROUND(SUM(total_operational_loss), 2) AS category_loss_usd,
  ROUND(AVG(total_operational_loss), 2) AS avg_loss_per_return
FROM
  `business-process-intelligence.operations.returns_cleaned`
GROUP BY
  product_category
ORDER BY
  category_loss_usd DESC;

-- Query 3: Regional Bottlenecks & Late Delivery Impact
SELECT
  region,
  return_reason,
  COUNT(order_id) AS breach_incidents,
  ROUND(SUM(total_operational_loss), 2) AS regional_loss_usd
FROM
  `business-process-intelligence.operations.returns_cleaned`
WHERE
  return_status = 'SI'
GROUP BY
  region,
  return_reason
ORDER BY
  region,
  regional_loss_usd DESC;
