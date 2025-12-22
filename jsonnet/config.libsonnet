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

    kubernetesMixinConfig: {
      cadvisorSelector: 'job="cadvisor"',
      kubeletSelector: 'job="kubelet"',
      kubeStateMetricsSelector: 'job="kube-state-metrics"',
      kubeApiserverSelector: 'job="kube-apiserver"',
      kubeSchedulerSelector: 'job="kube-scheduler"',
      kubeControllerManagerSelector: 'job="kube-controller-manager"',
      kubeProxySelector: 'job="kube-proxy"',
    },

    nodeExporterMixinConfig: {
      nodeExporterSelector: 'job="node-exporter"',
      diskDeviceSelector: 'device=~"(/dev/)?(mmcblk.p.+|nvme.+|sd.+|vd.+|xvd.+|dm-.+|dasd.+)"',
    },

    argoCdMixinConfig: {},
    lokiMixinConfig: {},
    alloyMixinConfig: {},
    mimirMixinConfig: {},
    tempoMixinConfig: {},
  },
}
