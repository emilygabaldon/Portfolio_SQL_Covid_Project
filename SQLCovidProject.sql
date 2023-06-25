--(EN)  Checking Tables Information
--(DEU) Tabelleninformationen Prüfung
--(ES)  Comprobación de la información en las tablas
SELECT *
From Covid_Portfolio_Project..CovidDeaths
order by 3,4

Select*
From Covid_Portfolio_Project..CovidVaccinations
order by 3,4

--(EN)  Selecting specific data from: CovidDeaths
--(DEU) Auswahl spezifischer Daten aus: CovidDeaths
--(ES)  Selección de datos específicos de: CovidDeaths
SELECT location, date, total_cases, new_cases, total_deaths, population
From Covid_Portfolio_Project..CovidDeaths
order by 1,2

--(EN)  Looking at the total cases vs Total deaths(likelihood of dying if you contractc Covid in Germany)
--(DEU) Gesamtzahl der Fälle im Vergleich zur Gesamtzahl der Todesfälle (die Wahrscheinlichkeit zu sterben, wenn man sich in Deutschland mit Covid infiziert)
--(ES)  Observando el total de casos frente al total de muertes (probabilidad de morir si contraes Covid en Alemania)
SELECT location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Covid_Portfolio_Project..CovidDeaths
WHERE location='Germany'

--
--(EN)  Looking at the total cases versus the population. What percentage of the population got covid?
--(DEU) Gesamtzahl der Fälle im Vergleich zur Bevölkerung. Wie viel Prozent der Bevölkerung hat Covid?
--(ES)  Observando el total de casos frente a la población. ¿Qué porcentaje de la población se contagió?
SELECT location, date, total_cases, Population, total_deaths,(total_cases/population)*100 as CasePercentage
From Covid_Portfolio_Project..CovidDeaths
WHERE location='Germany'
order by 2


--(EN)  What country has the highest infection rate compared to population?
--(DEU) Welches Land hat die höchste Infektionsrate im Verhältnis zur Bevölkerung?
--(ES)  ¿Qué país tiene la mayor tasa de infección en comparación con su población?
SELECT location, Max(total_cases) as HighestInfectionCount, Population,Max((total_cases/population))*100 as CasePercentage
From Covid_Portfolio_Project..CovidDeaths
Group by Location, population
order by CasePercentage desc


--(EN)  Showing the countries with the highests death count per population
--(DEU) Länder mit den meisten Todesfällen pro Bevölkerung
--(ES)  Países con mayor número de muertes por habitante
SELECT location, Max(cast(total_deaths as int)) as TotalDeathCount
FROM Covid_Portfolio_Project..CovidDeaths
Where continent is not null
Group by Location
order by TotalDeathCount desc


--(EN)  Breaking the information out by continent
--(DEU) Aufschlüsselung der Informationen nach Kontinenten
--(ES)  Desglose de la información por continentes
SELECT continent, Max(cast(total_deaths as int)) as TotalDeathCount
FROM Covid_Portfolio_Project..CovidDeaths
Where continent is not null
Group by continent
order by TotalDeathCount desc


--(EN)  Global numbers per day
--(DEU) Globale Zahlen pro Tag
--(ES)  Cifras globales por día

SELECT date, SUM(new_cases) as total_cases_world, SUM(cast(new_deaths as int)) as total_deaths_world, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as WorldDeathPercentage
From Covid_Portfolio_Project..CovidDeaths
where continent is not null
group By date
order by 1,2


--(EN)  Global numbers in total
--(DEU) Globale Zahlen insgesamt
--(ES)  Cifras globales en total

SELECT SUM(new_cases) as total_cases_world, SUM(cast(new_deaths as int)) as total_deaths_world, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as WorldDeathPercentage
From Covid_Portfolio_Project..CovidDeaths
where continent is not null
order by 1,2


--(EN)  Joining Tables
--(DEU) Tabellen verknüpfen
--(ES)  Unión de tablas
Select *
from Covid_Portfolio_Project..CovidDeaths dea
join Covid_Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
order by 1,2

--(EN)  Looking at total Population versus Vaccinations
--(DEU) Betrachtung der Gesamtbevölkerung im Vergleich zu den Impfungen
--(ES)  Población total y vacunaciones


--CTE
With PopvsVac (Continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, sum(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location
,dea.Date) as RollingPeopleVaccinated
--(What "Over partition by"  does is to stop the sum at the end of each new location)
from Covid_Portfolio_Project..CovidDeaths dea
join Covid_Portfolio_Project..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/population)*100 as PercentVaccinated
From PopvsVac

