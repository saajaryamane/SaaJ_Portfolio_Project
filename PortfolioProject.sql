select *
from CovidDeaths
where continent is NOT null
order by 3,4

--select *
--from CovidVaccinations
--order by 3,4

--Select needed data

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths
order by 1,2

--Looking at deaths as percentage of cases
--Chances of dying after contracting covid in a specific country
select location, date, total_cases, total_deaths, Round ((total_deaths/total_cases)*100, 2) as Death_Percentage
from CovidDeaths
where location = 'India'
order by 1,2

--Looking at total cases vs population
--What percentage of the population got Covid?
select location, date, total_cases, population, Round ((total_cases/population)*100, 4) as Cases_Percentage
from CovidDeaths
where location = 'India'
order by 1,2

--Which countries had the highest infection rates compared to their population?

select location, population, Max(total_cases) as HighestCaseCount, 
Max(Round((total_cases/population)*100, 2)) as PercentOfPopulationInfected
from CovidDeaths
group by location, population
order by 4 desc

--Which countries had the highest death count as percentage of population?
select location, population, Max(cast(total_deaths as int)) as HighestDeathCount, 
Max(Round((total_deaths/population)*100, 2)) as PercentOfPopulationDead
from CovidDeaths
where continent is not null
group by location, population
order by 4 desc

--Looking at the number of deaths per continent
Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from [Portfolio Project]..CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc

--Cases and deaths globally for every date--

select date, sum (new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths,
sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Portfolio Project]..CovidDeaths
--where location = 'India'
where continent is not null
group by date
order by DeathPercentage desc


--Combining CovidDeaths and CovidVaccinations tables
select *
from [Portfolio Project]..CovidDeaths DeathsTable
join [Portfolio Project]..CovidVaccinations VaccTable
on DeathsTable.location = VaccTable.location
and DeathsTable.date = VaccTable.date
where DeathsTable.continent is not null
order by 2,3

--Inserting a Rolling Count of People Vaccinated and Percent Vaccinated

with PopvsVac (continent, location, date, population, new_vaccinations, RollingCountPeopleVaccinated)
as
(
select DeathsTable.continent, DeathsTable.location, DeathsTable.date, DeathsTable.population, VaccTable.new_vaccinations
, Sum(cast(VaccTable.new_vaccinations as int)) over (partition by DeathsTable.location order by DeathsTable.location
, DeathsTable.date) as RollingCountPeopleVaccinated
from [Portfolio Project]..CovidDeaths DeathsTable
join [Portfolio Project]..CovidVaccinations VaccTable
on DeathsTable.location = VaccTable.location
and DeathsTable.date = VaccTable.date
where DeathsTable.continent is not null
--order by 2,3
)
Select *, (RollingCountPeopleVaccinated/population)*100
from PopvsVac

--Creating VIEW to store data for use in later visualizations
Create View PercentPopulationVaccinated as 
select DeathsTable.continent, DeathsTable.location, DeathsTable.date, DeathsTable.population, VaccTable.new_vaccinations
, Sum(cast(VaccTable.new_vaccinations as int)) over (partition by DeathsTable.location order by DeathsTable.location
, DeathsTable.date) as RollingCountPeopleVaccinated
from [Portfolio Project]..CovidDeaths DeathsTable
join [Portfolio Project]..CovidVaccinations VaccTable
on DeathsTable.location = VaccTable.location
and DeathsTable.date = VaccTable.date
where DeathsTable.continent is not null
--order by 2,3
