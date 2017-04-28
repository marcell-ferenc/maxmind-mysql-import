CREATE TABLE blocks (
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
) ENGINE=MyISAM DEFAULT CHARSET=utf8mb4 DEFAULT COLLATE=utf8mb4_unicode_520_ci;