RELEASE_NAME=google-cas-issuer
CHART_NAME=jetstack/cert-manager-google-cas-issuer
VERSION=v0.6.2
RELOADER_RELEASE_NAME=reloader
RELOADER_CHART_NAME=stakater/reloader
RELOADER_VERSION=v1.0.27

.PHONY: install-dependencies
install-dependencies:
	helm repo add jetstack https://charts.jetstack.io
	helm repo add stakater https://stakater.github.io/stakater-charts
	helm repo update

.PHONY: deploy
deploy: validate install-dependencies
	# TODO: uncomment if using Private CA module
	#helm upgrade --install --namespace cert-manager --wait \
	#	$(RELEASE_NAME) $(CHART_NAME) \
	#	--version $(VERSION)
	#kubectl apply -f ${ENVIRONMENT}/googleCASClusterIssuer.yaml
	#kubectl apply -f rolebinding.yaml -f clusterrolebinding.yaml
	#kubectl -n cert-manager patch deployment cert-manager-$(RELEASE_NAME) --patch-file sa-patch.yaml

	#helm upgrade --install --wait --namespace sre --create-namespace \
	#	$(RELOADER_RELEASE_NAME) $(RELOADER_CHART_NAME) \
	#	--version $(RELOADER_VERSION)

.PHONY: delete
delete: install-dependencies
	helm uninstall -n cert-manager $(RELEASE_NAME)
	helm uninstall -n sre $(RELOADER_RELEASE_NAME)
	kubectl delete -f ${ENVIRONMENT}/googleCASClusterIssuer.yaml
	kubectl delete -f rolebinding.yaml -f clusterrolebinding.yaml

.PHONY: validate
validate:
ifeq (${ENVIRONMENT},)
	$(error ENVIRONMENT is undefined. Should be development, staging or production)
endif

