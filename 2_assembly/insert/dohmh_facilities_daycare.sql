INSERT INTO
facilities (
	pgtable,
	hash,
	geom,
	idagency,
	idname,
	idfield,
	facname,
	addressnum,
	streetname,
	address,
	boro,
	zipcode,
	bbl,
	bin,
	geomsource,
	factype,
	facsubgrp,
	capacity,
	util,
	capacitytype,
	utilrate,
	area,
	areatype,
	optype,
	opname,
	opabbrev,
	overagency,
	overabbrev,
	datecreated,
	children,
	youth,
	senior,
	family,
	disabilities,
	dropouts,
	unemployed,
	homeless,
	immigrants,
	groupquarters
)
SELECT
	-- pgtable
	'dohmh_facilities_daycare',
	-- hash,
    hash,
	-- geom
	NULL,
	-- idagency
	Day_Care_Id,
	'DOHMH Day Care ID',
	'Day_Care_Id',
	-- facilityname
		(CASE
			WHEN Center_Name LIKE '%SBCC%' THEN initcap(Legal_Name)
			WHEN Center_Name LIKE '%SCHOOL BASED CHILD CARE%' THEN initcap(Legal_Name)
			ELSE initcap(Center_Name)
		END),
	-- addressnumber
	Building,
	-- streetname
	initcap(Street),
	-- address
	CONCAT(Building,' ',initcap(Street)),
	-- borough
	initcap(Borough),
	-- zipcode
	ZipCode::integer,
	-- bbl
	NULL,
	-- bin
	NULL,
	NULL,
	-- facilitytype
		(CASE
			WHEN (facility_type = 'CAMP' OR facility_type = 'Camp') AND (program_type = 'All Age Camp' OR program_type = 'ALL AGE CAMP')
				THEN 'Camp - All Age'
			WHEN (facility_type = 'CAMP' OR facility_type = 'Camp') AND (program_type = 'School Age Camp' OR program_type = 'SCHOOL AGE CAMP')
				THEN 'Camp - School Age'
			WHEN (program_type = 'Preschool Camp' OR program_type = 'PRESCHOOL CAMP')
				THEN 'Camp - Preschool Age'
			WHEN (facility_type = 'GDC') AND (program_type = 'Child Care - Infants/Toddlers' OR program_type = 'INFANT TODDLER')
				THEN 'Group Day Care - Infants/Toddlers'
			WHEN (facility_type = 'GDC') AND (program_type = 'Child Care - Pre School' OR program_type = 'PRESCHOOL')
				THEN 'Group Day Care - Preschool'
			WHEN (facility_type = 'SBCC') AND (program_type = 'PRESCHOOL')
				THEN 'School Based Child Care - Preschool'
			WHEN (facility_type = 'SBCC') AND (program_type = 'INFANT TODDLER')
				THEN 'School Based Child Care - Infants/Toddlers'
			WHEN facility_type = 'SBCC'
				THEN 'School Based Child Care - Age Unspecified'
			WHEN facility_type = 'GDC'
				THEN 'Group Day Care - Age Unspecified'
			ELSE CONCAT(facility_type,' - ',program_type)
		END),
	-- facilitysubgroup
		(CASE
			WHEN (facility_type = 'CAMP' OR facility_type = 'Camp' OR program_type LIKE '%CAMP%' OR program_type LIKE '%Camp%')
				THEN 'Camps'
			ELSE 'Day Care'
		END),
	-- capacity
		(CASE
			WHEN Maximum_Capacity <> '0' THEN ARRAY[Maximum_Capacity::text]
			WHEN Maximum_Capacity = '0' THEN NULL
		END),
	-- utilization
	NULL,
	-- capacitytype
	(CASE
		WHEN program_type LIKE '%INFANT%' THEN  'Infant and toddler maxiumum capacity calculated by DOHMH'
		WHEN upper(program_type) LIKE '%PRESCHOOL%' THEN 'Preschooler maxiumum capacity calculated by DOHMH'
		ELSE 'Maxiumum child capacity calculated by DOHMH'
	END),
	-- utilizationrate
	NULL,
	-- area
	NULL,
	-- areatype
	NULL,
	-- operatortype
	'Non-public',
	-- operator
	initcap(Legal_Name),
	-- operatorabbrev
	'Non-public',
	-- oversightagency
	'NYC Department of Health and Mental Hygiene',
	-- oversightabbrev
	'NYCDOHMH',
	-- datecreated
	CURRENT_TIMESTAMP,
	-- children
	TRUE,
	-- youth
	FALSE,
	-- senior
	FALSE,
	-- family
	FALSE,
	-- disabilities
	FALSE,
	-- dropouts
	FALSE,
	-- unemployed
	FALSE,
	-- homeless
	FALSE,
	-- immigrants
	FALSE,
	-- groupquarters
	FALSE
FROM 
	dohmh_facilities_daycare
GROUP BY
	hash,
	Day_Care_ID,
	Center_Name,
	Legal_Name,
	Building,
	Street,
	ZipCode,
	Borough,
	facility_type,
	child_care_type,
	program_type,
	Maximum_Capacity