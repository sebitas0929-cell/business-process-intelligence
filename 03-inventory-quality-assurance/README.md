# 📦 Reverse Logistics, Defect Rate & Quality Assurance Audit

> **Operational root-cause audit diagnosing return costs, supplier defect clusters, and fulfillment discrepancies across multi-channel retail hubs using BigQuery DML, Spreadsheets, and Tableau.**

---

## 📌 Executive Summary
In omni-channel distribution and retail operations, unmonitored return rates erode operational margin and create inventory reconciliation deficits. 

This case study audits transactional return logs to isolate why products are sent back, quantify financial scrap/restocking write-offs, and trace failure patterns back to origin vendors. Integrating spreadsheet data sanitation with interactive visual intelligence on **Tableau Public**, this audit maps over **$1,700 in direct return costs** and defines an operational vendor quarantine protocol to safeguard product integrity.

---

## 📐 Methodology (Google Data Analytics 6-Phase Framework)

### 1. Ask (Operational Problem & Objectives)
* **Core Business Problem:** Elevated customer return rates are driving up reverse logistics freight costs and inventory holding losses. Operations leadership needs visibility into whether product returns stem from vendor quality defects, sizing confusion, or carrier transit delays.
* **Key Operational Metrics (KPIs):**
  * **Overall Return Rate (%):** Total returned units divided by total dispatched volume.
  * **Financial Loss from Returns ($):** Sum of lost gross margin plus unrecoverable return shipping fees.
  * **Defect Concentration Ratio (%):** Percentage of returns caused by functional/manufacturing failure (`Defectuoso`).
  * **Late Delivery Return Impact ($):** Financial waste generated exclusively by transit carrier SLA breaches.

---

### 2. Prepare (Data Architecture & Cleaning Pipeline)
* **Dataset Scope:** Multi-regional retail return and order logs across regional corridors (`Norte`, `Central`, `Sur`).
* **Relational Schema:**
  * `order_id` (STRING): Unique shipment identifier.
  * `product_category` (STRING): Product family (`Tecnologia`, `Moda`, `Muebles`).
  * `region` (STRING): Operational hub fulfillment zone.
  * `unit_price` (NUMERIC): Baseline invoice item price.
  * `quantity` (INT64): Dispatched unit count.
  * `shipping_cost` (NUMERIC): Forward freight expense.
  * `return_status` (STRING): Binary return indicator (`SI` / `Sin Devolucion`).
  * `return_reason` (STRING): Defect classification (`Defectuoso`, `Talla/Modelo Incorrecto`, `Llego Tarde`).
* **Sanitization Protocol:** Enforced uppercase standardization, whitespace eradication via string parsing (`TRIM`), and imputation of empty return fields with baseline status.

---

### 3. Process (Data Transformation & Loss Modeling)
Feature engineering was executed to model operational loss metrics directly from line items:

* **Gross Sales Model:**
  `=C2 * D2` *(Unit Price * Quantity)*
* **Return Indicator Normalization:**
  `=IF(G2 = "SI"; 1; 0)`
* **Total Operational Loss Calculation:**
  `=IF(G2 = "SI"; Gross_Sales + Shipping_Cost; 0)`

---

### 4. Analyze (Root Cause & Defect Concentration)

#### Return Impact by Reason & Product Family:

| Return Reason | Dominant Category | Net Operational Loss ($) | Share of Total Loss | Operational Root Cause |
| :--- | :--- | ---: | :---: | :--- |
| **Defectuoso (Defective)** | Tecnologia / Muebles | $711.00 | 41.4% | Hardware component failure & packaging breakdown during transit. |
| **Talla/Modelo Incorrecto** | Moda | $661.00 | 38.5% | Misleading online sizing dimensions and customer specification errors. |
| **Llego Tarde (Late Transit)** | Monitores / Tecnologia | $345.00 | 20.1% | Regional 3PL delivery SLA breaches in the Northern corridor. |
| **Total Loss Audited** | **All Categories** | **$1,717.00** | **100.0%** | **Targetable Operational Discrepancies** |

#### Diagnostic Findings:
1. **Supplier Quality Clusters:** Manufacturing defects accounted for the largest financial drain (**$711.00**), isolated specifically within high-ticket hardware and furniture units.
2. **Sizing Ambiguity in Apparel:** Moda generated **$661.00** in preventable returns purely due to dimension confusion, representing an avoidable inbound handling overhead.
3. **Logistics Bottlenecks (Region Norte):** 100% of late arrival returns (**$345.00**) were concentrated in `Region Norte`, proving that carrier transit failures directly trigger product cancellations.

---

### 5. Share (Executive BI Dashboard)

* **Interactive Visualization:** Executive Return & Quality Triage Dashboard hosted on **Tableau Public**.
* **Visual Architecture:**
  * **Top Level (Diagnostic):** Return rate comparison segmented across product category and operating region.
  * **Bottom Level (Financial Loss):** Dynamic cost breakdown categorized by operational return reason.
  * **Dynamic Cross-Filtering:** Selecting high-loss bars instantly isolates root causes and category losses.

> 🔗 **Tableau Public Dashboard:** [Explore the Interactive Quality Control Dashboard](https://public.tableau.com/shared/TGPGGCZYD)

---

### 6. Act (Operational Governance & Quality Recommendations)

| Operational Domain | Analytical Finding | Recommended Action | Expected Business Impact |
| :--- | :--- | :--- | :--- |
| **Vendor QA Governance** | Factory defects drive $711.00 in losses across tech units. | Enforce mandatory inbound QA lot inspections and charge back freight costs to failing vendors. | Estimated 60% drop in defective customer deliveries; stops recurring scrap write-offs. |
| **Catalog Specification** | Sizing mismatches cause $661.00 in avoidable fashion returns. | Publish standardized centimeter dimension charts and fitment guides on checkout pages. | Projected 30% reduction in reverse logistics handling and customer return processing. |
| **Carrier SLA Enforcement** | Northern hub suffers $345.00 in returns due to delivery delays. | Renegotiate delivery windows with local 3PL carriers and establish on-time delivery penalties. | Recovery of carrier transit compliance above target (>95%). |

---

### 👤 Author & Analyst
**Sebastián Corrales Blanco**  
*Operations & Business Process Analyst • San José, Costa Rica*  
[LinkedIn Profile](https://linkedin.com/in/sebasti%C3%A1n-corrales-blanco-a04a1a152)
