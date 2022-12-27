/*
Covid 19 Data Exploration 

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
*/

-- selecting data that I am going to use

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM portofolio..CovidDeaths
WHERE continent is not null 
ORDER BY location, date


-- Looking for Total Cases vs Total Deaths
-- Shows the likelihood of dying if you contact Covid in Germany

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM portofolio..CovidDeaths
WHERE Location = 'Germany'
AND continent IS NOT NULL
--in some places within the table the Continet is NULL and the Location is a Continent or other group as income
ORDER BY location, date

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT Location, date, total_cases, population, (total_cases/population)*100 as percent_of_population_infected
FROM portofolio..CovidDeaths
--WHERE Location = 'Germany'
WHERE continent IS NOT NULL
ORDER BY location, date

--Looking at the Countries with Highest Infaction Rate compared to Population

SELECT Location,  population, MAX(total_cases) as Highest_infection_count, MAX((total_cases/population)*100) as percent_of_population_infected
FROM portofolio..CovidDeaths
--WHERE Location = 'Germany'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY percent_of_population_infected DESC

--Showing the Countries with Highest Death count per Population

SELECT Location,  MAX(cast(total_deaths as int)) as Total_Death_Count
FROM portofolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC


----Showing the Groupes with Highest Death count per Population

SELECT Location,  MAX(cast(total_deaths as int)) as Total_Death_Count
FROM portofolio..CovidDeaths
--WHERE Location = 'Germany'
WHERE continent IS NULL
GROUP BY Location
ORDER BY Total_Death_Count DESC


----Showing the Groupes/Continets with Highest Death count per Population

SELECT continent,  SUM(cast(total_deaths as int)) as Total_Death_Count
FROM portofolio..CovidDeaths
--WHERE Location = 'Germany'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Total_Death_Count DESC


--Global Numbers

--Total Cases and Deaths by Date

SELECT date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM portofolio..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2

--Total cases and deaths

-- This query shows the global number of total cases, deaths and the percentage of deaths across the coutries
SELECT SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as Death_Percentage
FROM portofolio..CovidDeaths
WHERE continent IS NOT NULL
-- in some places within the table the Continent is NULL and the Location is a Continent or other group as income level.
ORDER BY 1,2


--Looking at Total Population vs Vaccincations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
FROM portofolio..CovidDeaths dea
JOIN portofolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 
ORDER BY 2,3


-- Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
FROM portofolio..CovidDeaths dea
JOIN portofolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL )
--ORDER BY 2,3


SELECT *, (Rolling_People_Vaccinated/Population)*100
FROM PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP table if exists #Percent_Population_Vaccinated
CREATE TABLE #Percent_Population_Vaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #Percent_Population_Vaccinated 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
FROM portofolio..CovidDeaths dea
JOIN portofolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

SELECT Continent, Location, Date, Population, New_vaccinations, Rolling_people_vaccinated, (Rolling_People_Vaccinated/Population)*100
FROM #Percent_Population_Vaccinated


--Creating View to store data for later visualizations

Create View Percent_Population_Vaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location ORDER BY dea.location, dea.date) as Rolling_people_vaccinated
FROM portofolio..CovidDeaths dea
JOIN portofolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL 

