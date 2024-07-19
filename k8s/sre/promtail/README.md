# Promtail

https://github.com/grafana/helm-charts/tree/main/charts/promtail

Deploys a Promtail daemonset that scrapes targets for logs and pushes them to Grafana Loki.

The deployment depends on a kubernetes basic auth secret named `grafana-metrics-publisher` created in [secrets.tf](../../../terraform/secrets.tf).

## Configuration

Some configuration values must be hardcoded to `values.yaml` before the initial deployment.

Update `values.yaml` setting the `config` `lokiAddress` and `extraClientConfigs.basic_auth.username` properties to match the ones obtained from Grafana Cloud:

```yaml
config:
  lokiAddress: https://<your-loki-url>/api/prom/push
  snippets:
    extraClientConfigs: |
      basic_auth:
        username: <your-numeric-grafana-username>
```

For environment-specific changes update `./[development|staging|production]/values.yaml`.

## How to apply changes

Export an `ENVIRONMENT` environment variable and call one of the make targets:

```sh
$ make deploy ENVIRONMENT=development
$ make delete ENVIRONMENT=development
```
