select *
from PorfolioProject..CovidDeaths$
order by 3,4

--select *
--from CovidVaccinations$
--order by 3,4

-- Select Data that we are going to using / Seleccionar datos que vamos a usar

select location, date, total_cases, new_cases, total_deaths, population
from PorfolioProject..CovidDeaths$
order by 1,2 

-- Looking at total cases vs Total deaths / Busca casos totales vs total muertes
-- Shows likelihoodof dying if you contract covid in your country /  Muestra la probabilidad de morir si contraes covid en tu país

select location, date, total_cases, new_cases, total_deaths, (cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from PorfolioProject..CovidDeaths$
where location like 'Chile'
order by 1,2 

-- Looking at total cases vs Population / mirando casos totales vs Población
-- Shows population got covid / Muestra Población que contrajo Covid

select location, date, total_cases, new_cases, population, (cast(total_cases as float)/cast(population as float))*100 as PercentPopulationInfected
from PorfolioProject..CovidDeaths$
where location like 'Chile'
order by 1,2 

-- What's the highest infection rate compared to population / Cuál es la tasa de infección más alta en comparación con la población?

select location, population, max(cast(total_cases as float)) as HighestInfection, Max((cast(total_cases as float)/cast(population as float)))*100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths$
--where location like 'Chile'
Group by location, population
order by PercentPopulationInfected desc

-- Let's break things down by continent / Desglosemos las cosas por continente

select location,  max(cast(total_deaths as float)) as TotalDeathCount
From PorfolioProject..CovidDeaths$
--where location like 'Chile'
where continent is null
Group by location
order by TotalDeathCount desc

-- Showing countries with highest death count per population / Mostrando países con el mayor recuento de muertes por población

select location,  max(cast(total_deaths as float)) as TotalDeathCount
From PorfolioProject..CovidDeaths$
--where location like 'Chile'
where continent is not null
Group by location
order by TotalDeathCount desc


-- showing continents with highest death count per poplation / mostrando los continentes con el mayor recuento de muertes por población

select continent,  max(cast(total_deaths as float)) as TotalDeathCount
from PorfolioProject..CovidDeaths$
--where location like 'Chile'
where continent is not null
Group by continent
order by TotalDeathCount desc

-- Global numbers / Números globales

select  SUM(cast(new_cases as float)) as total_cases, SUM(cast(new_deaths as float)) as total_deaths, SUM(cast(new_deaths as float))/NULLIF(SUM(cast(new_cases as float)),0)*100 as DeathPercentage
from PorfolioProject..CovidDeaths$
--where location like 'Chile'
where continent  is not null
--group by date
--having count(total_cases) > 0
order by 1,2 

-- Looking at total population vs vaccinations / En cuanto a la población total frente a las vacunas

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as float)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- Use CTE / Uso CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
from PopvsVac


-- TEMP TABLE / Tabla temporal
Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations / Creando una vista para visualizaciones posteriores

create view PercentPopulatioVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(CONVERT(FLOAT,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.date) as RollingPeopleVaccinated
from PorfolioProject..CovidDeaths$ dea
join PorfolioProject..CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulatioVaccinated