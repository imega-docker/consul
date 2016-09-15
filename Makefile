# Build rootfs for consul

DOCKER_RM = false

build:
	@docker run --rm \
		-v $(CURDIR)/runner:/runner \
		-v $(CURDIR)/build:/build \
		imega/base-builder \
		--packages="consul@testing"

test:
	@docker build -t imega/consul:test .

	@docker run -d \
		$(MOCK_SERVER_CONSUL_PORT) \
		--name=mock_server_consul \
		imega/consul:test \
		agent -client=0.0.0.0 -dev

	@docker run --rm=$(DOCKER_RM) \
		-v $(CURDIR)/tests:/data \
		-w /data \
		--link mock_server_consul:consul \
		alpine \
		sh -c 'apk add --update bash curl jq && ./wait.sh consul:8500 && ./import.sh consul:8500'


.PHONY: build
