SELECT *
FROM CovidDeaths;

SELECT *
FROM CovidVaccinations;

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM CovidDeaths
ORDER BY 1,2

-- TOTAL CASES VS TOTAL DEATHS
--LIKELIHOOD OF DYING IF YOU ARE LIVING IN A SPECIFIC COUNTRY

SELECT location,date,total_cases,total_deaths,(total_deaths * 100 / total_cases)  AS DeathPercentage
FROM CovidDeaths
WHERE location='India'
ORDER BY 1,2

-- TOTAL CASES VS POPULATION
-- SHOWS HOW MUCH POPULATION GOT COVID

SELECT location,total_cases,population,(total_cases / population) * 100 AS PopulationPercentage
FROM CovidDeaths
WHERE location='India'
ORDER BY 1,2

-- COUNTRIES WITH HIGHEST INFECTION RATE

SELECT location,population,MAX(total_cases) AS InfectionRate, MAX(total_cases/population) * 100 AS PopulationPercentage
FROM CovidDeaths
GROUP BY location,population
ORDER BY PopulationPercentage DESC

-- COUNTRY DEATH COUNT BY COVID

SELECT location, MAX(CAST(total_deaths AS int)) AS DeathCount
FROM CovidDeaths
WHERE continent is not null
GROUP BY location
ORDER BY DeathCount DESC

SELECT location,MAX(CAST(total_deaths AS INT)) AS DeathCount
FROM CovidDeaths
WHERE continent is null
GROUP BY location
ORDER BY DeathCount DESC

-- GLOBAL NUMBERS

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int)) AS total_deaths, SUM(CAST(new_deaths AS int))/ NULLIF(SUM(new_cases),0)*100
AS DeathPercentage
FROM CovidDeaths
WHERE continent is not null
ORDER BY 1,2


-- TOTAL POPULATION VS TOTAL VACCINATIONS

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location)
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

-- USE CTE EXPRESSION
WITH PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
CREATE TABLE #PercentPopulationVaccinated
(continent nvarchar (255),
location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
);
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated

-- VIEWS TO BE USED LATER FOR DATA VISUALIZATION

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccinations vac
ON dea.location = vac.location
AND dea.date = vac.date