--SELECT *
--FROM [Portfolio-projects]..CovidDeaths
--where continent is not null
--ORDER BY 3,4

--SELECT *
--FROM [Portfolio-projects]..CovidVaccinations
--ORDER BY 3,4

--SELECT location,date, total_cases, new_cases, total_deaths, population
--FROM [Portfolio-projects]..CovidDeaths
--ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS

SELECT location,date, total_cases, new_cases, total_deaths, (total_deaths/total_cases) *100 AS death_percentage
FROM [Portfolio-projects]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--TOTAL CASES VS POPULATION
-- PERCENTAGE THAT GOT COVID

SELECT location,date, total_cases, population, (total_cases/population) *100 AS death_percentage
FROM [Portfolio-projects]..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--Hightest infection rate vs POPULATION

SELECT location, MAX(total_cases) as highest_infection_count, population, MAX((total_cases/population)) *100 AS percent_population_infected
FROM [Portfolio-projects]..CovidDeaths
--WHERE location like '%states%'
GROUP BY location, population
ORDER BY percent_population_infected desc

--DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths as int))as total_death_count
FROM [Portfolio-projects]..CovidDeaths
--WHERE location like '%states%'
where continent is not null
GROUP BY location, population
ORDER BY total_death_count desc


-- BREAK IT DOWN BY CONTINENT

SELECT location, MAX(cast(total_deaths as int))as total_death_count
FROM [Portfolio-projects]..CovidDeaths
--WHERE location like '%states%'
where continent is null
GROUP BY location
ORDER BY total_death_count desc

-- GLOBAL NUMBERS

SELECT SUM(new_cases) as total_Cases, SUM(cast(new_deaths as int)) as total_deaths,SUM (cast(new_deaths as int)) / SUM(new_cases)* 100 as death_percentage
FROM [Portfolio-projects]..CovidDeaths
WHERE continent IS NOT NULL AND total_cases IS NOT NULL
--GROUP BY date
ORDER BY 1,2

-- TOTAL POPULATION VS VACCINATION

SELECT DEA.continent, DEA.location, DEA.date, DEA.population, DEA.new_vaccinations,
SUM (CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date ) as rolling_people_vaccinated

FROM [Portfolio-projects]..CovidDeaths DEA 
JOIN [Portfolio-projects]..CovidVaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
	WHERE DEA.continent IS NOT NULL
	ORDER BY 2,3



-- USE CTE
WITH pop_vs_vac(continent,  location, date, population,new_vaccinations ,rolling_people_vaccinated)
as
(
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, DEA.new_vaccinations,
SUM (CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date ) as rolling_people_vaccinated

FROM [Portfolio-projects]..CovidDeaths DEA 
JOIN [Portfolio-projects]..CovidVaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
	WHERE DEA.continent IS NOT NULL
	--ORDER BY 2,3
	)


	SELECT * , (rolling_people_vaccinated/population)*100
	FROM pop_vs_vac


--TEMP TABLE
DROP TABLE IF EXISTS #percent_population_vaccinated
CREATE TABLE #percent_population_vaccinated
(
continent nvarchar(255),
locationn nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

INSERT INTO #percent_population_vaccinated 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, DEA.new_vaccinations,
SUM (CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date ) as rolling_people_vaccinated

FROM [Portfolio-projects]..CovidDeaths DEA 
JOIN [Portfolio-projects]..CovidVaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
	--WHERE DEA.continent IS NOT NULL
	--ORDER BY 2,3

SELECT * , (rolling_people_vaccinated/population)*100
FROM  #percent_population_vaccinated


-- CREATE VIEW TO STORE DATA

CREATE VIEW percent_population_vaccinated as 
SELECT DEA.continent, DEA.location, DEA.date, DEA.population, DEA.new_vaccinations,
SUM (CONVERT(int, VAC.new_vaccinations)) OVER (PARTITION BY DEA.location ORDER BY DEA.location,DEA.date ) as rolling_people_vaccinated

FROM [Portfolio-projects]..CovidDeaths DEA 
JOIN [Portfolio-projects]..CovidVaccinations VAC
	ON DEA.location = VAC.location AND DEA.date = VAC.date
	WHERE DEA.continent IS NOT NULL
	--ORDER BY 2,3


	SELECT *
	FROM percent_population_vaccinated







