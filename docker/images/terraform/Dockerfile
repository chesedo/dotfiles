FROM alpine:latest

ARG version=1.0.5

RUN wget https://releases.hashicorp.com/terraform/${version}/terraform_${version}_linux_amd64.zip
RUN unzip terraform_${version}_linux_amd64.zip && rm terraform_${version}_linux_amd64.zip
RUN mv terraform /usr/bin/terraform

RUN addgroup -g 1000 -S developer && \
    adduser -u 1000 -S developer -G developer
USER developer

CMD terraform
