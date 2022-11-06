USE PortfolioProject
GO


SELECT * FROM PortfolioProject..CD
WHERE Continent IS NOT NULL
ORDER BY 3,4;




--SELECT * FROM PortfolioProject..CV
--ORDER BY 3,4;

--SELECT Location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..CD
--ORDER BY 1,2;

----Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying from Covid 
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathChance
FROM PortfolioProject..CD
--WHERE Location LIKE 'Russia%'
ORDER BY 1,2;
--next

SELECT TOP 10 Location, date, population, total_cases, (total_cases/population)*100 AS GetCovidChance
FROM PortfolioProject..CD
--WHERE Location LIKE 'Russia'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) as InfectedPercentage
FROM PortfolioProject..CD
GROUP BY Location, Population
ORDER BY 4 DESC;

--Showing Countries with Highest Death Count per Population

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT Location, MAX(cast(total_deaths AS INT)) AS TotalDeathCount, MAX((total_deaths/population)*100) as DeathPercentage
FROM PortfolioProject..CD
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY 3 DESC;

--LET'S BREAK THIS DOWN BY CONTINENT
SELECT Continent, MAX(cast(total_deaths AS INT)) AS TotalDeathCount, MAX((total_deaths/population)*100) as DeathPercentage
FROM PortfolioProject..CD
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY 3 DESC;


--#########GLOBAL NUMBERS##########
--		BY DATE
SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathChance
FROM PortfolioProject..CD
WHERE Continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;
--		OVER ALL
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths AS INT)) AS total_deaths, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS DeathChance
FROM PortfolioProject..CD
WHERE Continent IS NOT NULL
ORDER BY 1,2;
--####################

-- Looking at Total Population vs Vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinated
FROM
PortfolioProject..CD JOIN PortfolioProject..CV
ON CD.location=CV.location AND cd.date=cv.date
WHERE cd.Continent IS NOT NULL
ORDER BY 1,2,3;


-- USE CTE
WITH PercentVaccinated (Continent, Location, Date, Population, New_Vaccinations, RollingVaccinated)
AS
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinated
FROM
PortfolioProject..CD JOIN PortfolioProject..CV
ON CD.location=CV.location AND cd.date=cv.date
WHERE cd.Continent IS NOT NULL
--ORDER BY 1,2,3;
)
SELECT *, (RollingVaccinated/Population*100) AS PercentVaccinated FROM
PercentVaccinated;

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentVaccinated
CREATE TABLE #PercentVaccinated
(
Continent NVARCHAR(255),
Location NVARCHAR(255),
Date DATETIME,
Population NUMERIC,
New_vaccinations NUMERIC,
RollingVaccinated NUMERIC
)
INSERT INTO #PercentVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinated
FROM
PortfolioProject..CD JOIN PortfolioProject..CV
ON CD.location=CV.location AND cd.date=cv.date
WHERE cd.Continent IS NOT NULL
--ORDER BY 1,2,3;

SELECT * FROM #PercentVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(CONVERT(bigint,cv.new_vaccinations)) OVER (PARTITION BY cd.location ORDER BY cd.location, cd.date) AS RollingVaccinated
FROM
PortfolioProject..CD JOIN PortfolioProject..CV
ON CD.location=CV.location AND cd.date=cv.date
WHERE cd.Continent IS NOT NULL
--ORDER BY 1,2,3;

DROP VIEW PercentVaccinated

SELECT * FROM PercentVaccinated