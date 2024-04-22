/*  
Cleaning Data in SQL
 */

-- Cleaning Nashville Housing data

SELECT *
FROM portfolioproject.nashville_housing;



-- STANDARDIZE DATE FROMAT


SELECT SaleDate
FROM portfolioproject.nashville_housing;

/* Current format has a string in the date (like 'January 1, 2000'), so must use st_to_date */
 
SELECT SaleDate, str_to_date(SaleDate,"%M %D %Y") As New_SaleDate
FROM portfolioproject.nashville_housing;

-- For Update to work make sure the "Safe update" is unchecked in preferences
Update nashville_housing
SET SaleDate = str_to_date(SaleDate,"%M %D %Y");





-- POPULATE PROPERTY ADDRESS DATA 

SELECT * 
FROM portfolioproject.nashville_housing
-- where PropertyAddress is null
order by ParcelID;
/* Each ParcelID matches a single address,
 So we can use the pracel ID and the non null addresses to populate the ones that are null */
 
SELECT A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress
FROM portfolioproject.nashville_housing A
join portfolioproject.nashville_housing B
	ON A.ParcelID = B.ParcelID
    AND A.ï»¿UniqueID <> B.ï»¿UniqueID
Where A.PropertyAddress is null;

Update nashville_housing
inner join
    (Select ParcelID, PropertyAddress, ï»¿UniqueID
    from portfolioproject.nashville_housing
    where PropertyAddress is not null) as nashville_2 on nashville_housing.ParcelID = nashville_2.ParcelID AND nashville_housing.ï»¿UniqueID <> nashville_2.ï»¿UniqueID
set nashville_housing.PropertyAddress = nashville_2.PropertyAddress
where nashville_housing.Propertyaddress is null;

-- Checking for null values to make sure my query is correct
SELECT * 
FROM portfolioproject.nashville_housing
where PropertyAddress is null
order by ParcelID;

-- No null values were found, now I can check for those duplicate addresses attached to parcelIDs 
SELECT ParcelID, PropertyAddress, COUNT(PropertyAddress)
from portfolioproject.nashville_housing
Group by ParcelID, PropertyAddress
Having COUNT(PropertyAddress)>1
Order by PropertyAddress desc;

-- matching parcelID and address but uniqueID is distinct this is the desired outcome 
SELECT ï»¿UniqueID, ParcelID, PropertyAddress
from portfolioproject.nashville_housing
where PropertyAddress LIKE'909  WYNTREE  S, HERMITAGE';





-- BREAKING OUT ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)

SELECT PropertyAddress
from portfolioproject.nashville_housing;

SELECT PropertyAddress, substring_index(PropertyAddress, ',', 1) as Address
from portfolioproject.nashville_housing;

SELECT PropertyAddress, substring_index(PropertyAddress, ',', -1) as City
from portfolioproject.nashville_housing;

-- Adding a column for the address
Alter table nashville_housing
Add PropertySplitAddress text;

-- Populating it 
Update nashville_housing
set PropertySplitAddress = substring_index(PropertyAddress, ',', 1);


-- Adding a column for the city
Alter table nashville_housing
Add PropertySplitCity text;

-- Populating it
update nashville_housing
set PropertySplitCity = substring_index(PropertyAddress, ',', -1);


-- Just making sure the columns have been added at the end by selecting all. 
select *
from portfolioproject.nashville_housing; -- Everything looks good


-- SEPERATE OUT OWNER ADRESS

Select OwnerAddress
from portfolioproject.nashville_housing; -- Want seperate columns for address, city, and state

select OwnerAddress, substring_index(Owneraddress, ',', 1) as owneraddress
from portfolioproject.nashville_housing;

select OwnerAddress, substring_index(Owneraddress, ',', -1) as ownerState
from portfolioproject.nashville_housing;

 /*  parsename function does not exist in MySQL Workbench.
 I will use a temp column to seperate the address further with substring_index */

select OwnerAddress, substring_index(Owneraddress, ',', -2) temp
from portfolioproject.nashville_housing;

-- Adding temp column
Alter table nashville_housing
ADD temp text;

update nashville_housing
set temp = substring_index(Owneraddress, ',', -2);

select temp, substring_index(temp, ',', 1) as ownercity 
from portfolioproject.nashville_housing;


-- Adding and Poulating Owner Address
alter table nashville_housing
add OwnersplitAddress text;

update nashville_housing
set OwnersplitAddress = substring_index(Owneraddress, ',', 1);


-- Adding and Poulating Owner city (using temp column)
alter table nashville_housing
add OwnersplitCity text;

update nashville_housing
set OwnersplitCity = substring_index(temp, ',', 1);

-- Adding and Poulating Owner State 
alter table nashville_housing
add OwnersplitState text;

update nashville_housing
set OwnersplitState = substring_index(Owneraddress, ',', -1);

-- Now we can remove the temp column
alter table nashville_housing
drop temp;





-- CHANGE Y AND N TO 'YES' AND 'NO' IN "SOLD AS VACANT FIELD"

select distinct(SoldAsVacant), count(SoldAsVacant)
from portfolioproject.nashville_housing
group by SoldAsVacant;

select SoldAsVacant,
case
	when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end
from portfolioproject.nashville_housing;


update nashville_housing
set SoldASVacant = case
	when SoldAsVacant = 'Y' then 'Yes'
    when SoldAsVacant = 'N' then 'No'
    else SoldAsVacant
    end;





-- DELETE UNUSED COLUMNS 

Alter table nashville_housing
drop column OwnerAddress;

Alter table nashville_housing
drop column PropertyAddress;

Alter table nashville_housing
drop column TaxDistrict;

select *
from portfolioproject.nashville_housing;

