# GTM Market Entry Strategy — Buy Now Pay Later, India

**A full-stack market entry analysis: should a new fintech player launch a BNPL product in India, and under what conditions?**

Built end-to-end in SQL, Python, and Excel — market sizing, competitive intelligence, state-level launch sequencing, unit economics, and a 5-year financial model culminating in an NPV/IRR-tested Go / Hold / No-Go recommendation.

`SQL (data layer) → Python (analysis & modeling) → Excel (executive workbook) → Tableau (dashboard, in progress)`

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Business Problem](#2-business-problem)
3. [Market Context](#3-market-context)
4. [Industry Overview](#4-industry-overview)
5. [Strategic Objectives](#5-strategic-objectives)
6. [Executive Business Questions](#6-executive-business-questions)
7. [Dataset Overview](#7-dataset-overview)
8. [Market Research Methodology](#8-market-research-methodology)
9. [Data Architecture](#9-data-architecture)
10. [Technology Stack](#10-technology-stack)
11. [SQL Analysis](#11-sql-analysis)
12. [Python Analysis](#12-python-analysis)
13. [Excel Dashboard](#13-excel-dashboard)
14. [Tableau Dashboard](#14-tableau-dashboard)
15. [Market Sizing Framework (TAM / SAM / SOM)](#15-market-sizing-framework-tam--sam--som)
16. [Customer Segmentation](#16-customer-segmentation)
17. [Merchant Segmentation](#17-merchant-segmentation)
18. [Competitive Landscape](#18-competitive-landscape)
19. [Unit Economics](#19-unit-economics)
20. [Strategic Risk Assessment](#20-strategic-risk-assessment)
21. [Analytical Methodology](#21-analytical-methodology)
22. [Business Insights](#22-business-insights)
23. [Executive Recommendations](#23-executive-recommendations)
24. [Financial Impact](#24-financial-impact)
25. [Business Value](#25-business-value)
26. [Folder Structure](#26-folder-structure)
27. [Repository Structure](#27-repository-structure)
28. [Key Skills Demonstrated](#28-key-skills-demonstrated)
29. [Challenges & Assumptions](#29-challenges--assumptions)
30. [Future Enhancements](#30-future-enhancements)
31. [Screenshots](#31-screenshots)
32. [How to Run the Project](#32-how-to-run-the-project)
33. [Conclusion](#33-conclusion)

---

## 1. Executive Summary

This project evaluates whether a new entrant should launch a Buy Now Pay Later (BNPL) product in India, using the same evidence chain a strategy or investment committee would demand before releasing capital: market sizing from two independent methods, a competitive concentration analysis, state-level launch sequencing, full unit economics, and a discounted cash flow model.

The headline top-down market size looks attractive — an **$8.1B BNPL TAM growing at 28% CAGR to $17.0B by 2027**. But the analysis doesn't stop at the headline number. A bottom-up, population-driven reconstruction of the same market lands at **~$2.26B** — a sizing gap wide enough to change the investment case, and the project treats that gap as a finding, not an inconvenience to smooth over.

Carried through to a 5-year discounted cash flow model, the financial case is **not yet fundable at a standard hurdle rate**: NPV is negative at a 15% discount rate and IRR is not computable within the 5-year explicit forecast because cash flows never turn positive in that window. The strategic case — a 28% CAGR market, moderate (not high) competitive concentration, and a clearly identified underserved segment (New-to-Credit Users) — remains strong.

**Bottom line: HOLD — Conditional Go.** Proceed to a limited-capital pilot targeting the New-to-Credit Users segment, sequenced by a state-level attractiveness score (not raw population), with three explicit conditions — extended horizon/CAC modeling, a default-rate margin-of-safety check, and multi-year retention validation — before committing full capital. The full reasoning is in the [Executive Recommendations](#23-executive-recommendations) section and [`docs/Executive_Recommendations.md`](docs/Executive_Recommendations.md).

## 2. Business Problem

A market entry decision is one of the highest-stakes calls a leadership team makes: it commits capital, regulatory exposure, and multi-year organizational focus before there is any real customer data to validate it. The BNPL segment specifically compounds that risk — it is capital-intensive (every transaction is a short-duration loan), regulator-sensitive (RBI digital lending guidelines directly shape the product), and already contested by well-capitalized marketplace incumbents (Amazon Pay Later, Flipkart Pay Later) who can subsidize BNPL economics with platform-level margins a standalone entrant cannot match.

This project frames the entry decision the way an internal strategy or corporate development team would frame it for a leadership team: **not "is the market big," but "is the market big, winnable, and financeable — and if not all three, what would need to be true to make it so?"**

## 3. Market Context

India is one of the largest and fastest-growing digital payments markets in the world, with UPI processing tens of billions of transactions monthly and a large under-25/35 population with limited formal credit history. That combination — high digital rail adoption plus a large "new-to-credit" population — is the structural argument for BNPL as a category. It is also why the category has already attracted five well-funded competitors (Simpl, LazyPay, ZestMoney, Amazon Pay Later, Flipkart Pay Later) plus adjacent EMI-financing incumbents like Bajaj Finance, and why RBI has issued specific Digital Lending Guidelines governing how BNPL products must operate (Key Fact Statement disclosure, mandatory cooling-off periods, a ban on lending service providers directly handling borrower funds, and mandatory grievance-officer infrastructure).

## 4. Industry Overview

BNPL sits inside India's broader digital lending market, estimated at **$45B**, of which BNPL represents an **18% share (~$8.1B)** by the top-down method used here. The category is growing faster than digital lending overall, driven by e-commerce checkout penetration and UPI-linked credit rails. Six tracked competitors span two structural types — pure-play BNPL apps optimizing for checkout conversion, and EMI-financing incumbents (led by Bajaj Finance, with 88M users) competing on scale and pre-existing lending infrastructure. The project's HHI analysis (Section 18) shows the BNPL-specific sub-market is **moderately concentrated, not saturated** — the strategic basis for treating entry as contestable.

## 5. Strategic Objectives

- Size the opportunity using two independent methods (top-down and bottom-up) and reconcile — or explicitly flag — any gap between them, rather than presenting a single unverified number.
- Segment customers and merchants by priority, and identify the specific white-space segment least contested by incumbents.
- Quantify competitive concentration (HHI, CR3/CR5) instead of asserting "the market is crowded" or "the market is open" without evidence.
- Rank Indian states for launch sequencing on a blended score (population, digital readiness, whitespace) rather than population alone.
- Build unit economics bottom-up (CAC, contribution margin, payback period) and carry them through to a 5-year revenue and cash-flow forecast.
- Stress-test that forecast with bear/base/bull scenarios, default-rate sensitivity, and a tornado analysis identifying which single variable moves NPV the most.
- Land on an explicit, criteria-based Go / Hold / No-Go recommendation — and state exactly what would need to change to move a Hold to a Go.

## 6. Executive Business Questions

This project is structured around the questions a CEO, CFO, or investment committee actually asks before approving a market entry:

1. How big is this market, really — and do our two sizing methods agree?
2. Who are we competing against, and is this market structurally open or closed to a new entrant?
3. Where should we launch first, and why there and not the largest-population state?
4. Which customer and merchant segments should we go after first?
5. Does the unit economics model work — what's our CAC payback period and contribution margin?
6. What does the 5-year P&L and cash flow look like, and does the business break even in a fundable window?
7. What is the single biggest risk to this thesis, and how would we monitor and mitigate it?
8. Given all of the above, is this a Go, a Hold, or a No-Go — and on what evidence?

## 7. Dataset Overview

All figures are compiled from public secondary sources (RBI publications, NPCI/UPI reporting, population census estimates, and competitor-disclosed user/merchant figures) into 12 structured tables covering regulation, UPI adoption, population and state demographics, competitor benchmarking, the BNPL macro market, customer and merchant segments, unit economics, and a consolidated financial model. See [`docs/Technical_Documentation.md`](docs/Technical_Documentation.md) for the full schema and [`docs/Executive_Recommendations.md`](docs/Executive_Recommendations.md)'s linked Assumption Registers for exactly which figures are direct data pulls versus modeling assumptions.

| Table | Grain | Used For |
|---|---|---|
| `RBI_DATA` | Regulation area | Regulatory landscape |
| `UPI_DATA` | Monthly UPI metric | Digital infrastructure readiness |
| `POPULATION` | National metric | Top-down TAM funnel |
| `STATE_DATA` | State | Launch sequencing |
| `COMPETITORS` | Competitor | Competitive landscape, HHI/CR3/CR5 |
| `BNPL_MARKET` | Metric | Top-down TAM / SAM / SOM |
| `CUSTOMER_SEGMENTS` | Segment | Customer prioritization |
| `MERCHANT_SEGMENTS` | Segment | Merchant prioritization |
| `UNIT_ECONOMICS` | Metric | CAC, contribution margin, payback |
| `RISK_REGULATION` | Risk factor | Risk assessment |

## 8. Market Research Methodology

Every market-sizing number in this project is produced by one of two explicit methods, and the two are deliberately cross-checked against each other rather than reported in isolation:

- **Top-down:** India's digital lending market ($45B) × BNPL's estimated share (18%) → $8.1B TAM, grown forward at the category's implied 28% CAGR.
- **Bottom-up:** national population → urban population → target age band (22–38) → smartphone/internet penetration → income match → addressable customers × estimated annual revenue per user.

Where the two methods disagree by a material margin (they do — roughly 3.6x, $8.1B vs. ~$2.26B), that gap is treated as the single most important finding in the market-sizing work, not smoothed over with a blended average. See [`docs/Market_Sizing_Methodology.md`](docs/Market_Sizing_Methodology.md) for the full reconciliation and the standing recommendation to underwrite investment decisions to the more conservative, bottom-up figure until primary data closes the gap.

## 9. Data Architecture

```
Excel Source Tables  →  SQL Layer (MySQL)  →  Python Analysis Layer  →  Excel Executive Workbook  →  Tableau (in progress)
   (12 tables)          (validation, market       (pandas/matplotlib,      (13-tab decision
                          sizing, competitive       scenario modeling,       workbook)
                          concentration, unit        NPV/IRR, sensitivity)
                          economics, decision
                          views)
```

The SQL layer is the single source of truth for every raw metric; the Python notebooks consume the same source tables independently (via `../DATA/`) and re-derive every figure rather than importing pre-computed SQL outputs — a deliberate redundancy that lets the two layers cross-check each other. The Excel workbook is the executive-facing summary layer, built from the same underlying inputs.

## 10. Technology Stack

| Layer | Tools |
|---|---|
| Data validation & core analysis | SQL (MySQL syntax — window functions, CTEs, views) |
| Statistical & financial modeling | Python — pandas, NumPy, matplotlib/seaborn, `numpy_financial` (NPV/IRR) |
| Executive reporting | Excel (formula-driven workbook, 13 tabs) |
| Dashboarding | Tableau (in progress) |
| Environment | Jupyter Notebook |

## 11. SQL Analysis

`sql/GTM_Market_Entry_Strategy.sql` is organized into 8 sections that mirror the executive narrative, not just a dump of ad-hoc queries:

- **Section 0 — Database Setup:** schema and row-count validation before any analysis runs.
- **Section 1 — Market Sizing:** TAM→SAM→SOM waterfall, plus a top-down vs. bottom-up reconciliation query with a built-in `RECONCILED` / variance flag.
- **Section 2 — Competitive Landscape:** ranking by users and merchants, market share via window functions, a Herfindahl-Hirschman Index (HHI) concentration score, and CR3/CR5 concentration ratios.
- **Section 3 — Market & State Prioritization:** an opportunity index, `RANK()`/`DENSE_RANK()`/`ROW_NUMBER()` state rankings, and a 3-phase launch priority matrix.
- **Section 4 — Macro Market Context:** BNPL and UPI adoption metrics, and a compounded 3-/5-year market growth projection.
- **Section 5 — Unit Economics:** contribution margin and CAC payback period, computed with `CASE`-based metric pivots rather than hardcoded columns.
- **Section 6 — Scenario & Risk:** bear/base/bull revenue sensitivity, and a `MARKET_SIZING_VIEW` as the single source of truth for downstream queries.
- **Section 7 — Executive Dashboards & Decision:** a slide-ready KPI summary, an investment scorecard, and a rule-based GO / HOLD / NO-GO query.

Demonstrated technique: CTEs, window functions (`RANK`, `DENSE_RANK`, `ROW_NUMBER`, `SUM() OVER`), `CASE`-based conditional aggregation and metric pivoting, views, and self-documenting queries (every section opens with a stated business goal and business questions before any SQL runs).

## 12. Python Analysis

Three notebooks, each with a distinct executive audience and a stated business goal per section:

**[`01_market_landscape_analysis.ipynb`](notebooks/01_market_landscape_analysis.ipynb)** — Market Landscape (audience: Strategy/Founder's Office). Top-down vs. bottom-up TAM reconciliation, a composite State Attractiveness Score (40% population / 35% digital readiness / 25% whitespace), UPI infrastructure readiness, launch sequencing, and a fully logged Assumption Register.

**[`02_competitive_intelligence_dashboard.ipynb`](notebooks/02_competitive_intelligence_dashboard.ipynb)** — Competitive Intelligence (audience: CEO/Product Strategy). HHI market concentration, a competitive positioning bubble chart, a white-space opportunity scatter matrix, a full SWOT, Porter's Five Forces, an Impact-vs-Effort recommendation priority matrix, and a risk heatmap.

**[`03_opportunity_sizing_launch_strategy.ipynb`](notebooks/03_opportunity_sizing_launch_strategy.ipynb)** — Opportunity Sizing & Launch Strategy (audience: Board/Investment Committee). A clean 5-year financial model, NPV & IRR, bear/base/bull scenario analysis, default-rate and CAC sensitivity, a tornado chart isolating the single highest-leverage variable, and a weighted Go/Hold/No-Go decision matrix.

Each notebook ends with an Assumption Register (every non-source-data number, its confidence level, and what would replace it with primary data) and an Executive Summary written to be read standalone. This is the layer where the project's central finding — a negative NPV that the Excel workbook's simpler view does not surface — is derived; see [Business Insights](#22-business-insights).

## 13. Excel Dashboard

`data/GTM_Market_Entry_Strategy.xlsx` is a 15-tab, formula-driven workbook: 10 raw source-data tabs feeding an Executive Dashboard, a Launch Priority Matrix, a GTM Recommendation tab, and full Market Sizing and 5-year Financial Model tabs (revenue, acquisition cost, contribution margin, and a breakeven-user calculation, all as live formulas rather than pasted values). This is the format built for a one-page leadership readout — see [`docs/Technical_Documentation.md`](docs/Technical_Documentation.md) for the full tab-by-tab breakdown, including where the workbook's simpler "ENTER" read differs from the Python layer's cash-flow-tested "HOLD" read, and why.

## 14. Tableau Dashboard

**Tableau Dashboard — In Progress.** A companion interactive dashboard (state-level launch map, competitive positioning, and scenario toggle) is planned to sit alongside the Excel workbook as the shareable, filterable version of the same analysis. This section will be updated with a published Tableau Public link once complete.

## 15. Market Sizing Framework (TAM / SAM / SOM)

| Measure | Method | Value | Note |
|---|---|---|---|
| TAM (top-down) | India digital lending ($45B) × BNPL share (18%) | **$8.1B**, growing to $17.0B by 2027 (28% CAGR) | Headline market-report figure |
| TAM (bottom-up) | Population → urban → age-band → digital → income funnel | **~$2.26B** | Independently reconstructed; see reconciliation query, Section 1 |
| SAM | TAM × addressable share (~55%) | ~$4.5B (top-down basis) | Digitally/economically reachable segment |
| SOM Year 1 → 5 | SAM × modeled capture curve (0.5% → 14%) | $40.5M → $1,134M (top-down basis) | Used for the 5-year revenue forecast |

The **72% gap (~3.6x) between the top-down and bottom-up TAM is the single most important market-sizing finding in this project.** Full detail, including the specific assumptions driving the gap (BNPL adoption rate among the addressable population, average annual spend per user) and what primary data would close it, is in [`docs/Market_Sizing_Methodology.md`](docs/Market_Sizing_Methodology.md) — which also documents a second, related finding: the Excel, SQL, and Python layers each run a *different* bottom-up build (using different population bases and a 14x-different revenue-per-user assumption), and the three don't converge on one number. The $2.26B Python figure is the one used throughout this project because its inputs are the most fully traceable; standardizing all three into one method is logged under [Future Enhancements](#30-future-enhancements).

## 16. Customer Segmentation

Five segments were scored by priority using age, income band, and credit-market positioning:

| Segment | Age | Income | Priority |
|---|---|---|---|
| New-to-Credit Users | 18–35 | Any | **Very High** |
| Young Professionals | 22–35 | ₹25k–80k | High |
| Salaried Millennials | 25–40 | ₹40k–120k | High |
| Students | 18–24 | <₹25k | Medium |
| Gig Workers | 20–40 | Variable | Medium |

**New-to-Credit Users** is the recommended lead segment — not because it's the largest, but because it's the only Very-High-priority segment that is also structurally underserved: incumbents with entrenched merchant ecosystems (Amazon Pay Later, Flipkart Pay Later) compete hardest for Young Professionals, leaving New-to-Credit Users as the clearest competitive whitespace. This is also, correctly, flagged as the highest-default-risk segment — see [Strategic Risk Assessment](#20-strategic-risk-assessment).

## 17. Merchant Segmentation

| Segment | Priority |
|---|---|
| Electronics | **Very High** |
| Fashion | High |
| Travel | High |
| Healthcare | Medium |
| Grocery | Medium |
| Food Delivery | Medium |
| Education | Medium |

Electronics is prioritized for merchant acquisition alongside the New-to-Credit customer push — high average order values suit BNPL's economics, and it's an aggressive acquisition category for market leader competitors, making it a productive early battleground rather than a passive category.

## 18. Competitive Landscape

Six tracked competitors span two structural types:

| Competitor | Type | Users (M) | Merchants | Strength |
|---|---|---|---|---|
| Bajaj Finance | EMI | 88 | 190,000 | Scale |
| Amazon Pay Later | BNPL | 20 | 30,000 | Ecosystem |
| Flipkart Pay Later | BNPL | 18 | 50,000 | Marketplace |
| ZestMoney | BNPL | 17 | 10,000 | EMI Financing |
| Simpl | BNPL | 12 | 26,000 | Checkout UX |
| LazyPay | BNPL | 10 | 20,000 | Consumer Credit |

The BNPL-specific HHI score is **2,124 — moderately concentrated**, not highly concentrated. That single number is the analytical basis for treating this as a contestable, not closed, market — and for the SWOT and Porter's Five Forces analyses (`notebooks/02_...ipynb`) converging on a segment-first entry strategy rather than a head-on feature fight with incumbents who already hold 30,000–190,000-merchant networks.

## 19. Unit Economics

| Metric | Value |
|---|---|
| Average Transaction | ₹3,500 |
| Transactions / User / Year | 8 |
| MDR (take rate) | 2.5% |
| Revenue / User / Year | ₹700 |
| CAC | ₹400 (declining to ₹250 by Year 5) |
| Gross Margin | 65% |
| Default Rate | 3.0% (base case) |
| Contribution Margin / User | ₹255 |
| CAC Payback Period | ~19 months at base-case volumes |

The model clears contribution margin at the unit level and reaches a **contribution-margin breakeven around Year 3** (~784K users). Carried through to a full cash-flow basis in the DCF model — which nets out CAC and fixed costs, not just contribution margin — the picture changes materially; see [Financial Impact](#24-financial-impact).

## 20. Strategic Risk Assessment

| Risk | Impact | Mitigation |
|---|---|---|
| RBI Regulation | High | Dedicated compliance team; track Digital Lending Guidelines evolution |
| Credit Default | High | Tiered/phased underwriting exposure, especially for New-to-Credit Users |
| Fraud | High | KYC + device-level checks |
| Data Breach | High | Encryption, data-privacy compliance program |
| Merchant Churn | Medium | Merchant incentive structuring |
| Customer Acquisition Cost | Medium | Referral-led growth to blend down paid CAC |
| Economic Slowdown | Medium | Conservative lending limits in downturns |

The **highest-heat risk is RBI regulatory tightening** — it compounds every other risk on this list (a stricter FLDG or KYC regime raises both compliance cost and effective CAC simultaneously) and is outside the company's control, which is why it anchors the risk heatmap in `notebooks/02_...ipynb` rather than being treated as a standard operating risk.

## 21. Analytical Methodology

The project deliberately runs two independent analytical passes rather than one:

1. **A top-down, headline-metrics pass** (the Excel workbook and the SQL layer's simpler queries) — fast, presentation-ready, and useful for a first-pass "is this worth investigating" screen.
2. **A bottom-up, assumption-logged pass** (the Python notebooks) — slower, more conservative, and explicitly designed to stress-test the first pass rather than simply restate it.

Every notebook closes with an **Assumption Register**: a table of every number that is not a direct pull from source data, its confidence level, and what primary data source would replace it. This is the project's core discipline — it treats "I don't know, here's my best estimate and here's how confident I am" as a more credible analytical stance than a single unqualified number, and it is the structure an interviewer can use to probe any figure in the project.

## 22. Business Insights

- **The top-down and bottom-up TAM disagree by ~3.6x.** That gap, not the $8.1B headline, is the material finding — and the recommendation is to underwrite the investment case to the conservative figure until it's closed with primary data.
- **The market is moderately concentrated (HHI 2,124), not saturated.** This is the evidence-based reason entry is treated as viable at all, replacing a qualitative "the market feels crowded" judgment with a quantitative one.
- **Population is a weak launch-sequencing signal on its own.** Uttar Pradesh and Bihar are both raw-population leaders but score lower on a blended Attractiveness Score once digital readiness is included — the sequencing model deliberately overrides population-only intuition.
- **Contribution-margin breakeven (Year 3) and cash-flow breakeven are not the same thing**, and the Excel workbook's simpler "Breakeven: Achieved" read does not hold once CAC and fixed costs are netted on a full cash-flow basis. Surfacing that gap — rather than letting the more favorable number stand unchallenged — is the single most consequential insight in the project.
- **The recommended segment (New-to-Credit Users) is also the highest-default-risk segment.** The opportunity and the risk are the same population, which is why phased underwriting limits, not a full-limit launch, are recommended.

## 23. Executive Recommendations

**Overall Read: HOLD — Conditional Go.**

The strategic case is strong: a 28% CAGR market, a moderately concentrated (not closed) competitive field, and a clearly identified whitespace segment. The financial case, as modeled, is not yet fundable at a standard 15% hurdle rate — Base and Bear scenarios are NPV-negative within the 5-year explicit forecast window, and IRR is not computable because cash flows don't turn positive in that window. **This is a horizon and unit-economics problem, not a market problem.**

Three conditions would move this from a Hold to a clean Go:

1. **Extend the model horizon or accelerate the user/CAC curve** — test whether Year 6–7 cash flows turn positive and whether that flips the NPV sign at a 15% hurdle rate.
2. **De-risk the default-rate margin of safety** — the unit economics model breaks roughly one point above the 3% base-case default rate, and the recommended entry segment is inherently higher-default-risk; phased underwriting limits are recommended specifically to protect this margin.
3. **Validate retention beyond Year 1** — the current LTV/CAC read is an explicitly-labeled single-year proxy; the investment case likely depends on multi-year retention the model does not yet have data to test.

**Recommended path:** proceed to a limited-capital pilot — not a full-capital launch — in the top Attractiveness-Score states, targeting the New-to-Credit Users segment, with UPI-rail distribution as the fastest, lowest-cost initial channel, generating the retention and default data needed to re-run this model with real inputs. Full detail, including the state-by-state phasing plan, is in [`docs/Executive_Recommendations.md`](docs/Executive_Recommendations.md).

## 24. Financial Impact

| Metric | Value |
|---|---|
| Year 5 Users (base case) | 2.5M |
| Year 5 Revenue | ₹175 Cr |
| Year 5 Contribution Margin | ₹63.75 Cr |
| Contribution-margin breakeven | ~Year 3 (~784K users) |
| Year-0 initial investment (est.) | ₹15 Cr (tech build + NBFC/regulatory setup) |
| NPV @ 15% discount rate (5-yr cash flow) | **–₹88.92 Cr** |
| IRR (5-yr window) | **Not computable** — cash flows never turn positive in-window |
| Weighted Go/Hold/No-Go decision score | 0.47 / 1.00 → **HOLD** |

The negative NPV is reported, not smoothed over, because a market-entry analysis that only ever confirms the thesis it started with isn't a real analysis — it's a pitch. Flagging the gap between a contribution-margin "breakeven achieved" read and a full free-cash-flow-negative read is the project's clearest demonstration of financial rigor.

## 25. Business Value

For a real organization, this project's value isn't the specific numbers (which are built on secondary/estimated data, honestly labeled as such) — it's the **decision framework**: two independent sizing methods cross-checked against each other, a quantitative rather than qualitative competitive-concentration read, a state-sequencing model that overrides naive population ranking, and a financial model that tests cash flow, not just contribution margin, before recommending capital deployment. That framework is directly reusable for any market-entry, new-product, or new-geography decision — the specific market (India BNPL) is the applied example, not the point.

## 26. Folder Structure

```
GTM-Market-Entry-Strategy/
├── README.md
├── data/
│   └── GTM_Market_Entry_Strategy.xlsx
├── sql/
│   └── GTM_Market_Entry_Strategy.sql
├── notebooks/
│   ├── 01_market_landscape_analysis.ipynb
│   ├── 02_competitive_intelligence_dashboard.ipynb
│   └── 03_opportunity_sizing_launch_strategy.ipynb
├── dashboards/
│   └── tableau/          # in progress
├── screenshots/
│   ├── excel/
│   └── notebooks/
└── docs/
    ├── Executive_Summary.md
    ├── Business_Problem.md
    ├── Market_Context.md
    ├── Business_Requirements.md
    ├── Market_Sizing_Methodology.md
    ├── Customer_Segmentation.md
    ├── Competitive_Analysis.md
    ├── Unit_Economics.md
    ├── Risk_Assessment.md
    ├── Business_Insights.md
    ├── Executive_Recommendations.md
    ├── Technical_Documentation.md
    └── Presentation_Guide.md
```

## 27. Repository Structure

The repository is organized to mirror the analytical pipeline, not the file types: `data/` and `sql/` are the source-of-truth layer, `notebooks/` is the analysis and modeling layer (numbered in the order they should be read), `dashboards/` and `screenshots/` are the presentation layer, and `docs/` holds the long-form write-up behind every README claim. This structure is intentional — a reviewer should be able to trace any number in the README back to the exact query, cell, or workbook tab that produced it.

## 28. Key Skills Demonstrated

- **Market sizing:** top-down and bottom-up TAM/SAM/SOM construction, with explicit cross-method reconciliation.
- **Competitive intelligence:** HHI and concentration-ratio analysis, SWOT, Porter's Five Forces, white-space mapping.
- **Financial modeling:** 5-year revenue/cost build, NPV and IRR, breakeven analysis, scenario and sensitivity (tornado) analysis.
- **SQL:** CTEs, window functions, conditional aggregation, views, schema validation.
- **Python analytics:** pandas-based data modeling, scenario simulation, data visualization, structured technical documentation.
- **Executive communication:** decision-ready dashboards, an explicit Go/Hold/No-Go framework, and board-level recommendation writing.
- **Analytical integrity:** assumption logging, and a willingness to report a finding (negative NPV) that complicates rather than confirms the initial thesis.

## 29. Challenges & Assumptions

The largest challenge in this project was structural, not technical: **secondary market data is directionally useful but not precise enough to underwrite a real investment decision on its own**, and the project's job was to be honest about that rather than paper over it with false precision. Every notebook logs this explicitly in its Assumption Register — for example, the BNPL adoption rate used in the bottom-up TAM (8%) and the average annual spend per user ($120) are both analyst judgment calls with no cited source, flagged as low-confidence and named as the first things to replace with primary data (a provider disclosure, an RBI report, or a primary survey). The discount rate (15%) and Year-0 investment (₹15 Cr) used in the DCF model are similarly labeled as reasonable-range estimates, not company-specific figures. Full registers are linked from [`docs/Executive_Recommendations.md`](docs/Executive_Recommendations.md) and each notebook.

## 30. Future Enhancements

- **Standardize the bottom-up TAM calculation across the Excel, SQL, and Python layers** — they currently use different population bases and a 14x-different revenue-per-user assumption ($120/yr vs. ₹700/yr), landing on three different results ($2.26B / $390M / a mislabeled ~$37M). See [`docs/Market_Sizing_Methodology.md`](docs/Market_Sizing_Methodology.md) for the full breakdown; this is the highest-priority data-quality fix in the project.
- Publish the Tableau dashboard (state-level launch map, competitive positioning, scenario toggle) referenced in Section 14.
- Extend the financial model to a 7–10 year horizon to test whether cash flows turn positive outside the current 5-year window, per Recommendation Condition 1.
- Replace the top 2–3 lowest-confidence assumptions (BNPL adoption rate, average annual spend/user) with primary or provider-disclosed data as it becomes available, and re-run the reconciliation.
- Add a Monte Carlo simulation layer over the scenario analysis to move from three discrete scenarios (bear/base/bull) to a full probability distribution on Year-3 and Year-5 revenue.
- Build a state-level default-rate model instead of a single national assumption, once regional credit-bureau data is accessible.

## 31. Screenshots

*(Add Excel workbook and notebook visualization screenshots to `screenshots/excel/` and `screenshots/notebooks/` and reference them here, e.g.:)*

```markdown
![Executive Dashboard](screenshots/excel/executive_dashboard.png)
![HHI Competitive Positioning](screenshots/notebooks/competitive_positioning.png)
![Tornado Chart — NPV Sensitivity](screenshots/notebooks/tornado_chart.png)
```

## 32. How to Run the Project

**SQL:**
```bash
# Load the 12 source tables into MySQL (or compatible RDBMS), then:
mysql -u <user> -p < sql/GTM_Market_Entry_Strategy.sql
```

**Python notebooks:**
```bash
pip install pandas numpy matplotlib seaborn numpy_financial jupyter
jupyter notebook notebooks/01_market_landscape_analysis.ipynb
# Run notebooks in numeric order — each is self-contained but follows the same narrative arc.
```

**Excel workbook:**
Open `data/GTM_Market_Entry_Strategy.xlsx` in Excel or LibreOffice Calc — all figures are formula-driven and will recalculate from the 10 source-data tabs.

## 33. Conclusion

This project set out to answer one question — should this company enter the Indian BNPL market — and refused to let a single attractive headline number (an $8.1B, 28%-CAGR TAM) answer it alone. By cross-checking market sizing methods, quantifying competitive concentration instead of asserting it, sequencing launch states on a blended readiness score, and carrying unit economics through to a real discounted cash flow model, the analysis surfaced a more complicated and more useful answer than "yes": a strategically sound but not-yet-fundable opportunity, with a specific, evidence-based path — a segment-first pilot — from Hold to Go. That is the standard the project was built to meet: not a recommendation an executive team would accept uncritically, but one they could stress-test line by line and still trust.

---
*Author: Sumit Kumar Gupta*
