CREATE TABLE location (
    geoname_id INT UNSIGNED,
    -- locale_code CHAR(2),
    continent_code CHAR(2),
    continent_name VARCHAR(15),
    country_iso_code CHAR(2),
    country_name VARCHAR(60),
    -- subdivision_1_iso_code VARCHAR(2),
    -- subdivision_1_name VARCHAR(60),
    -- subdivision_2_iso_code VARCHAR(2),
    -- subdivision_2_name VARCHAR(60),
    city_name VARCHAR(60),
    -- metro_code VARCHAR(60),
    -- time_zone VARCHAR(60),
    PRIMARY KEY (geoname_id)
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_520_ci;