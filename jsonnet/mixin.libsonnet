local config = import 'config.libsonnet';

// Import upstream mixins
local kubernetesMixin = (import 'kubernetes-mixin/mixin.libsonnet') + config;
local nodeExporterMixin = (import 'node-mixin/mixin.libsonnet') + config;
local argoCdMixin = (import 'argo-cd-mixin/mixin.libsonnet') + config;
local lokiMixin = (import 'loki-mixin/mixin.libsonnet') + config;

// Import resource-optimization mixin
local resourceOptimizationDashboards = import 'dashboards/resource-optimization/dashboards.libsonnet';
local resourceOptimizationAlerts = import 'alerts/resource-optimization/alerts.libsonnet';

config {
  // Per-mixin exports for separate file generation (used by Makefile)
  kubernetesAlerts:: kubernetesMixin.prometheusAlerts,
  kubernetesRules:: kubernetesMixin.prometheusRules,

  nodeExporterAlerts:: nodeExporterMixin.prometheusAlerts,
  nodeExporterRules:: nodeExporterMixin.prometheusRules,

  argoCdAlerts:: argoCdMixin.prometheusAlerts,
  argoCdRules:: argoCdMixin.prometheusRules,

  lokiAlerts:: lokiMixin.prometheusAlerts,
  lokiRules:: lokiMixin.prometheusRules,

  resourceOptimizationAlerts:: resourceOptimizationAlerts.alerts,

  // Merged dashboards (used by Makefile with -m flag for individual files)
  grafanaDashboards+::
    (if $._config.enableKubernetesMixin then kubernetesMixin.grafanaDashboards else {}) +
    (if $._config.enableNodeExporterMixin then nodeExporterMixin.grafanaDashboards else {}) +
    (if $._config.enableResourceOptimizationMixin then resourceOptimizationDashboards else {}) +
    (if $._config.enableArgoCdMixin then argoCdMixin.grafanaDashboards else {}) +
    (if $._config.enableLokiMixin then lokiMixin.grafanaDashboards else {}),
}
