BASE_DIR=base
RELEASE_NAME=opentelemetry-collector
CHART_NAME=open-telemetry/opentelemetry-collector
VERSION=0.80.0
CHART_VERSION=0.54.1
EXTRA_ARGS=--set image.tag=${VERSION} --version ${CHART_VERSION}
NAMESPACE=sre

.PHONY: install-dependencies
install-dependencies:
	helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
	helm repo update

.PHONY: template
template: validate install-dependencies
	rm -rf ${BASE_DIR}/${RELEASE_NAME}
	helm template -n $(NAMESPACE) ${RELEASE_NAME} $(CHART_NAME) $(EXTRA_ARGS) -f ./values.yaml -f ./$(ENVIRONMENT)/values.yaml --output-dir $(BASE_DIR)

.PHONY: deploy
deploy: validate install-dependencies
	helm upgrade --install --wait -n $(NAMESPACE) $(RELEASE_NAME) $(CHART_NAME) $(EXTRA_ARGS) -f ./values.yaml -f ./$(ENVIRONMENT)/values.yaml

.PHONY: delete
delete: install-dependencies
	helm uninstall -n $(NAMESPACE) $(RELEASE_NAME)

.PHONY: validate
validate:
ifeq (${ENVIRONMENT},)
	$(error ENVIRONMENT is undefined. Should be development, staging or production)
endif
