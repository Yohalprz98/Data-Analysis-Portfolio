SELECT *
FROM CovidDeaths$
WHERE continent IS NOT NULL
ORDER BY 3,4


-- Selecting data 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100
FROM CovidDeaths$
order by 1,2


-- Total Cases vs Total Deaths
-- Probability of dying if you contracted Covid in 2020 and 2021
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM CovidDeaths$
order by 1,2

-- Total Cases vs Population
-- Percentage of population infected with Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 as PopulationInfectedPercentage
FROM CovidDeaths$
order by 1,2

-- Countries with highest infection rate compared to population
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population)*100) as 
PopulationInfectedPercentage
FROM CovidDeaths$
group by location, population
order by PopulationInfectedPercentage desc

-- Continent with the highest death count per population
SELECT  continent, MAX(cast(total_deaths as int)) as TotalDeathCount 
FROM CovidDeaths$
WHERE continent is not null
group by continent
order by TotalDeathCount desc


-- Global numbers

SELECT date, SUM(new_cases) as total_cases, SUM(CAST(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage 
FROM CovidDeaths$
where continent is not null
group by date
order by 1,2

-- Total Population vs Vaccinations (CTE)

WITH CTE_PopVsVac (Continent, Location, Date, Population, New_vaccinations, AddPeopleVaccinated)
as

(SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as AddPeopleVaccinated
FROM CovidDeaths$ as dea
JOIN CovidVaccinations$ as vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3 asc
)
SELECT *, (AddPeopleVaccinated/population)*100 as PercPeopleVaccinated
FROM CTE_PopVsVac


-- Total Population vs Vaccinations (TEMP TABLE)
CREATE TABLE #Temp_PopVsVac
(Continent varchar(255),
Location varchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
AddPeopleVaccinated numeric)

INSERT INTO #Temp_PopVsVac
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
	SUM(CONVERT(int, vac.new_vaccinations)) OVER (partition by dea.location order by dea.date) as AddPeopleVaccinated
FROM CovidDeaths$ as dea
JOIN CovidVaccinations$ as vac
ON  dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 1,2,3 asc

SELECT *, (AddPeopleVaccinated/population)*100 as PercPeopleVaccinated
FROM #Temp_PopVsVac
