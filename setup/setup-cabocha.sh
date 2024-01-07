#!/usr/bin/bash

# install CRF++
cd
wget "https://drive.google.com/uc?export=download&id=0B4y35FiV1wh7QVR6VXJ5dWExSTQ" -O CRF++-0.58.tar.gz

tar zxvf CRF++-0.58.tar.gz
cd CRF++-0.58
./configure

make
make check
sudo make install
sudo ldconfig

cd
rm CRF++-0.58.tar.gz

# install Cabocha
FILE_ID=0B4y35FiV1wh7SDd1Q1dUQkZQaUU
FILE_NAME=cabocha-0.69.tar.bz2
curl -sc /tmp/cookie "https://drive.google.com/uc?export=download&id=${FILE_ID}" > /dev/null
CODE="$(awk '/_warning_/ {print $NF}' /tmp/cookie)"  
curl -Lb /tmp/cookie "https://drive.google.com/uc?export=download&confirm=${CODE}&id=${FILE_ID}" -o ${FILE_NAME}

bzip2 -dc cabocha-0.69.tar.bz2 | tar xvf -
cd cabocha-0.69
LDFLAGS="-Wl,-rpath=/usr/local/lib -L/usr/local/lib" ./configure --with-mecab-config=`which mecab-config` --with-charset=UTF8

make
make check
sudo make install
sudo ldconfig

cd
rm ${FILE_NAME}
