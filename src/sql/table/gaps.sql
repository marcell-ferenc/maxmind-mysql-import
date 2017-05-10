SET @diff = (SELECT network_start_integer FROM blocks ORDER BY network_last_integer ASC LIMIT 1);
CREATE TABLE tmp_blocks (
    network_start_integer INT UNSIGNED,
    network_last_integer INT UNSIGNED,
    geoname_id INT UNSIGNED,
    -- registered_country_geoname_id INT UNSIGNED,
    -- represented_country_geoname_id INT UNSIGNED,
    -- is_anonymous_proxy INT UNSIGNED,
    -- is_satellite_provider INT UNSIGNED,
    -- postal_code VARCHAR(10),
    -- latitude DECIMAL(8,4),
    -- longitude DECIMAL(8,4),
    INDEX (network_last_integer),
    INDEX (geoname_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_520_ci AS (
SELECT
    x.gap_start_integer AS network_start_integer
    , x.gap_end_integer AS network_last_integer
    , NULL AS geoname_id
    -- , NULL AS registered_country_geoname_id
    -- , NULL AS represented_country_geoname_id
    -- , NULL AS is_anonymous_proxy
    -- , NULL AS is_satellite_provider
    -- , NULL AS postal_code
    -- , NULL AS latitude
    -- , NULL AS longitude
FROM (
    SELECT
        network_start_integer,
        network_last_integer,
        geoname_id,
        network_start_integer - @diff AS diff,
        NULL AS new_geoname_id,
        @diff + 1 AS gap_start_integer,
        (network_start_integer - 1) AS gap_end_integer,
        @diff := network_last_integer AS ref
    FROM blocks
    ORDER BY network_last_integer ASC) AS x
WHERE x.diff > 1);

INSERT INTO tmp_blocks
SELECT *
FROM blocks;

TRUNCATE TABLE blocks;

INSERT INTO blocks (
    network_start_integer
    , network_last_integer
    , geoname_id
    -- , registered_country_geoname_id
    -- , represented_country_geoname_id
    -- , is_anonymous_proxy
    -- , is_satellite_provider
    -- , postal_code
    -- , latitude
    -- , longitude
)
SELECT
    network_start_integer
    , network_last_integer
    , geoname_id
    -- , NULL AS registered_country_geoname_id
    -- , NULL AS represented_country_geoname_id
    -- , NULL AS is_anonymous_proxy
    -- , NULL AS is_satellite_provider
    -- , NULL AS postal_code
    -- , NULL AS latitude
    -- , NULL AS longitude
FROM tmp_blocks
ORDER BY network_last_integer ASC;

DROP TABLE tmp_blocks;