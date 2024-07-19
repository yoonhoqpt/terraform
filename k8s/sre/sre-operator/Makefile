VERSION=0.7.1
BASE_DIR=base
RELEASE_NAME=sre-operator
CHART_NAME=dapper/${RELEASE_NAME}
PLUGIN_INSTALL=$(shell helm plugin list | grep gcs)

.PHONY: install-dependencies
install-dependencies:
ifeq (${PLUGIN_INSTALL},)
	helm plugin install https://github.com/hayorov/helm-gcs.git
endif
	helm repo add dapper gs://dapperlabs-platform-helm-charts
	helm repo update

.PHONY: deploy
deploy: install-dependencies
	helm upgrade --install -n sre $(RELEASE_NAME) $(CHART_NAME) --version $(VERSION) -f ./values.yaml

.PHONY: delete
delete: install-dependencies
	helm uninstall -n sre $(RELEASE_NAME)
