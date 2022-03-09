SELECT *
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%states%' or continent is not null
order by 1,2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid

SELECT location, date, total_cases, population, (total_deaths/population)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like '%states%' or continent is not null
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to Population
SELECT location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by population, location
order by PercentPopulationInfected desc

-- Breaking things down by Continent


SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Showing the Continents with the Highest Death Count per Population

SELECT continent, max(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

SELECT sum(new_cases) as total_cases, sum(cast (new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like '%states%' 
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--use cte

with PopvsVac (Continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

select *, (RollingPeopleVaccinated/population)*100
From PopvsVac


-- temp table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated


--Creating View to store date for later visualizations

create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
--, (
from PortfolioProject..CovidDeaths$ dea
Join PortfolioProject..CovidVaccinations$ vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select *
from PercentPopulationVaccinated