# 📊 Bellabeat Consumer Health Data Analysis

> **Google Data Analytics Professional Certificate Capstone Project**  
> *Author:* Narayani SS  

---

## 📌 Executive Summary
Bellabeat manufactures health-focused smart products designed to empower women with personalized insights into their activity, sleep, and overall wellness. This analysis focuses on consumer usage data from smart fitness trackers (Fitbit) to identify behavioral patterns and recommend actionable marketing strategies for Bellabeat's digital ecosystem.

---

## 🎯 Business Task & Objectives
* **Primary Objective:** Uncover behavioral trends in physical activity, intensity levels, and daily habits using tracker records.
* **Goal:** Deliver data-backed marketing recommendations to optimize user engagement, product adoption, and campaign timing.
* **Key Stakeholders:** Urška Sršen (Chief Creative Officer & Co-founder), Sando Mur (Co-founder), and the Bellabeat Marketing Analytics team.

---

## 🛠️ Data Pipeline & Toolstack
* **Google Sheets:** Initial profiling, duplicate elimination, trimming whitespace, standardizing datetime formatting.
* **Google BigQuery (SQL):** Aggregation, relational joins across 10 tables, user engagement classification, and hourly intensity breakdowns.
* **Tableau / Datawrapper:** Multi-variable correlation plots and time-series activity distributions.

---

## 🔍 Analytical Process

### 1. Data Cleaning & Integrity Checks
* **Dataset Constraints:** Evaluated a 30-user public Fitbit tracking dataset collected via Amazon Mechanical Turk. Identified limitations including small sample size, absence of demographic data (age/gender), and time-bound records.
* **Filtering & Joins:**
  * Verified that `DailyCalories`, `DailyIntensities`, and `DailySteps` matched the aggregated `DailyActivity` table across all 940 records using `FULL OUTER JOIN` checks on `Id` and `ActivityDate`.
  * Preserved full datasets for the 33 tracked users with comprehensive daily and hourly activity records.
* **Deduplication:** Dropped duplicate records across granular minute and sleep logs (e.g., removed 543 duplicate entries from minute sleep records).

### 2. SQL Transformations & Segmentation
* Segmented users based on tracking consistency:
```sql
SELECT 
    Id, 
    COUNT(Id) AS total_activities_records,
    CASE
        WHEN COUNT(Id) <= 10 THEN 'Less Active'
        WHEN COUNT(Id) BETWEEN 11 AND 20 THEN 'Moderately Active'
        WHEN COUNT(Id) > 20 THEN 'Highly Active'
    END AS Active_Status
FROM `FitBit_Fitness_Tracker.DailyActivity`
GROUP BY Id
ORDER BY Id;
