TEMPLATE_DIR=template
RELEASE_NAME=kyverno
CHART_NAME=kyverno/kyverno
NAMESPACE=kyverno
VERSION=v1.8.5
CHART_VERSION=2.6.5
STANDARD_ARGS=--namespace ${NAMESPACE}
EXTRA_ARGS=--set image.tag=${VERSION} --version ${CHART_VERSION}
PR=policy-reporter
PR_VERSION=2.11.1
PR_CHART_VERSION=2.14.1
PR_ARGS=--set target.slack.webhook=${SLACK_WEBHOOK}
# TODO update me
CLUSTER_NAME="CLUSTER_NAME_NEEDS_UPDATING"
PR_EXTRA_ARGS=--set image.tag=${PR_VERSION} --set emailReports.clusterName="${CLUSTER_NAME}-${ENVIRONMENT}" --version ${PR_CHART_VERSION}


.PHONY: install-dependencies
install-dependencies:
	helm repo add kyverno https://kyverno.github.io/kyverno/
	helm repo add policy-reporter https://kyverno.github.io/policy-reporter
	helm repo update

.PHONY: template
template:
	rm -rf ${TEMPLATE_DIR} || true
	mkdir -p ${TEMPLATE_DIR}/${RELEASE_NAME}
	helm template $(RELEASE_NAME) $(CHART_NAME) $(STANDARD_ARGS) $(EXTRA_ARGS) --output-dir=./$(TEMPLATE_DIR) -f ./values.yaml
	helm template $(PR) $(PR)/$(PR) -n $(PR) $(PR_ARGS) $(PR_EXTRA_ARGS) --output-dir=./$(TEMPLATE_DIR) -f ./pr_values.yaml

.PHONY: install
install:
	helm upgrade --install --wait $(RELEASE_NAME) $(CHART_NAME) $(STANDARD_ARGS) $(EXTRA_ARGS) -f ./values.yaml

.PHONY: install-policy-reporter
install-policy-reporter:
	helm upgrade --install --wait $(PR) $(PR)/$(PR) -n $(PR) $(PR_ARGS) $(PR_EXTRA_ARGS) -f ./pr_values.yaml

.PHONY: deploy
deploy: validate install-dependencies install install-relay install-policy-reporter policies

.PHONY: delete
delete: validate install-dependencies delete-policies delete-relay
	helm uninstall -n $(NAMESPACE) $(RELEASE_NAME)
	helm uninstall -n $(PR) $(PR)

.PHONY: install-relay
install-relay:
	cd relay && kustomize build . | kubectl apply -n $(PR) -f  -

.PHONY: delete-relay
delete-relay:
	cd relay && kustomize build . | kubectl delete -n $(PR) -f  -

.PHONY: policies
policies: validate
	cd $(ENVIRONMENT) && kustomize build . | kubectl apply -f -

.PHONY: delete-policies
delete-policies: validate
	cd $(ENVIRONMENT) && kustomize build . | kubectl delete -f -

.PHONY: validate
validate:
ifeq (${ENVIRONMENT},)
	$(error ENVIRONMENT is undefined. Should be sandbox, staging or production)
endif