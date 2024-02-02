#Covid 2019 Data Exploration 

#Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
FROM portfolio.coviddeaths
where continent is not null
order by 3,4

#Selecting Data that we are going to be starting with

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolio.coviddeaths
WHERE continent is not null
order by 1,2

#Total Cases vs Total Deaths

#Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_cases/total_deaths)*100 as DeathPrecentage
FROM portfolio.coviddeaths
WHERE location LIKE '%Albania%' AND continent IS NOT NULL 
ORDER BY 1,2

#Total Cases vs Population
#Shows what percentage of population infected with Covid

SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM portfolio.coviddeaths
ORDER BY 1,2

#Countries with Highest Infection Rate compared to Population

SELECT location, population, date,
	MAX(total_cases) as HighestInfectionRate, 
    MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolio.coviddeaths
GROUP BY location, population, date
ORDER BY PercentPopulationInfected DESC

#Countries with Highest Death Count per Population

SELECT location,
       MAX(total_deaths) as TotalDeathCount
FROM portfolio.coviddeaths
WHERE continent IS NOT NULL 
GROUP BY location
ORDER BY TotalDeathCount DESC

#BREAKING THINGS DOWN BY CONTINENT
#Showing contintents with the highest death count per population

SELECT continent, 
       MAX(total_deaths) as TotalDeathCount
FROM portfolio.coviddeaths
WHERE continent IS NOT NULL 
GROUP BY continent 
ORDER BY TotalDeathCount DESC 

#GLOBAL NUMBERS

SELECT 
  SUM(new_cases) as Total_cases, 
  SUM(new_deaths) as Total_deaths, 
  SUM(new_deaths/new_cases)*100 as DeathPercentage
FROM portfolio.coviddeaths
WHERE continent IS NOT NULL 
ORDER BY 1,2 

#Total Population vs Vaccinations
#Shows Percentage of Population that has recieved at least one Covid Vaccine

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM portfolio.coviddeaths dea
JOIN portfolio.covidvaccinations vac
 ON dea.location = vac.location 
 AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
ORDER BY 1,2

#Using CTE to perform Calculation on Partition By in previous query

WITH PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
       SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM portfolio.coviddeaths dea
JOIN portfolio.covidvaccinations vac
 ON dea.location = vac.location 
 AND dea.date = vac.date 
WHERE dea.continent IS NOT NULL 
) 
SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PopvsVac

#Using Temp Table to perform Calculation on Partition By in previous query

CREATE TABLE PercentPopulationVaccinated
( 
 Continent VARCHAR(255),
 Location VARCHAR(255),
 Date DATETIME,
 Population INT,
 New_vaccinations INT,
 RollingPeopleVaccinated INT
 )
 INSERT INTO PercentPopulationVaccinated
 SELECT dea.continent, 
        dea.location, 
        dea.date, 
        dea.population, 
        vac.new_vaccinations,
        SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) as RollingPeopleVaccinated
FROM portfolio.coviddeaths dea
JOIN portfolio.covidvaccinations vac
 ON dea.location = vac.location 
 AND dea.date = vac.date
 
 SELECT *, (RollingPeopleVaccinated/Population)*100 
FROM PercentPopulationVaccinated



