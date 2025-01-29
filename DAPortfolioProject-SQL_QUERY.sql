select * From DAPortfolioProject..CovidDeaths
Where continent is not null
order by 3,4


select Location , date , total_cases,new_cases ,total_deaths,population
From DAPortfolioProject..CovidDeaths
order by 1,2

--Looking at total_cases Vs total_deaths
--Shows likelihood of dying if you contract covid in your country
select Location , date , total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From DAPortfolioProject..CovidDeaths
Where location like'%states%'
and continent is not null
order by 1,2

--Looking at total_cases Vs population
--Shows what percentage of population got covid
select Location , date , total_cases,population,(total_cases/population)*100 as DeathPercentage
From DAPortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
order by 1,2

--Looking at countries with highestinfection rate compared to population
select Location,Population ,  MAX(total_cases) as Highestinfectioncount,Max((total_cases/population))*100 as
PercentagePopulationInfected
From DAPortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
Group by Location,Population
order by PercentagePopulationInfected desc


--Showing countries with Highest death count per Population
select Location,MAX(cast(total_deaths as int)) as TotalDeathCount
From DAPortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
Group by Location
order by TotalDeathCount  desc

--LET'S BREAK THINGS BY CONTINENT 

select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From DAPortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
Group by  continent
order by TotalDeathCount  desc



--Showing continents with Highest death count per Population
select continent,MAX(cast(total_deaths as int)) as TotalDeathCount
From DAPortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
Group by  continent
order by TotalDeathCount  desc





--GLOBAL NUMBERS
select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths ,SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From DAPortfolioProject..CovidDeaths
--Where location like'%states%'
Where continent is not null
--Group by date
order by 1,2


--Looking at total population Vs vaccinations

Select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
  order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from DAPortfolioProject..CovidDeaths dea
Join DAPortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
	 Where dea.continent is not null
	 order by 2,3


--USE CTE 
With PopvsVac (continent,location , Date,Population, New_Vaccinations,RollingPeopleVaccinated)
as
(
Select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
  order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from DAPortfolioProject..CovidDeaths dea
Join DAPortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
	 Where dea.continent is not null
	-- order by 2,3
)
select* , ( RollingPeopleVaccinated /Population)*100
from PopvsVac 




--TEMP TABLE 

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric,
)

Insert into #PercentPopulationVaccinated

Select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
  order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from DAPortfolioProject..CovidDeaths dea
Join DAPortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
 --Where dea.continent is not null
-- order by 2,3

select* , ( RollingPeopleVaccinated /Population)*100
from #PercentPopulationVaccinated



-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent , dea.location , dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location
  order by dea.location,dea.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/population)*100
from DAPortfolioProject..CovidDeaths dea
Join DAPortfolioProject..CovidVaccinations vac
     on dea.location = vac.location
	 and dea.date = vac.date 
 Where dea.continent is not null
--order by 2,3


Select * from PercentPopulationVaccinated 