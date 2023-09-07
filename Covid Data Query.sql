--This is the data we want to look at
select location, date, total_cases, new_cases, total_deaths, population
From [Covid Data Analysis]..Covid_Deaths

--Looking at the Death Rate in the US over time
select location, date, round(cast(cast(total_deaths as float)/cast(total_cases as float) as float)*100, 2) as [Death Rate]
from [Covid Data Analysis]..Covid_Deaths
where location like '%states%'
order by 1, 2

--Looking at the Infection Rate in the US over time
select location, date,  round(cast(cast(total_cases as float)/cast(population as float) as float)*100, 2) as [Infection Rate]
from [Covid Data Analysis]..Covid_Deaths
where location like '%states%'
order by 1,2

--Looking at the overall Infection Rate for each country
select location, round(cast(max(cast(total_cases as float)/cast(population as float)) as float)*100, 2) as [Infection Rate]
from [Covid Data Analysis]..Covid_Deaths
where location is not null
group by location
order by [Infection Rate] desc

--Looking at the overall Death Rate for each country
select location, 
round(cast(cast(max(total_deaths) as float)/cast(max(total_cases) as float) as float)*100, 2) as [Death Rate]
from [Covid Data Analysis]..Covid_Deaths
where location is not null
group by location
order by [Death Rate] desc

--Looking at the overall Infection Rate by continent
select continent, 
round(cast(max(cast(total_cases as float)/cast(population as float)) as float)*100, 2) as [Infection Rate]
from [Covid Data Analysis]..Covid_Deaths
where continent is not null
group by continent
order by [Infection Rate] desc

--Looking at the overall Death Rate by continent
select continent, 
round(cast(cast(max(total_deaths) as float)/cast(max(total_cases) as float) as float)*100, 2) as [Death Rate]
from [Covid Data Analysis]..Covid_Deaths
where continent is not null
group by continent
order by [Death Rate] desc

--Looking at things on a global scale

--How many new cases and deaths on each day
select date, 
sum(new_cases) as [Total Cases for the Day],
sum(cast(new_deaths as int)) as [Total Deaths for the Day]
from [Covid Data Analysis]..Covid_Deaths
where continent is not null
group by date
order by 1, 2

--How many have been infected and died globally
select sum(new_cases) as [Total Cases],
sum(cast(new_deaths as int)) as [Total Deaths],
round(cast(cast(sum(cast(new_deaths as int)) as float)/cast(sum(new_cases) as float) as float)*100, 2) as [Death Rate]
from [Covid Data Analysis]..Covid_Deaths
where continent is not null
order by 1, 2


select deaths.continent, deaths.location, deaths.date, deaths.population,
vaccs.new_vaccinations, 
sum(convert(bigint, vaccs.new_vaccinations)) 
over (partition by deaths.location order by deaths.location, deaths.date) as [Total Vaccinations]
from [Covid Data Analysis]..Covid_Deaths deaths
join [Covid Data Analysis]..Covid_Vacc vaccs 
on deaths.location = vaccs.location and deaths.date = vaccs.date
where deaths.continent is not null
order by 2, 3

with PopulationVVacc (continent, location, date, population,new_vaccinations, [Total Vaccinations])
as 
(
select deaths.continent, deaths.location, deaths.date, deaths.population,
vaccs.new_vaccinations, 
sum(convert(bigint, vaccs.new_vaccinations)) 
over (partition by deaths.location order by deaths.location, deaths.date) as [Total Vaccinations]
from [Covid Data Analysis]..Covid_Deaths deaths
join [Covid Data Analysis]..Covid_Vacc vaccs 
on deaths.location = vaccs.location and deaths.date = vaccs.date
where deaths.continent is not null)

select location, cast(max(cast([Total Vaccinations] as float))/max(cast(population as float)) as float)*100 as [Vaccination Rate]
from PopulationVVacc
group by location
order by [Vaccination Rate] desc

drop table if exists PercPopVacc
create table PercPopVacc 
(continent nvarchar(255), 
location nvarchar(255), 
date datetime,
population numeric,
new_vaccinations numeric,
[Total Vaccinations] numeric)

insert into PercPopVacc
select deaths.continent, deaths.location, deaths.date, deaths.population,
vaccs.new_vaccinations, 
sum(convert(bigint, vaccs.new_vaccinations)) 
over (partition by deaths.location order by deaths.location, deaths.date) as [Total Vaccinations]
from [Covid Data Analysis]..Covid_Deaths deaths
join [Covid Data Analysis]..Covid_Vacc vaccs 
on deaths.location = vaccs.location and deaths.date = vaccs.date
where deaths.continent is not null

select *
from PercPopVacc


--views
create view PercentPopVacc as
select deaths.continent, deaths.location, deaths.date, deaths.population,
vaccs.new_vaccinations, 
sum(convert(bigint, vaccs.new_vaccinations)) 
over (partition by deaths.location order by deaths.location, deaths.date) as [Total Vaccinations]
from [Covid Data Analysis]..Covid_Deaths deaths
join [Covid Data Analysis]..Covid_Vacc vaccs 
on deaths.location = vaccs.location and deaths.date = vaccs.date
where deaths.continent is not null