/* ********************************************

T-SQL DATE / TIME Manipulations
Blog: tomaztsql.wordpress.com
Author: Tomaz TSQL
Date: 03.SEPT.2018


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
	 DATEADD(DAY,DATEDIFF(DAY,1,GETDATE()),0) AS Yesterday
	,DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),0) AS Today
	,DATEADD(DAY,DATEDIFF(DAY,0,GETDATE()),1) AS Tomorrow

						