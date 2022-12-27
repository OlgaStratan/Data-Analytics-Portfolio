# Nashville Housing (Data) Cleaning Project
In this project, I was using Microsoft SQL Server to clean [Nashville Housing dataset](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx). The Dataset has more than 56,000 rows and 19 columns.

The following tasks were performed:
- **Standardize date format**
- **Populate missing property address data**
- **Parsing long-formatted address into individual columns (Address, City, State)**
- **Standardize “Sold as Vacant” field (from Y/N to Yes and No)**
- **Remove Duplicates**

## Overview of data
```
-- Overview of the dataset

Select *
FROM portofolio.dbo.NashvilleHousing
```
**output:**
![Screenshot 2022-12-26 165338](https://user-images.githubusercontent.com/67650188/209565701-545a52a2-2bb1-413a-a61f-c18cd6b4b487.png)

## Standardize date format

In the **‘SaleDate’** column, we see that the current format of date is in **YYYY-MM-DD HH:MM:SS**

Since the value of HH:MM:SS are all 0, therefore, I will get rid of the **HH:MM:SS**


```
-- Standardize Date Format

--Create a new column for converting date
ALTER TABLE portofolio.dbo.NashvilleHousing
ADD SaleDateConverted Date;

--Update the new SaleDateConverted column
Update portofolio.dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

-- See if it works
Select SaleDateConverted
FROM portofolio.dbo.NashvilleHousing
```
**output:**

![Screenshot 2022-12-26 172402](https://user-images.githubusercontent.com/67650188/209567427-5dd6ab47-7d61-4c62-97b9-83d78669f390.png)

## Populate missing property address data
I have identified that there are 29 rows with **NULL** property address.
```
Select *
FROM portofolio.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID
```

![Screenshot 2022-12-26 173034](https://user-images.githubusercontent.com/67650188/209567875-84eb6875-98d5-4b4a-9d13-6013e007362f.png)

Taking a closer look at the dataset, I have identified that te entries with the same **ParcelID** have the same **PropertyAddress**. Therefore, we can use ParcelID as a reference point to populate the missing address in PropertyAddress.

![Screenshot 2022-12-26 174639](https://user-images.githubusercontent.com/67650188/209568870-3d5d7488-3a48-4a96-8273-9fd17eace4a8.png)

To do so I have used **self-join** to populate the null property address with a property address that had the same ParcelID.
```
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portofolio.dbo.NashvilleHousing a
JOIN portofolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
```
![Screenshot 2022-12-26 175503](https://user-images.githubusercontent.com/67650188/209569492-fe1bdbd0-dc1f-4ce4-99ef-073e74b8cf0f.png)

Now I can go ahead and update the missing PropertyAddress
```
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM portofolio.dbo.NashvilleHousing a
JOIN portofolio.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
```
## Breaking out Address into Individual Columns (Address, City, State)

The PropertyAddress column contains the address and the city the property is located. We could separate the address and the city into different columns for future analysis purposes.

![Screenshot 2022-12-26 180032](https://user-images.githubusercontent.com/67650188/209569832-55264fcc-e48f-43ef-a726-5cf9d8018acf.png)

**Create new columns for Address and City of Property**
```
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
```

**Update the columns**

```
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1, CHARINDEX(',',PropertyAddress)-1)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))
```

**output:**

![Screenshot 2022-12-26 180518](https://user-images.githubusercontent.com/67650188/209570170-2830e2be-978f-472d-a116-ece0cbc381ab.png)

For the OwnerAddress, it contains Address, City and State in just a single column. We also need to split them to their own columns as well.

```
-- Create new column for OwnerAddress
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);

-- Update OwnerSplitAddress to be included only address
UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

-- Create new column for OwnerCity
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

-- Update OwnerSplitCity to be included only city
UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

-- Create new column for OwnerState
ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);

-- Update OwnerSplitState to be included only State
UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)

-- Check the updates
Select OwnerSplitAddress, OwnerSplitCity, OwnerSplitState
FROM portofolio.dbo.NashvilleHousing
```
**output:**

![Screenshot 2022-12-26 181218](https://user-images.githubusercontent.com/67650188/209570694-054cffa3-307c-4ed0-948a-ce2c582e8e6d.png)

## Standardize “Sold as Vacant” field (from Y/N to Yes and No)

In SoldAsVacant column, we have 4 categorical values — **Y, N, Yes, No** — instead of 2 - Yes and No

![Screenshot 2022-12-27 131640](https://user-images.githubusercontent.com/67650188/209665517-af53e4dd-6808-4a85-b942-8974f195d7a1.png)

Therefore, we need to format them by convert Y and N into Yes and No respectively. We can do so by using conditions statement.
```
-- Convert Y and N into Yes and No
UPDATE NashvilleHousing
SET SoldAsVacant =  CASE  
		WHEN SoldAsVacant = 'Y' THEN 'Yes'
		WHEN SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
FROM portofolio.dbo.NashvilleHousing
```

**output:**


