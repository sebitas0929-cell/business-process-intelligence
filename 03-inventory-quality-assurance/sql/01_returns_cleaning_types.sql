-- =============================================================================
-- Project: Reverse Logistics, Defect Rate & Quality Assurance Audit
-- File: 01_returns_cleaning_types.sql
-- Description: Data sanitization, text standardization, and loss metrics modeling.
-- Engine: Google BigQuery Standard SQL
-- =============================================================================

CREATE OR REPLACE TABLE `business-process-intelligence.operations.returns_cleaned` AS
WITH raw_staged AS (
  SELECT
    TRIM(order_id) AS order_id,
    UPPER(TRIM(region)) AS region,
    TRIM(product_category) AS product_category,
    SAFE_CAST(unit_price AS NUMERIC) AS unit_price,
    SAFE_CAST(quantity AS INT64) AS quantity,
    SAFE_CAST(shipping_cost AS NUMERIC) AS shipping_cost,
    
    -- Standardize binary return indicator
    CASE 
      WHEN UPPER(TRIM(return_status)) IN ('SI', 'YES', '1', 'RETURNED') THEN 'SI'
      ELSE 'Sin Devolucion'
    END AS return_status,
    
    -- Clean return reason and assign default baseline for non-returns
    COALESCE(NULLIF(TRIM(return_reason), ''), 'Sin Devolucion') AS return_reason

  FROM
    `business-process-intelligence.operations.retail_orders_raw`
  WHERE
    order_id IS NOT NULL
)
SELECT
  order_id,
  region,
  product_category,
  unit_price,
  quantity,
  shipping_cost,
  return_status,
  return_reason,
  
  -- Gross sales calculation
  (unit_price * quantity) AS gross_sales,

  -- Binary numeric flag for aggregation
  CASE 
    WHEN return_status = 'SI' THEN 1 
    ELSE 0 
  END AS is_returned_flag,

  -- Total operational loss (product cost lost + forward shipping fee)
  CASE 
    WHEN return_status = 'SI' THEN (unit_price * quantity) + shipping_cost 
    ELSE 0.00 
  END AS total_operational_loss

FROM
  raw_staged;
