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

I have also checked to see if there are significant numbers of **NULL values** in the relevant columns for our analysis. ‘Started_at’ and ‘end_at’ (Time) and ‘member_casual’ columns did not have NULL values which is great news since they are important values for this analysis. There were around 5,000 NULL values for ‘latitude’ and ‘longitude’ columns and 1298357 for start and end station name, but this fact was not overwhelmingly damaging to the validity of the dataset considering the total 5 million rows.

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
  
 SELECT COUNT(*)
 FROM year2022
 WHERE start_station_name IS NULL OR end_station_name IS NULL
  -- found 1298357 NULLS
 ```

## Stage 4 and 5: Analyze and Share

First of all I looked at the total number of rides counted per quarter:

```
SELECT  DATEPART(QUARTER, started_at) AS quarter, COUNT(*) AS total_rides_per_qtr
FROM year2022
GROUP BY DATEPART(QUARTER, started_at)
ORDER BY total_rides_per_qtr
 ```
![image](https://user-images.githubusercontent.com/67650188/212715959-bf10c447-b6b7-4c42-871b-31ed6e5630a0.png)

We can see from the results that the third quarter had the biggest number of rides. This means that Cyclistic had the highest volume of rides in the summer season, particularly in July with a total rides of 823,488.
```
SELECT DATEPART(Month FROM started_at) AS month, COUNT(*) AS q3_rides_per_month
FROM third_qrt
GROUP BY DATEPART(Month FROM started_at)
ORDER BY DATEPART(Month FROM started_at)
```
![image](https://user-images.githubusercontent.com/67650188/212716788-8654695d-d0e8-4bfc-b4ab-0ed908318169.png)

Then I wanted to see the percentage of rides that were done by each group throughout the year:
```
WITH cte AS
(SELECT CAST (COUNT(ride_id) AS FLOAT) AS total_num
FROM year2022)
SELECT member_casual, CASE
WHEN member_casual = 'member' THEN ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
ELSE ROUND(CAST((COUNT(*) / total_num) * 100 AS numeric),2)
END AS percentage_of_total_rides_all_year
FROM year2022, cte
GROUP BY member_casual, cte.total_num
```
![image](https://user-images.githubusercontent.com/67650188/212717549-a349e4b2-fd80-425e-a83b-994f2deac62c.png)

To see how these numbers changed during the year, I applied the same query but for each quarter, and got the following results:

![image](https://user-images.githubusercontent.com/67650188/212718006-1833cba4-0c27-4952-a232-958588cb20c0.png)

![image](https://user-images.githubusercontent.com/67650188/212718231-9fbfb274-1779-4b46-8502-8be29151f85b.png)

![image](https://user-images.githubusercontent.com/67650188/212718313-9aa1d3ca-d7b6-4f17-808c-8f8ca37ddc91.png)

![image](https://user-images.githubusercontent.com/67650188/212718401-267ebc9a-7b99-44b2-926e-b099a99d958b.png)

From results above I noticed that there is a significant increase in the percentage of rides made by casuals in Q2 and Q3 compared with Q1. Then the percentage drops in Q4 but is still significantly higher than in Q1.
I can conclude, from all of the above, that the third quarter had by far the highest number of rides and also the highest casual-rides percentage within a quarter compared with the other quarters. Which makes sense as during the summer months people spend more time outside.

I then tried to understand how casual riders and annual members use Cyclistic bikes differently. So I started by calculating the average ride duration for both annual members and casual riders to see how it differs:
```
SELECT member_casual, CASE
WHEN member_casual = 'member' THEN (SELECT CAST(AVG(CAST(ended_at AS FLOAT)) AS DATETIME)- CAST(AVG(CAST(started_at AS FLOAT)) AS DATETIME))
ELSE (SELECT CAST(AVG(CAST(ended_at AS FLOAT)) AS DATETIME)- CAST(AVG(CAST(started_at AS FLOAT)) AS DATETIME))
END AS average_trip_duration_all_year
FROM year2022
GROUP BY member_casual
```

**average_trip_duration_all_year** \
member: 00:12:42 \
casual: 00:29:08

When I ran the same query on Q3 (which as we already know had the highest volume of rides) I got very similar results:

**average_trip_duration_q3** \
member: 00:13:21 \
casual: 00:28:55

Looks like the average trip duration for casual riders was significantly higher than for annual members.

Then I wanted to find which day of the week had the highest volume of trips for both members and casuals, and see if there was a trend:
```
SELECT member_casual,
  FORMAT(CAST(started_at AS DATE), 'dddd') AS day_of_week, 
  CASE
  WHEN member_casual = 'member' THEN COUNT(*)
  WHEN member_casual = 'casual' THEN COUNT(*)
END AS week_day_count
FROM year2022
GROUP BY member_casual, FORMAT(CAST(started_at AS DATE), 'dddd')
ORDER BY member_casual, week_day_count DESC
```

![image](https://user-images.githubusercontent.com/67650188/212721933-222677d1-19b9-4ec4-b703-50bb610cc76a.png)


For casual rides the biggest volume of rides was on Saturday and then Sunday. So the volume for casual riders was at its highest on the weekend and dropped during weekdays. And it is the opposite for members where the highest volume happened on Thursday, followed by Wednesday and then Tuesday and the volume was at its lowest on Sunday.
From this I can conclude that the members use the bikes for commuting, whereas casuals use them for leisure during weekends.

Now I wanted to know which stations were most used (top three) as a start_station and also as an end_station for both casual and member riders, so I used the DENSE_RANK function in the following query:

```
WITH cte AS
(
SELECT member_casual, start_station_name, CASE 
	WHEN member_casual = 'casual' THEN DENSE_RANK() OVER(PARTITION BY member_casual ORDER BY COUNT(start_station_name) DESC)
	WHEN member_casual = 'member' THEN DENSE_RANK() OVER(PARTITION BY member_casual ORDER BY COUNT(start_station_name) DESC)
END AS Rank
FROM year2022
WHERE start_station_name IS NOT NULL
GROUP BY start_station_name, member_casual
)

SELECT * FROM cte
WHERE RANK <= 3
```

![image](https://user-images.githubusercontent.com/67650188/212722398-47260421-c577-4280-be67-a326140ee46b.png)
```
with cte AS
(
SELECT member_casual, end_station_name, CASE 
	WHEN member_casual = 'casual' THEN DENSE_RANK() OVER(PARTITION BY member_casual ORDER BY COUNT(end_station_name) DESC)
	WHEN member_casual = 'member' THEN DENSE_RANK() OVER(PARTITION BY member_casual ORDER BY COUNT(end_station_name) DESC)
END AS Rank
FROM year2022
WHERE end_station_name IS NOT NULL
GROUP BY end_station_name, member_casual
)

SELECT * FROM cte
WHERE RANK <= 3
```
![image](https://user-images.githubusercontent.com/67650188/212722532-aaf49dcd-237a-4831-b8cf-c4fdfb31220d.png)

Looking at the results, I can see that the Top 3 pick up and drop off locations are the same for both casual and member riders. 

One last thing I looked at before moving to the visualisations was the rideable_type column. As mentioned before, there are three types of bikes: docked_bike, electric_bike and classic_bike

I wrote a query to return a report that shows the count of rides during the year grouped by quarter, rideable_type, and member_casual:
```
SELECT rideable_type, member_casual, DATEPART(QUARTER FROM started_at) AS quarter, COUNT(*) AS total_rides
FROM year2022
GROUP BY DATEPART(QUARTER FROM started_at), rideable_type, member_casual
ORDER BY DATEPART(QUARTER FROM started_at), member_casual, total_rides DESC
```
![image](https://user-images.githubusercontent.com/67650188/212724135-a724e518-864b-4c16-a6a0-3170faa8af83.png)

Looking at the results, I can see a clear pattern - Casual riders prefer electric bikes, whereas Member riders prefer classic bikes, this is only not true in the 4th quarter, where members chose electric bikes too. 
Also I can see that the docket bikes are only used by the casual rider.

What was the percentage of rides that were done with each type from the total rides in 2022?
```
WITH cte AS
(
SELECT CAST (COUNT(ride_id) AS numeric) AS total_num
FROM year2022
)
SELECT rideable_type, CASE
	WHEN rideable_type = 'electric_bike' THEN CAST((COUNT(*) / total_num) * 100 AS numeric)
	WHEN rideable_type = 'docked_bike' THEN CAST((COUNT(*) / total_num) * 100 AS numeric)
	WHEN rideable_type = 'classic_bike' THEN CAST((COUNT(*) / total_num) * 100 AS numeric)
END AS percentage_of_total_rides
FROM year2022, cte
GROUP BY rideable_type, cte.total_num
ORDER BY percentage_of_total_rides DESC
```
![image](https://user-images.githubusercontent.com/67650188/214081271-9d679379-00b3-4ae2-b91c-af1ca950812a.png)

We can see that the electric bikes are the most popular and used ones. This can be looked into deeper, is the company providing more electric bikes or this is just popular among the clients and so the company has to focus on providing more of the electric bikes.  

## Supporting Visualisations

I used Tableau Public to run some further analysis and generate visualisations that support the key findings in the analysis.

### I. Total Rides by user type
![image](https://user-images.githubusercontent.com/67650188/215540427-31f969fe-161c-4c1d-909b-27aa52985dbf.png)


**Members** dominate bike trips all year round. **Casual** riders pick in Summer, reaching **47%** of the total and are at the lowest during the winter with only **21%**.

### II. Bike type by member type
![image](https://user-images.githubusercontent.com/67650188/215541791-41d19e7e-f87d-47a4-bc9b-6e714e85669f.png)

**The docked bikes** are mainly only used by *casual riders*.

The ride distance is similar to all types of bikes and is similar among the user types.

The ride length is significantly different for the casual user when using the **docket bikes**.

When using the docked bikes casual riders are spending more time riding but this is not impacting the distance value as they are dropping off the bikes in the same location where it was picked up or nearby. (the most popular stations are in the turist zones).

### III. Rides per user type by Month

![image](https://user-images.githubusercontent.com/67650188/215544176-e06fd272-fd9d-4a03-ae1a-975003fb4496.png)

### IV. Ride Length and Distance

![image](https://user-images.githubusercontent.com/67650188/215544805-5aa6f405-cc4f-49e0-8dad-082437449980.png)

### V. Rides per user type by weekday

![image](https://user-images.githubusercontent.com/67650188/215545204-ce023fcd-7f36-4c92-b76a-441073c45a72.png)

### VI. Rush hours bikes use

![image](https://user-images.githubusercontent.com/67650188/215545699-44bc07a9-9ca5-41dc-8c9e-4f73cac46ae9.png)

### VII. Map of most used stations

![image](https://user-images.githubusercontent.com/67650188/215546054-2517f3ac-4687-4b24-b020-d1f3b0a8ddc7.png)


## Stage 6: Act

I have performed my analysis, and gained some insights and created visualizations. It is time to use these insights to make data-driven recommendations for marketing strategies.

**Again, the goal is to convert casual riders into annual members**

- The ride time for members is twice shorter as for casual riders. So, members tend to ride more frequently for relatively short distances whereas casual riders ride longer distances but less frequently. This is perhaps because many members ride to commute to work daily whereas casual riders ride for tourism purposes or leisure activities along the coastline. This conclusion is also supported by the fact that there are significantly more casual rides during the weekend whilst there is little or no change in the number of members’ rides over the whole week, and that causal riders ride along touristic locations along the coastline while members seem to ride inland as much as they ride coastal areas. Thus the best days of the week to reach casual riders are Saturday, Sunday, and Friday respectively.

- Since casual riders ride a lot more during the weekend compared to weekdays, the company could consider introducing different types of membership such as weekend membership where casual riders who only ride during the weekend can be easily attracted.

- Since the significant bike usage begins **from May until September**, May can be a good time to launch the campaign which builds up until September, perhaps with additional focus in the peak season between June and July.

- **Streeter Dr & Grand Ave, DuSable Lake Shore Dr & Monroe St and Millennlum Park** are the top 3 stations casual riders visited most, and thus locations where the campaign can reach most casual riders.

- To attract and motivate casual riders to purchase an annual membership, the company can consider launching a new membership program that rewards/incentivize the riders for their usage. For example, riders will collect points depending on the ride length which they can exchange for rewards. Another instance would be creating a ranking system or rider’s community where only members can participate and enjoy excluded and unique features. This program and system not only attract new members but also make existing members continue their membership.


[Link to the Tableau Public Presentation](https://public.tableau.com/shared/PM6WF45Z2?:display_count=n&:origin=viz_share_link)
