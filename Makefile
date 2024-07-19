CHARTS=sre-operator sre-resources ace promtail prometheus tempo cert-manager google-cas-issuer github-actions-runner

.PHONY: deploy-charts
deploy-charts:
	@for v in $(CHARTS); do \
		cd ./k8s/sre/$$v && $(MAKE) deploy ENVIRONMENT=${ENVIRONMENT} ; cd ../../.. ; \
	done

.PHONY: deploy-chart
deploy-chart:
		cd ./k8s/sre/$(CHART) && $(MAKE) deploy ENVIRONMENT=$(ENVIRONMENT);
