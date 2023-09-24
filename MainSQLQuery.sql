/*
Data Cleaning using SQL

Converting a housing dataset into more usable information for analysis.

*/

--Looking at the dataset
SELECT *
FROM SQLCleaning..NashvilleHousing;

--**Correcting the date format**
/*
SUMMARY:
Adding a new column named StandardSaleDate with the date formalized without the time
*/

SELECT SaleDate, CONVERT(Date,SaleDate)
FROM SQLCleaning..NashvilleHousing;

ALTER TABLE SQLCleaning..NashvilleHousing
ADD StandardSaleDate date;

UPDATE SQLCleaning..NashvilleHousing
SET StandardSaleDate = CONVERT(date,SaleDate);


--**Addressing Gaps in Address Data**

SELECT *
FROM SQLCleaning..NashvilleHousing
WHERE PropertyAddress is null
ORDER BY ParcelID;

SELECT *
FROM SQLCleaning..NashvilleHousing
ORDER BY ParcelID;

/*
A column name issue with "UniqueID" was resolved prior to this step.
The column's original name contains an extra space and was removed via renaming.
*/

--A self join to connect entries where the address is missing with another entry where an address is present and possesses the same ID
SELECT main.ParcelID, main.PropertyAddress, t.ParcelID, t.PropertyAddress, ISNULL(main.PropertyAddress, t.PropertyAddress)
FROM SQLCleaning..NashvilleHousing main
JOIN SQLCleaning..NashvilleHousing t
	on main.ParcelID = t.ParcelID
	AND main.UniqueID <> t.UniqueID
WHERE main.PropertyAddress is null;

UPDATE main
SET PropertyAddress = ISNULL(main.PropertyAddress, t.PropertyAddress)
FROM SQLCleaning..NashvilleHousing main
JOIN SQLCleaning..NashvilleHousing t
	on main.ParcelID = t.ParcelID
	AND main.UniqueID <> t.UniqueID
WHERE main.PropertyAddress is null;


--**Breaking Address apart into distinct columns**
/*
SUMMARY:
Divded addresses into one containing just the street address, as well as distinct city and state columns.

New Columns: Address, City, OwnerSplitAddress, OwnerCity, OwnerState
Note: Properties do not have a state listed, so this information was skipped.
*/

SELECT PropertyAddress
FROM SQLCleaning..NashvilleHousing

--Test Query for breaking apart PropertyAddress
SELECT
--Selects first part via substring, separating at point the comma appears
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address,
--Selects the second section
	SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
FROM SQLCleaning..NashvilleHousing;


--Updating table
ALTER TABLE SQLCleaning..NashvilleHousing
ADD Address nvarchar(255);
ALTER TABLE SQLCleaning..NashvilleHousing
ADD City nvarchar(255);

UPDATE SQLCleaning..NashvilleHousing
SET Address = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) ;
UPDATE SQLCleaning..NashvilleHousing
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress));

--Cleaning OwnerAddress
SELECT OwnerAddress
FROM SQLCleaning..NashvilleHousing;

--Now using Parsename
SELECT
	PARSENAME(REPLACE(OwnerAddress,',','.'),3) as OwnerSplitAddress,
	PARSENAME(REPLACE(OwnerAddress,',','.'),2) as OwnerCity,
	PARSENAME(REPLACE(OwnerAddress,',','.'),1) as OwnerState
FROM SQLCleaning..NashvilleHousing;

--Adding new columns
ALTER TABLE SQLCleaning..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);
ALTER TABLE SQLCleaning..NashvilleHousing
ADD OwnerCity nvarchar(255);
ALTER TABLE SQLCleaning..NashvilleHousing
ADD OwnerState nvarchar(5);

--Updating added columns to corresponding information
UPDATE SQLCleaning..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3);
UPDATE SQLCleaning..NashvilleHousing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2);
UPDATE SQLCleaning..NashvilleHousing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1);

--**Making Yes and No in the "Sold as Vacant" column consistent**

SELECT DISTINCT(SoldAsVacant), COUNT(SoldasVacant) as HouseCount
FROM SQLCleaning..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY HouseCount;

SELECT SoldAsVacant,
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM SQLCleaning..NashvilleHousing;

UPDATE SQLCleaning..NashvilleHousing
SET SoldAsVacant =
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END;

--**Removing Duplicate values from a table**

--Deletes duplicates
WITH TestCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
	ORDER BY UniqueID
	) row_num
FROM SQLCleaning..NashvilleHousing
)
DELETE
FROM TestCTE
WHERE row_num <> 1;

--**Deleting Obsolete Columns**
ALTER TABLE SQLCleaning..NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, SaleDate;