
		/*
	Covid 19 Data analysis 
	Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types
	data source https://ourworldindata.org/coronavirus
	*/
	
	
	select * from COVID19_deaths
	where continent is not null  
	order by 3,4;


	SELECT * FROM covied19_vaccinations
	where continent is not null 
	ORDER BY 3,4;


	Select DATE,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	From COVID19_deaths
	--Where location like '%states%'
	where continent is not null 
	Group By date
	order by 1,2;


	---> sclecting the data 
	select location,date,total_cases,new_cases,total_deaths,population
	from COVID19_deaths
	where continent is not null 
	order by 1,2;


	------>death percentage for the peaple got covied
	select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpersantage, population
	from COVID19_deaths
	where continent is not null 
	--and location = 'india'
	order by 1,2;
	

	-------->Death percentage due to COVID19 over total popultion <----------------		 -
	select location,date,total_deaths, population,(total_deaths/population)*100 as deathpersantage 
	from COVID19_deaths
	where continent is not null 
	--and location = 'india'
	--where location LIKE 'Pakistan'
	--where location  like '%state%'
	order by 2;


	-------> grouped by Countries with Highest Death percentage due to COVID19
	select location,MAX(total_deaths) Max_Deaths, population,MAX(deathpersantage) AS Max_Deathpersantage
	from(select location,date,total_deaths, population,(total_deaths/population)*100 as deathpersantage 
	from COVID19_deaths) AS X
	GROUP BY location,population
	ORDER BY 2 DESC;


	select location,MAX(total_deaths) Max_Deaths, population,MAX((total_deaths/population))*100 as Max_Deathpersantage 
	from COVID19_deaths
	GROUP BY location,population
	order by 2 DESC;


	
	-----------> COVID19 Infected persantage over total populatuion 

	select location,date,total_cases,total_deaths,population,(total_cases/population)*100 as COVID_InfectedPercent_overPoplatuion 
	from COVID19_deaths
	--where location = 'india'
	--where location  like '%state%'

	-------->Countries with Highest COVID19 Infection Rate over Population
	
	select location,max(total_cases) max_num_Cases,population,max((total_cases/population))*100 as COVID_InfectedPercent_overPoplatuion
	from COVID19_deaths
	group by location,population
	order by COVID_InfectedPercent_overPoplatuion desc;

	
	-- BREAKING THINGS DOWN BY CONTINENT
	Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	From COVID19_deaths
	--Where location like '%states%'
	Where continent is not null 
	Group by continent
	order by TotalDeathCount;

-----------------------------------------------------------------------------------------------------

	--->Total Population vs Vaccinations
	--->Shows Percentage of Population that has recieved at least one Covid Vaccine

	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From COVID19_deaths dea
	Join covied19_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3
	

	----> using CTE 

	With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
	as
	(
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From COVID19_deaths	dea
	Join covied19_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null 
	)
	Select *, (RollingPeopleVaccinated/Population)*100 as  PeopleVaccinatedPercentage
	From PopvsVac


	-----> Using Temp Table to perform Calculation on Partition By in previous 

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
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From COVID19_deaths dea
	Join covied19_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	--where dea.continent is not null 
	--order by 2,3

	Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated

	-- Creating View to store data for later visualizations

	Create View PercentPopulationVaccinated as
	Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	--, (RollingPeopleVaccinated/population)*100
	From COVID19_deaths dea
	Join covied19_vaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null 

	select * from PercentPopulationVaccinated


