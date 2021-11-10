test: build
	IMAGE=$(IMAGE) TAG=$(TAG) ARCH=$(ARCH) docker-compose up -d --build --scale acceptance=0
	IMAGE=$(IMAGE) TAG=$(TAG) ARCH=$(ARCH) docker-compose up --abort-on-container-exit acceptance

IMAGE=imega/consul
TAG=latest
ARCH=$(shell uname -m)

ifeq ($(ARCH),aarch64)
        ARCH=arm64
endif

ifeq ($(ARCH),x86_64)
        ARCH=amd64
endif

build: buildfs
	@docker build -t $(IMAGE):$(TAG)-$(ARCH) .
	@docker tag $(IMAGE):$(TAG)-$(ARCH) $(IMAGE):latest-$(ARCH)

buildfs:
	@docker run --rm \
		-v $(CURDIR)/src:/src \
		-v $(CURDIR)/runner:/runner \
		-v $(CURDIR)/build:/build \
		imega/base-builder \
		--packages="busybox bash curl jq consul@edge-community"

login:
	@docker login --username $(DOCKER_USER) --password $(DOCKER_PASS)

release: login
	@docker scan $(IMAGE):$(TAG)-$(ARCH)
	@docker push $(IMAGE):$(TAG)-$(ARCH)
	@docker push $(IMAGE):latest-$(ARCH)

release-manifest: login
	@docker manifest create $(IMAGE):$(TAG) $(IMAGE):$(TAG)-amd64 $(IMAGE):$(TAG)-ppc64le $(IMAGE):$(TAG)-arm64
	@docker manifest create $(IMAGE):latest $(IMAGE):latest-amd64 $(IMAGE):latest-ppc64le $(IMAGE):latest-arm64
	@docker manifest push $(IMAGE):$(TAG)
	@docker manifest push $(IMAGE):latest
