output "grafana_datasource_loki_uid" {
  value = grafana_data_source.loki_datasource.uid
}

output "grafana_datasource_loki_name" {
  value = grafana_data_source.loki_datasource.name
}

output "grafana_datasource_prometheus_uid" {
  value = grafana_data_source.prometheus_datasource.uid
}

output "grafana_datasource_prometheus_name" {
  value = grafana_data_source.prometheus_datasource.name
}

output "grafana_datasource_tempo_uid" {
  value = grafana_data_source.tempo_datasource.uid
}

output "grafana_datasource_tempo_name" {
  value = grafana_data_source.tempo_datasource.name
}

output "grafana_datasource_gcp_uid" {
  value = module.gcp_metrics_grafana_datasource.datasource_uid
}

output "grafana_datasource_gcp_name" {
  value = module.gcp_metrics_grafana_datasource.datasource_name
}
