
-- Data Exploration Using SQL Query

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2



--Total Deaths vs Total Cases

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location = 'United States'
order by date


--Total Cases vs Population

select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from CovidDeaths
where location = 'United States'
order by date


--Countries with highest infection count

select location, population, max(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentPopulationInfected
from CovidDeaths
group by location, population
order by PercentPopulationInfected desc



--Countries with highest death count
select location, population, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location, population
order by TotalDeathCount desc


--Continent with highest death count

select continent, max(total_deaths) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers

select sum(new_cases) as TotalNewCases, sum(new_deaths) as DeathCount, (sum(new_deaths)/sum(new_cases))*100 as DeathPercentage
from CovidDeaths
where continent is not null
order by TotalNewCases


-- Total Population vs Vaccinations

select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
sum(convert(bigint,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date)
from CovidDeaths
join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
order by 2,3;


--Using CTE 

With PopVsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as 
(
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
sum(convert(bigint,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date)
as RollingPeopleVaccinated
from CovidDeaths
join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
)

select *,(RollingPeopleVaccinated/Population)*100 from PopVsVac


-- Temp Table

Drop table if exists #PercentPopulationVaccinated
Create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
sum(convert(bigint,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date)
as RollingPeopleVaccinated
from CovidDeaths
join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100 from #PercentPopulationVaccinated



-- Creating View to store data

Create View PercentPopulationVaccinated as 
select CovidDeaths.continent, CovidDeaths.location, CovidDeaths.date, CovidDeaths.population, CovidVaccinations.new_vaccinations,
sum(convert(bigint,CovidVaccinations.new_vaccinations)) over (partition by CovidDeaths.location order by CovidDeaths.location,CovidDeaths.date)
as RollingPeopleVaccinated
from CovidDeaths
join CovidVaccinations
on CovidDeaths.location = CovidVaccinations.location
and CovidDeaths.date = CovidVaccinations.date
where CovidDeaths.continent is not null


select * from PercentPopulationVaccinated