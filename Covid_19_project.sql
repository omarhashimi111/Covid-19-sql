-- Covid 19 PROJECT 

-- CREATING DATABASE
CREATE DATABASE Covid_19;
-- I import to tables from CSV files
-- Covid deaths and Covid vaccinations
USE Covid_19;

-- Explorations 
SELECT *
FROM CovidDeaths
ORDER BY 3,4;


SELECT Location, date , total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2;


-- Looking at total cases and total deaths percentage
SELECT Location, date , total_cases, total_deaths, (total_deaths / total_cases)*100 as Death_percentage
FROM CovidDeaths
ORDER BY 1,2;


-- looking at what percent of the population has gotten covid 19
SELECT Location, date ,population, total_cases, (total_cases / population)*100 as infected_percentage
FROM CovidDeaths
ORDER BY 1,2;


-- Looking at the countries with the highes infection compare to population
SELECT Location,population, MAX(total_cases)as highest_case, MAX(total_cases / population)*100 as country_case_percentage
FROM CovidDeaths
GROUP BY Location,population
ORDER BY country_case_percentage DESC;


-- Changing data type of Total_deaths column
ALTER TABLE CovidDeaths MODIFY Total_deaths INT;


-- Looking at the countries with the highest death compare to population
SELECT Location, MAX(cast(Total_deaths as DECIMAL)) as max_deaths_per_country
FROM CovidDeaths
GROUP BY Location
ORDER BY max_deaths_per_country DESC;

-- Lets see total deaths by continent
SELECT continent,SUM(cast(new_deaths as DECIMAL)) as max_deaths_per_continent
FROM CovidDeaths
GROUP BY continent
ORDER BY max_deaths_per_continent DESC;

-- Let's Look at GLOBAL NUMBERS
SELECT SUM(cast(new_cases as DECIMAL))as total_cases,SUM(cast(new_deaths as DECIMAL)) as total_deaths,
SUM(cast(new_deaths as DECIMAL))/SUM(cast(new_cases as DECIMAL))*100 as Deaths_percentage
FROM CovidDeaths
ORDER BY total_deaths DESC;

-- population vs vaccinated
SELECT de.continent , de.location, de.date , de.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY de.location ORDER BY de.location,de.date) as ROLLING_addition_of_vaccinations
FROM CovidDeaths as de
JOIN CovidVaccine as vac
ON vac.location = de.location AND vac.date = de.date;

-- finding vaccination percentage per day rolling
-- Using CTE
WITH pv(continent,location,date,population,new_vaccination,ROLLING_addition_of_vaccinations) 
as (SELECT de.continent , de.location, de.date , de.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY de.location ORDER BY de.location,de.date) as ROLLING_addition_of_vaccinations
FROM CovidDeaths as de
JOIN CovidVaccine as vac
ON vac.location = de.location AND vac.date = de.date)
SELECT *,(new_vaccination * 100)/population as percentage
FROM pv;

-- Creating temporary table
DROP TABLE temp_pv;
CREATE TEMPORARY TABLE temp_pv(continent varchar(50),
location varchar(100),
date datetime,
population decimal,
new_vaccinations NUMERIC,
rolling_addintion_of_vaccination NUMERIC);

INSERT INTO temp_pv
SELECT de.continent , de.location, de.date , de.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY de.location ORDER BY de.location,de.date) as ROLLING_addition_of_vaccinations
FROM CovidDeaths as de
JOIN CovidVaccine as vac
ON vac.location = de.location AND vac.date = de.date ;


-- Creating Views to store data for later visualizations

CREATE VIEW population_infected as
SELECT Location, date ,population, total_cases, (total_cases / population)*100 as infected_percentage
FROM CovidDeaths
ORDER BY 1,2;

CREATE VIEW Death_percentage as
SELECT Location, date , total_cases, total_deaths, (total_deaths / total_cases)*100 as Death_percentage
FROM CovidDeaths
ORDER BY 1,2;

CREATE VIEW Highest_coutries_infected as
SELECT Location,population, MAX(total_cases)as highest_case, MAX(total_cases / population)*100 as country_case_percentage
FROM CovidDeaths
GROUP BY Location,population
ORDER BY country_case_percentage DESC;


CREATE VIEW Continent_deaths AS
SELECT continent,SUM(cast(new_deaths as DECIMAL)) as max_deaths_per_continent
FROM CovidDeaths
GROUP BY continent
ORDER BY max_deaths_per_continent DESC;


CREATE VIEW roll_vaccinate_percentage AS
WITH pv(continent,location,date,population,new_vaccination,ROLLING_addition_of_vaccinations) 
as (SELECT de.continent , de.location, de.date , de.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (PARTITION BY de.location ORDER BY de.location,de.date) as ROLLING_addition_of_vaccinations
FROM CovidDeaths as de
JOIN CovidVaccine as vac
ON vac.location = de.location AND vac.date = de.date)
SELECT *,(new_vaccination * 100)/population as percentage
FROM pv;
