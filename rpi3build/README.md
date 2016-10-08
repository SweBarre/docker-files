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


#Environment variables
```
DEBEMAIL		: your email address in changelog
DEBBFULLNAME	: your full name in changelog 
FINAL_UID		: chown the final debs and/or config to UID
MAKE_PARAMS		: specify -j to make (for examiple -j4)
CHANGE_MESSAGE	: message in debian/changelog (defaults to "My kernel build")
```
