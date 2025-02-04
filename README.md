# Dockerized phpBB

## Setup
Download this repository or fetch it: `git clone https://github.com/Indianos/phpbb-docker.git phpbb-docker`

Enter into the folder (`cd phpbb-docker`)

Copy `.env.example` to `.env` and fill and adjust to Your specific needs.
At minimum, fill values `MARIADB_ROOT_PASSWORD` and `DBPASSWD`.

### SSL files
> If you don't require HTTPS, skip this section and remove the SSL volume mount from the `phpbb` container definition in `docker-compose.yml`.

Create the `ssl` directory:
```sh
mkdir ssl
```

Uncomment two lines of code in `docker-compose.yml`:
```yaml
services:
  phpbb:
    ...
    volumes:
      - ./ssl:/etc/apache2/ssl
```

For development, generate a private key file and an associated self-signed
certificate, with the Common Name option - replace `$SERVER_NAME` with your planned host written in `.env`):
```sh
openssl req -nodes -x509 -newkey rsa:2048 \
  -subj "/CN=$SERVER_NAME" \
  -keyout ssl/default.key \
  -out ssl/default.crt
```

For a production system, retrieve an SSL certificate for your domain signed by
an official Certificate Authority. Combine the issued certificate and any
intermediate certificates into a file called `default.crt` and put it into the
`ssl` directory. Add the private key used for the certificate signing request as
`default.key`:

- `ssl/default.crt`
- `ssl/default.key`

### Database options
Apart from initial database passwords, if there is already a database server, You can disable default container in `docker-compose.yml` and add necessary config in `.env`:
```yaml
services:
#  mysql:
#    image: mariadb
#    # Debug access:
#    #ports:
#    #  - "3306:3306"
#    environment:
#      MARIADB_ROOT_PASSWORD: $MARIADB_ROOT_PASSWORD
#      MARIADB_USER: $DBUSER
#      MARIADB_PASSWORD: $DBPASSWD
#      MARIADB_DATABASE: $DBNAME
  ...
```

```sh
DBHOST='mysql'
DBPORT= # Defaults to 3306 in phpBB
DBNAME='phpbb'
DBUSER='phpbb'
TABLE_PREFIX='phpbb_'
```

### Scheduled backups to Amazon S3
TODO: Not yet implemented

### Container start
Start the MySQL and phpBB containers:

```sh
docker-compose up -d
```

### phpBB
Open a browser with the server URL and follow the installation instructions.

#### Database configuration
Use the following database configuration, again replacing "password2" with the
`$DBPASSWD` value:

Setting                       | Value
------------------------------|----------
Database type                 | mysqli
Database server hostname      | mysql
Database server port          |
Database username             | phpbb
Database password             | password2
Database name                 | phpbb
Prefix for tables in database | phpbb_

#### Email configuration
Use the following Email settings to use Gmail as SMTP provider:

Setting                        | Value
-------------------------------|---------------------
Use SMTP server for e-mail     | Yes
SMTP server address            | tls://smtp.gmail.com
SMTP server port               | 465
Authentication method for SMTP | PLAIN
SMTP username                  | example@gmail.com
SMTP password                  | YourGmailPassword

Please note that you need to create an
[app password](https://security.google.com/settings/security/apppasswords)
if you use 2-Step Verification for your Google account.

## After-setup
### Remove 'install' directory
Of course, phpBB will ask You to remove `install` directory. This can be done using `docker compose exec phpbb rm -rf install`.

### Change installed status
Also You must enable installed variable. Change `PHPBB_INSTALLED=true` in `.env` file on the host machine and after saving, recreate the phpBB container:

```sh
docker-compose up -d --force-recreate phpbb
```

### Automatic updates
TODO: Not yet implemented

## License
Released under the [MIT license](https://opensource.org/licenses/MIT).

## Author
[Sebastian Tschan](https://blueimp.net/)
[Indianos](https://github.com/Indianos)
