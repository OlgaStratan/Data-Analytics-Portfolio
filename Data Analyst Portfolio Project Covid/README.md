# Data Analytics Project with SQL and Tableau
### In this project I was using SQL (Microsoft SQL Server) for Data Exploration and Tableau for further Data Visualization

## Data Collection
For this project I used the Covid 19 Data from [Our World
in Data](https://ourworldindata.org/covid-deaths).

The initial CSV dataset contains some demographics information like location, population count, median age, gdp per capita, and medication history. Besides, it records covid tracking information starting on January 1st, 2020. This table records the new and total case count, number of death cases, and vaccination count on each day. I have splited the dataset into two separate tables, **CovidDeaths** and **CovidVaccination**, in order to use JOIN statement.

## PART I

The first part of the project performs some data exploration with basic SQL queries that involves statements like **Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.** The full SQL code can be find in the file section - [Covid_SQL_Data_Exploration.sql](https://github.com/OlgaStratan/Data-Analytics-Portfolio/blob/main/Data%20Analyst%20Portfolio%20Project%20Covid/Covid_SQL_Data_Exploration.sql)

### SQL Queries 
Here I will show only the SQL Queries that have been used for further visualizations.

### 1. This query shows the global number of total cases, deaths, and the percentage of deaths across the countries 

```
SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM portofolio..CovidDeaths
WHERE continent IS NOT NULL
-- in some places within the table the Continent is NULL and the Location is a Continent or other group as income level.
ORDER BY 1,2
```

**output:**

![Screenshot 2022-12-27 141643](https://user-images.githubusercontent.com/67650188/209672236-2aef68dd-fd63-453e-961b-4e99d4005683.png)


### 2. Total number of new deaths cases in each continent,

Since the total_deaths variable is a **VARCHAR**, we need to convert it into **INTEGER** first. 
We can see that **Europe, Norht America and Asia** are the Top three continents that have the highest covid deaths count as per 13/12/2022. 
```
SELECT continent,  SUM(cast(total_deaths as int)) as Total_Death_Count
FROM portofolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC
```
**output:**

![Screenshot 2022-12-27 142110](https://user-images.githubusercontent.com/67650188/209672717-f458c607-3526-4eb5-a748-d99a55d58626.png)

### 3. This query shows the highest infection count and infection percentage for each country across the years
```
SELECT Location,  population, MAX(total_cases) as Highest_infection_count
, MAX((total_cases/population)*100) as percent_of_population_infected
FROM portofolio..CovidDeaths
--WHERE Location = 'Germany'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_of_population_infected DESC
```
**output:**

![Screenshot 2022-12-27 142329](https://user-images.githubusercontent.com/67650188/209672990-f61d01a2-cc77-44d8-9a6a-dd1341a4a854.png)

### 4. This query shows the highest infection count and infection percentage for each country every day

SELECT Location,  population, date MAX(total_cases) as Highest_infection_count
, MAX((total_cases/population)*100) as percent_of_population_infected
FROM portofolio..CovidDeaths
--WHERE Location = 'Germany'
WHERE continent IS NOT NULL
GROUP BY location, population, date
ORDER BY percent_of_population_infected DESC

**output:**

![Screenshot 2022-12-27 142748](https://user-images.githubusercontent.com/67650188/209673501-77f9004b-3f82-4b78-a488-8bb6472024ab.png)

### This is the end for the part one of the project, in the next section I have used the results tables as the data sources (in excel format) for the visualizations in Tableau.

## PART II

## Final Dashboard

You can access the [Dashboard here.](https://public.tableau.com/views/CovidDashboard_16717196289560/Dashboard1?:language=en-US&:display_count=n&:origin=viz_share_link)

![Screenshot 2022-12-22 163712](https://user-images.githubusercontent.com/67650188/209673748-a471a348-a4b8-481c-a620-d924ad8ed9f9.png)

## 1. The First For Graph - "Global Numbers" - represents the summary table on the global numbers of Covid-19 tracking.

The main insight from this table is that although the number of Total Deaths during the 2 years of pandemic is huge, it exceeds **6 millions deaths**, the Avarage Percentage Death from the Covid-19 around the world is around **1.02**. Thus the chance of dying from Covid-19 is just **1%**.

## 2. The second - "Total Deaths" Bar Chart - represents the total number of people that died from Covid on every Continent.
It shows that the most deaths are in **Europe**, almost 2M of people died after contracting Covid-19.

## 3. The third visualization is showing the map with the percent of population infected by each country across the years.
From the first look, we can see that the **European Union** has highest infection rate.

## 4. The last visualization, represents a line chart that shows the progression of covid infection rate across the years for a selection of countries.
In this line chart I have chosen the following 4 Countries: **United Kingdom, Germany, Spain and Romania**. These are the countries I have spent the most time during the pandemic years. <br /> <br />  I have also added a forecasting analysis to the chart to predict the future trend of infection rate for each country. <br /> <br /> As of todays date 13th Dec 2022, Germany has **43.32%** of population infected, and the forecast shows that by the end of the next year 2023, Germany will have close to **65%.** This could be true or not, as these days the testing for Covid-19 has visibly decreased, thus the number of infected people is not that accurate.

# Conclusion
* Although Total Deaths during the 2 years of pandemic is big, and exceeds 6 millions deaths, the Avarage Percentage Death from the Covid-19 around the world is around **1.02.** Thus the chance of dying from Covid-19 is just **1%.**
* The highest infection rate is in the **European Union Countries.**
* Almost 2M of people died after contracting Covid-19 on **European Continent**.
