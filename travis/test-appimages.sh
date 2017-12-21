#! /bin/bash

set -x
# important to allow for checking the exit code of timeout
set +e

TIMEOUT=3
ARCH=${ARCH:-$(uname -p)}

error() {
    echo "Error: command failed" >&2
    exit 1
}

curl --upload-file out/appimagetool-"$ARCH".AppImage https://transfer.sh/appimagetool-"$ARCH".AppImage
curl --upload-file out/appimaged-"$ARCH".AppImage https://transfer.sh/appimaged-"$ARCH".AppImage

# first of all, try to run appimagetool
./out/appimagetool-"$ARCH".AppImage && error  # should fail due to missing parameter
./out/appimagetool-"$ARCH".AppImage -h || error  # should not fail

# now check appimaged
timeout "$TIMEOUT" out/appimaged-"$ARCH".AppImage --no-install

if [ $? -ne 124 ]; then
    echo "Error: appimaged was not terminated by timeout as expected" >&2
    exit 1
fi

echo "" >&2
echo "Tests successful!" >&2
