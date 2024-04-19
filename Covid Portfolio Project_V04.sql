select *
from portfolioproject.coviddeaths_02
where continent is not null
order by 3,4;

-- select *
-- from portfolioproject.covidvaccinations_02
-- order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from portfolioproject.coviddeaths_02
where continent is not null
order by 1,2;

-- Total cases VS total deaths
-- Looking at the percentage gives an idea of the likelihood of death if covid is contracted (specific to country in this case)
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as percentDeceased 
from portfolioproject.coviddeaths_02
where location like '%states%'
order by 1,2;


-- Total cases VS population 
select location, date, population, total_cases, (total_cases/population)*100 as  percentInfected
from portfolioproject.coviddeaths_02
-- where location like '%states%'
where continent is not null
order by 1,2;

-- Total Cases by Location highest to lowest with min of one case
select location, MAX(total_cases) as totalInfected
from portfolioproject.coviddeaths_02
where continent is not null AND total_cases is not null
group by location
order by totalInfected desc;

-- Highest infection rate by Location and percent infected
select location, population, MAX(total_cases) as totalInfected, MAX((total_cases/population))*100 as  percentInfected
from portfolioproject.coviddeaths_02
group by location, population 
order by percentInfected desc;

-- Countries with highest death count 
select location, MAX(cast(total_deaths as unsigned)) as deathCount
from portfolioproject.coviddeaths_02
where continent is not null 
group by location
order by deathCount desc;

-- Continent with highest death count 
Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject.coviddeaths_02
-- Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- Global Numbers 
-- percent deceased by date 
select date, SUM(new_cases) as totalCases, SUM(new_deaths) as totalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as percentDeceased
from portfolioproject.coviddeaths_02
where continent is not null
group by date
order by 1,2;

-- Total deaths vs Cases, percent deceased for the whole world 
select SUM(new_cases) as totalCases, SUM(new_deaths) as totalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as percentDeceased
from portfolioproject.coviddeaths_02
where continent is not null
order by 1,2;

-- Total vaccinations by country 
SELECT location, SUM(total_vaccinations) as total_vacc
FROM portfolioproject.covidvaccinations_02
where continent is not null
group by location
order by total_vacc desc;

-- Total vaccinations by continent
SELECT continent, SUM(total_vaccinations) as total_vacc
FROM portfolioproject.covidvaccinations_02
where continent is not null
group by continent
order by total_vacc desc;

-- Looking at vaccinations 

-- Total population VS vaccinations 
select deth.continent, deth.location, deth.date, deth.population, vacc.new_vaccinations,
SUM(convert(new_vaccinations, unsigned)) OVER (partition by location order by location, date) as RollingVaccinations
from portfolioproject.coviddeaths_02 deth
join portfolioproject.covidvaccinations_02 vacc
	on deth.location = vacc.location
where deth.continent is not null
    and deth.date = vacc.date
order by 2,3;


-- CTE to calculate percentage on 'rollingvaccinations' 
with PopsVAc (continent, lcoation, date, population, new_vaccinations, RollingVaccinations)
as
(
select deth.continent, deth.location, deth.date, deth.population, vacc.new_vaccinations,
SUM(convert(new_vaccinations, unsigned)) OVER (partition by location order by location, date) as RollingVaccinations
from portfolioproject.coviddeaths_02 deth
join portfolioproject.covidvaccinations_02 vacc
	on deth.location = vacc.location
    and deth.date = vacc.date
    where deth.continent is not null
)
select *, (RollingVaccinations/population)*100 as percentVaccinated
from PopsVac;


-- Temp table to use rollingVaccinations
drop table if exists PercentPopulationVaccinated;
create table PercentPopulationVaccinated
(
continent nchar (255),
location nchar (255),
date date,
population double,
new_vaccinations double, 
RollingVaccinations double
);
insert into PercentPopulationVaccinated
select deth.continent, deth.location, deth.date, deth.population, vacc.new_vaccinations,
SUM(convert(new_vaccinations, unsigned)) OVER (partition by location order by location, date) as RollingVaccinations
from portfolioproject.coviddeaths_02 deth
join portfolioproject.covidvaccinations_02 vacc
	on deth.location = vacc.location
    and deth.date = vacc.date
    where deth.continent is not null;

select *, (RollingVaccinations/population)*100 as percentVaccinated
from PercentPopulationVaccinated;


-- Creating views for later visualization

-- 001 Death percentage world wide
create view death_percent_worldwide as
select SUM(new_cases) as totalCases, SUM(new_deaths) as totalDeaths, SUM(new_deaths)/SUM(new_cases)*100 as percentDeceased
from portfolioproject.coviddeaths_02
where continent is not null
order by 1,2;

-- 002 Death Count by Continent
create view death_count_by_continent as
Select location, SUM(new_deaths) as TotalDeathCount
From PortfolioProject.coviddeaths_02
-- Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc;

-- 003 Percent infected by country
create view percent_infected_bycountry as
select location, population, MAX(total_cases) as totalInfected, MAX((total_cases/population))*100 as  percentInfected
from portfolioproject.coviddeaths_02
group by location, population 
order by percentInfected desc;

-- 004 Percent of Population infected with dates
create view percent_infected_byday_country as
Select Location, Population, date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject.coviddeaths_02
-- Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc;





