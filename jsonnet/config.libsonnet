{
  _config+:: {
    // Mixin selection
    enableKubernetesMixin: true,
    enableNodeExporterMixin: true,
    enableResourceOptimizationMixin: true,
    enableArgoCdMixin: true,
    enableLokiMixin: true,

    // Grafana settings
    grafanaFolders: {
      kubernetes: 'Kubernetes',
      nodeExporter: 'Node Exporter',
      resourceOptimization: 'Resource Optimization',
      argocd: 'Argo CD',
      loki: 'Loki',
    },

    // Dashboard datasource
    datasourceName: 'prometheus',
    datasourceRegex: '',

    // Kubernetes mixin config overrides for k8s-monitoring 3.6.1
    cadvisorSelector: 'job="integrations/kubernetes/cadvisor"',
    kubeletSelector: 'job="integrations/kubernetes/kubelet"',
    kubeStateMetricsSelector: 'job="integrations/kubernetes/kube-state-metrics"',
    nodeExporterSelector: 'job="integrations/node_exporter"',
    // These may not be scraped by k8s-monitoring by default
    kubeApiserverSelector: 'job="integrations/kubernetes/kube-apiserver"',
    kubeSchedulerSelector: 'job="kube-scheduler"',
    kubeControllerManagerSelector: 'job="kube-controller-manager"',
    kubeProxySelector: 'job="kube-proxy"',

    // Alert thresholds
    cpuThrottlingPercent: 25,
    diskDeviceSelector: 'device=~"(/dev/)?(mmcblk.p.+|nvme.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+)"',

    // Namespace for resources
    namespace: 'monitoring',
  },
}
