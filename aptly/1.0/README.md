#My Aptly + Nginx image
```
docker run -e APTLY_DISTRIBUTION=jessie \
           -v ~/.passfile:/.passfile \
           -v ~/.gnupg/aptly-sign-key:/sign-key \
           -v ~/my-debs:/debs \
           -p 80:8000 \
           aptly
```

# Environment variables
```
APTLY_REPO_NAME		Name of aptly repo (defaults to repo)
APTLY_DISTRIBUTION	Distribution of repo
APTLY_COMPONENT		Component of repo (defaults to main)

```

#create a sub-key for signing packages
* Find your key ID: gpg --list-keys yourname
* gpg --edit-key YOURMASTERKEYID
* At the gpg> prompt: addkey \n This asks for your passphrase, type it in. 
* Choose the "RSA (sign only)" key type. 
* choose 4096 bits long key
* Choose an expiry date (you can rotate your subkeys more frequently than the master keys, or keep them for the life of the master key, with no expiry). 
* GnuPG will (eventually) create a key, but you may have to wait for it to get enough entropy to do so. 
* Save the key: save
* push the keys to keyservers
```
gpg --send-keys
```
get the ID of the signing key you just created
```
Find your key ID: gpg --list-keys yourname
```
Export the newly created signing subkey to a file (don't forget the ! at the end of the subkey)
```
gpg --output signing-key  --export-secret-subkeys SUBKEYID!
```

