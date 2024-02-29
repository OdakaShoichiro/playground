#!/usr/bin/bash

# use user home
cd

# install CRF++
DIR_NAME=CRF++-0.58 
FILE_NAME=${DIR_NAME}.tar.gz
wget "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ" -O ${FILE_NAME}

tar zxvf ${FILE_NAME}
cd ${DIR_NAME}
./configure

make
make check
sudo make install
sudo ldconfig

cd
rm ${FILE_NAME}

# install Cabocha
DIR_NAME=cabocha-0.69
FILE_NAME=${DIR_NAME}.tar.bz2
# FILE_ID=0B4y35FiV1wh7SDd1Q1dUQkZQaUU
# curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${FILE_ID}" > /dev/null
# CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"  
# curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${CODE}&id=${FILE_ID}" -o ${FILE_NAME}
cp /workspace/setup/${FILE_NAME} .

bzip2 -dc ${FILE_NAME} | tar xvf -
cd ${DIR_NAME}
LDFLAGS="-Wl,-rpath=/usr/local/lib -L/usr/local/lib" ./configure --with-mecab-config=`which mecab-config` --with-charset=UTF8

make
make check
sudo make install
sudo ldconfig

cd
rm ${FILE_NAME}
