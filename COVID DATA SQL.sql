show databases;
drop database CovidDeath;

CREATE SCHEMA `CovidDeaths`;

use CovidDeaths;

Select * from covdeaths;

Select count(date) from covdeaths;
Select count(date) from covidvaccinations;


describe covdeaths;
describe covidvaccinations;

UPDATE `covdeaths`
SET `date` = str_to_date( `date`, '%m/%d/%Y' );

UPDATE `covidvaccinations`
SET `date` = str_to_date( `date`, '%m/%d/%Y' );

select * from covidvaccinations
where continent is not null
order by 3,4;

select * from covdeaths
where continent is not null
order by 3,4;

#Selecting data which is required 

select location,date,total_cases,new_cases,total_deaths, population
from covdeaths
where continent is not null
order by 1,2;

#Looking at Total Cases vs Total Deaths in INDIA
#shows likelihood of dying if you get covid infected in your country

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Death_percent
from covdeaths
where location like '%India%' and continent is not null
order by 1,2;

#Looking at Total Cases vs Population
#Shows what percent of population got covid infected

select location,date,population,total_cases,(total_cases/population)*100 as Infected_Percent
from covdeaths
where location like '%India%' and continent is not null
order by 1,2;

##Looking at countries with higher infection rate compared to population

select location,population,MAX(total_cases) as Highest_InfectionCount,MAX((total_cases/population))*100 as Infected_Percent
from covdeaths
where continent is not null
Group by location,population
order by Infected_Percent desc;

#Showing Countries with Highest death Count per Population

select location,population,MAX(cast(total_deaths as unsigned)) as Total_DeathCount
# cast allows us to change the datatype of the given variable
from covdeaths
where continent is null
Group by location,population
order by Total_DeathCount desc;

#BREAKING THINGS DOWN BY CONTINENT
-- Showing Continents with highest Death count per population

select continent,MAX(cast(total_deaths as unsigned)) as Total_DeathCount
-- convert(unsigned,total_deaths)
from covdeaths
where continent is not null
Group by continent
order by Total_DeathCount desc;

-- GLOBAL NUMBERS

select sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,sum(new_deaths)/sum(new_cases)*100 as Death_percentage 
from covdeaths
where continent is not null
-- group by date
order by 1,2;


-- Looking at Total Population Vs Vaccinations

Select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(v.new_vaccinations) 
OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from covdeaths d
join covidvaccinations as v 
    on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	order by 2,3;

-- using CTE

with PopvsVac (continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(v.new_vaccinations) 
OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
from covdeaths as d
join covidvaccinations as v 
    on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	-- order by 2,3
	)
select *,(RollingPeopleVaccinated/population)*100 as perc_RollingPeopleVaccinated
from PopvsVac;


-- Creating View to store data for Later Visualizations

DROP TABLE PercentPopulationVaccinated;

CREATE VIEW PercentPopulationVaccinated as
Select d.continent,d.location,d.date,d.population,v.new_vaccinations,SUM(v.new_vaccinations) 
OVER (partition by d.location order by d.location,d.date) as RollingPeopleVaccinated
-- (RollingPeopleVaccinated/population)*100
from covdeaths as d
join covidvaccinations as v 
    on d.location = v.location
	and d.date = v.date
	where d.continent is not null
	-- order by 2,3
;
Select * from PercentPopulationVaccinated;