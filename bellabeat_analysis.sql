-- =====================================================================================
-- Project: Bellabeat Wellness Technology Case Study
-- Certification: Google Data Analytics Professional Certificate Capstone
-- Author: Narayani SS
-- Dialect: Google BigQuery Standard SQL
-- Description: End-to-end SQL transformation, data validation, and exploratory analysis
--              for Fitbit consumer fitness tracker data to inform Bellabeat marketing.
-- =====================================================================================

-- -------------------------------------------------------------------------------------
-- 1. DATA VALIDATION & RECONCILIATION
-- Objective: Confirm whether DailyCalories, DailyIntensities, and DailySteps tables
--            contain redundant data already captured in the aggregated DailyActivity table.
-- -------------------------------------------------------------------------------------

-- Check 1.1: Full Outer Join between DailyActivity and DailyCalories
-- Purpose: Verify if all (Id, Date) pairs and calorie numbers match across both tables.
SELECT 
    act.Id, 
    act.ActivityDate, 
    cal.ActivityDay, 
    act.TotalSteps, 
    cal.Calories 
FROM `FitBit_Fitness_Tracker_Nara.DailyActivity` act
FULL OUTER JOIN `FitBit_Fitness_Tracker_Nara.DailyCalories` cal
    ON act.Id = cal.Id
    AND act.ActivityDate = cal.ActivityDay;

-- Check 1.2: Full Outer Join between DailyActivity and DailyIntensities
-- Purpose: Verify intensity distance measures match DailyActivity records without orphans.
SELECT 
    act.Id, 
    act.ActivityDate, 
    int.ActivityDay, 
    act.TotalSteps, 
    int.VeryActiveDistance 
FROM `FitBit_Fitness_Tracker_Nara.DailyActivity` act
FULL OUTER JOIN `FitBit_Fitness_Tracker_Nara.DailyIntensities` int
    ON act.Id = int.Id
    AND act.ActivityDate = int.ActivityDay;

-- Check 1.3: Full Outer Join between DailyActivity and DailySteps
-- Purpose: Confirm that StepTotal in DailySteps is 100% identical to TotalSteps in DailyActivity.
SELECT 
    act.Id, 
    act.ActivityDate, 
    act.TotalSteps, 
    steps.StepTotal 
FROM `FitBit_Fitness_Tracker_Nara.DailyActivity` act
FULL OUTER JOIN `FitBit_Fitness_Tracker_Nara.DailySteps` steps
    ON act.Id = steps.Id
    AND act.ActivityDate = steps.ActivityDay;


-- -------------------------------------------------------------------------------------
-- 2. HOURLY TABLE ROW COUNT & INTEGRITY AUDITING
-- Objective: Verify row completeness and consistency across all three hourly tables.
--            Expected: 22,099 rows per table for the 33 unique users over the tracking month.
-- -------------------------------------------------------------------------------------

SELECT count(*) AS total_hourly_calories_rows 
FROM `FitBit_Fitness_Tracker_Nara.HourlyCalories`;

SELECT count(*) AS total_hourly_intensities_rows 
FROM `FitBit_Fitness_Tracker_Nara.HourlyIntensities`;

SELECT count(*) AS total_hourly_steps_rows 
FROM `FitBit_Fitness_Tracker_Nara.HourlySteps`;


-- -------------------------------------------------------------------------------------
-- 3. USER ENGAGEMENT & LOGGING CONSISTENCY
-- Objective: Quantify how frequently each user logged daily tracker activity.
-- -------------------------------------------------------------------------------------

-- Query 3.1: Logged Days per User (Sorted by frequency)
SELECT 
    Id, 
    COUNT(Id) AS total_activities_records 
FROM `FitBit_Fitness_Tracker_Nara.DailyActivity`
GROUP BY Id
ORDER BY total_activities_records DESC;

-- Query 3.2: User Engagement Segmentation (Active Status Bucketing)
-- Categorization logic:
--   - Less Active: <= 10 days
--   - Moderately Active: 11 to 20 days
--   - Highly Active: > 20 days (up to 31 days)
SELECT 
    Id, 
    COUNT(Id) AS total_activities_records,
    CASE
        WHEN COUNT(Id) <= 10 THEN 'Less Active'
        WHEN COUNT(Id) > 10 AND COUNT(Id) <= 20 THEN 'Moderately Active'
        WHEN COUNT(Id) > 20 AND COUNT(Id) <= 31 THEN 'Highly Active'
    END AS Active_Status
FROM `FitBit_Fitness_Tracker_Nara.DailyActivity`
GROUP BY Id 
ORDER BY Id;


-- -------------------------------------------------------------------------------------
-- 4. BEHAVIORAL TRENDS & TIME-BASED ANALYSIS
-- Objective: Replicate day-of-week and hourly intensity trends in SQL for export to BI.
-- -------------------------------------------------------------------------------------

-- Query 4.1: Day of Week Aggregation (Steps, Distance, Calories)
-- Purpose: Evaluates user activity across Sunday–Saturday cycles to locate drop-offs.
SELECT
    FORMAT_DATE('%A', ActivityDate) AS day_of_week,
    EXTRACT(DAYOFWEEK FROM ActivityDate) AS day_num,
    SUM(TotalSteps) AS sum_total_steps,
    ROUND(AVG(TotalSteps), 2) AS avg_total_steps,
    ROUND(AVG(TotalDistance), 2) AS avg_total_distance,
    ROUND(AVG(Calories), 2) AS avg_calories
FROM `FitBit_Fitness_Tracker_Nara.DailyActivity`
GROUP BY day_of_week, day_num
ORDER BY day_num;

-- Query 4.2: Hourly Intensity Breakdown Across the 24-Hour Cycle
-- Purpose: Uncovers diurnal peaks (12:00 PM and 5:00 PM - 7:00 PM) for targeted reminders.
SELECT
    EXTRACT(HOUR FROM ActivityHour) AS activity_hour,
    ROUND(AVG(TotalIntensity), 2) AS avg_intensity,
    ROUND(AVG(AverageIntensity), 4) AS avg_intensity_rate
FROM `FitBit_Fitness_Tracker_Nara.HourlyIntensities`
GROUP BY activity_hour
ORDER BY activity_hour ASC;