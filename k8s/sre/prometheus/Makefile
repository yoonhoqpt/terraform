BASE_DIR=base
RELEASE_NAME=prometheus
CHART_NAME=prometheus-community/prometheus 
VERSION=23.1.0
IMAGE_TAG=v2.45.0
EXTRA_ARGS=--version ${VERSION} --set image.tag=${IMAGE_TAG}

.PHONY: install-dependencies
install-dependencies:
	helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
	helm repo add kube-state-metrics https://kubernetes.github.io/kube-state-metrics
	helm repo update

.PHONY: template
template: validate install-dependencies
	rm -rf ${BASE_DIR}/${RELEASE_NAME}
	helm template -n sre ${RELEASE_NAME} $(CHART_NAME) $(EXTRA_ARGS) --output-dir=./base -f ./values.yaml -f ./$(ENVIRONMENT)/values.yaml

.PHONY: deploy
deploy: validate install-dependencies
	helm upgrade --install --wait -n sre $(RELEASE_NAME) $(CHART_NAME) $(EXTRA_ARGS) -f ./values.yaml -f ./$(ENVIRONMENT)/values.yaml

.PHONY: delete
delete: install-dependencies
	helm uninstall -n sre $(RELEASE_NAME)

.PHONY: validate
validate:
ifeq (${ENVIRONMENT},)
	$(error ENVIRONMENT is undefined. Should be development, staging or production)
endif
