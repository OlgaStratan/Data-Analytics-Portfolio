# Data Analytics Project with SQL and Tableau
## In this project I was using SQL (Microsoft SQL Server) to do Data Exploration and then visualize the data in Tableau.

The first part of the project performs some data exploration with basic SQL queries that involves statements like **Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.**

## Data Collection
For this project I used the Covid 19 Data from [Our World
in Data](https://ourworldindata.org/covid-deaths).

The initial CSV dataset contains some demographics information like location, population count, median age, gdp per capita, and medication history. Besides, it records covid tracking information starting on January 1st, 2020. This table records the new and total case count, number of death cases, and vaccination count on each day. I have splited the dataset into two separate tables, **CovidDeaths** and **CovidVaccination**, in order to use JOIN statement.

## SQL Queries 
Here you can see a few example of SQL Queries that have been used, you can see the full SQL Code in the files section of this project.

### Likelihood of dying from Covid in Germany
We want to know the percentage of covid deaths rate in Germany every day, so here we divide the total death numbers by the number of total cases. This query shows the likelihood of people dying from covid in Germany.

![Screenshot 2022-12-19 155608](https://user-images.githubusercontent.com/67650188/208454820-9feadd5a-0909-4dee-a5cb-b86b2cc39c2e.png)

### What percentage of population got Covid
This query shows the percentage of people who contract covid in the Germany each day. We can see that as of the latest date (13/12/2022), covid infection rate in the Germany is over 44%!
![Screenshot 2022-12-19 161214](https://user-images.githubusercontent.com/67650188/208458020-7047ae3c-7d74-48de-81a6-492e5f5ef214.png)


### Countries with the highest Death Count
This following query looks at the highest total death count per population in overall for each country. Since the total_deaths variable is a **VARCHAR**, we need to convert it into **INTEGER** first. We can see that United States, Brazil, and India are the first three countries that have the highest covid deaths count as per 13/12/2022. 
