FROM alpine
RUN apk add --update --no-cache bash python openssh
COPY pipe.sh /pipe.sh
COPY pipe.yml /pipe.yml
RUN pip3 install ansible
RUN wget --no-verbose -P / https://bitbucket.org/bitbucketpipelines/bitbucket-pipes-toolkit-bash/raw/master/common.sh
RUN chmod a+x /*.sh
ENTRYPOINT ["/pipe.sh"]