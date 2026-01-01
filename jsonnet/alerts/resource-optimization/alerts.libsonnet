// Custom alerts for gitops-mixin
local config = import '../../config.libsonnet';
local cfg = config._config.resourceOptimizationConfig;

// Build selector components.
local selectorParts = std.filter(function(s) s != '', [
  'container!="POD"',
  'container!=""',
  if cfg.labelSelector != '' then cfg.labelSelector else '',
  if cfg.namespaceSelector != '' then 'namespace=~"%s"' % cfg.namespaceSelector else '',
]);
local selector = std.join(',', selectorParts);

// Cluster label for by() clauses.
local clusterBy = if cfg.showMultiCluster then ',' + cfg.clusterLabel else '';

// Cluster info for alert descriptions.
local clusterDescription = if cfg.showMultiCluster
then ' on cluster {{ $labels.%s }}' % cfg.clusterLabel
else '';

{
  prometheusAlerts: {
    groups: [
      {
        name: 'resource-optimization.rules',
        rules: [
          {
            alert: 'PodCPUUnderutilized',
            annotations: {
              description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }}%s CPU utilization is below 30%% for 24h.' % clusterDescription,
              summary: 'Pod CPU is underutilized.',
            },
            expr: |||
              avg_over_time((
                100 * sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace,pod%s)
                / sum(kube_pod_container_resource_requests{resource="cpu",%s}) by (namespace,pod%s)
              )[24h:]) < 30
            ||| % [selector, clusterBy, selector, clusterBy],
            'for': '1h',
            labels: {
              severity: 'info',
            },
          },
          {
            alert: 'PodMemoryUnderutilized',
            annotations: {
              description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }}%s memory utilization is below 30%% for 24h.' % clusterDescription,
              summary: 'Pod memory is underutilized.',
            },
            expr: |||
              avg_over_time((
                100 * sum(container_memory_working_set_bytes{%s}) by (namespace,pod%s)
                / sum(kube_pod_container_resource_requests{resource="memory",%s}) by (namespace,pod%s)
              )[24h:]) < 30
            ||| % [selector, clusterBy, selector, clusterBy],
            'for': '1h',
            labels: {
              severity: 'info',
            },
          },
          {
            alert: 'PodCPUOverutilized',
            annotations: {
              description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }}%s CPU utilization is above 80%% for 24h.' % clusterDescription,
              summary: 'Pod CPU is overutilized.',
            },
            expr: |||
              avg_over_time((
                100 * sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace,pod%s)
                / sum(kube_pod_container_resource_requests{resource="cpu",%s}) by (namespace,pod%s)
              )[24h:]) > 80
            ||| % [selector, clusterBy, selector, clusterBy],
            'for': '1h',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'PodMemoryOverutilized',
            annotations: {
              description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }}%s memory utilization is above 80%% for 24h.' % clusterDescription,
              summary: 'Pod memory is overutilized.',
            },
            expr: |||
              avg_over_time((
                100 * sum(container_memory_working_set_bytes{%s}) by (namespace,pod%s)
                / sum(kube_pod_container_resource_requests{resource="memory",%s}) by (namespace,pod%s)
              )[24h:]) > 80
            ||| % [selector, clusterBy, selector, clusterBy],
            'for': '1h',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'PodCPUNearLimit',
            annotations: {
              description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }}%s CPU usage is above 80%% of its limit for 1h.' % clusterDescription,
              summary: 'Pod CPU approaching limit.',
            },
            expr: |||
              avg_over_time((
                100 * sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace,pod%s)
                / sum(kube_pod_container_resource_limits{resource="cpu",%s}) by (namespace,pod%s)
              )[1h:]) > 80
            ||| % [selector, clusterBy, selector, clusterBy],
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
          {
            alert: 'PodMemoryNearLimit',
            annotations: {
              description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }}%s memory usage is above 80%% of its limit for 1h.' % clusterDescription,
              summary: 'Pod memory approaching limit.',
            },
            expr: |||
              avg_over_time((
                100 * sum(container_memory_working_set_bytes{%s}) by (namespace,pod%s)
                / sum(kube_pod_container_resource_limits{resource="memory",%s}) by (namespace,pod%s)
              )[1h:]) > 80
            ||| % [selector, clusterBy, selector, clusterBy],
            'for': '15m',
            labels: {
              severity: 'warning',
            },
          },
        ],
      },
    ],
  },
}
