### EXAMINING AND CLEANING THE DATA

# Selecting distinct IDs to find number of unique participants with daily activity data
SELECT DISTINCT Id
FROM DailyActivity
# Returns 33 rows
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
# Start date was 2016-4-12, end date 2016-5-12
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
SELECT ID, ActivityDate, COUNT(*) AS num_row
FROM DailyActivity
GROUP BY ID, ActivityDate # Each row is uniquely identified by the ID and ActivityDate colummns
HAVING num_row > 1
# No results, no duplicate rows in the DailyActivity table
;

# Finding duplicate rows, if any, in SleepLog
SELECT *, COUNT(*) AS num_row
FROM SleepLog
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING num_row > 1
# 3 duplicate rows returned
;

# Creating new table with all distinct values
CREATE TABLE SleepLog2 SELECT DISTINCT * FROM SleepLog
;

# Double checking new table no longer has duplicate rows
SELECT *, COUNT(*) AS num_row
FROM SleepLog2
GROUP BY Id, SleepDay, TotalSleepRecords, TotalTimeInBed, TotalMinutesAsleep
HAVING num_row > 1
# 0 duplicate rows returned in new table; duplicate rows deleted
;

# Dropping original SleepLog table; renaming new table
ALTER TABLE SleepLog RENAME junk
DROP TABLE IF EXISTS junk;
ALTER TABLE SleepLog2 RENAME SleepLog
;

# Finding duplicate rows, if any, in WeightLog table
SELECT *, COUNT(*) AS num_row
FROM WeightLog
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8
HAVING num_row > 1
# 0 duplicate rows returned
;

# Examining records with NULL values in TotalSteps
SELECT Id, COUNT(*) AS numZeroStepsDays
FROM DailyActivity
WHERE TotalSteps = 0
GROUP BY Id
ORDER BY numZeroStepsDays DESC
;

SELECT Id, ActivityDate, (SedentaryMinutes / 60) AS SedentaryHours
FROM DailyActivity
WHERE Id = 1927972279 AND TotalSteps = 0
# Records for this participant indicate they were sedentary for the entire day. Not necessarily an inconsistency, but worth noting; it's possible that this is the case for all records with zero total steps 
;


# To make the column easier to understand, converting Boolean (tinyint in MySQL) values in IsManualReport in WeightLog table to varchar "True" and "False"
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

# Looking at time asleep/in bed in SleepLog table in hours instead of minutes
SELECT TotalMinutesAsleep / 60 AS TotalHoursAsleep, TotalTimeInBed / 60 AS TotalTimeInBed
FROM SleepLog
;

# Rounded to two decimal places
SELECT ROUND(TotalMinutesAsleep / 60, 2) AS TotalHoursAsleep, 
		ROUND(TotalTimeInBed / 60, 2) AS TotalTimeInBed
FROM SleepLog
;

# Double checking that all IDs in DailyActivity have the same number of characters
SELECT LENGTH(Id)
FROM DailyActivity
# Most common result, at a glance, is 10 characters per ID
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
SELECT LogId, COUNT(LogId) AS num_LogIds
FROM WeightLog
GROUP BY LogId
HAVING num_LogIds > 1
ORDER BY num_LogIds DESC
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
# Results unclear; matching LogIds occur on the same Date but don't appear to have anything else in common, which raises the question: If not a primary key in the WeightLog table, what exactly is a LogId?
;


### QUERYING THE CLEANED DATABASE TO IDENTIFY PATTERNS AND GAIN INSIGHTS