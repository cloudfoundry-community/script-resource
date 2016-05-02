FROM gliderlabs/alpine:3.3

RUN apk add --no-cache curl bash jq

ADD assets/ /opt/resource
ADD test/ /opt/resource-tests/
RUN /opt/resource-tests/all.sh \
 && rm -rf /tmp/*

