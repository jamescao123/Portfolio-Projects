Select *
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 3,4

--Select *
--From PortfolioProject..CovidVaccinations
--order by 3,4

--Step 1:Select Data that I'm going to be analysing

Select Location,date,total_cases,new_cases, total_deaths,population
From PortfolioProject..CovidDeaths
Where continent is not NULL
order by 1,2

--Step 2 Total Cases vs total Deaths
-- To show likelihood of dying if you contract covid in your country
Select Location,date,total_cases, total_deaths,
(total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
Where continent is not NULL
order by 1,2

-- Looking at Total cases Vs Population
-- Percentage of population got COvid

Select Location,date,Population,total_cases,
(total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where continent is not NULL
-- Where location like '%states%'
order by 1,2 

--Looking at countries with highes infection rate compared to population

Select Location,Population,MAX(total_cases)as HighestInfectionCount,
MAX((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not NULL
Group by Location, Population
order by 4 DESC

-- Showing countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
Where continent is not NULL
Group by Location
order by 2 DESC

--Looking at Death Count Per Pop By Continent
Select location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is  NULL
Group by location
order by 2 DESC


--Showing Continents with the highest death count per population

Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
Where continent is  Not NULL
Group by continent
order by 2 DESC


-- GLOBAL NUMBERS

Select 
Sum(new_cases) as total_cases, 
SUM(cast(new_deaths as int))as total_deaths, 
SUM(cast(new_deaths as int))/ sum(NEW_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not NULL
Order by 1,2

-- Looking at Total Population Vs Vaccinations
--Show Percentage of Population that has received at least one Covid Vaccine
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by dea.location ORDer by dea.location,dea.date) as RollingPeopleVaccinated,
--Rolling Count has to be location if it gets to a new country it will restart count again
--(RollingPeopleVaccinated/population)*100 try to figure % of pop gets vaccinated. Using CTE to solve this probem
From PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	Where dea.continent is NOT NULL
	Order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query


With PopvsVac(Continent, Location, Date, Population,New_vaccinations,RollingPeopleVaccinated)
as
(
Select 
dea.continent, 
dea.location, 
dea.date, 
dea.population, 
vac.new_vaccinations,
SUM(CONVERT(int,Vac.new_vaccinations)) OVER (Partition by dea.location ORDer by dea.location,dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
Join  PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location 
	and dea.date = vac.date
	Where dea.continent is NOT NULL
	--Order by 2,3
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
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 

Select * 
From PercentPopulationVaccinated