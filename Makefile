# Build rootfs for consul

DOCKER_RM = false
MOCK_SERVER_CONSUL_PORT = -p 8500:8500

build:
	@docker run --rm \
		-v $(CURDIR)/runner:/runner \
		-v $(CURDIR)/build:/build \
		-v $(CURDIR)/src:/src \
		imega/base-builder \
		--packages="bash curl jq consul@testing"

test: build
	@docker build -t imega/consul:test .

	@docker run -d \
		$(MOCK_SERVER_CONSUL_PORT) \
		-v $(CURDIR)/tests/fixtures:/data \
		--name=mock_server_consul \
		imega/consul:test

	@docker run --rm=$(DOCKER_RM) \
		-v $(CURDIR)/tests:/data \
		-w /data \
		--link mock_server_consul:consul \
		alpine \
		sh -c 'apk add --update bash curl && ./test.sh consul:8500'

.PHONY: build
