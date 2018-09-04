/* ********************************************

T-SQL DATE / TIME Manipulations
Blog: tomaztsql.wordpress.com
Author: Tomaz TSQL
Date: 03.SEPT.2018

Version 1.0 - 03.09.2018 - Adding the file

********************************************* */

USE msdb;
GO


-----------------------------------------------
-----------------------------------------------
-- 1. Starting Simple Date
-----------------------------------------------
-----------------------------------------------

SELECT
	 GETDATE() AS RightNow
	,YEAR(GETDATE()) AS Year_RightNow
	,MONTH(GETDATE()) AS Month_RightNow
	,DAY(GETDATE()) AS Day_RightNow

-- Is Leap Year (we check for presence/existence of 29.Feb)
SELECT
	 ISDATE('2019/02/29') AS CheckLeapYear -- if 1, date exists and this year is a leap year; if 0 date does not exists and is not leap year
	,CASE WHEN (YEAR(GETDATE()) % 4 = 0 AND YEAR(GETDATE()) % 100 <> 0) OR YEAR(GETDATE()) % 400 = 0 THEN 'Leap Year' ELSE 'Non Leap Year' END AS CheckLeapYear


-- Name of Days, Months
SELECT 
	DATENAME(WEEKDAY, GETDATE()) AS [DayName]
   ,DATENAME(MONTH, GETDATE()) AS [MonthName]
   ,DATEPART(WEEK, GETDATE()) AS [WeekNumber]
   ,DATEPART(ISO_WEEK, GETDATE()) AS [ISO_WeekNumber]


-- Using Date format or FORMAT or CAST / CONVERT
SELECT
	CAST(GETDATE() AS DATE) AS Date_RightNow
	,FORMAT(GETDATE(), 'dd/MM/yyyy') AS DATE_dd_MM_yyyy
	,FORMAT(GETDATE(), 'yyyy-MM-dd') AS DATE_yyyy_MM_dd
	,FORMAT(GETDATE(), 'MM-dd') AS DATE_MM_dd
	,FORMAT(GETDATE(), 'dd/MM/yyyy', 'en-US' ) AS DATE_US 
	,FORMAT(GETDATE(), 'dd/MM/yyyy', 'sl-SI' ) AS DATE_SLO

-- Days
SELECT
	 DATEADD(DAY,DATEDIFF(DAY,1,GETDATE()),0) AS Yesterday
	,DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),0) AS Today
	,DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),1) AS Tomorrow

-- Weeks
SELECT
	 DATEADD(WEEK,DATEDIFF(WEEK,7,GETDATE()),0) AS LastWeek_startOf
	,DATEADD(WEEK,DATEDIFF(WEEK,0,GETDATE()),0) AS ThisWeek_startOf
	,DATEADD(WEEK,DATEDIFF(WEEK,0,GETDATE()),7) AS NextWeek_startOf

-- Months (works for all months; with 30 or 31 days, or with February)
SELECT
	 DATEADD(MONTH,DATEDIFF(MONTH,31,GETDATE()),0) AS LastMonth_startOf
	,DATEADD(MONTH,DATEDIFF(MONTH,0,GETDATE()),0) AS ThisMonth_startOf
	,DATEADD(MONTH,DATEDIFF(MONTH,-1,GETDATE()),0) AS NextMonth_startOf

SELECT 
	 EOMONTH(GETDATE()) AS CurrentMonthEnd
    ,EOMONTH(GETDATE(), -1) AS PreviousMonthEnd
    ,EOMONTH(GETDATE(), 1) AS NextMonthEnd


-- Years (works with leap years)
SELECT
	 DATEADD(year, DATEDIFF(year, 365, (GETDATE())), 0) AS LastYear_startOf
	,DATEADD(year, DATEDIFF(year, 0, (GETDATE())), 0) AS ThisYear_startOf
	,DATEADD(year, DATEDIFF(year, -1, (GETDATE())), 0) AS NextYear_startOf

-----------------------------------------------
-----------------------------------------------
-- 2. Getting dates in particular point-in-time
-----------------------------------------------
-----------------------------------------------

-- return the date on today in a month
SELECT
	DATEADD(MONTH, DATEDIFF(MONTH, -1, (GETDATE())), DAY(GETDATE()-1)) AS OneMonthFromNow
   ,CAST(DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)) AS DATETIME) AS OneMonthFromNow


SELECT
	CAST(DATEADD(YEAR, 1, CAST(GETDATE() AS DATE)) AS DATETIME) AS OneYearFromNow
   ,DATEADD(DAY, DATEDIFF(DAY, 0, (GETDATE())), 365) AS OneYearFromNow



-----------------------------------------------
-----------------------------------------------
-- 3. Differences in dates
-----------------------------------------------
-----------------------------------------------

-- Number of days until ...
SELECT
	 (DATEDIFF(DAY, GETDATE(), DATEADD(MONTH, DATEDIFF(MONTH, -1, (GETDATE())), 0)))-1 AS NumberOfDAysUntilEndOfMonth
	,(DATEDIFF(DAY, GETDATE(), DATEADD(YEAR, DATEDIFF(YEAR, -1, (GETDATE())), 0)))-1 AS NumberOfDAysUntilEndOfYear


-- Number of business / working days between two dates
SET DATEFIRST 1;
DECLARE @dayFrom SMALLDATETIME = '20180901'
DECLARE @dayTO SMALLDATETIME = '20180905'

SELECT
   (DATEDIFF(DAY, @dayFrom, @dayTO) + 1)-(DATEDIFF(WEEK, @dayFrom, @dayTO) * 2)-(CASE WHEN DATEPART(WEEKDAY, @dayFrom) = 7 THEN 1 ELSE 0 END)-(CASE WHEN DATEPART(WEEKDAY, @dayTO) = 6 THEN 1 ELSE 0 END) AS NumberOfWorkingDays


-- Number of working hours between two dates
SET DATEFIRST 1;
DECLARE @dayFromDateTime SMALLDATETIME = '2018-09-01 12:33:11.245'
DECLARE @dayTODateTime SMALLDATETIME = '2018-09-05 09:33:32.256'
DECLARE @hourFrom INT = 8
DECLARE @hourTo INT = 16

;WITH cte
AS
(SELECT
	  DATEADD(MINUTE, -1, @dayFromDateTime) AS StartDate
	 ,0 AS WorkDayFlag
	 ,0 AS WorkHourFlag

UNION ALL

SELECT
	 DATEADD(MINUTE, 1, StartDate) AS StartDate
	,CASE WHEN DATEPART(WEEKDAY, DATEADD(MINUTE, 1, StartDate)) IN (1,2,3,4,5) THEN 1 ELSE 0 END AS WorkDayFlag
	,CASE WHEN DATEPART(HOUR, DATEADD(MINUTE, 1, StartDAte)) BETWEEN @hourFrom AND @hourTo-1 THEN 1 ELSE 0 END AS WorkHourFlag
	FROM cte
	WHERE
		StartDate <= @dayTODateTime
)
SELECT
 SUM(CASE WHEN WorkDayFlag = 1 AND WorkHourFlag = 1 THEN 1 ELSE 0 END) AS nofWorkingMinutes
,SUM(CASE WHEN WorkDayFlag = 1 AND WorkHourFlag = 1 THEN 1 ELSE 0 END)*1.0/60 AS nofWorkingHours
FROM cte 
OPTION (maxRecursion 10000)







-----------------------------------------------
-----------------------------------------------
-- 5. Date functions
-----------------------------------------------
-----------------------------------------------


SET LANGUAGE us_english;
SELECT DATENAME(WEEKDAY, '20190904') [US_English];
 
SET LANGUAGE Slovenian;
SELECT DATENAME(WEEKDAY, '20180904') [Slovenian];


-- Starting week with day
SET LANGUAGE Slovenian;  
SELECT @@DATEFIRST AS weekStart;  

SET LANGUAGE us_english;  
SELECT @@DATEFIRST AS WeekStart;  


--OR
SET DATEFIRST 1; -- week starts with monday

-----------------------------------------------
-----------------------------------------------
-- 4. Date intervals
-----------------------------------------------
-----------------------------------------------

SELECT	
	 DATEADD(WEEK, DATEDIFF(WEEK, '19000101', GETDATE()), '18991231') as FromCurrentWeek
	,DATEADD(WEEK, DATEDIFF(WEEK, '18991231', GETDATE()), '19000106') as ToCurrentWeek 


SELECT	
	 CAST(DATEADD(DAY, 1, EOMONTH(GETDATE(),-1)) AS DATETIME) AS FromCurrentMonth
	,CAST(EOMONTH(GETDATE()) AS DATETIME) AS ToCurrentMonth

