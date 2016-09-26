#!/bin/bash

if [ ! -f /web/index.html ]; then
cat <<EOF > /web/index.html
<!DOCTYPE html> 
<meta charset="utf-8">
<html>
<body>
<p>hostname is:<b> $(hostname)</b></p>
</body>
</html>
EOF
fi

python2.7 -m SimpleHTTPServer
