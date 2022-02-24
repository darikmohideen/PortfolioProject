-- Cleaning Data with SQL Queries
select top 10 * from HousingData

---------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDateConverted, convert(date,SaleDate) from HousingData

alter table HousingData
add SaleDateConverted date

update HousingData
set SaleDateConverted = convert(date,SaleDate)

---------------------------------------------------------------------------------

-- Separating Address into Columns - PropertyAddress

select substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)from HousingData
select substring(PropertyAddress,charindex(',',PropertyAddress)+2,len(PropertyAddress))from HousingData

alter table HousingData
add PropertyStreetAddress nvarchar(255)

alter table HousingData
add PropertyCity nvarchar(255)

update HousingData
set PropertyStreetAddress = substring(PropertyAddress,1,charindex(',',PropertyAddress)-1)

update HousingData
set PropertyCity = substring(PropertyAddress,charindex(',',PropertyAddress)+2,len(PropertyAddress))


-- Separating Address into Columns - OwnerAddress

select OwnerAddress from HousingData

select 
parsename(replace(OwnerAddress,',','.'),3),
parsename(replace(OwnerAddress,',','.'),2),
parsename(replace(OwnerAddress,',','.'),1)
from HousingData

alter table HousingData
add OwnerStreetAddress nvarchar(255)

alter table HousingData
add OwnerCity nvarchar(255)

alter table HousingData
add OwnerState nvarchar(255)

update HousingData
set OwnerStreetAddress = parsename(replace(OwnerAddress,',','.'),3)

update HousingData
set OwnerCity = parsename(replace(OwnerAddress,',','.'),2)

update HousingData
set OwnerState = parsename(replace(OwnerAddress,',','.'),1)


---------------------------------------------------------------------------------

--Edit Y and N to YES and NO in "Sold as Vacant" column

update HousingData
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
						when SoldAsVacant = 'N' then 'No'
			       else SoldAsVacant
				   end

---------------------------------------------------------------------------------

-- Removing Duplicates

with HousingDataCTE as 
(
select *,ROW_NUMBER() over (partition by ParcelID, LandUse, PropertyAddress, SaleDate order by UniqueID) as Row_num 
from HousingData
)
select * from HousingDataCTE where Row_num > 1

delete 
from HousingDataCTE
where Row_num > 1

---------------------------------------------------------------------------------

-- Delete Irrelevant Columns

alter table HousingData
drop column OwnerAddress, PropertyAddress, TaxDistrict

select * from HousingData

---------------------------------------------------------------------------------
