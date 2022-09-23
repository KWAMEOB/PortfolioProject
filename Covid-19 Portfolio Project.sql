
Select *
From [PortfolioProject].[dbo].[CovidDeaths]
Order by 3,4;


Select *
From [PortfolioProject].[dbo].[CovidVaccinations]
Order by 3,4;


-- Select Data that we are going to be using

Select location, date, total_cases, new_cases,total_deaths, population
From [PortfolioProject].[dbo].[CovidDeaths]
Order By 1,2 


-- Looking at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage 
From [PortfolioProject].[dbo].[CovidDeaths]
Where location like '%states%'
Order By 1,2


Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 As DeathPercentage 
From [PortfolioProject].[dbo].[CovidDeaths]
Where location like '%Ghana%'
Order By 1,2


-- Looking at Total cases vs Population
-- Shows what percentage of population got covid

Select location, date, population, total_cases,  (total_cases/population)*100 As PercentPopulationInfected 
From [PortfolioProject].[dbo].[CovidDeaths]
Where location Like '%states%'
Order By 1,2

Select location, date, population, total_cases,  (total_cases/population)*100 As PercentPopulationInfected 
From [PortfolioProject].[dbo].[CovidDeaths]
Where location Like '%Ghana%'
Order By 1,2

-- Looking at countries with highest infection rate compared to population

Select location,  population, max(total_cases) As HighestInfectionCount,  max((total_cases/population))*100 As PercentPopulationInfected 
From [PortfolioProject].[dbo].[CovidDeaths]
Group By location,population
Order By PercentPopulationInfected desc


-- Showing countries with highest death count per population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProject].[dbo].[CovidDeaths]
Where continent is not null 
Group by Location
order by TotalDeathCount desc


-- BREAKING THINGS DOWN BY CONTINENT

-- Showing contintents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From [PortfolioProject].[dbo].[CovidDeaths]
Where continent is not null 
Group by continent
order by TotalDeathCount desc


-- GLOBAL NUMBERS

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From [PortfolioProject].[dbo].[CovidDeaths]
where continent is not null 
order by 1,2



--Select *
--From [PortfolioProject].[dbo].[CovidVaccinations]


 Total Population vs Vaccinations
 Shows Percentage of Population that has recieved at least one Covid Vaccine

Select * 
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



-- Using Temp Table to perform Calculation on Partition By in previous query

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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From [PortfolioProject].[dbo].[CovidDeaths] dea
Join [PortfolioProject].[dbo].[CovidVaccinations] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null


Select *
From PercentPopulationVaccinated