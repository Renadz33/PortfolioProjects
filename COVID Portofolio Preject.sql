
select *
from PortfolioProject..CovidDeath
where continent is not null
order by 3,4


--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4


-- select Data that we are going to be using


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
where continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths 

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
order by 1,2



--select *
--from PortfolioProject..CovidVaccinations
--order by 3,4

-- select Data that we are going to be using


select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeath
order by 1,2


-- Looking at Total Cases vs Total Deaths 
-- show Likelihood of dying if you contract covid in your country  
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeath
where location like '%states'
and continent is not null
order by 1,2

Select *
From dbo.CovidDeath
EXEC sp_help 'dbo.CovidDeath';
ALTER TABLE dbo.CovidDeath
ALTER COLUMN total_cases float


Select *
From dbo.CovidDeath
EXEC sp_help 'dbo.CovidDeath';
ALTER TABLE dbo.CovidDeath
ALTER COLUMN total_deaths float 


-- -- Looking at Total Cases vs Population
-- shows what percentage of population got covid 
select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
--where location like '%states'
order by 1,2


-- Looking at countries with Highest Infection Rate Compared to Population 
select location, population, Max(total_cases) As HighestInfectionCount, MAx((total_cases/population))*100 as PercentPopulationInfected
from PortfolioProject..CovidDeath
--where location like '%states'
where continent is not null
Group by location, population
order by PercentPopulationInfected desc



-- Break things down by continent
--show countries with highest death count per population

select location, Max(cast(total_deaths As int)) AS TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%states'
where continent is not null
Group by location
order by TotalDeathCount desc


---- showing continents with the highest death count per population 
select continent, Max(cast(total_deaths As int)) AS TotalDeathCount
from PortfolioProject..CovidDeath
--where location like '%states'
where continent is not null
Group by continent
order by TotalDeathCount desc



-- Global Numbers 
set ANSI_WARNINGS OFF
select Sum(new_cases)as total_cases,Sum(cast(new_deaths as int))as total_deaths ,Sum(cast(New_deaths as int))/Nullif(SUM(new_Cases),0)*100 as DeathPercentage
from PortfolioProject..CovidDeath
--where location like '%states'
where continent is not null
--Group by date
order by 1,2


--Looking at Total Population vs Vaccination
-- USE CTE

with PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *
from PopvsVac



--Temp table

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100 As vaccinated
from #PercentPopulationVaccinated



-- create view to store date for later visualizations

Create View PercentPopulationVaccinated As
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as bigint)) over (partition by dea.location order by dea.location, dea.date) As RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
from PortfolioProject..CovidDeath dea
join PortfolioProject..CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated