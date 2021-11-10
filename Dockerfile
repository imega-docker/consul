FROM scratch

LABEL maintainer="Dmitry Stoletoff <info@imega<dot>ru>" \
    description="This is docker image to run the Consul." \
    url="https://github.com/imega-docker/base-builder" \
    changelog="https://github.com/imega-docker/consul/blob/master/CHANGELOG.md" \
    license="https://github.com/imega-docker/consul/blob/master/LICENSE.txt"

ADD build/rootfs.tar.gz /

CMD ["/entry.sh"]
