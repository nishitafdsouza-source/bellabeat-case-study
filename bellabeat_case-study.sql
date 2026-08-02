select*
from `bellabeat_data.daily_activity`
limit 10;

select
count(*) as TotalRows
from `bellabeat_data.daily_activity`;

select
count(distinct Id) AS unique_users
FROM `bellabeat_data.daily_activity`;

select
min(ActivityDate) as start_date,
max(ActivityDate) AS end_date
from `bellabeat_data.daily_activity`;

SELECT
    column_name,
    data_type
FROM `bellabeat_data.INFORMATION_SCHEMA.COLUMNS`
WHERE table_name = 'daily_activity';

select 
Id, 
ActivityDate,
count(*) duplicates
from `bellabeat_data.daily_activity`
group by
Id,
ActivityDate
HAVING COUNT(*) > 1;

select
countif(Calories IS NULL) AS missing_calories,
countif(TotalSteps IS NULL) AS missing_steps,
COUNTIF(TotalDistance IS NULL) AS missing_distance,
countif(SedentaryMinutes is null) AS missing_sedentary
FROM `bellabeat_data.daily_activity`;

CREATE OR REPLACE TABLE `bellabeat_data.daily_activity_clean`
AS
SELECT *
FROM `bellabeat_data.daily_activity`
WHERE TotalSteps IS NOT NULL;

SELECT
ROUND(AVG(TotalSteps),2) AverageSteps,
MIN(TotalSteps) MinimumSteps,
MAX(TotalSteps) MaximumSteps,
ROUND(STDDEV(TotalSteps),2) StandardDeviation
FROM `bellabeat_data.daily_activity_clean`;

SELECT
ROUND(AVG(Calories),2) AverageCalories,
MIN(Calories) MinimumCalories,
MAX(Calories) MaximumCalories
FROM `bellabeat_data.daily_activity_clean`;

SELECT
ROUND(AVG(VeryActiveMinutes),2) VeryActive,
ROUND(AVG(FairlyActiveMinutes),2) FairlyActive,
ROUND(AVG(LightlyActiveMinutes),2) LightlyActive,
ROUND(AVG(SedentaryMinutes),2) Sedentary
FROM `bellabeat_data.daily_activity_clean`;

SELECT
Id,
TotalSteps,
CASE
WHEN TotalSteps < 5000 THEN 'Sedentary'
WHEN TotalSteps BETWEEN 5000 AND 7499 THEN 'Low Active'
WHEN TotalSteps BETWEEN 7500 AND 9999 THEN 'Somewhat Active'
ELSE 'Active'
END AS ActivityLevel
FROM `bellabeat_data.daily_activity_clean`;

WITH activity_level AS (
SELECT
CASE
WHEN TotalSteps < 5000 THEN 'Sedentary'
WHEN TotalSteps BETWEEN 5000 AND 7499 THEN 'Low Active'
WHEN TotalSteps BETWEEN 7500 AND 9999 THEN 'Somewhat Active'
ELSE 'Active'
END AS ActivityLevel
FROM `bellabeat_data.daily_activity_clean`
)
SELECT
ActivityLevel,
COUNT(*) Records
FROM activity_level
GROUP BY ActivityLevel
ORDER BY Records DESC;

SELECT
FORMAT_DATE('%A', ActivityDate) Weekday,
ROUND(AVG(TotalSteps),0) AvgSteps,
ROUND(AVG(Calories),0) AvgCalories,
ROUND(AVG(VeryActiveMinutes),1) AvgVeryActive,
ROUND(AVG(SedentaryMinutes),1) AvgSedentary
FROM `bellabeat_data.daily_activity_clean`
GROUP BY Weekday
ORDER BY
CASE Weekday
WHEN 'Monday' THEN 1
WHEN 'Tuesday' THEN 2
WHEN 'Wednesday' THEN 3
WHEN 'Thursday' THEN 4
WHEN 'Friday' THEN 5
WHEN 'Saturday' THEN 6
ELSE 7
END;

SELECT
ROUND(AVG(TotalMinutesAsleep),1) AverageSleep,
ROUND(AVG(TotalTimeInBed),1) AverageTimeInBed
FROM `bellabeat_data.sleep_day`;

SELECT
CASE
WHEN TotalMinutesAsleep < 360 THEN 'Poor'
WHEN TotalMinutesAsleep BETWEEN 360 AND 480 THEN 'Adequate'
ELSE 'Excellent'
END SleepQuality,
COUNT(*) Users
FROM `bellabeat_data.sleep_day`
GROUP BY SleepQuality;

CREATE OR REPLACE TABLE
`bellabeat_data.activity_sleep`
AS
SELECT
a.Id,
a.ActivityDate,
a.TotalSteps,
a.Calories,
s.TotalMinutesAsleep,
s.TotalTimeInBed
FROM `bellabeat_data.daily_activity_clean` a
LEFT JOIN `bellabeat_data.sleep_day` s
ON
a.Id=s.Id
AND a.ActivityDate=DATE(s.SleepDay);

SELECT
ROUND(AVG(TotalSteps),0) AverageSteps,
ROUND(AVG(TotalMinutesAsleep),0) AverageSleep
FROM `bellabeat_data.activity_sleep`;

SELECT
EXTRACT(HOUR FROM ActivityHour) Hour,
ROUND(AVG(StepTotal),1) AverageSteps
FROM `bellabeat_data.hourly_steps`
GROUP BY Hour
ORDER BY Hour;

SELECT
Id,
ROUND(AVG(TotalSteps),0) AverageSteps,
RANK() OVER(ORDER BY AVG(TotalSteps) DESC) ActivityRank
FROM `bellabeat_data.daily_activity_clean`
GROUP BY Id
ORDER BY ActivityRank
LIMIT 10;

CREATE OR REPLACE VIEW
`bellabeat_data.weekday_summary`
AS
SELECT
FORMAT_DATE('%A',ActivityDate) Weekday,
ROUND(AVG(TotalSteps),0) AvgSteps,
ROUND(AVG(Calories),0) AvgCalories,
ROUND(AVG(VeryActiveMinutes),1) AvgVeryActive
FROM `bellabeat_data.daily_activity_clean`
GROUP BY Weekday;

CREATE OR REPLACE VIEW
`bellabeat_data.marketing_dashboard`
AS
SELECT
FORMAT_DATE('%A',ActivityDate) Weekday,
COUNT(*) Records,
ROUND(AVG(TotalSteps),0) AvgSteps,
ROUND(AVG(Calories),0) AvgCalories,
ROUND(AVG(SedentaryMinutes),1) AvgSedentary
FROM `bellabeat_data.daily_activity_clean`
GROUP BY Weekday;