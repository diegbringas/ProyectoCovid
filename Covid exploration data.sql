with PopvsVac (continent, location, date, population, new_vaccinations, RollingPersonasVacunadas)
as
(select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations,
SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
dea.date) as RollingPersonasVacunadas

from Proyecto..['covid deaths$'] dea
join Proyecto..covidVacunas$ vac

	on dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPersonasVacunadas/population) * 100
from PopvsVac


--temp table

DROP TABLE IF EXISTS #PorcentajePoblacionVacunada;

CREATE TABLE #PorcentajePoblacionVacunada
(
    continent nvarchar(255),
    location nvarchar(255),
    date datetime,
    population numeric,
    new_vaccinations numeric,
    RollingPersonasVacunadas numeric
);

INSERT INTO #PorcentajePoblacionVacunada
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    COALESCE(vac.new_vaccinations, 0) AS new_vaccinations, -- Reemplaza NULL con 0
    SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPersonasVacunadas -- No convertir a int
FROM 
    Proyecto..['covid deaths$'] dea
JOIN 
    Proyecto..covidVacunas$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

-- Seleccionar todo y calcular el porcentaje
SELECT *, 
       (RollingPersonasVacunadas / population) * 100 AS PorcentajePoblacionVacunada
FROM 
    #PorcentajePoblacionVacunada;


create view PorcentajePoblacionVacunada as
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population,
    COALESCE(vac.new_vaccinations, 0) AS new_vaccinations, -- Reemplaza NULL con 0
    SUM(COALESCE(vac.new_vaccinations, 0)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPersonasVacunadas -- No convertir a int
FROM 
    Proyecto..['covid deaths$'] dea
JOIN 
    Proyecto..covidVacunas$ vac
    ON dea.location = vac.location
    AND dea.date = vac.date
where dea.continent is not null

select * 
from PorcentajePoblacionVacunada