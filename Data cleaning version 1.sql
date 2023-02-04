-- Select All columns
SELECT *
FROM [Nashville housing]

--Extract only Date
ALTER TABLE [NASHVILLE housing]
ADD DATE_SALE DATE-- new column added

UPDATE [Nashville housing]
SET DATE_SALE=CONVERT(DATE,SaleDate) --

--populate property address wherever its null
SELECT * --check which rows are null
FROM [Nashville housing]
WHERE PropertyAddress IS NULL

UPDATE a
SET PropertyAddress=b.PropertyAddress

FROM [Nashville housing] as a
INNER JOIN [Nashville housing] as b
ON a.ParcelID=b.ParcelID AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Split Propertyaddress into Address, city & state
 
SELECT *
FROM [Nashville housing]

ALTER TABLE [Nashville housing]
ADD p_address char(200)

ALTER TABLE [Nashville housing]
add city_name char(200)

UPDATE [Nashville housing]
set p_address=LEFT(PropertyAddress,CHARINDEX(',',PropertyAddress)-1)

UPDATE [Nashville housing]
set city_name=RIGHT(PropertyAddress,LEN(PropertyAddress)-CHARINDEX(',',PropertyAddress))

--Split Owner address into 3 parts address, city and state
ALTER TABLE [Nashville housing] --ADDED owner_address as new column
ADD owner_address CHAR(200)

ALTER TABLE [Nashville housing] --ADDED owner_city as new column
ADD owner_city CHAR (200)

ALTER TABLE [Nashville housing] --ADDED owner_city as new column
ADD owner_state CHAR(200)

UPDATE [Nashville housing]
SET owner_address = PARSENAME(REPLACE(OwnerAddress,',','.'),3)
UPDATE [Nashville housing]
SET owner_city = PARSENAME(REPLACE(OwnerAddress,',','.'),2)
UPDATE [Nashville housing]
SET owner_state = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
FROM [Nashville housing]

--REPLACE SOLDASVACANT field ,Y with 'Yes' and N with 'NO'
UPDATE [Nashville housing]
SET SoldAsVacant=CASE WHEN SoldAsVacant='Y' THEN 'Yes'
					WHEN SoldAsVacant='N' THEN 'No'
					else SoldAsVacant END

SELECT *
FROM [Nashville housing]

--Delete unused columns
ALTER TABLE [Nashville housing]
DROP COLUMN PropertyAddress,owner_address,SaleDate,TaxDistrict

SELECT *
FROM [Nashville housing]