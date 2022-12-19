# Data Analytics Project with SQL and Tableau
## In this project I was using SQL (Microsoft SQL Server) to do some Data Exploration and then visualize the data in Tableau.

The first part of the project performs some data exploration with basic SQL queries that involves statements like **Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types.**

## Data Collection
For this project I used the Covid 19 Data from [Our World
in Data](https://ourworldindata.org/covid-deaths).

The initial CSV dataset contains some demographics information like location, population count, median age, gdp per capita, and medication history. Besides, it records covid tracking information starting on January 1st, 2020. This table records the new and total case count, number of death cases, and vaccination count on each day. I have splited the dataset into two separate tables, **CovidDeaths** and **CovidVaccination**, in order to use JOIN statement.

## SQL Queries 
Here you can see a few example of SQL Queries that have been used, you can see the full SQL Code in the files section of this project.

### Likelihood of dying from Covid in Germany

![Screenshot 2022-12-19 155608](https://user-images.githubusercontent.com/67650188/208454820-9feadd5a-0909-4dee-a5cb-b86b2cc39c2e.png)

### What percentage of population gor Covid every day**

