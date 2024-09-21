#!/usr/bin/env bash

ENVDIR=${ENVDIR:-~/pkgenv}
SRCDIR=${SRCDIR:-~/pkgsrc}

mkdir -p $ENVDIR
mkdir -p $ENVDIR/include
mkdir -p $ENVDIR/lib
mkdir -p $ENVDIR/lib/cmake

mkdir -p $SRCDIR

sudo apt-get remove --purge -y gcc g++ cmake
sudo apt-get -y autoremove
sudo apt-get clean

# GCC installation
echo "=================================="
echo "|          GCC install           |"
echo "=================================="

sudo apt-get install -y software-properties-common

sudo add-apt-repository ppa:ubuntu-toolchain-r/test
sudo apt-get update
sudo apt-get install -y gcc-11 g++-11

# Do it manually(not work in .sh)
sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-11 60
# sudo update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-9 50
sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-11 60
# sudo update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-9 50

# GCC installation
echo "=================================="
echo "|          GCC install done      |"
echo "=================================="


# GCC installation
echo "=================================="
echo "|          CMake 3.30.2 install  |"
echo "=================================="

sudo apt-get update
sudo apt-get install -y libssl-dev

sudo apt-get update
sudo apt-get install -y build-essential

sudo apt-get install -y wget
wget https://cmake.org/files/v3.30/cmake-3.30.2.tar.gz
tar -zxvf cmake-3.30.2.tar.gz
cd cmake-3.30.2
./bootstrap
make -j$(nproc)
sudo make install
export PATH=/usr/local/bin:$PATH

echo "=================================="
echo "|      CMake 3.30.2 install done |"
echo "=================================="

echo ""
echo "version check..."
cmake --version
gcc --version
g++ --version
python3 --version

echo "[CHECKPOINT]press any key to continue..."
read -n 1 -s -r
echo "continue..."

echo "=================================="
echo "|      python 3.6 install start  |"
echo "=================================="
sudo apt-get update
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt-get update
sudo apt-get install -y python3.6 python3.6-dev
sudo apt-get install python3.6-venv

sudo apt-get install -y build-essential pkg-config git
sudo apt-get install -y libeigen3-dev libassimp-dev libtinyxml2-dev
sudo apt-get install -y libccd-dev libfcl-dev libboost-regex-dev libboost-system-dev
sudo apt-get install -y libxi-dev libxmu-dev freeglut3-dev libglfw3-dev libgl1-mesa-dev libglu1-mesa-dev
sudo apt-get install -y libbullet-dev libode-dev liboctomap-dev
sudo apt-get install -y libopenscenegraph-dev libnlopt-cxx-dev coinor-libipopt-dev
sudo apt-get install -y libdw-dev libbfd-dev libdwarf-dev libelf-dev

# sudo apt-get install -y pybind11-dev


# If CentOS server, set C++ compiler manually
if [ -f /etc/redhat-release ]; then
    export CC=/opt/ohpc/pub/compiler/gcc/8.3.0/bin/gcc
    export CXX=/opt/ohpc/pub/compiler/gcc/8.3.0/bin/g++
fi


install_library() {
    git clone --depth 1 --branch $3 $2 $1
    echo "==== Installing $1 at $ENVDIR ===="
    mkdir $1/build
    pushd $1/build
    if [ -f ../CMakeLists.txt ]; then
        cmake -DCMAKE_BUILD_TYPE=Release \
              -DCMAKE_PREFIX_PATH=$ENVDIR \
              -DCMAKE_INSTALL_PREFIX=$ENVDIR \
              -DCMAKE_INSTALL_RPATH_USE_LINK_PATH=TRUE \
              -DCMAKE_INSTALL_RPATH=$ENVDIR \
              -DFCL_INCLUDE_DIRS=/home/$USER/pkgenv/include/fcl \
              $4 \
              ..
    elif [ -f Makefile ]; then
        cd ..
    fi

    make -j$(nproc) install
    popd
}

install_tbb() {
    local pkgver=$1
    wget https://github.com/oneapi-src/oneTBB/archive/v$pkgver/tbb-$pkgver.tar.gz
    tar -xvzf tbb-$pkgver.tar.gz
    rm tbb-$pkgver.tar.gz

    pushd oneTBB-$pkgver
    pushd src
    make -j$(nproc) tbb tbbmalloc
    popd
    install -Dm755 build/linux_*/*.so* -t $ENVDIR/lib
    install -d $ENVDIR/include
    cp -a include/tbb $ENVDIR/include
    cmake \
        -DINSTALL_DIR=$ENVDIR/lib/cmake/TBB \
        -DSYSTEM_NAME=Linux -DTBB_VERSION_FILE=$ENVDIR/include/tbb/tbb_stddef.h \
        -P cmake/tbb_config_installer.cmake
    popd
}

pushd $SRCDIR

install_tbb 2020.3
install_library tinyxml2 https://github.com/leethomason/tinyxml2 8.0.0
install_library pybind11 https://github.com/pybind/pybind11 v2.5.0 "-DPYBIND11_TEST=OFF"
install_library eigen3 https://gitlab.com/libeigen/eigen 3.3.7
install_library libccd https://github.com/danfis/libccd v2.0
install_library assimp https://github.com/assimp/assimp v4.0.1
install_library octomap https://github.com/OctoMap/octomap v1.8.1
install_library fcl https://github.com/flexible-collision-library/fcl 0.6.1 "-DFCL_BUILD_TESTS=OFF"
install_library bullet3 https://github.com/bulletphysics/bullet3 2.89 \
    "-DBUILD_SHARED_LIBS=ON -DCMAKE_POSITION_INDEPENDENT_CODE=ON"
    
# install_library dart https://github.com/dartsim/dart v6.9.2 \
#     "-DDART_ENABLE_SIMD=ON -DFCL_INCLUDE_DIRS=$ENVDIR/include/fcl 
-DBULLET_INCLUDE_DIRS=$ENVDIR/include/bullet"
install_library dart https://github.com/dartsim/dart v6.9.2 \
    "-DDART_ENABLE_SIMD=ON \
     -DDART_BUILD_GUI_OSG=ON \
     -DFCL_INCLUDE_DIRS=$ENVDIR/include/fcl \
     -DBULLET_INCLUDE_DIRS=$ENVDIR/include/bullet"

popd
