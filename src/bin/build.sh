#!/bin/bash

echo "Start"
start=$(date +%s)

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $SCRIPT_DIR/config.sh

# check mysql user
mysql --login-path=$MYSQL_LOGIN -e 'SHOW DATABASES' &> /dev/null
case $? in
  0) ;;
  *) echo "Invalid mysql login-path, see mysql_config_editor!"
     exit 2 ;;
esac

echo " * Drop and create maxmind db"
mysql --login-path=$MYSQL_LOGIN < $SCRIPT_DIR/../sql/db/maxmind.sql

echo " * Create location table"
mysql --login-path=$MYSQL_LOGIN maxmind < $SCRIPT_DIR/../sql/table/location.sql

echo " * Create blocks table"
mysql --login-path=$MYSQL_LOGIN maxmind < $SCRIPT_DIR/../sql/table/blocks.sql

case $# in
  2) ;;
  *) echo "Two arguments are required!"
     exit 2 ;;
esac

LOCATION_FILE=$1
BLOCK_FILE=$2

if [ ! -s "$LOCATION_FILE" ]; then
  echo "Missing location file!"
  exit 2
fi

case ${LOCATION_FILE##*/} in
  GeoIP2-City-Locations-en.csv) ;;
  *) echo "Wrong location file: <$LOCATION_FILE>"
     exit 2 ;;
esac

if [ ! -s "$BLOCK_FILE" ]; then
  echo "Missing block file!"
  exit 2
fi

case ${BLOCK_FILE##*/} in
  GeoIP2-City-Blocks-IPv4.csv) ;;
  *) echo "Wrong block file: <$BLOCK_FILE>"
     exit 2 ;;
esac

type realpath &> /dev/null
case $? in
  0) ;;
  *) echo "Missing realpath program, please install it!"
     exit 2 ;;
esac

LOCATION_FILE=$(realpath $LOCATION_FILE)
BLOCK_FILE=$(realpath $BLOCK_FILE)
BLOCK_FILE_MOD=$BLOCK_FILE.mod

type /usr/local/bin/geoip2-csv-converter &> /dev/null
case $? in
  0) ;;
  *) echo "Missing geoip2-csv-converter script, see setup-maxmind-converter.sh!"
     exit 2 ;;
esac

echo " * Convert block file"
rm -f $BLOCK_FILE_MOD &> /dev/null
/usr/local/bin/geoip2-csv-converter -block-file="$BLOCK_FILE" -output-file="$BLOCK_FILE_MOD" -include-integer-range

case $? in
  0) ;;
  *) echo "Conversion error!"
     exit 2 ;;
esac

read -r -d '' VAR <<EOF
    mysql --login-path=$MYSQL_LOGIN maxmind -e
    "LOAD DATA LOCAL INFILE '$LOCATION_FILE'
     INTO TABLE location
     CHARACTER SET utf8mb4
     FIELDS TERMINATED BY ','
     OPTIONALLY ENCLOSED BY '\"'
     LINES TERMINATED BY '\n'
     IGNORE 1 ROWS (
         geoname_id,
         @locale_code,
         continent_code,
         continent_name,
         country_iso_code,
         country_name,
         @subdivision_1_iso_code,
         @subdivision_1_name,
         @subdivision_2_iso_code,
         @subdivision_2_name,
         city_name,
         @metro_code,
         @time_zone)"
EOF

# set -f +f in order to handle properly "\'" in the variable string
set -f
echo " * Import location file: $LOCATION_FILE"
#echo "RUN: " $VAR
eval $VAR
set +f

read -r -d '' VAR <<EOF
    mysql --login-path=$MYSQL_LOGIN maxmind -e
    "LOAD DATA LOCAL INFILE '$BLOCK_FILE_MOD'
     INTO TABLE blocks
     CHARACTER SET utf8mb4
     FIELDS TERMINATED BY ','
     OPTIONALLY ENCLOSED BY '\"'
     LINES TERMINATED BY '\n'
     IGNORE 1 ROWS (
         network_start_integer,
         network_last_integer,
         geoname_id,
         @registered_country_geoname_id,
         @represented_country_geoname_id,
         @is_anonymous_proxy,
         @is_satellite_provider,
         @postal_code,
         @latitude,
         @longitude)"
EOF

set -f
echo " * Import block file: $BLOCK_FILE_MOD"
#echo "RUN: " $VAR
eval $VAR
set +f

echo " * Fill gaps in blocks table"
mysql --login-path=$MYSQL_LOGIN maxmind < $SCRIPT_DIR/../sql/table/gaps.sql

end=$(date +%s)
secs=$(( $end - $start ))
echo "Done"
# echo "Elapsed time: $(date -d@$elapsed -u +%H:%M:%S)"
printf 'Elapsed time: %02d:%02d:%02d\n' $(($secs/3600)) $(($secs%3600/60)) $(($secs%60))