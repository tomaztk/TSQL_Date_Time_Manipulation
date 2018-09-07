/* ********************************************

T-SQL DATE / TIME Manipulations
Blog: tomaztsql.wordpress.com
Code: github.com/tomaztk/TSQL_Date_time_Manipulation
Author: Tomaz Kastrun
Twitter: @tomaz_tsql
Date: 03.SEPT.2018

Version 1.0 - 03.09.2018 - Adding the file to git
Version 1.1 - 07.09.2018 - Adding Fiscal Years

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
	 -- Author of this example is Dan Guzman. Thank you Dan.
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
-- 4. Date intervals
-----------------------------------------------
-----------------------------------------------

SELECT	
	 DATEADD(WEEK, DATEDIFF(WEEK, '19000101', GETDATE()), '18991231') as FromCurrentWeek
	,DATEADD(WEEK, DATEDIFF(WEEK, '18991231', GETDATE()), '19000106') as ToCurrentWeek 


SELECT	
	 CAST(DATEADD(DAY, 1, EOMONTH(GETDATE(),-1)) AS DATETIME) AS FromCurrentMonth
	,CAST(EOMONTH(GETDATE()) AS DATETIME) AS ToCurrentMonth


SELECT	
	 DATEADD(QUARTER, DATEDIFF(QUARTER, 0, (GETDATE())), 0) as FromStartCurrentQuarter
	,DATEADD(DAY,-1,DATEADD(QUARTER, DATEDIFF(QUARTER, -1, (GETDATE())), 0)) as ToEndCurrentQuarter
	

--Last days
SELECT 
	DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE()),0)) AS LastDayOfPreviousMonth
	,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+1,0)) AS LastDayOfCurrentMonth
	,DATEADD(s,-1,DATEADD(mm, DATEDIFF(m,0,GETDATE())+2,0)) AS LastDayOfNextMonth


-----------------------------------------------
-----------------------------------------------
-- 5. Support Date functions
-----------------------------------------------
-----------------------------------------------


-- Set language
SET LANGUAGE us_english;
SELECT DATENAME(WEEKDAY, '20190904') [US_English];
 
SET LANGUAGE Slovenian;
SELECT DATENAME(WEEKDAY, '20180904') [Slovenian];


-- Starting week with day
SET LANGUAGE Slovenian;  
SELECT @@DATEFIRST AS weekStart;  

SET LANGUAGE us_english;  
SELECT @@DATEFIRST AS WeekStart;  


-- datefirst or @@datefirst
SET DATEFIRST 1; -- week starts with monday


-- Example with  September 5th, 2018
-- Possible formats:  mdy, dmy, ymd, ydm, myd, and dym. 
DROP TABLE IF EXISTS #dateformats
CREATE TABLE #dateformats (dd SMALLDATETIME
						   ,ddFormat VARCHAR(10))

SET DATEFORMAT mdy;
INSERT INTO #dateformats  VALUES ('09/06/2018', 'mdy');
SET DATEFORMAT ymd;
INSERT INTO #dateformats  VALUES ('2018/09/07', 'ymd');
SET DATEFORMAT dmy;
INSERT INTO #dateformats  VALUES ('08/09/2018', 'ymd');

SELECT 
	 dd AS InsertedDate
	,ddFormat AS InsertedDateFormat
FROM #dateformats

-----------------------------------------------
-----------------------------------------------
-- 6. Starting Simple Time
-----------------------------------------------
-----------------------------------------------


SELECT
	 GETDATE() AS RightNow
	,DATEPART(HOUR,GETDATE()) AS Hour_RightNow
	,DATEPART(MINUTE, GETDATE()) AS Minute_RightNow
	,DATEPART(SECOND, GETDATE()) AS Second_RightNow
	,DATEPART(MILLISECOND, GETDATE()) AS MilliSecond_RightNow


-- Using Date format or FORMAT or CAST / CONVERT To get only time
SELECT
	 CAST(GETDATE() AS TIME) AS TIME_RightNow
	,CONVERT(CHAR,GETDATE(),14) AS TIME_withConvert14
	,CONVERT(TIME, GETDATE())  AS Time_ConvertONly
	,CAST(CONVERT(CHAR(8),GETDATE(),114) AS DATETIME)  AS Time_WithConvert114_AandDate
	,CONVERT(VARCHAR(12),GETDATE(),114)  AS Time_standardFormat
	,GETUTCDATE() AS TimeUTC_RightNow
	,SYSDATETIME() AS SystemDateTime
	,CONVERT(VARCHAR(10), CAST(GETDATE() AS TIME(0)), 100) AS SimpleAM_PM

SELECT
	 FORMAT(cast(GETDATE() AS TIME), N'hh\.mm') AS timeFormatDot
	,FORMAT(cast(GETDATE() AS TIME), N'hh\:mm') AS timeFormatColon
	,FORMAT(CAST(GETDATE() AS TIME), 'hh\:mm\:ss') AS standardTimeFormat


-----------------------------------------------
-----------------------------------------------
-- 7. Converting to time formats
-----------------------------------------------
-----------------------------------------------

-- seconds/milliseconds to time format
DECLARE @MilliSec INT = 55433
DECLARE @Sec INT = 532

SELECT 
	 CONVERT(VARCHAR(10),DATEADD(ms,@MilliSec,0),114) AS MilliSecToTime --format hh:mm:ss:nnn
    ,CONVERT(VARCHAR(10),DATEADD(s,@Sec,0),114) AS SecToTime --format hh:mm:ss:nnn



-- Converting seconds to time readable format
DECLARE @seconds INT = 10000

SELECT
	 @seconds AS NumberOfSeconds
	,@seconds/86400 AS NumberOfDays
	,@seconds/3600 As NumberOfHours
	,@seconds/60 AS NumberMinutes
	,CONVERT(VARCHAR, DATEADD(ms, @seconds * 1000, 0), 114) AS FormatedTime



-----------------------------------------------
-----------------------------------------------
-- 8. VARCHAR / DECIMAL/FLOAT to time formats
-----------------------------------------------
-----------------------------------------------

-- Using Decimal data type
DECLARE @test_DTY TABLE
(id int
,KA2_DATE decimal (8,0)
,KA2_TIME decimal (6,0)
)

INSERT INTO @test_DTY
		  SELECT 1, 20180905,	110951
UNION ALL SELECT 2, 20180905,	113407
UNION ALL SELECT 3, 20180905,	063407

SELECT
 id
,KA2_DATE AS OriginalDate
,KA2_TIME AS OriginalDate --Note leading zeros will not be presented as this is decimal data type

,RIGHT(CAST(KA2_DATE AS VARCHAR(8)),2) + '/' + SUBSTRING(CAST(KA2_DATE AS VARCHAR(8)),5,2) + '/' + LEFT(CAST(KA2_DATE AS VARCHAR(8)),4) AS DateFormated_dd_MM_yyyy
,LEFT(CAST(REPLICATE('0', 6 - LEN(CAST(KA2_TIME AS VARCHAR(6)))) AS VARCHAR(1)) + CAST(CAST(KA2_TIME AS VARCHAR(6)) AS VARCHAR(6)),2) + ':' 
           + SUBSTRING(CAST(REPLICATE('0', 6 - LEN(CAST(KA2_TIME AS VARCHAR(6)))) AS VARCHAR(1)) + CAST(CAST(KA2_TIME AS VARCHAR(6)) AS VARCHAR(6)),3,2) + ':' 
		   + RIGHT(CAST(REPLICATE('0', 6 - LEN(CAST(KA2_TIME AS VARCHAR(6)))) AS VARCHAR(1)) + CAST(CAST(KA2_TIME AS VARCHAR(6)) AS VARCHAR(6)),2) AS Time_formatted_hh_mm_ss
FROM @test_DTY



-- Using String data Type (Varchar)

DECLARE @temp TABLE
(
	Ddate VARCHAR(20)
)

INSERT INTO @temp (Ddate)
		  SELECT '3.11.2017 14:55:53'   
UNION ALL SELECT '12.11.2018 22:39:49' 
UNION ALL SELECT '12.8.2018 22:39:49' 
UNION ALL SELECT '2.3.2018 22:39:49' 
UNION ALL SELECT '12.8.2018 7:39:49' 
UNION ALL SELECT '12.8.2018 7:09:49' 


SELECT 
	 Ddate AS OriginalDateFormatInVarchar
	,PARSENAME(Ddate,3) AS DayFromVarchar
	,PARSENAME(Ddate,2) AS MonthFromVarchar
	,LEFT(PARSENAME(Ddate,1),4) AS YearFromVarchar
	,REPLACE(SUBSTRING(Ddate, CHARINDEX(' ', Ddate), CHARINDEX(':', Ddate)),':','') AS TimeFromVarchar

	,CAST(CAST(LEFT(PARSENAME(Ddate,1),4) AS CHAR(4)) + REPLICATE ('0', 2 - LEN(CAST(PARSENAME(Ddate,2) AS VARCHAR(2)))) + 
			   CAST(PARSENAME(Ddate,2) AS VARCHAR(2)) + REPLICATE ('0', 2 - LEN(CAST(PARSENAME(Ddate,3) AS VARCHAR(2)))) + 
			   CAST(PARSENAME(Ddate,3) AS VARCHAR(2)) AS INT) AS DateFormattedFromVarchar --Leading zeros corrected!

	,CAST(CAST(LEFT(PARSENAME(Ddate,1),4) AS CHAR(4)) + REPLICATE ('0', 2 - LEN(CAST(PARSENAME(Ddate,2) AS VARCHAR(2)))) + 
				CAST(PARSENAME(Ddate,2) AS VARCHAR(2)) + REPLICATE ('0', 2 - LEN(CAST(PARSENAME(Ddate,3) AS VARCHAR(2)))) + 
				CAST(PARSENAME(Ddate,3) AS VARCHAR(2)) AS SMALLDATETIME) AS DateFormattedFromVarcharToSmallDateTime
	
	,CAST(CAST(left(PARSENAME(Ddate,1),4) AS CHAR(4)) + REPLICATE ('0', 2 - LEN(CAST(PARSENAME(Ddate,2) AS VARCHAR(2)))) + 
		   CAST(PARSENAME(Ddate,2) AS VARCHAR(2)) + REPLICATE ('0', 2 - LEN(CAST(PARSENAME(Ddate,3) AS VARCHAR(2)))) + 
		   CAST(PARSENAME(Ddate,3) AS VARCHAR(2)) +  REPLICATE('0', 6 - LEN(
			CAST(LTRIM(RTRIM(REPLACE(SUBSTRING(Ddate, CHARINDEX(' ', Ddate), CHARINDEX(':', Ddate)),':',''))) AS VARCHAR(6)))) +
			CAST(LTRIM(RTRIM(REPLACE(SUBSTRING(Ddate, CHARINDEX(' ', Ddate), CHARINDEX(':', Ddate)),':',''))) AS VARCHAR(6))
				AS VARCHAR(14)) AS DateAndTimeFormatFromVarchar

FROM @temp
ORDER BY 8 ASC



-----------------------------------------------
-----------------------------------------------
-- 9. Calculating Fiscal Years
-----------------------------------------------
-----------------------------------------------

-- a) it start on April 1 and runs for 364,25 days until March 31 of next year 
-- b) it starts on October 1 and runs for 364,25 days until September 30 of next year


SELECT
-- Fiscal Year Apr-Mar
     CASE WHEN MONTH(GETDATE()) >= 4 THEN YEAR(GETDATE()) ELSE DATEPART(year,DATEADD(Year,-1,GETDATE())) END AS StartOfFiscalYearYear
	,CASE WHEN MONTH(GETDATE()) >= 4 THEN YEAR(GETDATE())+1 ELSE YEAR(GETDATE()) END AS EndOfFiscalYearYear
	,CASE WHEN MONTH(GETDATE()) >= 4 THEN CAST(CONCAT(CAST(YEAR(GETDATE()) AS VARCHAR),'/04/01') AS DATE)  ELSE CAST(CONCAT(CAST(DATEPART(year,DATEADD(Year,-1,GETDATE())) AS VARCHAR),'/04/01') AS DATE)  END AS StartOfFiscalYearDateTime
	,CASE WHEN MONTH(GETDATE()) >= 4 THEN CAST(CONCAT(CAST(YEAR(dateadd(year,1,getdate())) AS VARCHAR),'/03/31') AS DATE) ELSE CAST(CONCAT(CAST(YEAR(GETDATE()) AS VARCHAR),'/03/31') AS DATE) END AS EndOfFiscalYearDateTime
-- Fiscal Year Oct-Sep
    ,CASE WHEN MONTH(GETDATE()) >= 10 THEN YEAR(GETDATE()) ELSE DATEPART(year,DATEADD(Year,-1,GETDATE())) END AS StartOfFiscalYearYear
	,CASE WHEN MONTH(GETDATE()) >= 10 THEN YEAR(GETDATE())+1 ELSE YEAR(GETDATE()) END AS EndOfFiscalYearYear
	,CASE WHEN MONTH(GETDATE()) >= 10 THEN CAST(CONCAT(CAST(YEAR(GETDATE()) AS VARCHAR),'/10/01') AS DATE)  ELSE CAST(CONCAT(CAST(DATEPART(year,DATEADD(Year,-1,GETDATE())) AS VARCHAR),'/10/01') AS DATE)  END AS StartOfFiscalYearDateTime
	,CASE WHEN MONTH(GETDATE()) >= 10 THEN CAST(CONCAT(CAST(YEAR(dateadd(year,1,getdate())) AS VARCHAR),'/09/30') AS DATE) ELSE CAST(CONCAT(CAST(YEAR(GETDATE()) AS VARCHAR),'/09/30') AS DATE) END AS EndOfFiscalYearDateTime


