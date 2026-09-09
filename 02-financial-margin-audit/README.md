# 📉 Retail Profit Margin Erosion & Commercial Discount Audit

> **Financial & operational audit diagnosing margin leaks, high-volume unprofitable segments, and commercial discount policies across US regional hubs using Advanced Spreadsheets and Tableau.**

---

## 📌 Executive Summary
In omni-channel and retail operations, high top-line revenue often conceals severe operating margin leakage caused by unmonitored commercial promotions and discounting policies.

This project audits ~10,000 retail transactions (Superstore dataset) to isolate the root cause of systemic operating losses within the **Central Region**. By combining multi-variable pivot modeling, dynamic variance charting, and margin cap simulations, this audit quantifies over **$15,000 in net margin erosion** and delivers an executive **Discount Cap Policy** to restore regional profitability without damaging organic volume.

---

## 📐 Methodology (Google Data Analytics 6-Phase Framework)

### 1. Ask (Operational Problem & Objectives)
* **Core Business Problem:** The Central Region maintains strong gross billing but consistently returns negative net margins across multiple product families. Operations and Finance leadership require an audit to identify whether margin collapse stems from manufacturing costs or unmanaged regional commercial discounting (>40%).
* **Key Operational & Financial KPIs:**
  * **Gross Sales ($):** Baseline invoice revenue before commercial deductions.
  * **Net Operating Profit ($):** Bottom-line cash generation after product cost and applied discounts.
  * **Profit Margin Ratio (%):** `SUM(Profit) / SUM(Sales)` (Corporate target: >= 15.0%).
  * **Average Commercial Discount (%):** Mean contractual price concession granted by sales teams.

---

### 2. Prepare (Data Architecture & Cleaning Integrity)
* **Dataset Scope:** 9,994 transactional lines covering product hierarchy (`Category`, `Sub-Category`), geography (`Region`, `State`), customer classifications (`Segment`), and financial metrics.
* **Integrity Auditing:**
  * Delimiter reconciliation and alignment of shifted numeric fields (`Sales`, `Quantity`, `Discount`, `Profit`).
  * Strict currency and percentage data-type enforcement.
  * Line-item feature modeling: `Unit_Margin = Profit / Sales` to enable granular distribution reviews.

---

### 3. Process (Multi-Variable Matrix Modeling in Spreadsheets)
Data staging was structured using nested formulas and dynamic matrices in spreadsheets to isolate margin erosion:

* **Key Mathematical Formulas Applied (Regional Configuration):**
  * Gross Invoice Calculation:
    `=C2 * D2` *(Units * Unit Price)*
  * Net Cash Flow:
    `=E2 - (E2 * F2)` *(Gross Sales - Applied Discount)*
  * Anomaly & Outlier Screening:
    `=COUNTIF(F2:F9994; ">0.40")` *(Detecting aggressive discounts exceeding 40%)*
  * Conditional Negative Margin Highlight:
    Applied conditional formatting across all profit metrics where value `< 0`.

---

### 4. Analyze (Root Cause & Variance Diagnostics)

#### Regional Performance Comparison (Furniture Category Audit):

| Operating Region | Gross Sales (SUM) | Net Profit (SUM) | Avg Discount (MEAN) | Financial Status |
| :--- | ---: | ---: | :---: | :---: |
| **Central** | $86,229.22 | -$3,994.43 | 31.4% | **Critical Net Loss** |
| **East** | $114,211.80 | +$2,038.11 | 15.8% | Profitable |
| **West** | $119,808.09 | +$4,330.67 | 13.0% | Profitable |
| **South** | $70,800.20 | +$4,616.73 | 11.2% | Profitable |

#### Diagnostic Findings & Root-Cause Isolation:
1. **The Discount-Profit Correlation:** Profitable operating regions (East, West, South) maintain controlled discount levels below **16.0%**. In contrast, the Central Region averages **31.4% to 50.9%** in discounts on troubled sub-categories.
2. **Sub-Category Failure Points:**
   * **Appliances (Central):** Suffered a **-124.98% average profit margin** driven by an unsustainable **44.9% mean discount**, generating over -$12,700 in cumulative net losses.
   * **Binders (Central):** Averaged a **50.9% commercial discount**, eroding bottom-line margins to **-85.94%**.
   * **Tables & Furnishings:** Sustained negative margins of -17.34% and -35.98% due to commercial markdowns between 31.2% and 41.1%.

---

### 5. Share (Executive Visual Reporting)
* **Visual Architecture:** High-contrast divergence chart with a baseline set at **$0.00** to highlight profitable versus loss-making product categories instantly.
* **Interactive Controls:** Dynamic multi-variable slicers (`Segment` and `Category`) to enable sales and operations leads to conduct real-time contract audits.
* **Key Visual Anchor:** Positive margin bars (`Copiers` at +$15.6K, `Phones` at +$12.3K) contrasted directly against severe negative drawdowns (`Appliances`, `Tables`, `Binders`).

---

### 6. Act (Strategic Operations & Policy Recommendations)

| Focus Area | Operational Diagnostic | Recommended Governance Action | Projected Financial Recovery |
| :--- | :--- | :--- | :--- |
| **Commercial Discount Policy** | Central Region granted discounts up to 50.9% to boost short-term volume. | Establish a mandatory **15% - 20% Discount Cap Policy** for `Furniture` and `Office Supplies`. | Elimination of negative margin transactions; regional net profit recovery estimated at +$15,000. |
| **Contract Approval Workflow** | Field sales teams applied discretionary markdowns without financial sign-off. | Implement automated spreadsheet workflow blocks requiring Finance approval for any discount >20%. | Immediate reduction of margin leakage on high-volume B2B enterprise contracts. |
| **Catalog Reallocation** | `Tables` and `Bookcases` generated systemic operational losses across multiple segments. | Renegotiate supplier unit acquisition costs or shift product mix to demand-only dropship models. | Mitigates inventory holding costs and stops bottom-line cash erosion. |

---

### 👤 Author & Analyst
**Sebastián Corrales Blanco**  
*Operations & Business Process Analyst • San José, Costa Rica*  
[LinkedIn Profile](https://linkedin.com/in/sebasti%C3%A1n-corrales-blanco-a04a1a152)
