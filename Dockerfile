# -*- Dockerfile -*-

FROM debian:buster
MAINTAINER MartyTremblay

RUN apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -y --no-install-recommends \
            build-essential \
            ca-certificates \
            python-setuptools \
            apt-utils \
            curl \
            libgsm1-dev \
            libspeex-dev \
            libspeexdsp-dev \
            libsrtp2-dev \
            libssl-dev \
            portaudio19-dev \
            python \
            python-dev \
            python-pip \
            python-virtualenv \
            && \
    apt-get purge -y --auto-remove && rm -rf /var/lib/apt/lists/*

RUN pip install wheel
RUN pip install paho-mqtt

COPY config_site.h /tmp/

ENV PJSIP_VERSION=2.9
RUN mkdir /usr/src/pjsip && \
    cd /usr/src/pjsip && \
    curl -vsL https://github.com/pjsip/pjproject/archive/${PJSIP_VERSION}.tar.gz | \ 
         tar --strip-components 1 -xz && \
    mv /tmp/config_site.h pjlib/include/pj/ && \
    CFLAGS="-O2 -DNDEBUG" \
    ./configure --enable-shared \
                --disable-opencore-amr \
                --disable-resample \
                --disable-sound \
                --disable-video \
                --with-external-gsm \
                --with-external-pa \
                --with-external-speex \
                --with-external-srtp \
                --prefix=/usr \
                && \
    make all install && \
    /sbin/ldconfig 
 

#ADD https://raw.githubusercontent.com/MartyTremblay/sip2mqtt/master/sip2mqtt.py /opt/sip2mqtt/sip2mqtt.py
RUN mkdir /opt/sip2mqtt && \
        curl -L https://raw.githubusercontent.com/MartyTremblay/sip2mqtt/master/sip2mqtt.py -o /opt/sip2mqtt/sip2mqtt.py
#RUN wget https://raw.githubusercontent.com/MartyTremblay/sip2mqtt/master/sip2mqtt.py -O /opt/sip2mqtt/sip2mqtt.py

RUN cd /usr/src/pjsip/pjsip-apps/src/python && \
    python setup.py build && python setup.py install


CMD ["python", "/opt/sip2mqtt/sip2mqtt.py"]
