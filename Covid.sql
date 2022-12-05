				--all data--
select * from [dbo].[covid_death]
where continent is not null and population is not null
order by 3,4

-- transformer population en int
alter table [dbo].[covid_death]
alter column [population] bigint
GO
-- transformer total_death en


--		Total Cases vs Total Deaths
--   la chance de mourir si tu es touch� par le covid dans ton pays  : 
select [location],[date],[total_cases],[total_deaths] , ([total_deaths]/[total_cases])*100 as chance_de_mourir
from [dbo].[covid_death]
where continent is not null and population  is not null
group by [continent],[location],[date],[population],[total_cases],[total_deaths]
order by 1,2

--  population vs total cases
--pourcentage de population touch� par le covid  :

select [location],[date],[population],[total_cases], ([total_cases]/[population])*100 as pourcentage_touch�
from [dbo].[covid_death] 
where  [location] like '%france%' 
and  continent is not null and population  is not null
order by pourcentage_touch� desc

-- les pays les plus touch� par le covid par rapport au population 
select [location],[population] , max([total_cases]) as total_cases, max(([total_cases]/[population]))*100 as pourcentage_touch�
from [dbo].[covid_death]
where continent is not null and population  is not null
group by [location],[population]
order by [location]

-- les pays avec les plus cas de d�c�s : 
select [location] , max([total_deaths]) as total_mort
from [dbo].[covid_death]
where continent is not null and population  is not null
group by [location]
order by total_mort desc

-- continents : 

--les continents avec les plus cas de d�c�s :
select [continent] , max([total_deaths]) as total_mort
from [dbo].[covid_death]
where [continent] is not null and [population] is not null 
group by [continent]

select sum([new_cases]) as total_cases ,sum([new_deaths]) as total_deaths, (sum([new_deaths])/sum([new_cases])) * 100 as idk
from [dbo].[covid_death]
where [continent] is not null and [population] is not null 


-- vaccination : 
-- transformer 
-- pourcentage de population vaccin� :
select [dbo].[covid_death].[location],[dbo].[covid_death].[date],[dbo].[covid_death].[population],
[dbo].[covid_vacc].[new_vaccinations], 
sum([dbo].[covid_vacc].[new_vaccinations]) over (partition by [dbo].[covid_death].[location] order by [dbo].[covid_death].[location],
	[dbo].[covid_death].[date]) as le_mise_�_jour_de_total_vac
from [dbo].[covid_death]
join [dbo].[covid_vacc]
	on [dbo].[covid_death].location=[dbo].[covid_vacc].location
	and [dbo].[covid_death].date=[dbo].[covid_vacc].date
where [dbo].[covid_death].continent is not null and [dbo].[covid_death].[population] is not null
order by 1,2


---Cte
with popultaionVSvacc ([location],[date],[population],[new_vaccinations],le_mise_�_jour_de_total_vac)
as
(
select [dbo].[covid_death].[location],[dbo].[covid_death].[date],[dbo].[covid_death].[population],
[dbo].[covid_vacc].[new_vaccinations], 
sum([dbo].[covid_vacc].[new_vaccinations]) over (partition by [dbo].[covid_death].[location] order by [dbo].[covid_death].[location],
	[dbo].[covid_death].[date]) as le_mise_�_jour_de_total_vac
from [dbo].[covid_death]
join [dbo].[covid_vacc]
	on [dbo].[covid_death].location=[dbo].[covid_vacc].location
	and [dbo].[covid_death].date=[dbo].[covid_vacc].date
where [dbo].[covid_death].continent is not null and [dbo].[covid_death].[population] is not null
--order by 1,2
)
select *,(le_mise_�_jour_de_total_vac/[population])*100 as pourcentage_vaccin�
from popultaionVSvacc
where location like '%canada%'
order by 2



-- temp table 
drop table if exists #avancement_de_vaccination
create table #avancement_de_vaccination(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population float,
new_vaccinations float,
le_mise_�_jour_de_total_vac float
);

insert into #avancement_de_vaccination
select [dbo].[covid_death].[continent],[dbo].[covid_death].[location],[dbo].[covid_death].[date],[dbo].[covid_death].[population],
[dbo].[covid_vacc].[new_vaccinations], 
sum([dbo].[covid_vacc].[new_vaccinations]) over (partition by [dbo].[covid_death].[location] order by [dbo].[covid_death].[location],
	[dbo].[covid_death].[date]) as le_mise_�_jour_de_total_vac
from [dbo].[covid_death]
join [dbo].[covid_vacc]
	on [dbo].[covid_death].location=[dbo].[covid_vacc].location
	and [dbo].[covid_death].date=[dbo].[covid_vacc].date
where [dbo].[covid_death].continent is not null and [dbo].[covid_death].[population] is not null
--order by 1,2

select * ,(le_mise_�_jour_de_total_vac/[population])*100 as pourcentage_vaccin�
from #avancement_de_vaccination
order by 2,3


-- cr�er des view : 
create view avancement_de_vaccination as 
select [dbo].[covid_death].[continent],[dbo].[covid_death].[location],[dbo].[covid_death].[date],[dbo].[covid_death].[population],
[dbo].[covid_vacc].[new_vaccinations], 
sum([dbo].[covid_vacc].[new_vaccinations]) over (partition by [dbo].[covid_death].[location] order by [dbo].[covid_death].[location],
	[dbo].[covid_death].[date]) as le_mise_�_jour_de_total_vac
from [dbo].[covid_death]
join [dbo].[covid_vacc]
	on [dbo].[covid_death].location=[dbo].[covid_vacc].location
	and [dbo].[covid_death].date=[dbo].[covid_vacc].date
where [dbo].[covid_death].continent is not null and [dbo].[covid_death].[population] is not null
--order by 1,2