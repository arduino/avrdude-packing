#!/bin/bash -ex

# TODO: Determine version from git tags instead of hardcoding it here
AVRDUDE_VERSION=8.2
ARDUINO_TAG=arduino.1

if [ $TARGET_OS = "windows" ]; then
	cmake \
		-S avrdude-${AVRDUDE_VERSION} \
		-B /avrdude-build \
		-DCMAKE_TOOLCHAIN_FILE=$(pwd)/patches/toolchain-mingw-w64.cmake \
		-DMINGW_COMPILER=${CROSS_COMPILE} \
		-DMINGW_TOOLCHAIN_ROOT=$(dirname $(dirname $(which ${CROSS_COMPILE}-gcc))) \
		-DUSE_STATIC_LIBS=ON \
		-DCMAKE_PREFIX_PATH=${PREFIX} \
		-DCMAKE_C_FLAGS="-I${PREFIX}/include/libusb-1.0 -I${PREFIX}/include/libelf -I${PREFIX}/include -pthread"
elif [ $TARGET_OS = "linux" ]; then
	cmake \
		-S avrdude-${AVRDUDE_VERSION} \
		-B /avrdude-build \
		-DCMAKE_TOOLCHAIN_FILE=$(pwd)/patches/toolchain-linux-gcc.cmake \
		-DMINGW_COMPILER=${CROSS_COMPILE} \
		-DMINGW_TOOLCHAIN_ROOT=$(dirname $(dirname $(which ${CROSS_COMPILE}-gcc))) \
		-DUSE_STATIC_LIBS=ON \
		-DCMAKE_PREFIX_PATH=${PREFIX} \
		-DLIB_NCURSES=${PREFIX}/lib/libncursesw.a \
		-DCMAKE_C_FLAGS="-I${PREFIX}/include/libusb-1.0 -I${PREFIX}/include/libelf -I${PREFIX}/include -pthread"
elif [ $TARGET_OS = "macos" ]; then
	cmake \
		-S avrdude-${AVRDUDE_VERSION} \
		-B /avrdude-build \
		-DCMAKE_TOOLCHAIN_FILE=$(pwd)/patches/toolchain-macos-clang.cmake \
		-DMINGW_COMPILER=${CROSS_COMPILE} \
		-DMINGW_TOOLCHAIN_ROOT=$(dirname $(dirname $(which ${CROSS_COMPILE}-cc))) \
		-DUSE_STATIC_LIBS=ON \
		-DCMAKE_PREFIX_PATH=${PREFIX} \
		-DLIB_NCURSES=${PREFIX}/lib/libncursesw.a \
		-DCMAKE_C_FLAGS="-I${PREFIX}/include/libusb-1.0 -I${PREFIX}/include/libelf -I${PREFIX}/include -pthread" \
		-DCMAKE_EXE_LINKER_FLAGS="-framework CoreFoundation -framework IOKit -framework Security -framework SystemConfiguration"
else
	echo "Unsupported TARGET_OS: $TARGET_OS"
	exit 1
fi

cmake --build /avrdude-build -v
cmake --install /avrdude-build --prefix /avrdude-${AVRDUDE_VERSION}-${ARDUINO_TAG}

${CROSS_COMPILE}-strip /avrdude-${AVRDUDE_VERSION}-${ARDUINO_TAG}/bin/avrdude*
tar cjf /build/avrdude-${AVRDUDE_VERSION}-${ARDUINO_TAG}.tar.bz2 -C / avrdude-${AVRDUDE_VERSION}-${ARDUINO_TAG}
file /avrdude-${AVRDUDE_VERSION}-${ARDUINO_TAG}/bin/avrdude* >> /build/avrdude-build.log
