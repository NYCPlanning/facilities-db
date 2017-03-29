UPDATE facilities AS f
    SET 
        datasource = ARRAY[j.datasource],
        dataname = ARRAY[CONCAT(j.datasource, ': ', j.dataname)],
        dataurl = 
            (CASE
                WHEN j.dataurl IS NOT NULL THEN ARRAY[CONCAT(j.datasource, ': ', j.dataurl)]
                ELSE NULL
            END),
        linkdownload = 
            (CASE
                WHEN j.linkdownload IS NOT NULL THEN ARRAY[CONCAT(j.datasource, ': ', j.linkdownload)]
                ELSE NULL
            END),
        datatype = ARRAY[CONCAT(j.datasource, ': ', j.datatype)],
        refreshmeans = ARRAY[CONCAT(j.datasource, ': ', j.refreshmeans)],
        refreshfrequency = ARRAY[CONCAT(j.datasource, ': ', j.refreshfrequency)],
        datadate = ARRAY[CONCAT(j.datasource, ': ', j.datadate)]
    FROM
        (SELECT DISTINCT ON (pgtable)
            f.pgtable,
            d.datasource,
            d.dataname,
            d.dataurl,
            d.linkdownload,
            d.datatype,
            d.refreshmeans,
            d.refreshfrequency,
            d.datadate::date
            FROM
            facilities AS f
            LEFT JOIN
            facilities_datasources AS d
            ON
            f.pgtable = ARRAY[d.pgtable]
        ) AS j
    WHERE
        f.pgtable = j.pgtable
    ;