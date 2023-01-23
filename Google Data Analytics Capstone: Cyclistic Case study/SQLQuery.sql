-- creating tables for each month of the year and populating them
drop table IF EXISTS december
CREATE TABLE december (
ride_id VARCHAR(100) PRIMARY KEY,
rideable_type VARCHAR(100),
started_at datetime,
ended_at datetime,
start_station_name VARCHAR(200),
start_station_id VARCHAR(100),
end_station_name VARCHAR(200),
end_station_id VARCHAR(100),
start_lat FLOAT,
start_lng FLOAT,
end_lat FLOAT,
end_lng FLOAT,
member_casual VARCHAR(100)
)
GO

BULK INSERT december
FROM 'C:\Users\User\Desktop\Data-analytics\Projects\Google-case-study-Cyclistic\202212_trip_data.csv'
WITH (
 FORMAT = 'CSV',
 FIRSTROW = 2,
 FIELDTERMINATOR = ',',
 ROWTERMINATOR = '\n'
 )
 GO
 
---creating new table year2022 to combine the 12 months of data into one, by using UNION ALL
SELECT * INTO year2022
	FROM january
UNION ALL
	SELECT * FROM  february
UNION ALL
	SELECT * FROM  march
UNION ALL 
	SELECT * FROM april
UNION ALL
	SELECT * FROM  may
UNION ALL
	SELECT * FROM  june
UNION ALL 
	SELECT * FROM july
UNION ALL
	SELECT * FROM  august
UNION ALL
	SELECT * FROM  september
UNION ALL 
	SELECT * FROM october
UNION ALL
	SELECT * FROM  november
UNION ALL
	SELECT * FROM  december


select *
from year2022

-------------------------------------------------------DATA CLEANING-----------------------------------------------------------------

-- Identify Duplicates
--Use CTE and window function to seperate them into groups
--If all the coloms within the table are similar then these are duplicates.
WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ride_id,
	rideable_type,
	started_at,
	ended_at,
	start_station_name,
	start_station_id,
	end_station_name,
	end_station_id,
	start_lat,
	start_lng,
	end_lat,
	end_lng,
	member_casual
	ORDER BY  ride_id
	) row_num
FROM year2022
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1

-- in this case no duplicates have been found

---checked to see if there are significant numbers of NULL values
SELECT COUNT(*)
 FROM year2022
 WHERE started_at IS NULL OR ended_at IS NULL
 -- found 0 NULLS

 SELECT COUNT(*)
 FROM year2022
 WHERE start_lat IS NULL OR start_lng IS NULL OR end_lat IS NULL OR end_lng IS NULL
 --found 5858 NULLS

 SELECT COUNT(*)
 FROM year2022
 WHERE member_casual IS NULL
 -- found 0 NULLS

 SELECT COUNT(*)
 FROM year2022
 WHERE start_station_name IS NULL OR end_station_name IS NULL
  -- found 1298357 NULLS

-------------------------------------------------------DATA ANALYSIS-----------------------------------------------------------------------------

--total number of rides counted per quarter  
SELECT  DATEPART(QUARTER, started_at) AS quarter, COUNT(*) AS total_rides_per_qtr
FROM year2022
GROUP BY DATEPART(QUARTER, started_at)
ORDER BY total_rides_per_qtr
 
-- number of rides made in quarter 3
SELECT DATEPART(Month FROM started_at) AS month, COUNT(*) AS q3_rides_per_month
FROM third_qrt
GROUP BY DATEPART(Month FROM started_at)
ORDER BY DATEPART(Month FROM started_at)

-- percentage of rides that were done by each group throughout year/ and every quarter

-- quarter1
WITH cte AS
(SELECT CAST (COUNT(ride_id) AS FLOAT) AS total_num
FROM first_qrt)
SELECT member_casual, CASE
WHEN member_casual = 'member' THEN ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),0)
ELSE ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),0)
END AS percentage_of_total_rides_first_qrt
FROM first_qrt, cte
GROUP BY member_casual, cte.total_num

-- quarter2
WITH cte AS
(SELECT CAST (COUNT(ride_id) AS FLOAT) AS total_num
FROM second_qrt)
SELECT member_casual, CASE
WHEN member_casual = 'member' THEN ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
ELSE ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
END AS percentage_of_total_rides_second_qrt
FROM second_qrt, cte
GROUP BY member_casual, cte.total_num

-- quarter3
WITH cte AS
(SELECT CAST (COUNT(ride_id) AS FLOAT) AS total_num
FROM third_qrt)
SELECT member_casual, CASE
WHEN member_casual = 'member' THEN ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
ELSE ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
END AS percentage_of_total_rides_third_qrt
FROM third_qrt, cte
GROUP BY member_casual, cte.total_num

-- quarter4
WITH cte AS
(SELECT CAST (COUNT(ride_id) AS FLOAT) AS total_num
FROM fourth_qrt)
SELECT member_casual, CASE
WHEN member_casual = 'member' THEN ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
ELSE ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
END AS percentage_of_total_rides_fourth_qrt
FROM fourth_qrt, cte
GROUP BY member_casual, cte.total_num

--full year
WITH cte AS
(SELECT CAST (COUNT(ride_id) AS FLOAT) AS total_num
FROM year2022)
SELECT member_casual, CASE
WHEN member_casual = 'member' THEN ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
ELSE ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
END AS percentage_of_total_rides_all_year
FROM year2022, cte
GROUP BY member_casual, cte.total_num


----calculating the average ride duration for both annual members and casual riders to see how it differs

SELECT member_casual, CASE
WHEN member_casual = 'member' THEN (SELECT CAST(AVG(CAST(ended_at AS FLOAT)) AS DATETIME)- CAST(AVG(CAST(started_at AS FLOAT)) AS DATETIME))
ELSE (SELECT CAST(AVG(CAST(ended_at AS FLOAT)) AS DATETIME)- CAST(AVG(CAST(started_at AS FLOAT)) AS DATETIME))
END AS average_trip_duration_all_year
FROM year2022
GROUP BY member_casual


---  find which day of the week had the highest volume of trips for both members and casuals

SELECT member_casual,
  FORMAT(CAST(started_at AS DATE), 'dddd') AS day_of_week, 
  CASE
  WHEN member_casual = 'member' THEN COUNT(*)
  WHEN member_casual = 'casual' THEN COUNT(*)
END AS week_day_count
FROM year2022
GROUP BY member_casual, FORMAT(CAST(started_at AS DATE), 'dddd')
ORDER BY member_casual, week_day_count DESC


--- which stations were most used (top three) as a start_station and also as an end_station for both casual and member riders,
--- so I used the DENSE_RANK function in the following query:
with cte AS
(
SELECT member_casual, start_station_name, CASE 
	WHEN member_casual = 'casual' THEN DENSE_RANK() OVER(PARTITION BY member_casual ORDER BY COUNT(start_station_name) DESC)
	WHEN member_casual = 'member' THEN DENSE_RANK() OVER(PARTITION BY member_casual ORDER BY COUNT(start_station_name) DESC)
END AS Rank
FROM all_year
WHERE start_station_name IS NOT NULL
GROUP BY start_station_name, member_casual
)

SELECT * FROM cte
WHERE RANK <= 3

--end station
with cte AS
(
SELECT member_casual, end_station_name, CASE 
	WHEN member_casual = 'casual' THEN DENSE_RANK() OVER(PARTITION BY member_casual ORDER BY COUNT(end_station_name) DESC)
	WHEN member_casual = 'member' THEN DENSE_RANK() OVER(PARTITION BY member_casual ORDER BY COUNT(end_station_name) DESC)
END AS Rank
FROM all_year
WHERE end_station_name IS NOT NULL
GROUP BY end_station_name, member_casual
)

SELECT * FROM cte
WHERE RANK <= 3

--- this query to return a report that shows the count of rides during the year grouped by quarter, rideable_type, and member_casual:

SELECT rideable_type, member_casual, DATEPART(QUARTER FROM started_at) AS quarter, COUNT(*) AS total_rides
FROM year2022
GROUP BY DATEPART(QUARTER FROM started_at), rideable_type, member_casual
ORDER BY DATEPART(QUARTER FROM started_at), member_casual, total_rides DESC

--- What was the percentage of rides that were done with each type of bikes from the total rides in 2022
WITH cte AS
(
SELECT CAST (COUNT(ride_id) AS numeric) AS total_num
FROM all_year
)
SELECT rideable_type, CASE
	WHEN rideable_type = 'electric_bike' THEN CAST((COUNT(*) / total_num) * 100 AS numeric)
	WHEN rideable_type = 'docked_bike' THEN CAST((COUNT(*) / total_num) * 100 AS numeric)
	WHEN rideable_type = 'classic_bike' THEN CAST((COUNT(*) / total_num) * 100 AS numeric)
END AS percentage_of_total_rides_all_year
FROM all_year, cte
GROUP BY rideable_type, cte.total_num
ORDER BY percentage_of_total_rides_all_year DESC