# Import MaxMind [GeoIP2 City CSV](http://dev.maxmind.com/geoip/geoip2/geoip2-city-country-csv-databases) data into MySQL

A simple script that imports MaxMind's **GeoIP2 City CSV** data into MySQL.

### Prerequisites

In these snippets I use mysql with a login path file (*.mylogin.cnf*) instead of providing the username and password on the command line.
If your mysql version is 5.6.x or newer You can generate this configuration file using [mysql_config_editor](https://dev.mysql.com/doc/refman/5.7/en/mysql-config-editor.html).

```
mysql_config_editor set --login-path=<login_path> --host=<host> --user=<db_user> --password
```

In the **GeoIP2 City** CSV files the IPv4 or IPv6IP addresses are stored in [CIDR](https://en.wikipedia.org/wiki/Classless_Inter-Domain_Routing) format. Here I use the integer representation of IP addresses, therefore, before import, the start/end of the IP range have to be converted to integers. MaxMind published a conversion utility to convert the IP network column to another format, called [geoip2-csv-converter](https://github.com/maxmind/geoip2-csv-converter).
You can run [setup-maxmind-converter.sh](src/bin/setup-maxmind-converter.sh) to setup ```geoip2-csv-converter```.

The **GeoIP2 City** database seems to contains gaps. Therefore they need to be identified and need to be filled in in order to get the correct results (```NULL```) instead of other record's details during a query. The ```build.sh``` do the job for You, see below.

### Installing

1. Type the following command in a terminal
    ```
    cd $HOME && git clone https://github.com/marcell-ferenc/maxmind-mysql-import.git
    ```

1. Change [config.sh](src/bin/config.sh)
   The only thing You need to change is the ```MYSQL_LOGIN``` variable. Use the value that You set for ```--login-path``` when using the ```mysql_config_editor```
   ```
   export MYSQL_LOGIN=<login_path>
   ```

1. Make the scripts executable
    ```
    chmod 0700 $HOME/maxmind-mysql-import/src/bin/build.sh
    chmod 0700 $HOME/maxmind-mysql-import/src/bin/setup-maxmind-converter.sh
    ```

## Running the script

```
$HOME/maxmind-mysql-import/src/bin/build.sh <LOCATION_FILE> <IPv4_BLOCK_FILE>
```

Where <[LOCATION_FILE](http://dev.maxmind.com/geoip/geoip2/geoip2-city-country-csv-databases/#Locations_Files)> and <[IPv4_BLOCK_FILE](http://dev.maxmind.com/geoip/geoip2/geoip2-city-country-csv-databases/#Blocks_Files)> are the purchased **GeoIP2 City CSV** files.

The [build.sh](src/bin/build.sh) script only imports some of the available fields and works with the **IPv4** addresses. If You need the other records, simply uncomment the required column names (remove the leading double-dash (```--```)) in [blocks.sql](src/sql/table/blocks.sql), [location.sql](src/sql/table/location.sql) and [gaps.sql](src/sql/table/gaps.sql) files located in the [src/sql/table](src/sql/table) directory. Then, for the corresponding column names you need to remove the leading at (```@```) sign from the ```LOAD DATA LOCAL INFILE``` blocks in the ```build.sh``` script. The columns that are assigned to the dummy user variables (leading at sign) are simply ignored. The ```build.sh``` script also fills the gaps in the ```blocks``` table using [gaps.sql](src/sql/table/gaps.sql).

### Query examples

```
SET @_iaddr = INET_ATON('your_ip_as_string');
```
OR
```
SET @_iaddr = your_ip_as_integer;
```

```
SELECT *
FROM blocks AS b
LEFT JOIN location AS l ON b.geoname_id = l.geoname_id
WHERE @_iaddr <= network_last_integer
ORDER BY network_last_integer ASC
LIMIT 1;
```

## Author

* **Marcell Ferenc** - *Initial work* - [marcell-ferenc](https://github.com/marcell-ferenc)

## License

These snippets are licensed under the MIT License - see the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

* MaxMind
