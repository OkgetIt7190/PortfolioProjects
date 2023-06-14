




---------/*Cleaning Data in SQL Queries*/-----


SELECT *
FROM DBO.Housingdata



----Standardize Date Format


SELECT SaleDateConverted, CONVERT(date, SaleDate)
FROM Nashville.DBO.Housingdata

UPDATE Nashville.DBO.Housingdata
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE Nashville.DBO.Housingdata
ADD SaleDateConverted Date;

Update Nashville.DBO.Housingdata
SET SaleDateConverted = CONVERT(Date,SaleDate)


----Populate Property Address Data


SELECT * 
FROM Nashville.DBO.Housingdata
order by ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
FROM Nashville.DBO.Housingdata a
join Nashville.DBO.Housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
FROM Nashville.DBO.Housingdata a
join Nashville.DBO.Housingdata b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is null



----Breaking out Address into Individual Columns(Address, City, State)


SELECT PropertyAddress
FROM Nashville.DBO.Housingdata


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from Nashville.DBO.Housingdata


ALTER TABLE Nashville.DBO.Housingdata
ADD PropertySplitAddress Nvarchar(255);

Update Nashville.DBO.Housingdata
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Nashville.DBO.Housingdata
ADD PropertySplitCity Nvarchar(255);

Update Nashville.DBO.Housingdata
SET PropertySplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))




SELECT
PARSENAME(replace(OwnerAddress,',','.'),3)
,PARSENAME(replace(OwnerAddress,',','.'),2)
,PARSENAME(replace(OwnerAddress,',','.'),1)
from Nashville.DBO.Housingdata


ALTER TABLE Nashville.DBO.Housingdata
ADD OwnerSplitAddress Nvarchar(255);

Update Nashville.DBO.Housingdata
SET OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.'),3)

ALTER TABLE Nashville.DBO.Housingdata
ADD OwnerSplitCity Nvarchar(255);

Update Nashville.DBO.Housingdata
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.'),2)

ALTER TABLE Nashville.DBO.Housingdata
ADD OwnerSplitState Nvarchar(255);

Update Nashville.DBO.Housingdata
SET OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.'),1)










----Change Y and N to Yes and No in 'Sold as Vacant' Field

select distinct(SoldAsVacant), count(SoldAsVacant)
from [dbo].[Housingdata]
group by SoldAsVacant
order by 2


select SoldAsVacant
, CASE when SoldAsVacant = 'Y' then 'Yes'
,      when SoldAsVacant = 'N' then 'No'
	   ELSE SoldAsVacant
	   END
from [dbo].[Housingdata]


update [dbo].[Housingdata]
set SoldAsVacant = CASE When SoldAsVacant ='Y' then 'Yes'
	When SoldAsVacant = 'N' then 'No'
	Else SoldAsVacant
	END





----Remove Duplicates


WITH RowNumCTE AS(
Select *, 
    ROW_NUMBER() Over (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
				   UniqueID
				   ) row_num

from Nashville.DBO.Housingdata

)
Select *
from RowNumCTE
where row_num > 1












----Delete Unused columns




alter table  Nashville.DBO.Housingdata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

alter table  Nashville.DBO.Housingdata
DROP COLUMN SaleDate
