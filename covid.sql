/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [continent]
      ,[location]
      ,[date]
      ,[population]
      ,[new_vaccinations]
      ,[le_mise_à_jour_de_total_vac]
  FROM [covid].[dbo].[avancement_de_vaccination]