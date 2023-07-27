FROM alpine
RUN apk add --update --no-cache bash python3 openssh git docker openrc
COPY pipe/pipe.sh /pipe.sh
COPY pipe.yml /pipe.yml
RUN rc-update add docker boot
RUN python3 -m ensurepip
RUN pip3 install ansible docker requests
RUN wget --no-verbose -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/master/common.sh
RUN chmod a+x /*.sh
ENTRYPOINT ["/pipe.sh"]
