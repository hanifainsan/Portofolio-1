/*

Cleaning Data in SQL Queries

*/

select *
from project3.dbo.NashvilleHousting


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select SaleDatedConverted, CONVERT(Date,SaleDate)
from project3.dbo.NashvilleHousting

update NashvilleHousting
SET Saledate = CONVERT(Date,SaleDate) --tidak bisa diconvert jadinya diubah mjd nama baru

ALTER TABLE NashvilleHousting
add SaleDatedConverted date;

update NashvilleHousting
SET SaleDatedConverted = CONVERT(Date,SaleDate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select *
from project3.dbo.NashvilleHousting
--where property address is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From project3.dbo.NashvilleHousting a
JOIN project3.dbo.NashvilleHousting b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null --kolom parcelid dan propertyadd ada yg sama dan property add null, u/ menghilangkan null digabungkan dua kolom menjadi 1 

Update a 
Set PropertyAddress = isnull(a.propertyaddress,b.propertyaddress)
from project3.dbo.NashvilleHousting a
join project3.dbo.NashvilleHousting b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null




--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

select PropertyAddress
from project3.dbo.NashvilleHousting --ada yg pemisah city(,) ada yg tidak
--Where PropertyAddress is null
--order by ParcelID

select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as Address --print kata sebelum koma
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address --+1 u/ menghilangkan koma sblum city
from project3.dbo.NashvilleHousting


--Split Property Address jadi dua kolom
Alter Table NashvilleHousting
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousting
SET PropertySplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


Alter Table NashvilleHousting
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousting
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

select *
from project3.dbo.NashvilleHousting



---------------------------
--split owner address jadi 3kolom
select OwnerAddress
from project3.dbo.NashvilleHousting

select
PARSENAME(Replace(OwnerAddress,',', '.') , 3)
,PARSENAME(replace(OwnerAddress, ',', '.') , 2)
,PARSENAME(replace(OwnerAddress, ',', '.') , 1)
from project3.dbo. NashvilleHousting


Alter Table NashvilleHousting
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousting
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',', '.') , 3)


Alter Table NashvilleHousting
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousting
SET OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.') , 2)


Alter Table NashvilleHousting
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousting
SET OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.') , 1)

select*
from project3.dbo.NashvilleHousting
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(SoldAsVacant), count(SoldAsVacant)
from project3.dbo.NashvilleHousting
Group By(SoldAsVacant)
Order by 2

select SoldAsVacant
, Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from project3.dbo.NashvilleHousting


Update NashvilleHousting
Set SoldAsVacant = Case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end



-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE As(
select *,
	ROW_NUMBER() Over(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From project3.dbo.NashvilleHousting
--order by ParcelID
)
--DELETE (run sebelum select)
select *
from RowNumCTE 
where row_num > 1
--Order by PropertyAddress


select * 
from project3.dbo.NashvilleHousting

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

select *
from project3.dbo.NashvilleHousting

ALTER TABLE NashvilleHousting --(No run)
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress --(No run)
















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO


















