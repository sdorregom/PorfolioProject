--Cleaning Data in SQL Queries / Limpiando datos en SQL queries

select *
from PorfolioProject.dbo.NashvilleHousing

-- Standarsize Date Format / Estandarizar formato fecha

Select SaleDateConverted, CONVERT(Date, SaleDate)
from PorfolioProject.dbo.NashvilleHousing

update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate property Address Data / Rellenar datos de dirección 

select *
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is not null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, a.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is null

update a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PorfolioProject.dbo.NashvilleHousing a
join PorfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]

-- Breaking out Address into Individual Colums (Address, City, State)

select PropertyAddress
from PorfolioProject.dbo.NashvilleHousing
--where PropertyAddress is not null
order by ParcelID

select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address
from PorfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
add PropertySplitCity nvarchar(255);

update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select *
from PorfolioProject.dbo.NashvilleHousing


select OwnerAddress
from PorfolioProject.dbo.NashvilleHousing

select
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
from PorfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

select *
from PorfolioProject.dbo.NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field / Cambiar Y y N a Yes y No en campo "Sold as Vacant"

select distinct(SoldAsVacant), count(SoldAsVacant)
from PorfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2

select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldASVacant = 'N' then 'No'
	   else SoldASVacant
	   end
from PorfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldASVacant = 'N' then 'No'
	   else SoldASVacant
	   end

-- Remove duplicates / remover duplicados

WITH RowNumCTE AS(
select *,
ROW_NUMBER() OVER(
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY UniqueID
			 ) row_num

from PorfolioProject.dbo.NashvilleHousing
--order by ParcelID
)

SELECT *
from RowNumCTE
where row_num > 1
ORDER BY PropertyAddress

-- Delete Unused Columns

select *
from PorfolioProject.dbo.NashvilleHousing

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE PorfolioProject.dbo.NashvilleHousing
DROP COLUMN SaleDate