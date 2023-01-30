

/*SELECT location,date,total_cases,new_cases,total_deaths,population
FROM ['covid death$']*/

select location,date,total_cases,total_deaths,ROUND(total_deaths/total_cases*100,2)
FROM ['covid death$']
where location='United arab emirates' AND (date> '2022-1-1' AND date<'2023-1-1')
ORDER BY 1,2

-- total cases of covid vs population
select location,date,population,total_cases,ROUND(total_cases/population*100,2) as perc_cases
FROM ['covid death$']
where location='united states' 
ORDER BY 1,2

--countries with highest cases & highest percentage of population
select location,population,max(total_cases) as max_cases,max(total_cases/population*100) as perc_cases_out_totalpopulation
FROM [Portfolio project covid].dbo.['covid death$']
WHERE continent is not null
 group by location,population
ORDER BY max_cases DESC

--highest death count per population
select location,population,max(cast(total_deaths as int)) as max_death
FROM [Portfolio project covid].dbo.['covid death$']
WHERE continent is not null
 group by location,population
 
ORDER BY max_death DESC

--total death count by continent
select continent,max(cast(total_deaths as int)) as max_death
FROM [Portfolio project covid].dbo.['covid death$']
WHERE continent is not null
 group by continent
 
ORDER BY max_death DESC

--global cases %death out of newcases
select date,sum(new_cases) as total_cases,sum(cast(new_deaths as int)) as new_deaths,sum(cast(new_deaths as int))/(sum(new_cases))*100 as death_percentage
from [Portfolio project covid].dbo.['covid death$']
where continent is not null
group by date
order by date

--Total population vs vaccination
select d.location,d.date,d.population,new_vaccinations,sum(cast(new_vaccinations as decimal)) OVER (partition by d.location ORDER BY d.date)
as rolling_people_vaccinated
from [Portfolio project covid].dbo.['covid death$'] as d
INNER JOIN [Portfolio project covid].dbo.['covid vaccinations$'] as v
ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL AND d.date>'2021-1-1' --and d.location='albania'
order by d.location,d.date

--this is CTE (common expression table), we will use it to find %vaccinated people out of total population
with popvacc as (
select d.location,d.date,d.population,new_vaccinations,sum(cast(new_vaccinations as decimal)) OVER (partition by d.location ORDER BY d.date)
as rolling_people_vaccinated
from [Portfolio project covid].dbo.['covid death$'] as d
INNER JOIN [Portfolio project covid].dbo.['covid vaccinations$'] as v
ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL AND d.date>'2021-1-1' --and d.location='albania'
)

select location,date,population,new_vaccinations,cast (new_vaccinations as decimal)/population*100 as percent_pop_vaccinated
from popvacc
ORDER BY location,date

--creating another example of tables instead of CTE
DROP TABLE if exists percent_vaccinated
CREATE TABLE percent_vaccinated
(location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric)

INSERT INTO percent_vaccinated

select d.location,d.date,d.population,new_vaccinations,sum(cast(new_vaccinations as decimal)) OVER (partition by d.location ORDER BY d.date)
as rolling_people_vaccinated
from [Portfolio project covid].dbo.['covid death$'] as d
INNER JOIN [Portfolio project covid].dbo.['covid vaccinations$'] as v
ON d.location=v.location AND d.date=v.date
WHERE d.continent IS NOT NULL AND d.date>'2021-1-1' --and d.location='albania'
order by d.location,d.date

SELECT *
FROM percent_vaccinated

--Grouping by country,year,month,new_cases
WITH covid_cases_country AS (
SELECT location,datepart(year,date) AS year,datepart(month,date) AS month,new_cases
FROM [Portfolio project covid].dbo.['covid death$']
)

SELECT location,year,month,sum(new_cases) as new_cases
FROM covid_cases_country
GROUP BY location,year,month
ORDER BY location,year,month

--CREATE VIEW for country,year,month & new cases
CREATE VIEW cases_by_country AS 
WITH covid_cases_country AS (
SELECT location,datepart(year,date) AS year,datepart(month,date) AS month,new_cases
FROM [Portfolio project covid].dbo.['covid death$']
)
SELECT location,year,month,sum(new_cases) as new_cases
FROM covid_cases_country
GROUP BY location,year,month
SELECT *
FROM cases_by_country
ORDER BY location
