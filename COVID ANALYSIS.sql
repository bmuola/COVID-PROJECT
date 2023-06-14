-- 🌍 PROJECT: Exploring COVID Data 🦠
-- 🧑‍💻 Project by Bernard Muola 😊

-- Retrieving all data related to COVID 💻
SELECT *
FROM PROJECT001.dbo.[c.deaths]
WHERE continent IS NOT NULL
ORDER BY 3, 4;

-- 📊 Let's see the selected data 📅🌟
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PROJECT001.dbo.[c.deaths]
WHERE continent IS NOT NULL
ORDER BY 1, 2;

-- Comparing Total Cases and Total Deaths 💔

-- Likelihood of COVID death in various countries 🌎
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS 'Percentage of Death'
FROM PROJECT001.dbo.[c.deaths]
WHERE location LIKE '%states%' -- Put your location here! 🏳️
		AND continent IS NOT NULL 
		AND total_cases IS NOT NULL
ORDER BY 1, 2;

-- Total Cases vs Population in country Kenya 🇰🇪

-- Exploring COVID impact in Kenya 📈
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS 'Percentage of infected population'
FROM PROJECT001.dbo.[c.deaths]
WHERE location LIKE '%kenya%' AND continent IS NOT NULL
ORDER BY 1, 2;

-- Countries with the Highest Infection Rates 🌟

-- Identifying hotspots of COVID spread 📊
SELECT continent, population, MAX(total_cases) AS HIC, MAX((total_cases / population)) * 100 AS PIP
-- HIC: Highest Infection Count, PIP: Percentage of Infected Population 🌡️
FROM PROJECT001.dbo.[c.deaths]
WHERE continent IS NOT NULL
GROUP BY continent, population
ORDER BY PIP DESC;


-- 🌍 LETS CREATE A 'VIEW' FOR THIS
CREATE VIEW Hotspots AS 
SELECT continent, population, MAX(total_cases) AS HIC, MAX((total_cases / population)) * 100 AS PIP
-- HIC: Highest Infection Count, PIP: Percentage of Infected Population 🌡️
FROM PROJECT001.dbo.[c.deaths]
WHERE continent IS NOT NULL
GROUP BY continent, population


-- Countries with the Highest Death Count per Population 💔

-- Awareness of the impact of COVID on countries 🌍
SELECT continent, MAX(CONVERT(INT, total_deaths)) AS HDC
-- HDC: Highest Death Count 💀
FROM PROJECT001.dbo.[c.deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HDC DESC;

-- 🌍 LETS CREATE A 'VIEW' FOR THIS
CREATE VIEW DeathPerCOUNTRY AS
SELECT continent, MAX(CONVERT(INT, total_deaths)) AS HDC
-- HDC: Highest Death Count 💀
FROM PROJECT001.dbo.[c.deaths]
WHERE continent IS NOT NULL
GROUP BY continent;

-- Continents with the Highest Death Counts 🌍

SELECT continent, MAX(CONVERT(INT, total_deaths)) AS HDC
-- HDC: Highest Death Count 💀
FROM PROJECT001.dbo.[c.deaths]
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HDC DESC;

-- 🌍 GLOBAL NUMBERS 🌟

-- Fetching the overall COVID data worldwide 💻
SELECT 
  SUM(new_cases) AS Total_cases,
  SUM(CONVERT(INT, new_deaths)) AS Total_deaths,
  SUM(CONVERT(INT, new_deaths))/SUM(new_cases)* 100 AS 'Percentage of Death'
FROM 
  PROJECT001.dbo.[c.deaths]
WHERE 
  continent IS NOT NULL
ORDER BY 
  Total_cases DESC;



-- 🌍 LOOKING AT TOTAL POPULATION VS VACCINATION 💉

-- Fetching COVID population and Cumulative vaccination data worldwide 💻
SELECT 
  D.continent, 
  D.location,
  D.date,
  D.population, 
  V.new_vaccinations,
  SUM(CONVERT(BIGINT,V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.LOCATION, D.DATE) AS CumulativePeopleVaccinated
FROM 
  PROJECT001.dbo.[c.deaths] D
JOIN 
  project001.dbo.[C.Vaccination] V 
	ON D.location = V.location AND D.date = V.date
WHERE 
  D.continent IS NOT NULL AND new_vaccinations IS NOT NULL
ORDER BY 2,3;


-- 🌍✨ TO DISCOVER THE MAGICAL PERCENTAGE OF POPULATION VACCINATED ✨🌍


WITH TOTPOPVSVAC (Continent, Location, Date, Population, New_Vaccination, CumulativePeopleVaccinated) AS (
  SELECT 
    D.continent, 
    D.location,
    D.date,
    D.population, 
    V.new_vaccinations,
    SUM(CONVERT(INT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS CumulativePeopleVaccinated
  FROM 
    PROJECT001.dbo.[c.deaths] D
  JOIN 
    project001.dbo.[C.Vaccination] V 
    ON D.location = V.location AND D.date = V.date
  WHERE 
    D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL
)

SELECT 
  Location, 
  CONCAT(FLOOR(MAX(CumulativePeopleVaccinated / Population * 100)), '%') AS PPV
  -- PPV BEING THE PERCENTAGE OF POPULATION VACCINATED! 🌟✨🚀
FROM 
  TOTPOPVSVAC
GROUP BY 
  Location;

 
 --Let's view this
 CREATE VIEW PPV AS
 WITH TOTPOPVSVAC (Continent, Location, Date, Population, New_Vaccination, CumulativePeopleVaccinated) AS (
  SELECT 
    D.continent, 
    D.location,
    D.date,
    D.population, 
    V.new_vaccinations,
    SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS CumulativePeopleVaccinated
  FROM 
    PROJECT001.dbo.[c.deaths] D
  JOIN 
    project001.dbo.[C.Vaccination] V 
    ON D.location = V.location AND D.date = V.date
  WHERE 
    D.continent IS NOT NULL AND V.new_vaccinations IS NOT NULL
)

SELECT 
  Location, 
  CONCAT(FLOOR(MAX(CumulativePeopleVaccinated / Population * 100)), '%') AS PPV
  -- PPV BEING THE PERCENTAGE OF POPULATION VACCINATED! 🌟✨🚀
FROM 
  TOTPOPVSVAC
GROUP BY 
  Location;



  -- Let's find out what percentage of people are getting their dose of magic across the continents!

WITH TOTPOPVSVAC (Continent, Location, Date, Population, New_Vaccination, CumulativePeopleVaccinated) AS (
  SELECT 
    D.continent, 
    D.location,
    D.date,
    D.population, 
    V.new_vaccinations,
    SUM(CONVERT(BIGINT, V.new_vaccinations)) OVER (PARTITION BY D.location ORDER BY D.location, D.date) AS CumulativePeopleVaccinated
  FROM 
    PROJECT001.dbo.[c.deaths] D
  JOIN 
    project001.dbo.[C.Vaccination] V 
    ON D.location = V.location AND D.date = V.date
  WHERE 
    D.continent IS NULL AND V.new_vaccinations IS NOT NULL
)

SELECT 
  Location, 
  MAX(CumulativePeopleVaccinated / Population * 100) AS PPV
  -- PPV BEING THE PERCENTAGE OF POPULATION VACCINATED! 🌟✨🚀
FROM 
  TOTPOPVSVAC
GROUP BY 
  Location;

