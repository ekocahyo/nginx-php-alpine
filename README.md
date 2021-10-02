# Engine information:
- apine => 3.13
- nginx => latest version
- php => 7.4
- composer => latest version

# env php:
- PHP_FPM_MAX_CHILDREN="5"
- PHP_FPM_START_SERVERS="2"
- PHP_FPM_MIN_SPARE_SERVERS="1"
- PHP_FPM_MAX_SPARE_SERVERS="2"
- PHP_FPM_MAX_REQUESTS="1000"
- PHP_FPM_PROCESS_IDLE_TIMEOUT="10s"
- POST_MAX_SIZE="10M"
- UPLOAD_MAX_FILESIZE=$POST_MAX_SIZE
- TIMEZONE=

# env nginx: 
- CLIENT_MAX_BODY_SIZE=$POST_MAX_SIZE
- ROOT_DIR="/usr/share/nginx/html"

# ext php:
- composer
- json
- phar
- mbstring
- openssl