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
	 ISDATE('2016/02/29') AS CheckLeapYear -- if 0, date does not exists and is not leap year
	,ISDATE('2019/02/29') AS CheckLeapYear -- if 1, date exists and this year is a leap year
	,CAST(GETDATE() AS INT) % 400  -- if modulo = 0 (equals to zero), year is a leap year
	,CAST(GETDATE()-800 AS INT) % 400  -- if modulo = 0 (equals to zero), year is a leap year
	
select getdate()-800

-- Using Date format
SELECT
	CAST(GETDATE() AS DATE) AS Date_RightNow

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
	 EOMONTH(GETDATE()) AS CurrentMonthEnd,
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
   ,CAST(DATEADD(MONTH, 1, CAST(GETDATE() AS DATE)) AS SMALLDATETIME) AS OneMonthFromNow2


SELECT
	DATEADD(DAY, DATEDIFF(DAY, -1, GETDATE()), 365) AS OneYearFromNow
		       , dateadd(day, datediff(day, -1, (getdate())), 365) as to�no_�ez_eno_leto_od_danes

-----------------------------------------------
-----------------------------------------------
-- 3. Starting with simple time
-----------------------------------------------
-----------------------------------------------