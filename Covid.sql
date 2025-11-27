select *
from Project2..CovidDeaths
order by 3,4

--select *
--from Project2..CovidVaccinations
--order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from Project2..CovidDeaths
order by 1,2

--Total Cases and Total Death, likelihood dying covid di suatu negara
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from Project2..CovidDeaths
where location like '%states%'
order by 1,2

--Total Cases vs Population and percentage population covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentPopulationInfected
from Project2..CovidDeaths
--where location like '%States%'--
order by 1,2

--Countries with highest infection rate compared to population
Select location, population, Max(Total_cases) as HighestInfectionCount, Max((Total_cases/Population))*100 as PercentPopulationInfected
from Project2..CovidDeaths
group by location, population
order by PercentPopulationInfected Desc

--Countries with highest death per population
select location, Max(cast(total_deaths as int)) as TotalDeathCount
from Project2..CovidDeaths
where continent is null
group by location
order by TotalDeathCount Desc

--Global Numbers
Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deathsm, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from Project2..CovidDeaths
where continent is null
--group by date
order by 1,2

--Total Population and Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
from Project2..CovidDeaths dea
join Project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

-- USE CTE 
with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
from project2..CovidDeaths dea
join Project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
select*, (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
--Drop Table if exist #PercentPopulationVaccinated--
create table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.date) as RollingPeopleVaccinated
from project2..CovidDeaths dea
join Project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
select*, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--create view to store data visualization
Create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location,
  dea.Date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/Population)*100
from Project2..CovidDeaths dea
join Project2..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
