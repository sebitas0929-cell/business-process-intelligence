-- =============================================================================
-- Project: Fulfillment Cycle Time & SLA Bottleneck Audit
-- File: 03_kpi_root_cause.sql
-- Description: Aggregate KPI reporting, Pareto breach analysis, and root cause diagnosis.
-- Engine: Google BigQuery Standard SQL
-- =============================================================================

-- Query 1: Regional Hub Performance & Pareto Breach Concentration
SELECT
  dispatch_hub,
  COUNT(order_id) AS total_dispatched_orders,
  COUNTIF(sla_status_flag != 'Within SLA') AS breached_orders,
  ROUND(COUNTIF(sla_status_flag != 'Within SLA') / COUNT(order_id) * 100, 2) AS breach_rate_pct,
  ROUND(AVG(dispatch_lead_time_days), 1) AS avg_internal_dwell_days,
  ROUND(AVG(transit_lead_time_days), 1) AS avg_carrier_transit_days,
  ROUND(AVG(total_fulfillment_days), 1) AS avg_total_cycle_days
FROM
  `business-process-intelligence.operations.fulfillment_modeled`
GROUP BY
  dispatch_hub
ORDER BY
  breached_orders DESC;

-- Query 2: Root Cause Segmentation by Origin Hub
SELECT
  dispatch_hub,
  breach_root_cause,
  COUNT(order_id) AS incident_count,
  ROUND(COUNT(order_id) / SUM(COUNT(order_id)) OVER(PARTITION BY dispatch_hub) * 100, 1) AS hub_impact_share_pct
FROM
  `business-process-intelligence.operations.fulfillment_modeled`
WHERE
  breach_root_cause != 'Compliant Flow'
GROUP BY
  dispatch_hub,
  breach_root_cause
ORDER BY
  dispatch_hub,
  incident_count DESC;

-- Query 3: Carrier (3PL) Transit SLA Breakdown
SELECT
  carrier_name,
  COUNT(order_id) AS total_carried_orders,
  ROUND(AVG(transit_lead_time_days), 1) AS avg_transit_days,
  COUNTIF(transit_lead_time_days > 3) AS transit_sla_breaches,
  ROUND(COUNTIF(transit_lead_time_days > 3) / COUNT(order_id) * 100, 2) AS transit_failure_rate_pct
FROM
  `business-process-intelligence.operations.fulfillment_modeled`
GROUP BY
  carrier_name
ORDER BY
  transit_failure_rate_pct DESC;
