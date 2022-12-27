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
SELECT Location,  population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population)*100) as percent_of_population_infected
FROM portofolio..CovidDeaths
--WHERE Location = 'Germany'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_of_population_infected DESC
```
