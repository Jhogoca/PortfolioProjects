--Select *
--From PortfolioProject..CovidDeaths
--Order By 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--Order By 3,4

-- Select Data thar we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
Order By 1,2

-- Looking at Toltal Cases vs Total Deaths
-- Shows the Likelyhood of dying if you contact covid in your country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Order By 1,2

--Looking at the total cases vs population
--Shows what percentage of populatuon got covid
Select location, date, population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%States%'
Order By 1,2

-- Looking at Countries with Highest Infection Rate compared to Population

Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))
*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%States%'
Group By location, population
Order By PercentPopulationInfected desc


-- Showing the countries with highest death count per population

Select location, MAX(cast(Total_deaths as  int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
where continent is not null
Group By location
Order By TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

Select continent, MAX(cast(Total_deaths as  int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
where continent is not null
Group By continent
Order By TotalDeathCount desc

-- Showing the continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as  int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%States%'
where continent is not null
Group By continent
Order By TotalDeathCount desc


-- Global numbers
 Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases) 
 as DeathPercentage
 From PortfolioProject..CovidDeaths
 --Where location like '%states%'
where continent is not null
Group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)

Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

-- Temp Table
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


Insert Into #PercentPopulationVaccinated

Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select  dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location,
dea.Date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated