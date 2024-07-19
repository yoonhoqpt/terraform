BASE_DIR=base
RELEASE_NAME=agent
CHART_NAME=grafana/grafana-agent
VERSION=0.8.0

.PHONY: install-dependencies
install-dependencies:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update

.PHONY: template
template: validate install-dependencies
	rm -rf ${BASE_DIR}/${RELEASE_NAME}
	helm template -n sre ${RELEASE_NAME} $(CHART_NAME) --output-dir=./base -f ./values.yaml -f ./$(ENVIRONMENT)/values.yaml

.PHONY: deploy
deploy: validate install-dependencies
	helm upgrade --install --wait -n sre $(RELEASE_NAME) $(CHART_NAME) --version $(VERSION) -f ./values.yaml -f ./$(ENVIRONMENT)/values.yaml

.PHONY: delete
delete: install-dependencies
	helm uninstall -n sre $(RELEASE_NAME)

.PHONY: validate
validate:
ifeq (${ENVIRONMENT},)
	$(error ENVIRONMENT is undefined. Should be development, staging or production)
endif
