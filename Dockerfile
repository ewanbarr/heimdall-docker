FROM nvidia/cuda:8.0-devel-ubuntu16.04

RUN apt-get update &&\
    apt-get install -y --no-install-recommends \
    git \
    cvs \
    csh \
    expect \
    autotools-dev \
    autoconf \
    automake \
    libtool \
    libboost-all-dev \
    ca-certificates 
    
WORKDIR /software/

#install Dedisp
RUN git clone https://github.com/ewanbarr/dedisp-flexi.git &&\
    cd dedisp-flexi &&\
    make -j 32 &&\
    make install 

#install Psrdada
RUN echo '#!/usr/bin/expect' > psrdada_cvs_login &&\
    echo 'spawn cvs -d:pserver:anonymous@psrdada.cvs.sourceforge.net:/cvsroot/psrdada login' >> psrdada_cvs_login &&\
    echo 'expect "CVS password:"' >> psrdada_cvs_login &&\
    echo 'send "\r"' >> psrdada_cvs_login &&\
    chmod +x psrdada_cvs_login &&\
    ./psrdada_cvs_login &&\
    cvs -z3 -d:pserver:anonymous@psrdada.cvs.sourceforge.net:/cvsroot/psrdada co -P psrdada
ENV PSRDADA_HOME /software/psrdada
WORKDIR $PSRDADA_HOME
RUN ./bootstrap && \
    ./configure --prefix=/usr/local && \
    make -j 32&& \
    make install && \
    make clean
ENV PSRDADA_BUILD /usr/local
ENV PACKAGES $PSRDADA_BUILD

WORKDIR /software/

#install Heimdall
RUN git clone https://git.code.sf.net/p/heimdall-astro/code heimdall-astro-code &&\
    cd heimdall-astro-code &&\
    ./bootstrap &&\
    ./configure --with-cuda-dir=/usr/local/cuda-8.0/ &&\
    chmod +x libtool &&\
    cp libtool /usr/local/bin &&\
    make -j 32 &&\ 
    make install &&\
    make clean &&\
    ldconfig /usr/local/lib/
    
 
 