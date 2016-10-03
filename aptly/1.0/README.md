docker run -e KEYSERVER=keys.gnupg.net \
           -e GPG_PASSPHRASE_FILE=/.passfile \
           -v ~/.passfile:/.passfile \
           -v $(pwd)/secret-subkeys:/secret-subkeys \
           -v ~/my-debs:/debs \
           -p 80:8000 \
           aptly
