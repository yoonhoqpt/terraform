VERSION=0.21.1
RELEASE_NAME=github-actions-runner
CHART_NAME=github-actions-runner/actions-runner-controller

.PHONY: install-dependencies
install-dependencies:
	helm repo add $(RELEASE_NAME) https://actions-runner-controller.github.io/actions-runner-controller
	helm repo update

.PHONY: template
template: install-dependencies
	helm template -n sre $(RELEASE_NAME) $(CHART_NAME) --version $(VERSION) -f ./values.yaml --output-dir ./base

.PHONY: deploy
deploy: validate install-dependencies
	helm upgrade --install --wait -n sre $(RELEASE_NAME) $(CHART_NAME) --version $(VERSION) -f ./values.yaml
	cd ./runners/$(ENVIRONMENT) && kubectl -n sre apply -k .

.PHONY: delete
delete: install-dependencies
	helm uninstall -n sre $(RELEASE_NAME)

.PHONY: validate
validate:
ifeq (${ENVIRONMENT},)
	$(error ENVIRONMENT is undefined. Should be development, staging or production)
endif
