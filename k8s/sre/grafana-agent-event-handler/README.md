# Grafana Agent Event Handler

The Grafana Agent binary provides integrations that go beyond the logs/metrics/tracing standards.

One of which is [eventhandler](eventhandler), which listens to ephemeral Kubernetes Events and ships them as structured log lines to a configured Loki instance.

[eventhandler]: https://grafana.com/docs/agent/latest/configuration/integrations/integrations-next/eventhandler-config/
