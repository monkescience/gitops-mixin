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
local resourceOptimizationMixin = import 'alerts/resource-optimization/alerts.libsonnet';

config {
  // Combined alerts output for multi-file generation.
  alerts:: {
    'kubernetes.json': kubernetesMixin.prometheusAlerts,
    'node-exporter.json': nodeExporterMixin.prometheusAlerts,
    'argocd.json': argoCdMixin.prometheusAlerts,
    'loki.json': lokiMixin.prometheusAlerts,
    'alloy.json': alloyMixin.prometheusAlerts,
    'mimir.json': mimirMixin.prometheusAlerts,
    'tempo.json': tempoMixin.prometheusAlerts,
    'resource-optimization.json': resourceOptimizationMixin.prometheusAlerts,
  },

  // Combined rules output for multi-file generation.
  rules:: {
    'kubernetes.json': kubernetesMixin.prometheusRules,
    'node-exporter.json': nodeExporterMixin.prometheusRules,
    'argocd.json': argoCdMixin.prometheusRules,
    'loki.json': lokiMixin.prometheusRules,
    'mimir.json': mimirMixin.prometheusRules,
    'tempo.json': tempoMixin.prometheusRules,
  },

  grafanaDashboards+::
    kubernetesMixin.grafanaDashboards +
    nodeExporterMixin.grafanaDashboards +
    resourceOptimizationDashboards +
    argoCdMixin.grafanaDashboards +
    lokiMixin.grafanaDashboards +
    extractDashboards(alloyMixin) +
    extractDashboards(mimirMixin) +
    extractDashboards(tempoMixin),
}
