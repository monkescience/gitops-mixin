{
  _config+:: {
    kubernetesMixinConfig: {
      showMultiCluster: true,
      cadvisorSelector: 'job="cadvisor"',
      kubeletSelector: 'job="kubelet"',
      kubeStateMetricsSelector: 'job="kube-state-metrics"',
      kubeApiserverSelector: 'job="kube-apiserver"',
      kubeSchedulerSelector: 'job="kube-scheduler"',
      kubeControllerManagerSelector: 'job="kube-controller-manager"',
      kubeProxySelector: 'job="kube-proxy"',
    },

    nodeExporterMixinConfig: {
      showMultiCluster: true,
      nodeExporterSelector: 'job="node-exporter"',
      diskDeviceSelector: 'device=~"(/dev/)?(mmcblk.p.+|nvme.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+)"',
    },

    argoCdMixinConfig: {
      showMultiCluster: true,
    },
    lokiMixinConfig: {},
    alloyMixinConfig: {
      logsFilterSelector: 'job=~".+"',
    },
    mimirMixinConfig: {},
    tempoMixinConfig: {},

    resourceOptimizationConfig: {
      // Enable multi-cluster support (adds cluster label to aggregations).
      showMultiCluster: true,
      // Label name used for cluster identification.
      clusterLabel: 'cluster',
      // Additional label selector for filtering (empty = all pods).
      // Example: 'app=~"myapp.*"' or 'team="platform"'
      labelSelector: '',
      // Namespace filter regex (empty = all namespaces).
      // Example: 'kube-.*|default' to exclude system namespaces
      namespaceSelector: '',
    },
  },
}
