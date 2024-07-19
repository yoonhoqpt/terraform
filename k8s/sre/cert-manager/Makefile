RELEASE_NAME=cert-manager
CHART_NAME=jetstack/cert-manager
VERSION=v1.10.1

.PHONY: install-dependencies
install-dependencies:
	helm repo add jetstack https://charts.jetstack.io
	helm repo update

.PHONY: deploy
deploy: validate install-dependencies
	helm upgrade --install --wait --namespace cert-manager --create-namespace --set installCRDs=true \
		$(RELEASE_NAME) $(CHART_NAME) \
		--version $(VERSION)

.PHONY: delete
delete: install-dependencies
	helm uninstall -n cert-manager $(RELEASE_NAME)

.PHONY: validate
validate:
ifeq (${ENVIRONMENT},)
	$(error ENVIRONMENT is undefined. Should be development, staging or production)
endif

