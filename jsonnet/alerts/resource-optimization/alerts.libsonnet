// Custom alerts for gitops-mixin
{
  alerts: {
    groups: [
      {
        name: 'custom.rules',
        rules: [
          {
            alert: 'PodCPUUnderutilized',
            annotations: {
              description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }} CPU utilization is below 30% for 12h.',
              summary: 'Pod CPU is underutilized.',
            },
            expr: |||
              avg_over_time((
                100 * sum(rate(container_cpu_usage_seconds_total{container!="POD"}[5m])) by (namespace,pod)
                / sum(kube_pod_container_resource_requests{resource="cpu",container!="POD"}) by (namespace,pod)
              )[12h:]) < 30
            |||,
            'for': '1h',
            labels: {
              severity: 'info',
            },
          },
          {
            alert: 'PodMemoryUnderutilized',
            annotations: {
              description: 'Pod {{ $labels.namespace }}/{{ $labels.pod }} memory utilization is below 30% for 12h.',
              summary: 'Pod memory is underutilized.',
            },
            expr: |||
              avg_over_time((
                100 * sum(container_memory_usage_bytes{container!="POD"}) by (namespace,pod)
                / sum(kube_pod_container_resource_requests{resource="memory",container!="POD"}) by (namespace,pod)
              )[12h:]) < 30
            |||,
            'for': '1h',
            labels: {
              severity: 'info',
            },
          },
        ],
      },
    ],
  },
}
