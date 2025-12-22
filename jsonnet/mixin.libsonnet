local config = import 'config.libsonnet';

local kubernetesMixin = (import 'kubernetes-mixin/mixin.libsonnet') + { _config+:: config._config.kubernetesMixinConfig };
local nodeExporterMixin = (import 'node-mixin/mixin.libsonnet') + { _config+:: config._config.nodeExporterMixinConfig };
local argoCdMixin = (import 'argo-cd-mixin/mixin.libsonnet') + { _config+:: config._config.argoCdMixinConfig };
local lokiMixin = (import 'loki-mixin/mixin.libsonnet') + { _config+:: config._config.lokiMixinConfig };

// These mixins have self-referencing configs that require extractDashboards() to preserve $ context.
local alloyMixin = (import 'alloy-mixin/mixin.libsonnet') + { _config+:: config._config.alloyMixinConfig };
local mimirMixin = (import 'mimir-mixin/mixin.libsonnet') + { _config+:: config._config.mimirMixinConfig };
local tempoMixin = (import 'tempo-mixin/mixin.libsonnet') + { _config+:: config._config.tempoMixinConfig };

local extractDashboards(mixin) = {
  [k]: mixin.grafanaDashboards[k]
  for k in std.objectFields(mixin.grafanaDashboards)
  if !std.startsWith(k, '_')
};

local resourceOptimizationDashboards = import 'dashboards/resource-optimization/dashboards.libsonnet';
local resourceOptimizationAlerts = import 'alerts/resource-optimization/alerts.libsonnet';

config {
  kubernetesAlerts:: kubernetesMixin.prometheusAlerts,
  kubernetesRules:: kubernetesMixin.prometheusRules,
  nodeExporterAlerts:: nodeExporterMixin.prometheusAlerts,
  nodeExporterRules:: nodeExporterMixin.prometheusRules,
  argoCdAlerts:: argoCdMixin.prometheusAlerts,
  argoCdRules:: argoCdMixin.prometheusRules,
  lokiAlerts:: lokiMixin.prometheusAlerts,
  lokiRules:: lokiMixin.prometheusRules,
  alloyAlerts:: alloyMixin.prometheusAlerts,
  mimirAlerts:: mimirMixin.prometheusAlerts,
  mimirRules:: mimirMixin.prometheusRules,
  tempoAlerts:: tempoMixin.prometheusAlerts,
  tempoRules:: tempoMixin.prometheusRules,
  resourceOptimizationAlerts:: resourceOptimizationAlerts.alerts,

  grafanaDashboards+::
    (if $._config.enableKubernetesMixin then kubernetesMixin.grafanaDashboards else {}) +
    (if $._config.enableNodeExporterMixin then nodeExporterMixin.grafanaDashboards else {}) +
    (if $._config.enableResourceOptimizationMixin then resourceOptimizationDashboards else {}) +
    (if $._config.enableArgoCdMixin then argoCdMixin.grafanaDashboards else {}) +
    (if $._config.enableLokiMixin then lokiMixin.grafanaDashboards else {}) +
    (if $._config.enableAlloyMixin then extractDashboards(alloyMixin) else {}) +
    (if $._config.enableMimirMixin then extractDashboards(mimirMixin) else {}) +
    (if $._config.enableTempoMixin then extractDashboards(tempoMixin) else {}),
}
