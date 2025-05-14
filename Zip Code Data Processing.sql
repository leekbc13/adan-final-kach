
/*
SOFTWARE TOOLS FOR DATA ANALYSIS - TEAM 2 GROUP PROJECT 

PURPOSE: PROCESS ZIP CODE DATA TO INCLUDE CITY AND COUNTY INFORMATION
AMELIA MARTIN
*/

-- REVIEW UPLOADED TABLES
	SELECT TOP 10 * FROM zip_dim_table;
	SELECT TOP 10 * FROM project_acs_zipcodes;
	SELECT TOP 10 * FROM project_sales_zipcodes;

-- CREATE OVERALL TABLE WITH SUM
	DROP TABLE IF EXISTS #project_zipcodes;
	SELECT 
	x.zipcode,
	category,
	sale_dollars,
	sale_volume,
	city,
	county,
	urban_rural_ind,
	lat_nbr,
	lon_nbr,
	x_coord_albers_nbr,
	y_coord_albers_nbr,
	high_school,
	bachelor,
	unemployment,
	income,
	population,
	pop_white,
	pop_black,
	pop_indian,
	pop_asian,
	pop_hawai,
	pop_other,
	pop_multi
	INTO #project_zipcodes
	FROM (SELECT zipcode, 'TOTAL' AS category, SUM(sale_dollars) AS sale_dollars, SUM(sale_volume) AS sale_volume FROM project_sales_zipcodes GROUP BY zipcode) X
	LEFT JOIN project_acs_zipcodes Y on X.zipcode = Y.zipcode
	LEFT JOIN zip_dim_table Z on X.zipcode = Z.zip
	-- 429

-- CREATE TABLE WITH CATEGORIES
	DROP TABLE IF EXISTS project_zipcodes;
	SELECT 
	x.zipcode,
	category,
	sale_dollars,
	sale_volume,
	city,
	county,
	urban_rural_ind,
	lat_nbr,
	lon_nbr,
	x_coord_albers_nbr,
	y_coord_albers_nbr,
	high_school,
	bachelor,
	unemployment,
	income,
	population,
	pop_white,
	pop_black,
	pop_indian,
	pop_asian,
	pop_hawai,
	pop_other,
	pop_multi
	INTO project_zipcodes
	FROM project_sales_zipcodes X
	LEFT JOIN project_acs_zipcodes Y ON X.zipcode = Y.zipcode
	LEFT JOIN zip_dim_table Z ON X.zipcode = Z.zip;
	-- 4150

-- UNION TABLES
	DROP TABLE IF EXISTS project_zipcodes_union;
	SELECT * 
	INTO project_zipcodes_union
	FROM project_zipcodes
	UNION ALL
	SELECT * FROM #project_zipcodes;

-- REVIEW FINAL TABLE
	SELECT * FROM project_zipcodes;
	SELECT * FROM project_zipcodes_union;

	SELECT COUNT(DISTINCT zipcode) FROM project_acs_zipcodes; --937
	SELECT COUNT(DISTINCT zipcode) FROM project_sales_zipcodes; --429
	SELECT COUNT(DISTINCT zipcode) FROM project_zipcodes_union;

	SELECT COUNT(*) FROM project_acs_zipcodes; --937
	SELECT COUNT(*) FROM project_sales_zipcodes; --4150
	SELECT COUNT(*) FROM project_zipcodes_union;
