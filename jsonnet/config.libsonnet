{
  _config+:: {
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
