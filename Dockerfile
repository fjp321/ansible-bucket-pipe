FROM alpine
RUN apk add --update --no-cache bash python3 openssh curl
COPY pipe/pipe.sh /pipe.sh
COPY pipe.yml /pipe.yml
RUN python3 -m ensurepip
RUN pip3 install ansible
RUN wget --no-verbose -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/master/common.sh
RUN chmod a+x /*.sh
ENTRYPOINT ["/pipe.sh"]
