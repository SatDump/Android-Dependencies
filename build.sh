# Settings
#ANDROID_SDK_ZIP=commandlinetools-linux-8512546_latest.zip

# Install deps
#apt update
#apt upgrade -y
#apt install -y cmake wget unzip build-essential git openjdk-11-jdk-headless make

# Install Android SDK
#wget --quiet --output-document=android-sdk.zip https://dl.google.com/android/repository/$ANDROID_SDK_ZIP
#mkdir android-sdk-linux 
#unzip -qq android-sdk.zip -d android-sdk-linux 
#export ANDROID_HOME=/android-sdk-linux
#echo y | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=android-sdk-linux --update
#(echo y; echo y; echo y; echo y; echo y; echo y; echo y; echo y) | $ANDROID_HOME/cmdline-tools/bin/sdkmanager --sdk_root=android-sdk-linux --licenses

# Install NDK
#$ANDROID_HOME/bin/sdkmanager --sdk_root=/android-sdk-linux --install "ndk;25.2.9519653" --channel=3 

OUTPUT_DIR=$PWD/output

# Utils
get_cmake_command() {
    echo "-DCMAKE_TOOLCHAIN_FILE=$ANDROID_HOME/ndk/25.2.9519653/build/cmake/android.toolchain.cmake -DANDROID_ABI=$1 -DANDROID_PLATFORM=android-24"
}

# Packages
build_cpufeatures() {
    echo "--- cpu_features $1"
    cd cpu_features
    mkdir build
    cd build
    cmake $(get_cmake_command $1) -DBUILD_TESTING=OFF -DBUILD_EXECUTABLE=OFF -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build
    cd ..
}


build_volk() {
    echo "--- Volk $1"
    cd volk
    mkdir build
    cd build
    cmake $(get_cmake_command $1) -DCMAKE_FIND_ROOT_PATH=$OUTPUT_DIR/$1 -DENABLE_TESTING=OFF -DENABLE_MODTOOL=OFF -DENABLE_STATIC_LIBS=ON -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build
    cd ..
}

build_zlib() {
    echo "--- ZLib $1"
    cd zlib
    mkdir build
    cd build
    cmake $(get_cmake_command $1) -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build
    cd ..
}

build_libpng() {
    echo "--- LibPNG $1"
    cd libpng
    mkdir build
    cd build
    cmake $(get_cmake_command $1) -DPNG_EXECUTABLES=OFF -DPNG_TESTS=OFF -DPNG_SHARED=OFF -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build
    cd ..
}

build_fftw3() {
    echo "--- FFTW3 $1"
    cd fftw3
    mkdir build
    cd build
    cmake $(get_cmake_command $1) -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 -DBUILD_SHARED_LIBS=OFF -DENABLE_FLOAT=ON ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build
    cd ..
}

build_wolfssl() {
    echo "--- wolfssl $1"
    cd wolfssl
    mkdir build
    cd build
    cmake $(get_cmake_command $1) -DBUILD_SHARED_LIBS=no -DWOLFSSL_CURL=yes -DWOLFSSL_CRYPT_TESTS=no -DWOLFSSL_EXAMPLES=no -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build
    cd ..
}

build_curl() {
    echo "--- curl $1"
    cd curl
    mkdir build
    cd build
    cmake $(get_cmake_command $1) -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 -DHTTP_ONLY=ON -DBUILD_STATIC_LIBS=ON -DCURL_USE_WOLFSSL=ON -DUSE_LIBIDN2=OFF -DWolfSSL_INCLUDE_DIR=$OUTPUT_DIR/$1/include -DWolfSSL_LIBRARY=$OUTPUT_DIR/$1/lib/libwolfssl.a ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build
    cd ..
}

build_nng() {
    echo "--- nng $1"
    cd nng
    mkdir build
    cd build
    cmake $(get_cmake_command $1) -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 -DNNG_TOOLS=OFF -DNNG_TESTS=OFF -DNNG_ENABLE_NNGCAT=OFF ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build
    cd ..
}

build_zstd() {
    echo "--- zstd $1"
    cd zstd
    mkdir build2
    cd build2
    cmake $(get_cmake_command $1) -DZSTD_BUILD_PROGRAMS=OFF -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 ../build/cmake -DZSTD_BUILD_STATIC=ON -DZSTD_BUILD_SHARED=OFF
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build2
    cd ..
}

build_tiff() {
    echo "--- libtiff $1"
    cd libtiff
    mkdir build2
    cd build2
    cmake $(get_cmake_command $1) -DBUILD_SHARED_LIBS=OFF -Dtiff-tools=OFF -Dtiff-tests=OFF -Dtiff-docs=OFF -DCMAKE_INSTALL_PREFIX=$OUTPUT_DIR/$1 ..
    make -j`nproc` DESDIR=$OUTPUT_DIR/$1 install
    cd ..
    rm -rf build2
    cd ..
}

# Build packages
git clone https://github.com/wolfSSL/wolfssl --depth 1 -b v5.7.2-stable
build_wolfssl armeabi-v7a
build_wolfssl arm64-v8a
build_wolfssl x86
build_wolfssl x86_64
rm -rf wolfssl

git clone https://github.com/curl/curl --depth 1 -b curl-8_9_1
build_curl armeabi-v7a
build_curl arm64-v8a
build_curl x86
build_curl x86_64
rm -rf curl

git clone https://github.com/google/cpu_features --depth 1 -b v0.9.0
build_cpufeatures armeabi-v7a
build_cpufeatures arm64-v8a
build_cpufeatures x86
build_cpufeatures x86_64
rm -rf cpu_features

# apt install -y python3-mako
git clone https://github.com/gnuradio/volk --depth 1 -b v3.1.2
build_volk armeabi-v7a
build_volk arm64-v8a
build_volk x86
build_volk x86_64
rm -rf volk

git clone https://github.com/madler/zlib --depth 1 -b v1.3.1
build_zlib armeabi-v7a
build_zlib arm64-v8a
build_zlib x86
build_zlib x86_64
rm -rf zlib

git clone https://github.com/glennrp/libpng --depth 1 -b v1.6.43
build_libpng armeabi-v7a
build_libpng arm64-v8a
build_libpng x86
build_libpng x86_64
rm -rf libpng

#git clone https://github.com/FFTW/fftw3 --depth 1 -b fftw-3.3.10
wget http://www.fftw.org/fftw-3.3.10.tar.gz && tar -zxvf fftw-3.3.10.tar.gz && mv fftw-3.3.10 fftw3 && rm fftw-3.3.10.tar.gz
build_fftw3 armeabi-v7a
build_fftw3 arm64-v8a
build_fftw3 x86
build_fftw3 x86_64
rm -rf fftw3

git clone https://github.com/nanomsg/nng --depth 1 -b v1.8.0
build_nng armeabi-v7a
build_nng arm64-v8a
build_nng x86
build_nng x86_64
rm -rf nng

git clone https://github.com/facebook/zstd --depth 1 -b v1.5.6
build_zstd armeabi-v7a
build_zstd arm64-v8a
build_zstd x86
build_zstd x86_64
rm -rf zstd

git clone https://github.com/libsdl-org/libtiff --depth 1 -b v4.6.0
build_tiff armeabi-v7a
build_tiff arm64-v8a
build_tiff x86
build_tiff x86_64
rm -rf libtiff
