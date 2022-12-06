
--     suprimé l'heur de la date :
alter table [dbo].[Sheet1$]
add Salesdate2 date

update [dbo].[Sheet1$]
set Salesdate2 = convert(date,[SaleDate])

select * 
from [dbo].[Sheet1$]

-- remplacer les null en propertyadress
select a.[UniqueID ],a.[ParcelID],a.[PropertyAddress], b.[UniqueID ],b.[ParcelID],b.[PropertyAddress],isnull(a.PropertyAddress,b.PropertyAddress)
from [dbo].[Sheet1$] a 
join [dbo].[Sheet1$] b
	on a.[ParcelID] = b.[ParcelID]
	and a.[UniqueID ] <> b.[UniqueID ]
where a.[PropertyAddress] is null


update a 
set [PropertyAddress] = isnull(a.PropertyAddress,b.PropertyAddress)
from [dbo].[Sheet1$] a 
join [dbo].[Sheet1$] b
	on a.[ParcelID] = b.[ParcelID]
	and a.[UniqueID ] <> b.[UniqueID ]
where a.[PropertyAddress] is null

------- séprarer la vile de ladresse 
select
SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1),
SUBSTRING([PropertyAddress],CHARINDEX(',',[PropertyAddress])+1,LEN([PropertyAddress]))
from[dbo].[Sheet1$]

--ajouter une colone pour la premiere partie d'adresse : 
alter table [dbo].[Sheet1$]
add Adresse_Rue nvarchar(255)
-- donner la valeur pour la nouvelle colone
update [dbo].[Sheet1$]
set Adresse_Rue = SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1)


--ajouter une colone pour la deuxième partie d'adresse : 
alter table [dbo].[Sheet1$]
add Ville nvarchar(255)
-- donner la valeur pour la nouvelle colone
update [dbo].[Sheet1$]
set Ville = SUBSTRING([PropertyAddress],1,CHARINDEX(',',[PropertyAddress])-1)

-- separer l'adresse du owner : 
select 
PARSENAME(REPLACE(OwnerAddress, ',','.'),3),
PARSENAME(REPLACE(OwnerAddress, ',','.'),2),
PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
from [dbo].[Sheet1$]

--créer des nouveau colone pour les adresse de owner : 
--créer la premiére table de Owner_Adress_RUE : 
alter table [dbo].[Sheet1$]
add Owner_Adress_RUE NVARCHAR(255)
--remplire les info dans la table de Owner_Adress_RUE:
update [dbo].[Sheet1$]
set Owner_Adress_RUE = PARSENAME(REPLACE(OwnerAddress, ',','.'),3)


--créer la deuxième table de Owner_Adress_Ville : 
alter table [dbo].[Sheet1$]
add Owner_Adress_Ville NVARCHAR(255)
--remplire les info dans la table de Owner_Adress_RUE:
update [dbo].[Sheet1$]
set Owner_Adress_Ville = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)


----créer la Troisiéme table de Owner_Adress_state : 
alter table [dbo].[Sheet1$]
add Owner_Adress_state NVARCHAR(255)
--remplire les info dans la table de Owner_Adress_RUE:
update [dbo].[Sheet1$]
set Owner_Adress_state = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

-- mettre tous les Y et les N  à Yes et Non
-- chercher les diffs
select distinct (SoldAsVacant) , count(SoldAsVacant)
from [dbo].[Sheet1$]
group by SoldAsVacant

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end as correction
from [dbo].[Sheet1$]
where SoldAsVacant = 'Y' or SoldAsVacant = 'N'
order by 1

update [dbo].[Sheet1$]
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end 

--remove duplicate : 
with repetition_CTE as(
select*, 
ROW_NUMBER() over(
	Partition by 
		[ParcelID],
		[PropertyAddress],
		[SalePrice],
		[SaleDate],
		[LegalReference]
		order by 
		[UniqueID ]
		) row_num
from [dbo].[Sheet1$]
)
delete
from repetition_CTE
where row_num > 1
--order by PropertyAddress

-- suprimer les colone pas utiliser
alter table [dbo].[Sheet1$]
drop column [SaleDate]

select * 
from [dbo].[Sheet1$]