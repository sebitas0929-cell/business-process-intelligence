# ⏱️ Fulfillment Cycle Time & SLA Bottleneck Audit

> **Operational root-cause analysis diagnosing dispatch bottlenecks, SLA breaches, and carrier transit variances using BigQuery SQL, Spreadsheets, and Tableau.**

---

## 📌 Executive Summary
In high-volume fulfillment and shared-services operations, missing Service Level Agreements (SLAs) directly inflates operational write-offs, triggers carrier penalties, and harms customer retention.

This case study audits an end-to-end fulfillment pipeline (+5,000 dispatch logs) across multi-regional distribution hubs. By modeling cycle times across discrete stages (Order to Ship vs. Ship to Delivery), this audit isolates the exact operational choke points, uncovers carrier-specific transit deficits, and outlines a data-driven workload reallocation model to recover compliance above target (>95.0%).

---

## 📐 Methodology (Google Data Analytics 6-Phase Framework)

### 1. Ask (Operational Problem & Objectives)
* **Core Business Problem:** The operation experiences a systemic drop in on-time delivery (operating at ~82.4% vs. the corporate SLA target of >= 95.0%). Operations leadership requires clarity on whether failures originate inside the warehouse (dispatch/processing lag) or downstream during carrier transit.
* **Key Operational Metrics (KPIs):**
  * **On-Time Fulfillment Rate (%):** Orders delivered within target SLA window (<= 5 business days).
  * **Order-to-Ship Cycle Time (Lead Time 1):** Days elapsed between order creation and carrier handoff (SLA <= 2 days).
  * **Ship-to-Delivery Cycle Time (Lead Time 2):** Days elapsed during transit with third-party logistics (3PL) carriers (SLA <= 3 days).
  * **Critical Breach Ratio:** Volume of delayed shipments exceeding >= 3 days past SLA threshold.

---

### 2. Prepare (Data Architecture & Integrity)
* **Dataset Scope:** 5,000+ fulfillment transactional records spanning regional distribution centers (`Hub_Central`, `Hub_Norte`, `Hub_Sur`).
* **Relational Schema:**
  * `order_id` (STRING): Unique tracking identifier.
  * `order_timestamp` (TIMESTAMP): Customer order placement time.
  * `shipped_timestamp` (TIMESTAMP): Outbound carrier handoff scan.
  * `delivered_timestamp` (TIMESTAMP): Customer final delivery scan.
  * `dispatch_hub` (STRING): Origin fulfillment center.
  * `carrier_name` (STRING): Third-party logistics provider (3PL).
  * `target_sla_days` (INT64): Target fulfillment threshold (standard: 5 days).
* **Data Hygiene Verification:** Verification of timestamp chronology (`order_timestamp <= shipped_timestamp <= delivered_timestamp`), duplicate scan eradication, and isolation of unfulfilled/lost in-transit orders.

---

### 3. Process (Data Cleaning & Metric Modeling in SQL)
All raw logs were staged and cleaned in **Google BigQuery**. Transformations include elapsed day calculations (`TIMESTAMP_DIFF`), chronological anomaly audits, and categorical SLA performance flags.

```sql
-- 01: Fulfillment Metric Modeling and Elapsed Cycle Times
WITH fulfillment_metrics AS (
  SELECT
    order_id,
    dispatch_hub,
    carrier_name,
    order_timestamp,
    shipped_timestamp,
    delivered_timestamp,
    target_sla_days,
    -- Cycle time calculations in days
    TIMESTAMP_DIFF(shipped_timestamp, order_timestamp, DAY) AS dispatch_lead_time_days,
    TIMESTAMP_DIFF(delivered_timestamp, shipped_timestamp, DAY) AS transit_lead_time_days,
    TIMESTAMP_DIFF(delivered_timestamp, order_timestamp, DAY) AS total_fulfillment_days
  FROM
    `business-process-intelligence.operations.fulfillment_logs`
  WHERE
    delivered_timestamp IS NOT NULL
    AND delivered_timestamp >= order_timestamp
)
SELECT
  *,
  -- SLA Performance Segmentation
  CASE
    WHEN total_fulfillment_days <= target_sla_days THEN 'Within SLA'
    WHEN total_fulfillment_days = target_sla_days + 1 THEN 'Minor Breach (1d)'
    ELSE 'Critical Breach (>2d)'
  END AS sla_status_flag,
  -- Root-Cause Categorization
  CASE
    WHEN dispatch_lead_time_days > 2 AND transit_lead_time_days > 3 THEN 'Dual Failure (Hub + Carrier)'
    WHEN dispatch_lead_time_days > 2 THEN 'Hub Bottleneck (Internal)'
    WHEN transit_lead_time_days > 3 THEN 'Transit Delay (External 3PL)'
    ELSE 'Compliant Flow'
  END AS delay_root_cause
FROM
  fulfillment_metrics;
```

---

### 4. Analyze (Root Cause & Pareto Diagnostics)
Aggregating the sanitized dataset surfaced actionable operational variances:

```sql
-- 02: Pareto Analysis of SLA Breaches by Distribution Hub
SELECT
  dispatch_hub,
  COUNT(order_id) AS total_orders,
  COUNTIF(sla_status_flag != 'Within SLA') AS breached_orders,
  ROUND(COUNTIF(sla_status_flag != 'Within SLA') / COUNT(order_id) * 100, 2) AS breach_rate_pct,
  ROUND(AVG(dispatch_lead_time_days), 1) AS avg_hub_dwell_days,
  ROUND(AVG(transit_lead_time_days), 1) AS avg_transit_days
FROM
  `business-process-intelligence.operations.fulfillment_modeled`
GROUP BY
  dispatch_hub
ORDER BY
  breached_orders DESC;
```

#### Diagnostic Findings:
* **Hub Concentration (Pareto 80/20):** `Hub_Norte` accounts for **78.4% of all SLA breaches**. While `Hub_Central` and `Hub_Sur` maintain average dispatch dwell times under 1.4 days, `Hub_Norte` averages **3.8 days in internal processing** before carrier handoff.
* **Internal vs. External Failure Points:** 68% of failures at `Hub_Norte` originate **prior to transit**, indicating that warehouse processing and sorting capacity—not carrier speed—is the bottleneck.
* **Carrier Transit Discrepancies:** For orders dispatched on time (<= 2 days), Carrier `FastLogistics` met 98.2% SLA, whereas Carrier `OmniFreight` caused a 14.5% SLA breach rate in rural transit corridors due to consolidation delays.

---

### 5. Share (Operational Dashboard & Visual Reporting)
* **Visual Representation:** Executive triage dashboard built in **Tableau Public** featuring cross-filtering by hub and carrier.
* **Key Visuals:**
  * **Hub Cycle Time Scatter Plot:** Internal warehouse dwell time vs. external carrier transit time.
  * **SLA Variance Pareto Chart:** Breakdown of breach root causes (Internal Hub vs. 3PL Transit).
  * **Fulfillment Trend Matrix:** Day-of-week dispatch backlogs showing significant accumulation during weekend shifts.

---

### 6. Act (Strategic Operations Recommendations)

| Operational Area | Data-Backed Finding | Recommended Action | Projected Impact |
| :--- | :--- | :--- | :--- |
| **Warehouse Operations (`Hub_Norte`)** | Processing dwell time averages 3.8 days (vs. 2.0 SLA limit), driven by weekend order surges. | Implement a staggered Sunday shift to balance the weekend backlog before Monday carrier arrival. | Reduction of warehouse dwell time from 3.8 to 1.8 days; +14% overall SLA recovery. |
| **3PL Carrier Governance** | `OmniFreight` regional transit breaches SLA in 14.5% of assignments. | Enforce penalty clauses in carrier contract and reallocate 40% of rural volume to primary carrier. | Immediate 3.5% reduction in total fulfillment cycle variance. |
| **Standardized Monitoring** | Lack of real-time visibility into unassigned orders pending handoff. | Deploy daily automated BigQuery SQL health check alerts for orders lingering >= 36 hours without a scan. | Elimination of blind spots; reduction of critical breach cases by ~80%. |

---

### 👤 Author & Analyst
**Sebastián Corrales Blanco**  
*Operations & Business Process Analyst • San José, Costa Rica*  
[LinkedIn Profile](https://linkedin.com/in/sebasti%C3%A1n-corrales-blanco-a04a1a152)
