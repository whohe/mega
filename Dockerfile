FROM alpine
WORKDIR /mnt

RUN apk add build-base
RUN apk add c-ares-dev
RUN apk add openssl-dev
RUN apk add zlib-dev
RUN apk add sqlite-dev
RUN apk add git
RUN apk add autoconf
RUN apk add libtool
RUN apk add intltool
RUN apk add automake
RUN apk add readline-dev
RUN apk add libsodium-dev
RUN apk add sqlite

RUN apk add abuild
RUN adduser who -D
RUN addgroup who abuild

USER who
WORKDIR /home/who
RUN git clone https://github.com/meganz/sdk.git 
RUN mkdir -p /tmp/curl
WORKDIR /tmp/curl
RUN wget https://git.alpinelinux.org/aports/plain/main/curl/APKBUILD?h=3.3-stable -O APKBUILD
RUN sed -i -e 's/configure/configure --with-ssl/' APKBUILD
RUN wget https://git.alpinelinux.org/aports/plain/main/curl/CVE-2017-1000254.patch?h=3.3-stable -O CVE-2017-1000254.patch
RUN wget https://git.alpinelinux.org/aports/plain/main/curl/CVE-2017-1000257.patch?h=3.3-stable -O CVE-2017-1000257.patch
RUN wget https://git.alpinelinux.org/aports/plain/main/curl/curl-do-bounds-check-using-a-double-comparison.patch?h=3.3-stable -O curl-do-bounds-check-using-a-double-comparison.patch
RUN abuild-keygen -an 
RUN abuild checksum && abuild -r
RUN mv /home/who/packages/tmp/x86_64/ /home/who/curl
USER root
WORKDIR /home/who/curl
RUN apk add --allow-untrusted *.apk

USER who
RUN mkdir -p /tmp/cripto++
WORKDIR /tmp/cripto++
RUN wget https://git.alpinelinux.org/aports/plain/testing/crypto++/APKBUILD 
RUN abuild-keygen -an 
RUN abuild checksum && abuild -r
RUN mv /home/who/packages/tmp/x86_64/ /home/who/crypto++
USER root
WORKDIR /home/who/crypto++
RUN apk add --allow-untrusted *.apk

USER who
RUN mkdir -p /tmp/freeimage
WORKDIR /tmp/freeimage
RUN wget https://git.alpinelinux.org/aports/plain/community/freeimage/APKBUILD
RUN wget https://git.alpinelinux.org/aports/plain/community/freeimage/0005-makefile-gnu.patch
RUN wget https://git.alpinelinux.org/aports/plain/community/freeimage/0002-fix-cpuid-x86.patch
RUN wget https://git.alpinelinux.org/aports/plain/community/freeimage/0001-no-root-install.patch
RUN abuild-keygen -an 
RUN abuild checksum && abuild -r
RUN mv /home/who/packages/tmp/x86_64/ /home/who/freeimage
USER root
WORKDIR /home/who/freeimage
RUN apk add --allow-untrusted *.apk

WORKDIR /home/who/
RUN rm -rf freeimage crypto++ curl packages

WORKDIR /home/who/sdk
USER who
RUN sh autogen.sh
RUN ./configure
RUN make
USER root
RUN make install
USER who
CMD megacli

