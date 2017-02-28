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
	ARRAY['dot_facilities_pedplazas'],
	-- hash,
	md5(CAST((dot_facilities_pedplazas.*) AS text)),
	-- geom
	geom,
	-- idagency
	ARRAY[mapid],
	-- facilityname
	name,
	-- addressnumber
	NULL,
	-- streetname
	NULL,
	-- address
	Street,
	-- borough
		(CASE
			WHEN boro_code = 1 THEN 'Manhattan'
			WHEN boro_code = 2 THEN 'Bronx'
			WHEN boro_code = 3 THEN 'Brooklyn'
			WHEN boro_code = 4 THEN 'Queens'
			WHEN boro_code = 5 THEN 'Staten Island'
		END),
	-- zipcode
	NULL,
	-- bbl
	NULL,
	-- bin
	NULL,
	-- facilitytype
	'Pedestrian Plaza',
	-- domain
	'Parks, Gardens, and Historical Sites',
	-- facilitygroup
	'Parks and Plazas',
	-- facilitysubgroup
	'Streetscapes, Plazas, and Malls',
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
	dot_facilities_pedplazas