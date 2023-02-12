/* 

Cleaning Data in SQL Queries

*/

Select * 
From PortfolioProject.dbo.NashvilleHousing




-------------------------------------------------------

-- Standardise SaleDate Format
--Convert datetime to date

Select SaleDate,
CONVERT(DATE,SaleDate) 
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
Set SaleDate = CONVERT(DATE,SaleDate) 


-------------------------------------------------------
--Populate Property Address Date

Select *
From PortfolioProject.dbo.NashvilleHousing
--Where PropertyAddress is NULL
Order by ParcelID

-- the same Parcel ID would go to the same address (  self joining to populate NULLvalues in PropertyAddress)

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID] <> b.[UniqueID]
where a.PropertyAddress is NULL

-- Update table to replace Property Address with ISNULL

Update a 
Set PropertyAddress =  ISNULL( a.PropertyAddress,b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
on a.ParcelID=b.ParcelID
and a.[UniqueID] <> b.[UniqueID]

--------------------------------------------------------------------------------------

-- Break out Address into Individual Columns (Address/City/State)

Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 
as Address,

SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress)) 
as CITY

From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 )


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update PortfolioProject.dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1 , LEN(PropertyAddress))



Select * 
From PortfolioProject.dbo.NashvilleHousing


-----Owner Address cleanup-----
Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing
where OwnerAddress is not NULL

Select 
--OwnerAddress,
Parsename(Replace(OwnerAddress, ',','.'),3),
Parsename(Replace(OwnerAddress, ',','.'),2),
Parsename(Replace(OwnerAddress, ',','.'),1)
From PortfolioProject.dbo.NashvilleHousing

-----ADDING COLUMNS-------
ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitCity Nvarchar(255);


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
Add OwnerSplitState Nvarchar(255);


Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitAddress = Parsename(Replace(OwnerAddress, ',','.'),3)


Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitCity = Parsename(Replace(OwnerAddress, ',','.'),2)


Update PortfolioProject.dbo.NashvilleHousing
SET OwnerSplitState = Parsename(Replace(OwnerAddress, ',','.'),1)


-------------------------------------------------------

--Change Y and Yes and No in " Sold as Vacant" field

Select Distinct (SoldasVacant),
Count(SoldasVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Returns y-52/n-399/yes-4623/No-51403

Select SoldasVacant
	
	, Case When SoldasVacant = 'Y' THEN 'Yes'
	When SoldasVacant = 'N' Then 'No'	
	ELSE SoldAsVacant
	End
	
From PortfolioProject.dbo.NashvilleHousing


Update PortfolioProject.dbo.NashvilleHousing
Set SoldasVacant = Case When SoldasVacant = 'Y' THEN 'Yes'
	When SoldasVacant = 'N' Then 'No'	
	ELSE SoldAsVacant
	End
-----------------------------------------------------------------------

--Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




-------------------------------------------------------

--Delete Unused columns





Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




--- Importing Data using OPENROWSET and BULK INSERT	


sp_configure 'show advanced options', 1;
RECONFIGURE;
GO
sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO


USE PortfolioProject 

GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

GO 

EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

GO 


---- Using BULK INSERT

USE PortfolioProject;
GO
BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
  WITH (
     FIELDTERMINATOR = ',',
      ROWTERMINATOR = '\n'
);
-GO


---- Using OPENROWSET
USE PortfolioProject;
GO
SELECT * INTO nashvilleHousing
FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
    'Excel 12.0; Database=C:\Users\Owner\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
GO


















-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	



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
--    'Excel 12.0; Database=C:\Users\james\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO





