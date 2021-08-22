	### BELLABEAT CASE STUDY - EXAMINING AND CLEANING THE DATA
		

# Selecting distinct IDs to find number of unique participants with daily activity data
SELECT DISTINCT Id
FROM DailyActivity
# 33 unique IDs reported in DailyActivity table
;

# Selecting unique IDs in SleepLog table
SELECT DISTINCT Id 
FROM SleepLog
# 24 unique IDs reported in SleepLog table
;

# Selecting unique IDs in WeightLog table
SELECT DISTINCT Id 
FROM WeightLog
# 8 unique IDs reported in WeightLog table
;

# Finding start and end date of data tracked in DailyActivity table
SELECT MIN(ActivityDate) AS startDate, MAX(ActivityDate) AS endDate
FROM DailyActivity
# Start date 2016-4-12, end date 2016-5-12
;

# Finding start and end date of data tracked in SleepLog table
SELECT MIN(SleepDay) AS startDate, MAX(SleepDay) AS endDate
FROM SleepLog
# Start date 2016-4-12, end date 2016-5-12
;

# Finding start and end date of data tracked in WeightLog table
SELECT MIN(Date) AS startDate, MAX(Date) AS endDate
FROM WeightLog
# Start date 2016-4-12, end date 2016-5-12
;

# Finding duplicate rows, if any, in DailyActivity
SELECT ID, ActivityDate, COUNT(*) AS numRow
FROM DailyActivity
GROUP BY ID, ActivityDate # Each row is uniquely identified by the ID and ActivityDate colummns
HAVING numRow > 1
# No results, no duplicate rows in the DailyActivity table
;

# Finding duplicate rows, if any, in SleepLog
SELECT *, COUNT(*) AS numRow
FROM SleepLog
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING numRow > 1
# 3 duplicate rows returned
;

# Creating new SleepLog table with all distinct values
CREATE TABLE SleepLog2 SELECT DISTINCT * FROM SleepLog
;

# Double checking new table no longer has duplicate rows
SELECT *, COUNT(*) AS numRow
FROM SleepLog2
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING numRow > 1
# 0 duplicate rows returned in new table; duplicate rows deleted
;

# Dropping original SleepLog table; renaming new table
ALTER TABLE SleepLog RENAME junk
DROP TABLE IF EXISTS junk;
ALTER TABLE SleepLog2 RENAME SleepLog
;

# Finding duplicate rows, if any, in WeightLog table
SELECT *, COUNT(*) AS numRow
FROM WeightLog
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
HAVING numRow > 1
# 0 duplicate rows returned
;

# To make the column easier to understand, converting Boolean values in IsManualReport in WeightLog table to varchar "True" and "False"
ALTER TABLE WeightLog
MODIFY IsManualReport varchar(255)
;

UPDATE WeightLog
SET IsManualReport = 'True'
WHERE IsManualReport = '1'
;

UPDATE WeightLog
SET IsManualReport = 'False'
WHERE IsManualReport = '0'
;

# Double checking that all IDs in DailyActivity have the same number of characters
SELECT LENGTH(Id)
FROM DailyActivity
;

# Looking for IDs in DailyActivity with more or less than 10 characters
SELECT Id
FROM DailyActivity
WHERE LENGTH(Id) > 10 
OR LENGTH(Id) < 10
# No values returned; all IDs in DailyActivity have 10 characters
;

# Looking for IDs in SleepLog with more or less than 10 characters
SELECT Id
FROM SleepLog
WHERE LENGTH(Id) > 10 
OR LENGTH(Id) < 10
# No values returned; all IDs in SleepLog have 10 characters
;

# Looking for IDs in WeightLog with more or less than 10 characters
SELECT Id
FROM WeightLog
WHERE LENGTH(Id) > 10 
OR LENGTH(Id) < 10
# No values returned; all IDs in WeightLog have 10 characters
;

# Looking at LogIds in WeightLog table to determine if they are its primary key
SELECT LogId, COUNT(LogId) AS numLogIds
FROM WeightLog
GROUP BY LogId
HAVING numLogIds > 1
ORDER BY numLogIds DESC
# Ten LogIds have a count greater than 1, suggesting there are duplicates or that the LogId column does not contain the primary key to this table
;

# Looking at records with matching LogIds to see if they are duplicates
SELECT *
FROM WeightLog
WHERE LogId IN (
	SELECT LogId
	FROM WeightLog
	GROUP BY LogId
	HAVING COUNT(LogId) > 1
	)
ORDER BY LogId
# Matching LogIds occur on the same Date but don't have anything else in common
;

# Examining records with 0 in TotalSteps column of DailyActivity table
SELECT Id, COUNT(*) AS numZeroStepsDays
FROM DailyActivity
WHERE TotalSteps = 0
GROUP BY Id
ORDER BY numZeroStepsDays DESC
# 15 participants with zero-step days
;

# Examining total number of days (records) with zero steps
SELECT SUM(numZeroStepsDays) AS totalDaysZeroSteps
FROM (
	SELECT COUNT(*) AS numZeroStepsDays
	FROM DailyActivity
	WHERE TotalSteps = 0
	) AS z
# 77 records with zero steps
;

# Looking at all attributes of each zero-step day
SELECT *, ROUND((SedentaryMinutes / 60), 2) AS SedentaryHours
FROM DailyActivity
WHERE TotalSteps = 0
# While technically possible that these records reflect days that users were wholly inactive (most records returned in the above query claim 24 total hours of sedentary activity), they're more likely reflective of days the users didn't wear their FitBits, making the records potentially misleading
;

# Deleting rows where TotalSteps = 0; see above for explanation
DELETE FROM DailyActivity
WHERE TotalSteps = 0
;


	### BELLABEAT CASE STUDY - QUERIES
		

# Selecting dates and corresponding days of the week to identify weekdays and weekends
SELECT ActivityDate, DAYNAME(ActivityDate) AS DayOfWeek
FROM DailyActivity
;

SELECT ActivityDate, 
	CASE 
		WHEN DayOfWeek = 'Monday' THEN 'Weekday'
		WHEN DayOfWeek = 'Tuesday' THEN 'Weekday'
		WHEN DayOfWeek = 'Wednesday' THEN 'Weekday'
		WHEN DayOfWeek = 'Thursday' THEN 'Weekday'
		WHEN DayOfWeek = 'Friday' THEN 'Weekday'
		ELSE 'Weekend' 
	END AS PartOfWeek
FROM
	(SELECT *, DAYNAME(ActivityDate) AS DayOfWeek
	FROM DailyActivity) as temp
;

# Looking at average steps, distance, and calories on weekdays vs. weekends
SELECT PartOfWeek, AVG(TotalSteps) AS AvgSteps, AVG(TotalDistance) AS AvgDistance, AVG(Calories) AS AvgCalories
FROM 
	(SELECT *, 
		CASE 
			WHEN DayOfWeek = 'Monday' THEN 'Weekday'
			WHEN DayOfWeek = 'Tuesday' THEN 'Weekday'
			WHEN DayOfWeek = 'Wednesday' THEN 'Weekday'
			WHEN DayOfWeek = 'Thursday' THEN 'Weekday'
			WHEN DayOfWeek = 'Friday' THEN 'Weekday'
			ELSE 'Weekend'
		END AS PartOfWeek
	FROM
		(SELECT *, DAYNAME(ActivityDate) AS DayOfWeek
		FROM DailyActivity) as temp
	) as temp2
GROUP BY PartOfWeek
;

# Looking at average steps, distance, and calories per day of the week
SELECT DAYNAME(ActivityDate) AS DayOfWeek, AVG(TotalSteps) AS AvgSteps, AVG(TotalDistance) AS AvgDistance, AVG(Calories) AS AvgCalories
FROM DailyActivity
GROUP BY DayOfWeek
ORDER BY AvgSteps DESC
;

# Looking at average amount of time spent asleep and average time to fall asleep per day of the week
SELECT DAYNAME(SleepDay) AS DayOfWeek, AVG(TotalMinutesAsleep) AS AvgMinutesAsleep, AVG(TotalMinutesAsleep / 60) AS AvgHoursAsleep, AVG(TotalTimeInBed - TotalMinutesAsleep) AS AvgTimeInMinutesToFallAsleep
FROM SleepLog
GROUP BY DayOfWeek
ORDER BY AvgHoursAsleep DESC
;

# Left joining all 3 tables
SELECT *
FROM DailyActivity AS d 
LEFT JOIN SleepLog AS s
ON d.ActivityDate = s.SleepDay AND d.Id = s.Id
LEFT JOIN WeightLog AS w
ON s.SleepDay = w.Date AND s.Id = w.Id
ORDER BY d.Id, Date
;

# Inner joining all 3 tables
SELECT *
FROM DailyActivity AS d 
JOIN SleepLog AS s
ON d.ActivityDate = s.SleepDay AND d.Id = s.Id
JOIN WeightLog AS w
ON s.SleepDay = w.Date AND s.Id = w.Id
ORDER BY d.Id, Date
# Only 35 rows returned
;

# Finding unique participants in the DailyActivity who do not have records in either the SleepLog or WeightLog tables (or both)
SELECT DISTINCT Id
FROM DailyActivity
WHERE Id NOT IN (
	SELECT d.Id
	FROM DailyActivity AS d 
	JOIN SleepLog AS s
	ON d.ActivityDate = s.SleepDay AND d.Id = s.Id
	JOIN WeightLog AS w
	ON s.SleepDay = w.Date AND s.Id = w.Id)
# Out of 33 participants in the DailyActivity table, 28 do not have records in either the SleepLog or WeightLog tables (or both)
;

# Looking at instances where users don't have records in SleepLog based on day of the week
SELECT DAYNAME(ActivityDate) AS DayOfWeek, COUNT(*) AS num
FROM DailyActivity AS d 
	LEFT JOIN SleepLog AS s
	ON d.ActivityDate = s.SleepDay AND d.Id = s.Id
WHERE s.TotalMinutesAsleep IS NULL
GROUP BY DayOfWeek
ORDER BY num DESC
;

# Looking at calories and active minutes
SELECT Id, ActivityDate, Calories, SedentaryMinutes, LightlyActiveMinutes, FairlyActiveMinutes, VeryActiveMinutes
FROM DailyActivity
;

# Looking at calories and active distances
SELECT Id, ActivityDate, Calories, SedentaryActiveDistance, LightActiveDistance, ModeratelyActiveDistance, VeryActiveDistance, TotalDistance
FROM DailyActivity
;

# Looking at calories and total steps
SELECT Id, ActivityDate, Calories, TotalSteps
FROM DailyActivity
;

# Looking at calories and total minutes asleep
SELECT d.Id, d.ActivityDate, Calories, TotalMinutesAsleep
FROM DailyActivity AS d 
INNER JOIN SleepLog AS s 
ON d.Id = s.Id AND d.ActivityDate = s.SleepDay
;

# Looking at calories and total minutes & hours asleep from day before
SELECT d.Id, d.ActivityDate, Calories, TotalMinutesAsleep,
			LAG(TotalMinutesAsleep, 1) OVER (ORDER BY d.Id, d.ActivityDate) AS MinutesSleptDayBefore,
			LAG(TotalMinutesAsleep, 1) OVER (ORDER BY d.Id, d.ActivityDate) / 60 AS HoursSleptDayBefore
FROM DailyActivity AS d 
INNER JOIN SleepLog AS s 
ON d.Id = s.Id AND d.ActivityDate = s.SleepDay
;

# Looking at manual reports vs. automated reports in WeightLog table; also looking at average weight of participants whose reports were generated manually vs. automatically
SELECT IsManualReport, COUNT(DISTINCT Id)
FROM WeightLog
GROUP BY IsManualReport
;

SELECT IsManualReport, COUNT(*) AS num_reports, AVG(WeightPounds) AS avg_weight
FROM WeightLog
GROUP BY IsManualReport
;

# Looking at all Minutes (inc. new column of total minutes) in DailyActivity table
SELECT Id, ActivityDate, (SedentaryMinutes + LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes) AS TotalMinutes, SedentaryMinutes, LightlyActiveMinutes, FairlyActiveMinutes, VeryActiveMinutes
FROM DailyActivity
;

# Looking at non-sedentary minutes and total sleep
SELECT d.Id, ActivityDate, LightlyActiveMinutes, FairlyActiveMinutes, VeryActiveMinutes, (LightlyActiveMinutes + FairlyActiveMinutes + VeryActiveMinutes) AS TotalMinutes, TotalMinutesAsleep, (TotalTimeInBed - TotalMinutesAsleep) AS MinutesToFallAsleep
FROM DailyActivity AS d
JOIN SleepLog AS s
ON d.Id = s.Id AND ActivityDate = SleepDay
;

# Looking at number of days where total steps is equal to or greater than the CDC-recommended amount of 10,000
SELECT DAYNAME(ActivityDate) AS DayOfWeek, COUNT(*)
FROM DailyActivity
WHERE TotalSteps >= 10000
GROUP BY DayOfWeek
;

# Looking at number of days where users got the CDC-recommended amount of sleep (7-9 hours a night)
SELECT DAYNAME(ActivityDate) AS DayOfWeek, COUNT(*) AS NumDays
FROM DailyActivity AS d 
JOIN SleepLog AS s
ON d.Id = s.Id AND d.ActivityDate = s.SleepDay
WHERE TotalMinutesAsleep >= 420 AND TotalMinutesAsleep <= 540
GROUP BY DayOfWeek
ORDER BY NumDays DESC
;