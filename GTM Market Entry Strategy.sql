/*==========================================================
PROJECT  : GTM Market Entry Strategy
AUTHOR   : Sumit Kumar Gupta
DATABASE : GTM_MARKET_ENTRY

OBJECTIVE: Evaluate India's BNPL (Buy Now Pay Later) market opportunity end-to-end — market sizing, competitive landscape,
state-level launch prioritization, macro market context, unit economics, and scenario/risk analysis — to support a data-driven 
GO / NO-GO market entry decision.

CONTENTS:
  SECTION 0  - Database Setup
  SECTION 1  - Market Sizing (TAM / SAM / SOM)
  SECTION 2  - Competitive Landscape
  SECTION 3  - Market & State Prioritization
  SECTION 4  - Macro Market Context (BNPL / UPI)
  SECTION 5  - Unit Economics & Financial Viability
  SECTION 6  - Scenario Analysis & Risk
  SECTION 7  - Executive Dashboards & Decision

SCHEMA NOTES:
  STATE_DATA        (STATE, POPULATION_M)
  COMPETITORS        (COMPETITOR, TYPE, USERS_M, MERCHANTS, STRENGTH)
                      TYPE expected values: 'BNPL' or 'EMI'
  BNPL_MARKET        (METRIC, VALUE)   -- macro BNPL market metrics
  UPI_DATA           (METRIC, VALUE)   -- UPI adoption funnel metrics
  POPULATION         (METRIC, VALUE)   -- national population metrics
  RBI_DATA           (METRIC, VALUE)   -- regulatory / RBI metrics
  RISK_REGULATION    (RISK_FACTOR, SEVERITY_SCORE)  -- 1-10 scale
  CUSTOMER_SEGMENTS  (SEGMENT, SEGMENT_SIZE_M, AVG_TICKET_SIZE)
  MERCHANT_SEGMENTS  (SEGMENT, MERCHANT_COUNT, AVG_GMV_PER_MERCHANT)
  UNIT_ECONOMICS     (METRIC, VALUE)   -- CAC_USD, AOV_USD, TAKE_RATE_PCT,
                                           VARIABLE_COST_PCT, DEFAULT_RATE_PCT,
                                           FIXED_COST_USD_MN,
                                           ORDERS_PER_CUSTOMER_PER_YEAR
==========================================================*/
/*==========================================================
SECTION 0 — DATABASE SETUP
Business Goal:
  Initialize the database and confirm all source tables are
  present and populated before running any analysis.
Business Questions:
  1. Does the database and schema exist?
  2. Are all expected tables populated with data?
==========================================================*/
CREATE DATABASE IF NOT EXISTS GTM_MARKET_ENTRY;
USE GTM_MARKET_ENTRY;
SHOW TABLES;
SELECT COUNT(*) AS ROW_COUNT FROM UPI_DATA;
SELECT COUNT(*) AS ROW_COUNT FROM POPULATION;
SELECT COUNT(*) AS ROW_COUNT FROM STATE_DATA;
SELECT COUNT(*) AS ROW_COUNT FROM COMPETITORS;
SELECT COUNT(*) AS ROW_COUNT FROM BNPL_MARKET;
SELECT COUNT(*) AS ROW_COUNT FROM CUSTOMER_SEGMENTS;
SELECT COUNT(*) AS ROW_COUNT FROM MERCHANT_SEGMENTS;
SELECT COUNT(*) AS ROW_COUNT FROM UNIT_ECONOMICS;
SELECT COUNT(*) AS ROW_COUNT FROM RBI_DATA;
SELECT COUNT(*) AS ROW_COUNT FROM RISK_REGULATION;

/*==========================================================
SECTION 1 — MARKET SIZING (TAM / SAM / SOM)
Business Goal:
  Size the opportunity from source data rather than hardcoded
  guesses, and confirm the sizing logic is internally
  consistent (SOM inside SAM inside TAM).
Business Questions:
  1. What is our total, serviceable, and obtainable market?
  2. Does a bottom-up, state-level estimate reconcile with
     the top-down TAM figure, or does it expose a sizing risk?
==========================================================*/
/* TAM → SAM → SOM Waterfall */

SELECT 'TAM' AS MARKET_LEVEL, 8100 AS VALUE_USD_MN
UNION ALL
SELECT 'SAM', ROUND(8100 * 0.55,2)
UNION ALL
SELECT 'SOM_YEAR_1', ROUND(8100 * 0.55 * 0.003,2)
UNION ALL
SELECT 'SOM_YEAR_3', ROUND(8100 * 0.55 * 0.027,2)
UNION ALL
SELECT 'SOM_YEAR_5', ROUND(8100 * 0.55 * 0.095,2)
UNION ALL
SELECT '2027_TAM',17000;

/* Top-Down vs Bottom-Up Market Sizing Reconciliation */
SELECT
(SELECT VALUE FROM BNPL_MARKET
WHERE METRIC = 'BNPL TAM ($B)') * 1000 AS TOP_DOWN_TAM_USD_MN,
ROUND(SUM(population_m) * 0.05 * 700 / 1000,2) AS BOTTOM_UP_TAM_USD_MN,
ROUND((ABS(((SELECT VALUE FROM BNPL_MARKET
WHERE METRIC = 'BNPL TAM ($B)') * 1000)-(SUM(population_m) * 0.05 * 700 / 1000)) * 100) /
((SELECT VALUE FROM BNPL_MARKET
WHERE METRIC = 'BNPL TAM ($B)') * 1000),2) AS VARIANCE_PCT,
CASE WHEN
ABS(((SELECT VALUE FROM BNPL_MARKET
WHERE METRIC = 'BNPL TAM ($B)') * 1000)-(SUM(population_m) * 0.05 * 700 / 1000)) * 100/
((SELECT VALUE FROM BNPL_MARKET
WHERE METRIC = 'BNPL TAM ($B)') * 1000)<= 15
THEN 'RECONCILED'
ELSE 'REVIEW ASSUMPTIONS'
 END AS RECONCILIATION_STATUS
FROM STATE_DATA;
/*==========================================================
SECTION 2 — COMPETITIVE LANDSCAPE
Business Goal:
  Map who we are competing against, how concentrated the
  market is, and where the competitive white space sits.
Business Questions:
  1. Who are the leading players by users, merchants, and
     implied scale?
  2. How concentrated is the BNPL-specific market (HHI, CR3/CR5)?
  3. Which competitors pose the highest competitive threat?
==========================================================*/
/* Total Competitors */
SELECT COUNT(*) AS TOTAL_COMPETITORS FROM COMPETITORS;

/* Competitor Ranking by Users */
SELECT COMPETITOR, USERS_M
FROM COMPETITORS
ORDER BY USERS_M DESC;

/* Competitor Ranking by Merchant Network */
SELECT COMPETITOR, MERCHANTS
FROM COMPETITORS
ORDER BY MERCHANTS DESC;

/* BNPL vs EMI Player Split */
SELECT TYPE, COUNT(*) AS TOTAL_PLAYERS
FROM COMPETITORS
GROUP BY TYPE;

/* Average Competitor User Base */
SELECT ROUND(AVG(USERS_M), 2) AS AVG_USERS_M
FROM COMPETITORS;

/* Competitor Rank (Window Function) */
SELECT
    COMPETITOR,
    USERS_M,
    RANK() OVER (ORDER BY USERS_M DESC) AS USER_RANK
FROM COMPETITORS;

/* Market Share — Users, Merchants, and Blended Scale Index */
SELECT
    COMPETITOR,
    USERS_M,
    ROUND(USERS_M * 100.0 / SUM(USERS_M) OVER (), 2) AS USER_SHARE_PCT,
    MERCHANTS,
    ROUND(MERCHANTS * 100.0 / SUM(MERCHANTS) OVER (), 2) AS MERCHANT_SHARE_PCT,
    ROUND((USERS_M * MERCHANTS) * 100.0 / SUM(USERS_M * MERCHANTS) OVER (), 2) AS SCALE_INDEX_SHARE_PCT
FROM COMPETITORS
ORDER BY USER_SHARE_PCT DESC;

/* White Space Analysis — Users per Merchant */
SELECT
    COMPETITOR,
    USERS_M,
    MERCHANTS,
    ROUND(USERS_M / MERCHANTS, 2) AS USERS_PER_MERCHANT
FROM COMPETITORS
ORDER BY USERS_PER_MERCHANT DESC;

/* Competitive Threat Tiering */
SELECT
    COMPETITOR,
    USERS_M,
    MERCHANTS,
    CASE
        WHEN USERS_M > 50 THEN 'HIGH THREAT'
        WHEN USERS_M > 15 THEN 'MEDIUM THREAT'
        ELSE 'LOW THREAT'
    END AS COMPETITIVE_THREAT
FROM COMPETITORS
ORDER BY USERS_M DESC;

/* HHI Market Concentration — BNPL Players Only */
WITH BNPL_ONLY AS (
    SELECT COMPETITOR, USERS_M
    FROM COMPETITORS
    WHERE TYPE = 'BNPL'
),
MARKET_SHARE AS (
    SELECT
        COMPETITOR,
        USERS_M,
        USERS_M / SUM(USERS_M) OVER () AS SHARE
    FROM BNPL_ONLY
)
SELECT
    ROUND(SUM(POWER(SHARE, 2)) * 10000, 0) AS HHI_SCORE,
    CASE
        WHEN ROUND(SUM(POWER(SHARE, 2)) * 10000, 0) < 1500 THEN 'COMPETITIVE MARKET'
        WHEN ROUND(SUM(POWER(SHARE, 2)) * 10000, 0) BETWEEN 1500 AND 2500 THEN 'MODERATELY CONCENTRATED'
        ELSE 'HIGHLY CONCENTRATED'
    END AS MARKET_STRUCTURE
FROM MARKET_SHARE;

/* Concentration Ratios — CR3 / CR5 */
WITH RANKED AS (SELECT COMPETITOR,USERS_M,
ROUND(USERS_M * 100.0 / SUM(USERS_M) OVER (), 2) AS SHARE_PCT,
ROW_NUMBER() OVER (ORDER BY USERS_M DESC) AS RNK
FROM COMPETITORS
WHERE TYPE = 'BNPL')
SELECT
    ROUND(SUM(CASE WHEN RNK <= 3 THEN SHARE_PCT END), 2) AS CR3_PCT,
    ROUND(SUM(CASE WHEN RNK <= 5 THEN SHARE_PCT END), 2) AS CR5_PCT
FROM RANKED;

/* Competitor Strength Mapping */
SELECT COMPETITOR, STRENGTH
FROM COMPETITORS
ORDER BY USERS_M DESC;


/*==========================================================
SECTION 3 — MARKET & STATE PRIORITIZATION
Business Goal:
  Rank Indian states by launch attractiveness and sequence a
  phased rollout, moving beyond population as the only signal.
Business Questions:
  1. Which states are the largest, and which are the top 5
     launch candidates by population?
  2. When digital readiness and merchant density are blended
     in, does the state ranking change?
  3. What revenue potential and launch phase does each state
     carry?
==========================================================*/
/* State Market Ranking */
SELECT STATE, POPULATION_M
FROM STATE_DATA
ORDER BY POPULATION_M DESC;

/* Top 5 Launch Markets */
SELECT STATE, POPULATION_M
FROM STATE_DATA
ORDER BY POPULATION_M DESC
LIMIT 5;

/* State Opportunity Index (vs. national average) */
SELECT STATE,POPULATION_M,
ROUND(POPULATION_M / (SELECT AVG(POPULATION_M) FROM STATE_DATA), 2) AS OPPORTUNITY_INDEX
FROM STATE_DATA
ORDER BY OPPORTUNITY_INDEX DESC;

/* State Opportunity Ranking */

SELECT STATE, POPULATION_M,
ROUND(POPULATION_M /(SELECT MAX(POPULATION_M) FROM STATE_DATA),3
)AS OPPORTUNITY_SCORE
FROM STATE_DATA
ORDER BY OPPORTUNITY_SCORE DESC;

/* Launch Priority Matrix — Rank + Phase */
WITH SCORED AS (
    SELECT
        STATE,
        POPULATION_M,
        ROUND(POPULATION_M / (SELECT AVG(POPULATION_M) FROM STATE_DATA), 2) AS OPPORTUNITY_SCORE
    FROM STATE_DATA
)
SELECT
    STATE,
    POPULATION_M,
    OPPORTUNITY_SCORE,
    ROW_NUMBER() OVER (ORDER BY OPPORTUNITY_SCORE DESC) AS LAUNCH_PRIORITY_RANK,
    CASE
        WHEN POPULATION_M >= 100 THEN 'PHASE 1'
        WHEN POPULATION_M >= 70 THEN 'PHASE 2'
        ELSE 'PHASE 3'
    END AS LAUNCH_PHASE
FROM SCORED
ORDER BY LAUNCH_PRIORITY_RANK;

/* Revenue Potential by State */
SELECT
    STATE,
    POPULATION_M,
    ROUND(POPULATION_M * 0.05, 2) AS TARGET_USERS_M,
    ROUND(POPULATION_M * 0.05 * 700, 0) AS POTENTIAL_REVENUE_MN
FROM STATE_DATA
ORDER BY POTENTIAL_REVENUE_MN DESC;

/* State Attractiveness — Dense Rank */
SELECT
    STATE,
    POPULATION_M,
    DENSE_RANK() OVER (ORDER BY POPULATION_M DESC) AS MARKET_RANK
FROM STATE_DATA;

/* Launch Priority — Row Number */
SELECT
    STATE,
    POPULATION_M,
    ROW_NUMBER() OVER (ORDER BY POPULATION_M DESC) AS LAUNCH_PRIORITY
FROM STATE_DATA;


/*==========================================================
SECTION 4 — MACRO MARKET CONTEXT (BNPL / UPI)
Business Goal:
  Ground the analysis in the macro backdrop the business is
  entering — market size today, digital rails adoption, and
  the trajectory the market is on.
Business Questions:
  1. What does the BNPL market look like today, and what is
     the UPI adoption funnel?
  2. At the market's implied historical CAGR, what does the
     3-year and 5-year trajectory look like?
==========================================================*/
/* BNPL Market — TAM Metrics */
SELECT METRIC, VALUE
FROM BNPL_MARKET
WHERE METRIC LIKE '%TAM%';

/* BNPL Market Summary */
SELECT METRIC, VALUE
FROM BNPL_MARKET;

/* UPI Adoption Funnel */
SELECT METRIC, VALUE
FROM UPI_DATA;

/* BNPL Market Growth Projection */
SELECT
    VALUE AS CURRENT_MARKET_USD_BN,
    28 AS CAGR_PCT,
    ROUND(VALUE * POWER(1.28, 3), 2) AS PROJECTED_2028_USD_BN,
    ROUND(VALUE * POWER(1.28, 5), 2) AS PROJECTED_2030_USD_BN
FROM BNPL_MARKET
WHERE METRIC = '2027 TAM ($B)';

/*==========================================================
SECTION 5 — UNIT ECONOMICS & FINANCIAL VIABILITY
Business Goal:
  Establish whether the business model is fundamentally
  viable at the transaction level, and tie market sizing to
  an actual revenue forecast.
Business Questions:
  1. What is our contribution margin per transaction?
  2. How many orders does a customer need to place before CAC
     is recovered?
  3. How many active users are needed nationally to cover
     fixed costs?
  4. What does the 5-year revenue forecast look like, tied
     directly to the SOM capture curve?
==========================================================*/
/* Contribution Margin per User */
SELECT
    MAX(CASE WHEN Metric = 'Revenue/User/Year INR' THEN Value END) AS REVENUE_PER_USER_INR,
    MAX(CASE WHEN Metric = 'CAC INR' THEN Value END) AS CAC_INR,
    MAX(CASE WHEN Metric = 'Default Rate %' THEN Value END) AS DEFAULT_RATE_PCT,
    MAX(CASE WHEN Metric = 'Contribution Margin INR' THEN Value END) AS CONTRIBUTION_MARGIN_INR
FROM UNIT_ECONOMICS;

/* CAC Payback Period */
WITH UE AS (SELECT MAX(CASE WHEN Metric = 'CAC INR' THEN Value END) AS CAC_INR,
MAX(CASE WHEN Metric = 'Contribution Margin INR' THEN Value END) AS CONTRIBUTION_MARGIN_INR,
MAX(CASE WHEN Metric = 'Transactions/User/Year' THEN Value END) AS TRANSACTIONS_PER_YEAR
FROM UNIT_ECONOMICS)
SELECT CAC_INR,CONTRIBUTION_MARGIN_INR,
CEIL(CAC_INR / CONTRIBUTION_MARGIN_INR) AS TRANSACTIONS_TO_PAYBACK,
ROUND(CEIL(CAC_INR / CONTRIBUTION_MARGIN_INR)/ TRANSACTIONS_PER_YEAR * 12,1) AS PAYBACK_PERIOD_MONTHS FROM UE;

/* CAC Payback Period */
SELECT MAX(CASE WHEN Metric='CAC INR' THEN Value END) AS CAC_INR,
MAX(CASE WHEN Metric='Contribution Margin INR' THEN Value END) AS CONTRIBUTION_MARGIN_INR,
CEIL(MAX(CASE WHEN Metric='CAC INR' THEN Value END)/MAX(CASE WHEN Metric='Contribution Margin INR' THEN Value END)
) AS ORDERS_TO_PAYBACK,
ROUND(CEIL(MAX(CASE WHEN Metric='CAC INR' THEN Value END)/MAX(CASE WHEN Metric='Contribution Margin INR' THEN Value END))/
MAX(CASE WHEN Metric='Transactions/User/Year' THEN Value END)* 12,1) AS PAYBACK_MONTHS
FROM UNIT_ECONOMICS;

/*==========================================================
SECTION 6 — SCENARIO ANALYSIS & RISK
Business Goal:
  Stress-test the revenue forecast against adoption
  uncertainty, and quantify overall market entry risk across
  regulatory, competitive, and unit-economics dimensions.
Business Questions:
  1. How sensitive is Year-3 revenue to bear / base / bull
     adoption assumptions?
==========================================================*/
/* Bear / Base / Bull Revenue Sensitivity */
SELECT 'BEAR' AS SCENARIO,1.5 AS SOM_CAPTURE_PCT,
ROUND((SELECT Value FROM BNPL_MARKET
WHERE Metric='2027 TAM ($B)')
* 0.015 * 1000,2) AS REVENUE_INR_MN
UNION ALL
SELECT 'BASE',2.7,
ROUND(
(SELECT Value FROM BNPL_MARKET
WHERE Metric='2027 TAM ($B)')* 0.027 * 1000,2)
UNION ALL
SELECT'BULL',4.5,
ROUND(
(SELECT Value
FROM BNPL_MARKET
WHERE Metric='2027 TAM ($B)')* 0.045 * 1000,2);

 /*CENTRAL MARKET SIZING VIEW Single source of truth for TAM / SAM / SOM*/
CREATE OR REPLACE VIEW MARKET_SIZING_VIEW AS
SELECT
    MAX(CASE WHEN Metric='TAM_USD_MN' THEN Value END) AS TAM_USD_MN,
    MAX(CASE WHEN Metric='SAM_USD_MN' THEN Value END) AS SAM_USD_MN,
    MAX(CASE WHEN Metric='SOM_YEAR5_USD_MN' THEN Value END) AS SOM_YEAR5_USD_MN
FROM BNPL_MARKET;

/*==========================================================
SECTION 7 — EXECUTIVE DASHBOARDS & DECISION
Business Goal:
  Package every finding above into decision-ready dashboards,
  culminating in an explicit, gate-based GO / NO-GO market
  entry recommendation.
==========================================================*/
/* Executive GTM Dashboard */
SELECT
    (SELECT COUNT(*) FROM COMPETITORS) AS TOTAL_COMPETITORS,
    (SELECT MAX(USERS_M) FROM COMPETITORS) AS MARKET_LEADER_USERS_M,
    (SELECT MAX(POPULATION_M) FROM STATE_DATA) AS LARGEST_STATE_POPULATION_M,
    (SELECT AVG(USERS_M) FROM COMPETITORS) AS AVG_COMPETITOR_USERS_M;

/* Single-Row KPI Summary (Slide-Ready) */
SELECT 'Total Competitors (BNPL)' AS KPI, CAST((SELECT COUNT(*) FROM COMPETITORS WHERE TYPE = 'BNPL') AS CHAR) AS VALUE
UNION ALL
SELECT 'Market Leader Users (M)', CAST((SELECT MAX(USERS_M) FROM COMPETITORS) AS CHAR)
UNION ALL
SELECT 'Largest State Population (M)', CAST((SELECT MAX(POPULATION_M) FROM STATE_DATA) AS CHAR)
UNION ALL
SELECT 'TAM (USD MN)', CAST((SELECT VALUE FROM BNPL_MARKET WHERE METRIC = 'TAM_USD_MN') AS CHAR)
UNION ALL
SELECT 'UPI Active User %', CAST((SELECT VALUE FROM UPI_DATA WHERE METRIC = 'UPI_ACTIVE_USER_PCT') AS CHAR)
UNION ALL
SELECT 'CAC (USD)', CAST((SELECT VALUE FROM UNIT_ECONOMICS WHERE METRIC = 'CAC_USD') AS CHAR);

/*Executive Investment Scorecard*/
SELECT 'BNPL TAM (USD MN)' AS KPI,
TAM_USD_MN AS Value,
CASE
WHEN TAM_USD_MN >= 8000 THEN 'PASS'
ELSE 'REVIEW'
END AS Status
FROM MARKET_SIZING_VIEW
UNION ALL
SELECT 'Top BNPL Users (M)',
MAX(Users_M),
'INFO'
FROM COMPETITORS
WHERE TYPE='BNPL'
UNION ALL
SELECT 'Total BNPL Competitors',
COUNT(*),
CASE
WHEN COUNT(*)<=10 THEN 'MODERATE'
ELSE 'HIGH'
END
FROM COMPETITORS
WHERE TYPE='BNPL';
/*GO / HOLD / NO-GO Recommendation*/
WITH DECISION AS
(SELECT
CASE
WHEN
(SELECT TAM_USD_MN FROM MARKET_SIZING_VIEW)>=8000
AND
(SELECT COUNT(*) FROM COMPETITORS
WHERE TYPE='BNPL')<=10
THEN 'GO'
WHEN
(SELECT TAM_USD_MN FROM MARKET_SIZING_VIEW)>=5000
THEN 'HOLD'
ELSE 'NO GO'
END AS Recommendation)
SELECT * FROM DECISION;

/*State Launch Priority Matrix*/
SELECT State,Population_M,
CASE WHEN Population_M>=100 THEN 'Phase 1'
WHEN Population_M>=70 THEN 'Phase 2'
ELSE 'Phase 3'
END AS Launch_Priority
FROM state_data
ORDER BY Population_M DESC;

/*Executive Risk Dashboard*/
SELECT 'Competition Risk' AS Risk,
CASE WHEN (SELECT COUNT(*) FROM competitors WHERE Type='BNPL')>=6
THEN 'Medium'
ELSE 'Low'
END AS Risk_Level,'Differentiate product & underwriting'
AS Recommendation
UNION ALL
SELECT 'Market Growth','Low','28% CAGR supports entry'
UNION ALL
SELECT 'Default Risk','Medium','Monitor credit underwriting'
UNION ALL
SELECT 'Regulatory Risk','High','Track RBI digital lending guidelines'; 
