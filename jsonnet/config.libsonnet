{
  _config+:: {
    enableKubernetesMixin: true,
    enableNodeExporterMixin: true,
    enableResourceOptimizationMixin: true,
    enableArgoCdMixin: true,
    enableLokiMixin: true,
    enableAlloyMixin: true,
    enableMimirMixin: true,
    enableTempoMixin: true,

    grafanaFolders: {
      kubernetes: 'Kubernetes',
      nodeExporter: 'Node Exporter',
      resourceOptimization: 'Resource Optimization',
      argocd: 'Argo CD',
      loki: 'Loki',
      alloy: 'Alloy',
      mimir: 'Mimir',
      tempo: 'Tempo',
    },

    datasourceName: 'prometheus',
    datasourceRegex: '',
    namespace: 'monitoring',

    // Job selectors for k8s-monitoring 3.6.1.
    kubernetesMixinConfig: {
      cadvisorSelector: 'job="integrations/kubernetes/cadvisor"',
      kubeletSelector: 'job="integrations/kubernetes/kubelet"',
      kubeStateMetricsSelector: 'job="integrations/kubernetes/kube-state-metrics"',
      kubeApiserverSelector: 'job="integrations/kubernetes/kube-apiserver"',
      kubeSchedulerSelector: 'job="kube-scheduler"',
      kubeControllerManagerSelector: 'job="kube-controller-manager"',
      kubeProxySelector: 'job="kube-proxy"',
      cpuThrottlingPercent: 25,
    },

    nodeExporterMixinConfig: {
      nodeExporterSelector: 'job="integrations/node_exporter"',
      diskDeviceSelector: 'device=~"(/dev/)?(mmcblk.p.+|nvme.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+)"',
    },

    argoCdMixinConfig: {},
    lokiMixinConfig: {},
    alloyMixinConfig: {},
    mimirMixinConfig: {},
    tempoMixinConfig: {},
  },
}
