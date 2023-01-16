# Google Data Analytics Capstone: Cyclistic Case Study

![image](https://user-images.githubusercontent.com/67650188/212098412-e3466184-c108-42bd-9e64-e35f88fe8724.png)

## Introduction
This post will guide you through the process of my [Google Data Analytics Professional Certificate](https://www.coursera.org/professional-certificates/google-data-analytics) case study: Cyclistic Bike-Share Analysis. This project will analyze the trends, behaviors, and characteristics of the rides in order to draw some insights. The purpose of this project is to provide insights in order to make data-driven decisions for marketing strategies that would convert casual riders into members. 

This project will follow the 6 Data Analytics stages: **Ask, Prepare, Process, Analyze, Share, Act.**

I used **Microsoft SQL Server** for data processing, data cleaning, validation, and exploration, and I also used **Tableau Desktop** for data visualization.

## The Scenario:

Cyclistic is a fictional bike-share company in Chicago. The director of marketing believes the company’s future success depends on maximising the number of annual memberships. Therefore, the data analytics team wants to understand how casual riders and annual members use Cyclistic bikes differently. From these insights, the team will design a new marketing strategy to convert casual riders into annual members.

## Stage 1: Ask
**Identifying Business Task**

The company is seeking marketing strategies that will effectively convert casual riders into annual members. In order to do this, they require data-based insights into the characteristics and behaviors of their casual riders and annual members. So, the questions to answer are:

- **How do annual members and casual riders use Cyclistic bikes differently?**
- **Why would casual riders buy Cyclistic annual memberships?**
- **How can Cyclistic use digital media to influence casual riders to become members?**

## Stage 2: Prepare
**Data Source:**

For this analysis, [Cyclistic’s historical trip data](https://divvy-tripdata.s3.amazonaws.com/index.html) was used. This is public data that has been made available by Motivate International Inc. under the [license](https://ride.divvybikes.com/data-license-agreement).

**Data organization & information:**

I downloaded 12 ‘.cvs’ files for each month from January/2022 to December/2022 and organized them into a folder with consistent names, for example, 202201_trip_data.

I stored these files on my laptop and I duplicated the data for backup purposes.

Each file consists of the same 13 columns with a total of 5.6 million rows.

- **ride_id**
- **rideable_type:** the type of the bike (docked_bike, electric_bike and classic_bike)
- **started_at:** the date and time the ride started at
- **ended_at:** the date and time the ride ended at
- **start_station_name:** station’s name the ride started at
- **start_station_id:** station’s ID the ride started at
- **end_station_name:** station’s name the ride ended at
- **end_station_id:** station’s ID the ride ended at
- **start_lat:** station's latitude the ride started at
- **start_lng:** station's longitude the ride started at
- **end_lat:** station's latitude the ride ended at
- **end_lng:** station's longitude the ride ended at
- **member_casual:** casual rider or member rider

Stage 3: Process

Before analyzing, the data has to be cleaned. I skimmed through a few files first to get an idea of the data formatting and quality in Microsoft Excel. But, for further process, I decided to use **SQL for data processing, cleaning, and exploration** as SQL is capable of handling large datasets while Microsoft Excel cannot process 5 million rows of data simultaneously.

### Data Import:

For the importation of the ‘.csv’ files, I first created the tables and then inserted the data for every month as follows:
```
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
FROM 'C:\...\Google-case-study-Cyclistic\202212_trip_data.csv'
WITH (
 FORMAT = 'CSV',
 FIRSTROW = 2,
 FIELDTERMINATOR = ',',
 ROWTERMINATOR = '\n'
 )
 GO
 ```
 
 I then created the new table **year2022** to combine the 12 months of data into one. To do this I used the **UNION ALL** statement:
 ```
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
 ```

### Data Cleaning:
To identify **duplicates**, I will consider that if all data withing a raw is the same, then it’s a duplicate entry.

I have used CTE and window functions to separate the data into groups based on above mentioned conditions.
If **RowNumCTE = 2**, this means that the entry is a **duplicate**.
 ```
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
 ```
**NO Duplicates were found!**

I have also checked to see if there are significant numbers of **NULL values** in the relevant columns for our analysis. ‘Started_at’ and ‘end_at’ (Time) and ‘member_casual’ columns did not have NULL values which is great news since they are important values for this analysis. There were around 5,000 NULL values for ‘latitude’ and ‘longitude’ columns, but this fact was not overwhelmingly damaging to the validity of the dataset considering the total 5 million rows.

 ```
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
 ```

# Stage4: Analyze

First of all I looked at the total number of rides counted per quarter:

```
SELECT  DATEPART(QUARTER, started_at) AS quarter, COUNT(*) AS total_rides_per_qtr
FROM year2022
GROUP BY DATEPART(QUARTER, started_at)
ORDER BY total_rides_per_qtr
 ```
