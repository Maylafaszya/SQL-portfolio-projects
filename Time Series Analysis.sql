CREATE TABLE housing (
						UniqueID int PRIMARY KEY, 
						ParcelID varchar(50), 	
						LandUse text, 
						PropertyAddress varchar(100), 
						SaleDate varchar(50), 
						SalePrice varchar(50), 
						LegalReference varchar(100), 
						SoldAsVacant text, 
						OwnerName text, 
						OwnerAddress varchar(100), 
						Acreage real, 
						TaxDistrict text, 
						LandValue bigint, 
						BuildingValue bigint, 
						TotalValue bigint, 
						YearBuilt int,
						Bedrooms int, 
						FullBath int, 
						HalfBath int);
						
						
COPY housing (
UniqueID, 
ParcelID,
LandUse, 
PropertyAddress, 
SaleDate, 
SalePrice, 
LegalReference, 
SoldAsVacant, 
OwnerName, 
OwnerAddress,
Acreage,
TaxDistrict, 
LandValue, 
BuildingValue, 
TotalValue,
YearBuilt, 
Bedrooms, 
FullBath, 
HalfBath)
FROM 'C:\Users\Public\Documents\Nashville Housing.csv'
DELIMITER ',' 
CSV HEADER;

--CHANGING SALE PRICE DATA TYPE 
ALTER TABLE housing ADD temp_col bigint;

UPDATE housing SET temp_col = CAST(REPLACE(REPLACE(SalePrice, ',', ''),'$','') AS INT);

SELECT temp_col FROM housing;

ALTER TABLE housing DROP COLUMN SalePrice;

ALTER TABLE housing RENAME temp_col TO SalePrice;

SElECT * 
FROM housing;


-- PRICE TIME ANALYSIS BASED ON LANDUSE 

WITH t1 AS (SELECT 
landuse, 
DATE_TRUNC('year',saledate::DATE) AS year, 
AVG(saleprice) AS yearly_avg_price
FROM housing
GROUP BY 1,2
ORDER BY 1,2 
			),

t2 AS (SELECT 
year,
landuse, 
yearly_avg_price, 
LAG(yearly_avg_price) OVER(PARTITION BY landuse ORDER BY year) AS prev_year_avg_price
FROM t1 
	   )
	   
SELECT year, 
landuse, 
ROUND((yearly_avg_price::DECIMAL/prev_year_avg_price)-1,2) AS yoy_growth
FROM t2 

-- built year on building value

WITH builtyear_summ AS (SELECT yearbuilt, 
buildingvalue 
FROM housing
ORDER BY yearbuilt
						)

SELECT y_bar_max - (slope*x_bar_max) AS intercept, 
slope
FROM(SELECT 
	SUM((yearbuilt-x_bar)*(buildingvalue-y_bar))/SUM((yearbuilt-x_bar)*(yearbuilt-x_bar)) AS slope,
	MAX(x_bar) AS x_bar_max, 
	MAX(y_bar) AS y_bar_max
	FROM (SELECT yearbuilt, 
		AVG(yearbuilt) OVER() AS x_bar,
		buildingvalue, 
		AVG(buildingvalue) OVER() AS y_bar
		FROM builtyear_summ) sub1) sub2;
		
-- 
SELECT 
soldasvacant, 
AVG(saleprice) AS avg_sale_price
FROM housing
GROUP BY 1 
