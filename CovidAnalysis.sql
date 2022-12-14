select * from dbo.CovidDeaths$
order by 3,4;

--select data that we are going to be using. 
select Location, date ,total_cases, new_cases, total_deaths, population
from Portfolio.dbo.CovidDeaths$
order by 1,2

-- Looking at Total cases vs Total Deaths
select Location, date ,total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolio.dbo.CovidDeaths$
order by 1,2


-- Looking at Total cases vs Total Deaths for India
-- shows likelihood of dying if you have contracted covid in india
select Location, date ,total_cases, total_deaths, (total_deaths/total_cases)*100 as deathpercentage
from Portfolio.dbo.CovidDeaths$
where Location like '%India%'
order by 1,2

--Looking at the total cases vs Population for India
select Location, date ,total_cases, population , (total_cases/population)*100 as Percentpopulation
from Portfolio.dbo.CovidDeaths$
where Location like '%India%'
order by 1,2

--Country with highest infection rate wrt population
Select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as 
PercentPopulationInfected 
from Portfolio.dbo.CovidDeaths$
Group by location,population
order by PercentPopulationInfected desc


--Countries with highest death count per population
Select location, max(cast(total_deaths as int)) as TotalDeathCount 
from Portfolio.dbo.CovidDeaths$
where continent is not null
Group by location
order by TotalDeathCount desc

--- Lets break things down by continent 

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
where continent is null
Group by location 
order by TotalDeathCount desc

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
where continent is not null
Group by continent 
order by TotalDeathCount desc

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From Portfolio..CovidDeaths$
where continent is not null
Group by location 
order by TotalDeathCount desc

--Global Numbers
Select SUM(new_cases) as Cases, SUM(cast(new_deaths as float)) as DeathToll, (SUM(cast(new_deaths as float))/SUM(new_cases))*100 as DeathPercentage
From Portfolio..CovidDeaths$
--where location like '%India%'
where continent is not null
--group by date
order by 1,2

Select date,SUM(new_cases) as Cases, SUM(cast(new_deaths as float)) as DeathToll, (SUM(cast(new_deaths as float))/SUM(new_cases))*100 as DeathPercentage
From Portfolio..CovidDeaths$
--where location like '%India%'
where continent is not null
group by date
order by 1,2


--- Looking at Total Population vs Vaccinations ------------

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio.dbo.CovidDeaths$ dea
Join vacinations.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--- using CTE ---- 
With PopVsVac(continent,location,date,population,new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from Portfolio.dbo.CovidDeaths$ dea
Join vacinations.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (RollingPeopleVaccinated/population)*100
from PopVsVac


---Temp Table

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER(Partition by dea.location ) as RollingPeopleVaccinated
from Portfolio.dbo.CovidDeaths$ dea
Join vacinations.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--Create View for store data for later visualizations 

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(Convert(bigint,vac.new_vaccinations)) OVER(Partition by dea.location ) as RollingPeopleVaccinated
from Portfolio.dbo.CovidDeaths$ dea
Join vacinations.dbo.CovidVaccinations$ vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3