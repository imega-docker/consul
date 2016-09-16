# Build rootfs for consul

DOCKER_RM = false
MOCK_SERVER_CONSUL_PORT = -p 8505:8500

build:
	@docker run --rm \
		-v $(CURDIR)/runner:/runner \
		-v $(CURDIR)/build:/build \
		-v $(CURDIR)/src:/src \
		imega/base-builder \
		--packages="bash curl jq consul@testing"

test: build
	@docker build -t imega/consul:test .

	docker run -d \
		$(MOCK_SERVER_CONSUL_PORT) \
		-v $(CURDIR)/tests/fixtures:/data \
		--name=mock_server_consul1 \
		imega/consul:test

.PHONY: build
