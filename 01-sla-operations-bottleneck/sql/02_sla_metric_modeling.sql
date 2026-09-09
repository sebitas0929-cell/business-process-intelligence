-- =============================================================================
-- Project: Fulfillment Cycle Time & SLA Bottleneck Audit
-- File: 02_sla_metric_modeling.sql
-- Description: Calculation of stage lead times, breach flags, and root cause tagging.
-- Engine: Google BigQuery Standard SQL
-- =============================================================================

CREATE OR REPLACE TABLE `business-process-intelligence.operations.fulfillment_modeled` AS
WITH cycle_calculations AS (
  SELECT
    order_id,
    dispatch_hub,
    carrier_name,
    order_timestamp,
    shipped_timestamp,
    delivered_timestamp,
    target_sla_days,

    -- Stage cycle times calculated in full days
    TIMESTAMP_DIFF(shipped_timestamp, order_timestamp, DAY) AS dispatch_lead_time_days,
    TIMESTAMP_DIFF(delivered_timestamp, shipped_timestamp, DAY) AS transit_lead_time_days,
    TIMESTAMP_DIFF(delivered_timestamp, order_timestamp, DAY) AS total_fulfillment_days

  FROM
    `business-process-intelligence.operations.fulfillment_logs_cleaned`
)
SELECT
  order_id,
  dispatch_hub,
  carrier_name,
  order_timestamp,
  shipped_timestamp,
  delivered_timestamp,
  target_sla_days,
  dispatch_lead_time_days,
  transit_lead_time_days,
  total_fulfillment_days,

  -- Variance against target SLA threshold
  total_fulfillment_days - target_sla_days AS sla_variance_days,

  -- Categorical SLA status flag
  CASE
    WHEN total_fulfillment_days <= target_sla_days THEN 'Within SLA'
    WHEN total_fulfillment_days = target_sla_days + 1 THEN 'Minor Breach (1d)'
    ELSE 'Critical Breach (>2d)'
  END AS sla_status_flag,

  -- Operational root cause segmentation
  CASE
    WHEN dispatch_lead_time_days > 2 AND transit_lead_time_days > 3 THEN 'Dual Failure (Hub + Carrier)'
    WHEN dispatch_lead_time_days > 2 THEN 'Hub Bottleneck (Internal Processing)'
    WHEN transit_lead_time_days > 3 THEN 'Carrier Delay (External Transit)'
    ELSE 'Compliant Flow'
  END AS breach_root_cause

FROM
  cycle_calculations;
