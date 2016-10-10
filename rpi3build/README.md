#My RPi3 Kernel Build image

##Create a kernel config
```
docker run \
  -v $(pwd):/config_output \
  --rm=true
  bardak/rpibuild \
  -it \
  menuconfig
```
##Running the container
```
docker run -e DEBMAIL="name@domain.tld" \
  -e DEBFULLNAME="Your full name" \
  -v /path/to/debs/output:/debs
  -v /path/to/config:/root/src/linux/.config
  -d \
  bardak/rpibuild \
```

look at docker-compose.yml for running together with my aptly image


#Environment variables
```
DEBEMAIL		: your email address in changelog
DEBBFULLNAME	: your full name in changelog 
FINAL_UID		: chown the final debs and/or config to UID
CHANGE_MESSAGE	: message in debian/changelog (defaults to "My kernel build")

APTLY_SERVER : fqdn to aptly server
APTLY_SERVER_PORT: port for aptly server (defaults to 8080)
APTLY_REPO : name on repo that debs should be published in (default to repo)
APTLY_DISTRIBUTION : Defaults to jessie

```
