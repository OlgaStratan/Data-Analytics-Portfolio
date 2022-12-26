# Nashville Housing (Data) Cleaning Project
In this project, I was using Microsoft SQL Server to clean [Nashville Housing dataset](https://github.com/AlexTheAnalyst/PortfolioProjects/blob/main/Nashville%20Housing%20Data%20for%20Data%20Cleaning.xlsx). The Dataset has more than 56,000 rows and 19 columns.

The following tasks were performed:
- **Standardize date format**
- **Populate missing property address data**
- **Parsing long-formatted address into individual columns (Address, City, State)**
- **Standardize “Sold as Vacant” field (from Y/N to Yes and No)**
- **Remove Duplicates**

### Overview of data
```
-- Overview of the dataset

Select *
FROM portofolio.dbo.NashvilleHousing
```
**output:**
![Screenshot 2022-12-26 165338](https://user-images.githubusercontent.com/67650188/209565701-545a52a2-2bb1-413a-a61f-c18cd6b4b487.png)

### Standardize date format

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

### Populate missing property address data
I have identified that there are 29 rows with **NULL** property address.
```
Select *
FROM portofolio.dbo.NashvilleHousing
WHERE PropertyAddress IS NULL
ORDER BY ParcelID
```

![Screenshot 2022-12-26 173034](https://user-images.githubusercontent.com/67650188/209567875-84eb6875-98d5-4b4a-9d13-6013e007362f.png)

Taking a closer look at the dataset, I have identified that te entries with the same ParcelID have the same PropertyAddress
