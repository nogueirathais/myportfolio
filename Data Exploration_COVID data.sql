select * from MyPortfolio..CovidDeaths
Where continent is not null
order by 3,4

--select * from MyPortfolio..CovidVaccinations
--order by 3,4

--Select Data that we are going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
From MyPortfolio..CovidDeaths
Where continent is not null
Order by 1,2

--Looking at the Total cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From MyPortfolio..CovidDeaths
Where location like '%brazil%' and continent is not null
Order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From MyPortfolio..CovidDeaths
--Where location like '%brazil%' 
Where continent is not null
Order by 1,2

--Looking at countries with highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount, (MAX(total_cases/population))*100 as PercentPopulationInfected
From MyPortfolio..CovidDeaths
Where continent is not null
Group by location, population
Order by PercentPopulationInfected desc

--Showing countries with Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From MyPortfolio..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--LET'S BREAK THINGS DOWN BY CONTINENT

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From MyPortfolio..CovidDeaths
Where continent is null 
and location not like '%income%'
Group by location
Order by TotalDeathCount desc

--GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, 
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From MyPortfolio..CovidDeaths
--Where location like '%brazil%' and 
Where continent is not null
--Group by date
Order by 1,2

-- Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From MyPortfolio..CovidDeaths dea
Join MyPortfolio..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3


--Using CTE

With PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From MyPortfolio..CovidDeaths dea
Join MyPortfolio..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100 
From PopvsVac

-- TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
continent nvarchar (225),
location nvarchar (255),
date datetime,
population numeric, 
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From MyPortfolio..CovidDeaths dea
Join MyPortfolio..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100 
From #PercentPopulationVaccinated

--Create view to store data for later visualization

USE MyPortfolio
GO
Create view PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(convert(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, 
dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
From MyPortfolio..CovidDeaths dea
Join MyPortfolio..CovidVaccinations vac 
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * from PercentPopulationVaccinated