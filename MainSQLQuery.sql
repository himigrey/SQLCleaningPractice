/*
Cleaning Practice in SQL

*/

--Looking at the dataset
SELECT *
FROM SQLCleaning..NashvilleHousing

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

SELECT main.ParcelID, main.PropertyAddress, t.ParcelID, t.PropertyAddress, ISNULL(main.PropertyAddress, t.PropertyAddress)
FROM SQLCleaning..NashvilleHousing main
JOIN SQLCleaning..NashvilleHousing t
	on main.ParcelID = t.ParcelID
	AND main.UniqueID <> t.UniqueID
WHERE main.PropertyAddress is null

UPDATE main
SET PropertyAddress = ISNULL(main.PropertyAddress, t.PropertyAddress)
FROM SQLCleaning..NashvilleHousing main
JOIN SQLCleaning..NashvilleHousing t
	on main.ParcelID = t.ParcelID
	AND main.UniqueID <> t.UniqueID
WHERE main.PropertyAddress is null

SELECT TOP(5) *
FROM SQLCleaning..NashvilleHousing

--**Breaking Address apart into distinct columns**
