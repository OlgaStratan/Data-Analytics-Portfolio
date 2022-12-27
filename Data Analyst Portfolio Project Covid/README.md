# Data Analytics Project with SQL and Tableau
### In this project I was using SQL (Microsoft SQL Server) for Data Exploration and Tableau for further Data Visualization

## Data Collection
For this project I used the Covid 19 Data from [Our World
in Data](https://ourworldindata.org/covid-deaths).

The initial CSV dataset contains some demographics information like location, population count, median age, gdp per capita, and medication history. Besides, it records covid tracking information starting on January 1st, 2020. This table records the new and total case count, number of death cases, and vaccination count on each day. I have splited the dataset into two separate tables, **CovidDeaths** and **CovidVaccination**, in order to use JOIN statement.

## PART I

The first part of the project performs some data exploration with basic SQL queries that involves statements like **Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.** 

### SQL Queries 
Here I will show only the SQL Queries that have been used for further visualizations, you can see the full SQL Code with more advanced queries in the files section of this project.

### 1. This query shows the global number of total cases, deaths, and the percentage of deaths across the countries 

```
SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths
, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM portofolio..CovidDeaths
WHERE continent IS NOT NULL
-- in some places within the table the Continent is NULL and the Location is a Continent or other group as income level.
ORDER BY 1,2
```
