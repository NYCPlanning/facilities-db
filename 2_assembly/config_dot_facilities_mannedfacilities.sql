INSERT INTO
facilities (
	pgtable,
	hash,
	geom,
	idagency,
	facilityname,
	addressnumber,
	streetname,
	address,
	borough,
	zipcode,
	bbl,
	bin,
	facilitytype,
	domain,
	facilitygroup,
	facilitysubgroup,
	agencyclass1,
	agencyclass2,
	capacity,
	utilization,
	capacitytype,
	utilizationrate,
	area,
	areatype,
	operatortype,
	operatorname,
	operatorabbrev,
	oversightagency,
	oversightabbrev,
	datecreated,
	buildingid,
	buildingname,
	schoolorganizationlevel,
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
	ARRAY['dot_facilities_mannedfacilities'],
	-- hash,
	md5(CAST((dot_facilities_mannedfacilities.*) AS text)),
	-- geom
	geom,
	-- idagency
	NULL,
	-- facilityname
	oper_label,
	-- addressnumber
	(CASE 
		WHEN arc_street IS NOT NULL THEN split_part(trim(both ' ' from REPLACE(arc_street,' - ','-')), ' ', 1)
		ELSE NULL
	END),
	-- streetname
	(CASE 
		WHEN arc_street IS NOT NULL THEN trim(both ' ' from substr(trim(both ' ' from REPLACE(arc_street,' - ','-')), strpos(trim(both ' ' from REPLACE(arc_street,' - ','-')), ' ')+1, (length(trim(both ' ' from REPLACE(arc_street,' - ','-')))-strpos(trim(both ' ' from REPLACE(arc_street,' - ','-')), ' '))))
		ELSE NULL
	END),
	-- address
	(CASE 
		WHEN arc_street IS NOT NULL THEN arc_street
		ELSE NULL
	END),
	-- borough
	NULL,
	-- zipcode
	NULL,
	-- bbl
	NULL,
	-- bin
	NULL,
	-- facilitytype
	'Manned Transportation Facility',
	-- domain
	'Core Infrastructure and Transportation',
	-- facilitygroup
	'Transportation',
	-- facilitysubgroup
	'Other Transportation',
	-- agencyclass1
	NULL,
	-- agencyclass2
	NULL,
	-- capacity
	NULL,
	-- utilization
	NULL,
	-- capacitytype
	NULL,
	-- utilizationrate
	NULL,
	-- area
	NULL,
	-- areatype
	NULL,
	-- operatortype
	'Public',
	-- operatorname
	'NYC Department of Transportation',
	-- operatorabbrev
	'NYCDOT',
	-- oversightagency
	ARRAY['NYC Department of Transportation'],
	-- oversightabbrev
	ARRAY['NYCDOT'],
	-- datecreated
	CURRENT_TIMESTAMP,
	-- buildingid
	NULL,
	-- buildingname
	NULL,
	-- schoolorganizationlevel
	NULL,
	-- children
	FALSE,
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
	dot_facilities_mannedfacilities