-- =============================================================================
-- Project: Fulfillment Cycle Time & SLA Bottleneck Audit
-- File: 01_data_cleaning_types.sql
-- Description: Data sanitization, timestamp validation, and null handling.
-- Engine: Google BigQuery Standard SQL
-- =============================================================================

CREATE OR REPLACE TABLE `business-process-intelligence.operations.fulfillment_logs_cleaned` AS
SELECT
  -- Canonical identifiers
  TRIM(order_id) AS order_id,
  TRIM(dispatch_hub) AS dispatch_hub,
  TRIM(carrier_name) AS carrier_name,

  -- Safe timestamp ingestion & chronological consistency check
  SAFE_CAST(order_timestamp AS TIMESTAMP) AS order_timestamp,
  SAFE_CAST(shipped_timestamp AS TIMESTAMP) AS shipped_timestamp,
  SAFE_CAST(delivered_timestamp AS TIMESTAMP) AS delivered_timestamp,

  -- Target baseline (SLA threshold in days)
  COALESCE(SAFE_CAST(target_sla_days AS INT64), 5) AS target_sla_days

FROM
  `business-process-intelligence.operations.fulfillment_logs_raw`
WHERE
  -- Filter invalid or incomplete tracking records
  order_id IS NOT NULL
  AND order_timestamp IS NOT NULL
  AND delivered_timestamp IS NOT NULL
  -- Integrity rule: chronology must flow Order <= Ship <= Delivery
  AND order_timestamp <= shipped_timestamp
  AND shipped_timestamp <= delivered_timestamp;
