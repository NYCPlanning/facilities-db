--------------------------------------------------------------------------------------------------
-- 1. CREATING A TABLE TO BACKUP THE DUPLICATE RECORDS BEFORE DROPPING THEM FROM THE DATABASE
--------------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS duplicates_colp_bin;
CREATE TABLE duplicates_colp_bin AS (

WITH matches AS (
	SELECT
		CONCAT(a.pgtable,'-',b.pgtable) as sourcecombo,
		a.hash,
		b.hash as hash_b,
		a.facilityname,
		b.facilityname as facilityname_b
	FROM facilities a
	LEFT JOIN facilities b
	ON a.bin = b.bin
	WHERE
		a.facilitysubgroup = b.facilitysubgroup
		AND b.pgtable = ARRAY['dcas_facilities_colp']
		AND a.oversightabbrev @> b.oversightabbrev
		AND a.geom IS NOT NULL
		AND b.geom IS NOT NULL
		AND a.bin IS NOT NULL
		AND b.bin IS NOT NULL
		AND a.bin <> ARRAY['']
		AND b.bin <> ARRAY['']
		AND a.bin <> ARRAY['0.00000000000']
		AND b.bin <> ARRAY['0.00000000000']
		AND a.pgtable <> b.pgtable
		AND a.hash <> b.hash
		ORDER BY CONCAT(a.pgtable,'-',b.pgtable), a.facilityname, a.facilitysubgroup
	),  

duplicates AS (
	SELECT
		hash,
		array_agg(hash_b) AS hash_merged
	FROM matches
	GROUP BY
	hash)

SELECT facilities.*
FROM facilities
WHERE facilities.hash IN (SELECT unnest(duplicates.hash_merged) FROM duplicates)
ORDER BY hash

);

--------------------------------------------------------------------------------------------------
-- 2. UPDATING FACDB BY MERGING ATTRIBUTES FROM DUPLICATE RECORDS INTO PREFERRED RECORD
--------------------------------------------------------------------------------------------------

WITH matches AS (
	SELECT
		CONCAT(a.pgtable,'-',b.pgtable) as sourcecombo,
		a.idagency,
		b.idagency as idagency_b,
		a.uid,
		b.uid as uid_b,
		a.hash,
		b.hash as hash_b,
		a.facilityname,
		b.facilityname as facilityname_b,
		a.facilitysubgroup,
		b.facilitysubgroup as facilitysubgroup_b,
		a.facilitytype,
		b.facilitytype as facilitytype_b,
		a.processingflag,
		b.processingflag as processingflag_b,
		a.bin,
		b.bin as bin_b,
		a.address,
		b.address as address_b,
		a.geom,
		a.pgtable,
		b.pgtable as pgtable_b,
		a.agencysource,
		b.agencysource as agencysource_b,
		a.sourcedatasetname,
		b.sourcedatasetname as sourcedatasetname_b,
		b.datesourceupdated as datesourceupdated_b,
		b.linkdata as linkdata_b,
		a.oversightagency,
		b.oversightlevel as oversightlevel_b,
		b.oversightagency as oversightagency_b,
		a.oversightabbrev,
		b.oversightabbrev as oversightabbrev_b,
		b.propertytype as propertytype_b,
		b.agencyclass2,
		b.colpusetype
	FROM facilities a
	LEFT JOIN facilities b
	ON a.bin = b.bin
	WHERE
		a.facilitysubgroup = b.facilitysubgroup
		AND b.pgtable = ARRAY['dcas_facilities_colp']
		AND a.oversightabbrev @> b.oversightabbrev
		AND a.geom IS NOT NULL
		AND b.geom IS NOT NULL
		AND a.bin IS NOT NULL
		AND b.bin IS NOT NULL
		AND a.bin <> ARRAY['']
		AND b.bin <> ARRAY['']
		AND a.bin <> ARRAY['0.00000000000']
		AND b.bin <> ARRAY['0.00000000000']
		AND a.pgtable <> b.pgtable
		AND a.hash <> b.hash
		ORDER BY CONCAT(a.pgtable,'-',b.pgtable), a.facilityname, a.facilitysubgroup
	), 

duplicates AS (
	SELECT
		count(*) AS countofdups,
		facilityname,
		facilitytype,
		array_agg(distinct facilitytype_b) AS facilitytype_merged,
		hash,
		array_agg(uid_b) AS uid_merged,
		array_agg(hash_b) AS hash_merged,
		array_agg(distinct agencysource_b) AS agencysource,
		array_agg(distinct sourcedatasetname_b) AS sourcedatasetname,
		array_agg(distinct datesourceupdated_b) AS datesourceupdated,
		array_agg(distinct linkdata_b) AS linkdata,
		array_agg(distinct oversightlevel_b) AS oversightlevel,
		array_agg(distinct oversightagency_b) AS oversightagency,
		array_agg(distinct oversightabbrev_b) AS oversightabbrev,
		array_agg(distinct pgtable_b) AS pgtable,
		array_agg(distinct colpusetype) AS colpusetype,
		unnest(array_agg(distinct propertytype_b)) AS propertytype
	FROM matches
	GROUP BY
	hash, facilityname, facilitytype
	ORDER BY facilitytype, countofdups DESC )

UPDATE facilities AS f
SET
	uid_merged = d.uid_merged,
	hash_merged = d.hash_merged,
	pgtable = array_cat(f.pgtable,d.pgtable),
	agencysource = array_cat(f.agencysource,d.agencysource),
	sourcedatasetname = array_cat(f.sourcedatasetname,d.sourcedatasetname),
	linkdata = array_cat(f.linkdata,d.linkdata),
	colpusetype = d.colpusetype,
	propertytype = d.propertytype
FROM duplicates AS d
WHERE f.hash = d.hash
;

--------------------------------------------------------------------------------------------------
-- 3. DROPPING DUPLICATE RECORDS AFTER ATTRIBUTES HAVE BEEN MERGED INTO PREFERRED RECORD
--------------------------------------------------------------------------------------------------

DELETE FROM facilities
WHERE facilities.hash IN (SELECT duplicates_colp_bin.hash FROM duplicates_colp_bin)
;
