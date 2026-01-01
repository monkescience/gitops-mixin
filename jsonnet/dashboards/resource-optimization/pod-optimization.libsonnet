// Pod Resource Optimization Dashboard
local config = import '../../config.libsonnet';
local cfg = config._config.resourceOptimizationConfig;

// Build selector for metric queries.
local selectorParts = std.filter(function(s) s != '', [
  '%s="$%s"' % [cfg.clusterLabel, cfg.clusterLabel],
  'container!="POD"',
  'container!=""',
  'namespace=~"$namespace"',
  if cfg.labelSelector != '' then cfg.labelSelector else '',
]);
local selector = std.join(',', selectorParts);

// Selector for kube_pod_* metrics (no container filter).
local podSelectorParts = std.filter(function(s) s != '', [
  '%s="$%s"' % [cfg.clusterLabel, cfg.clusterLabel],
  'namespace=~"$namespace"',
  if cfg.labelSelector != '' then cfg.labelSelector else '',
]);
local podSelector = std.join(',', podSelectorParts);

// Request selector (includes resource type).
local requestSelector(resource) = std.join(',', std.filter(function(s) s != '', [
  '%s="$%s"' % [cfg.clusterLabel, cfg.clusterLabel],
  'resource="%s"' % resource,
  'container!="POD"',
  'namespace=~"$namespace"',
  if cfg.labelSelector != '' then cfg.labelSelector else '',
]));

// Limit selector (includes resource type).
local limitSelector(resource) = std.join(',', std.filter(function(s) s != '', [
  '%s="$%s"' % [cfg.clusterLabel, cfg.clusterLabel],
  'resource="%s"' % resource,
  'container!="POD"',
  'namespace=~"$namespace"',
  if cfg.labelSelector != '' then cfg.labelSelector else '',
]));

// Stat panel for summary.
local statPanel(id, title, expr, thresholds) = {
  datasource: { type: 'prometheus', uid: '${datasource}' },
  fieldConfig: {
    defaults: {
      color: { mode: 'thresholds' },
      mappings: [],
      thresholds: { mode: 'absolute', steps: thresholds },
      unit: 'none',
    },
  },
  gridPos: { h: 4, w: 4, x: (id - 101) * 4, y: 1 },
  id: id,
  options: {
    colorMode: 'value',
    graphMode: 'none',
    justifyMode: 'auto',
    orientation: 'auto',
    reduceOptions: { calcs: ['lastNotNull'], fields: '', values: false },
    textMode: 'auto',
  },
  targets: [{
    datasource: { type: 'prometheus', uid: '${datasource}' },
    expr: expr,
    refId: 'A',
  }],
  title: title,
  type: 'stat',
};

// Table panel field overrides for CPU.
local cpuTableOverrides = [
  { matcher: { id: 'byName', options: 'Namespace' }, properties: [{ id: 'custom.width', value: 150 }] },
  { matcher: { id: 'byName', options: 'Pod' }, properties: [{ id: 'custom.width', value: 250 }] },
  { matcher: { id: 'byName', options: 'Request' }, properties: [
    { id: 'unit', value: 'suffix:m' },
    { id: 'custom.width', value: 90 },
    { id: 'decimals', value: 0 },
    { id: 'custom.cellOptions', value: { type: 'color-text' } },
    { id: 'color', value: { mode: 'fixed', fixedColor: 'text' } },
  ] },
  { matcher: { id: 'byName', options: 'Limit' }, properties: [
    { id: 'unit', value: 'suffix:m' },
    { id: 'custom.width', value: 90 },
    { id: 'decimals', value: 0 },
    { id: 'custom.cellOptions', value: { type: 'color-text' } },
    { id: 'color', value: { mode: 'fixed', fixedColor: 'text' } },
  ] },
  { matcher: { id: 'byName', options: 'Avg Usage' }, properties: [{ id: 'unit', value: 'suffix:m' }, { id: 'custom.width', value: 100 }, { id: 'decimals', value: 1 }] },
  { matcher: { id: 'byName', options: 'P95 Usage' }, properties: [{ id: 'unit', value: 'suffix:m' }, { id: 'custom.width', value: 100 }, { id: 'decimals', value: 1 }] },
  { matcher: { id: 'byName', options: 'Recommended' }, properties: [
    { id: 'unit', value: 'suffix:m' },
    { id: 'custom.width', value: 110 },
    { id: 'decimals', value: 0 },
    { id: 'custom.cellOptions', value: { type: 'color-text' } },
    { id: 'color', value: { mode: 'fixed', fixedColor: 'super-light-blue' } },
  ] },
  { matcher: { id: 'byName', options: 'Utilization' }, properties: [
    { id: 'unit', value: 'percentunit' },
    { id: 'custom.width', value: 120 },
    { id: 'decimals', value: 1 },
    { id: 'custom.cellOptions', value: { mode: 'gradient', type: 'gauge', valueDisplayMode: 'text' } },
    { id: 'min', value: 0 },
    { id: 'max', value: 1 },
    { id: 'thresholds', value: { mode: 'absolute', steps: [
      { color: 'red', value: null },
      { color: 'orange', value: 0.2 },
      { color: 'yellow', value: 0.3 },
      { color: 'green', value: 0.5 },
      { color: 'yellow', value: 0.8 },
      { color: 'red', value: 0.95 },
    ] } },
  ] },
  { matcher: { id: 'byName', options: 'Limit %' }, properties: [
    { id: 'unit', value: 'percentunit' },
    { id: 'custom.width', value: 120 },
    { id: 'decimals', value: 1 },
    { id: 'custom.cellOptions', value: { mode: 'gradient', type: 'gauge', valueDisplayMode: 'text' } },
    { id: 'min', value: 0 },
    { id: 'max', value: 1 },
    { id: 'thresholds', value: { mode: 'absolute', steps: [
      { color: 'green', value: null },
      { color: 'yellow', value: 0.7 },
      { color: 'orange', value: 0.85 },
      { color: 'red', value: 0.95 },
    ] } },
  ] },
  { matcher: { id: 'byName', options: 'Potential Savings' }, properties: [
    { id: 'unit', value: 'suffix:m' },
    { id: 'custom.width', value: 130 },
    { id: 'decimals', value: 0 },
    { id: 'custom.cellOptions', value: { type: 'color-text' } },
    { id: 'thresholds', value: { mode: 'absolute', steps: [
      { color: 'text', value: null },
      { color: 'yellow', value: 100 },
      { color: 'orange', value: 500 },
      { color: 'red', value: 1000 },
    ] } },
  ] },
];

// Table panel field overrides for Memory.
local memoryTableOverrides = [
  { matcher: { id: 'byName', options: 'Namespace' }, properties: [{ id: 'custom.width', value: 150 }] },
  { matcher: { id: 'byName', options: 'Pod' }, properties: [{ id: 'custom.width', value: 250 }] },
  { matcher: { id: 'byName', options: 'Request' }, properties: [
    { id: 'unit', value: 'suffix:Mi' },
    { id: 'custom.width', value: 100 },
    { id: 'decimals', value: 0 },
    { id: 'custom.cellOptions', value: { type: 'color-text' } },
    { id: 'color', value: { mode: 'fixed', fixedColor: 'text' } },
  ] },
  { matcher: { id: 'byName', options: 'Limit' }, properties: [
    { id: 'unit', value: 'suffix:Mi' },
    { id: 'custom.width', value: 100 },
    { id: 'decimals', value: 0 },
    { id: 'custom.cellOptions', value: { type: 'color-text' } },
    { id: 'color', value: { mode: 'fixed', fixedColor: 'text' } },
  ] },
  { matcher: { id: 'byName', options: 'Avg Usage' }, properties: [{ id: 'unit', value: 'suffix:Mi' }, { id: 'custom.width', value: 100 }, { id: 'decimals', value: 1 }] },
  { matcher: { id: 'byName', options: 'P95 Usage' }, properties: [{ id: 'unit', value: 'suffix:Mi' }, { id: 'custom.width', value: 100 }, { id: 'decimals', value: 1 }] },
  { matcher: { id: 'byName', options: 'Recommended' }, properties: [
    { id: 'unit', value: 'suffix:Mi' },
    { id: 'custom.width', value: 110 },
    { id: 'decimals', value: 0 },
    { id: 'custom.cellOptions', value: { type: 'color-text' } },
    { id: 'color', value: { mode: 'fixed', fixedColor: 'super-light-blue' } },
  ] },
  { matcher: { id: 'byName', options: 'Utilization' }, properties: [
    { id: 'unit', value: 'percentunit' },
    { id: 'custom.width', value: 120 },
    { id: 'decimals', value: 1 },
    { id: 'custom.cellOptions', value: { mode: 'gradient', type: 'gauge', valueDisplayMode: 'text' } },
    { id: 'min', value: 0 },
    { id: 'max', value: 1 },
    { id: 'thresholds', value: { mode: 'absolute', steps: [
      { color: 'red', value: null },
      { color: 'orange', value: 0.2 },
      { color: 'yellow', value: 0.3 },
      { color: 'green', value: 0.5 },
      { color: 'yellow', value: 0.8 },
      { color: 'red', value: 0.95 },
    ] } },
  ] },
  { matcher: { id: 'byName', options: 'Limit %' }, properties: [
    { id: 'unit', value: 'percentunit' },
    { id: 'custom.width', value: 120 },
    { id: 'decimals', value: 1 },
    { id: 'custom.cellOptions', value: { mode: 'gradient', type: 'gauge', valueDisplayMode: 'text' } },
    { id: 'min', value: 0 },
    { id: 'max', value: 1 },
    { id: 'thresholds', value: { mode: 'absolute', steps: [
      { color: 'green', value: null },
      { color: 'yellow', value: 0.7 },
      { color: 'orange', value: 0.85 },
      { color: 'red', value: 0.95 },
    ] } },
  ] },
  { matcher: { id: 'byName', options: 'Potential Savings' }, properties: [
    { id: 'unit', value: 'suffix:Mi' },
    { id: 'custom.width', value: 130 },
    { id: 'decimals', value: 0 },
    { id: 'custom.cellOptions', value: { type: 'color-text' } },
    { id: 'thresholds', value: { mode: 'absolute', steps: [
      { color: 'text', value: null },
      { color: 'yellow', value: 100 },
      { color: 'orange', value: 512 },
      { color: 'red', value: 1024 },
    ] } },
  ] },
];

// Table transformations.
local tableTransformations = [
  { id: 'merge', options: {} },
  { id: 'organize', options: {
    excludeByName: { Time: true },
    indexByName: { namespace: 0, pod: 1, 'Value #request': 2, 'Value #limit': 3, 'Value #avg': 4, 'Value #p95': 5, 'Value #recommended': 6 },
    renameByName: { namespace: 'Namespace', pod: 'Pod', 'Value #request': 'Request', 'Value #limit': 'Limit', 'Value #avg': 'Avg Usage', 'Value #p95': 'P95 Usage', 'Value #recommended': 'Recommended' },
  } },
  { id: 'calculateField', options: { alias: 'Utilization', binary: { left: 'Avg Usage', operator: '/', right: 'Request' }, mode: 'binary', reduce: { reducer: 'sum' } } },
  { id: 'calculateField', options: { alias: 'Limit %', binary: { left: 'Avg Usage', operator: '/', right: 'Limit' }, mode: 'binary', reduce: { reducer: 'sum' } } },
  { id: 'calculateField', options: { alias: 'Potential Savings', binary: { left: 'Request', operator: '-', right: 'Recommended' }, mode: 'binary', reduce: { reducer: 'sum' } } },
  { id: 'filterByValue', options: { filters: [{ config: { id: 'greaterOrEqual', options: { value: 0 } }, fieldName: 'Utilization' }], match: 'all', type: 'include' } },
];

{
  editable: false,
  links: [],
  panels: [
    // Summary Row
    { collapsed: false, gridPos: { h: 1, w: 24, x: 0, y: 0 }, id: 100, title: 'Summary', type: 'row' },

    // Summary Stats
    statPanel(101,
              'CPU Under-utilized',
              'count(avg_over_time((100 * sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace,pod) / sum(kube_pod_container_resource_requests{%s}) by (namespace,pod))[$timeWindow:]) < 30)' % [selector, requestSelector('cpu')],
              [{ color: 'green', value: null }, { color: 'yellow', value: 1 }, { color: 'orange', value: 5 }]),
    statPanel(102,
              'CPU Over-utilized',
              'count(avg_over_time((100 * sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace,pod) / sum(kube_pod_container_resource_requests{%s}) by (namespace,pod))[$timeWindow:]) > 80)' % [selector, requestSelector('cpu')],
              [{ color: 'green', value: null }, { color: 'orange', value: 1 }, { color: 'red', value: 3 }]),
    statPanel(103,
              'Memory Under-utilized',
              'count(avg_over_time((100 * sum(container_memory_working_set_bytes{%s}) by (namespace,pod) / sum(kube_pod_container_resource_requests{%s}) by (namespace,pod))[$timeWindow:]) < 30)' % [selector, requestSelector('memory')],
              [{ color: 'green', value: null }, { color: 'yellow', value: 1 }, { color: 'orange', value: 5 }]),
    statPanel(104,
              'Memory Over-utilized',
              'count(avg_over_time((100 * sum(container_memory_working_set_bytes{%s}) by (namespace,pod) / sum(kube_pod_container_resource_requests{%s}) by (namespace,pod))[$timeWindow:]) > 80)' % [selector, requestSelector('memory')],
              [{ color: 'green', value: null }, { color: 'orange', value: 1 }, { color: 'red', value: 3 }]),
    statPanel(105,
              'CPU Near Limit',
              'count(avg_over_time((100 * sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace,pod) / sum(kube_pod_container_resource_limits{%s}) by (namespace,pod))[$timeWindow:]) > 70)' % [selector, limitSelector('cpu')],
              [{ color: 'green', value: null }, { color: 'orange', value: 1 }, { color: 'red', value: 3 }]),
    statPanel(106,
              'Mem Near Limit',
              'count(avg_over_time((100 * sum(container_memory_working_set_bytes{%s}) by (namespace,pod) / sum(kube_pod_container_resource_limits{%s}) by (namespace,pod))[$timeWindow:]) > 70)' % [selector, limitSelector('memory')],
              [{ color: 'green', value: null }, { color: 'orange', value: 1 }, { color: 'red', value: 3 }]),

    // CPU Optimization Row
    { collapsed: false, gridPos: { h: 1, w: 24, x: 0, y: 5 }, id: 200, title: 'CPU Optimization', type: 'row' },

    // CPU Table
    {
      datasource: { type: 'prometheus', uid: '${datasource}' },
      description: 'Shows CPU resource optimization opportunities. Pods are sorted by utilization to help identify over-provisioned resources.',
      fieldConfig: { defaults: { custom: { align: 'auto', cellOptions: { type: 'auto' }, inspect: false, filterable: true }, mappings: [], thresholds: { mode: 'absolute', steps: [{ color: 'green', value: null }] } }, overrides: cpuTableOverrides },
      gridPos: { h: 12, w: 24, x: 0, y: 6 },
      id: 201,
      options: { cellHeight: 'sm', footer: { countRows: false, fields: ['Request', 'Recommended', 'Potential Savings'], reducer: ['sum'], show: true }, showHeader: true, sortBy: [{ desc: false, displayName: 'Utilization' }] },
      targets: [
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'sum(kube_pod_container_resource_requests{%s}) by (namespace, pod) * 1000 > 0' % requestSelector('cpu'), format: 'table', instant: true, refId: 'request' },
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'sum(kube_pod_container_resource_limits{%s}) by (namespace, pod) * 1000' % limitSelector('cpu'), format: 'table', instant: true, refId: 'limit' },
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'avg_over_time((sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace, pod))[$timeWindow:5m]) * 1000' % selector, format: 'table', instant: true, refId: 'avg' },
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'quantile_over_time(0.95, (sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace, pod))[$timeWindow:5m]) * 1000' % selector, format: 'table', instant: true, refId: 'p95' },
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'clamp_min(ceil(quantile_over_time(0.95, (sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace, pod))[$timeWindow:5m]) * 1.2 * 100) * 10, 10)' % selector, format: 'table', instant: true, refId: 'recommended' },
      ],
      title: 'CPU Optimization Recommendations',
      transformations: tableTransformations,
      type: 'table',
    },

    // Memory Optimization Row
    { collapsed: false, gridPos: { h: 1, w: 24, x: 0, y: 18 }, id: 300, title: 'Memory Optimization', type: 'row' },

    // Memory Table
    {
      datasource: { type: 'prometheus', uid: '${datasource}' },
      description: 'Shows Memory resource optimization opportunities. Pods are sorted by utilization to help identify over-provisioned resources.',
      fieldConfig: { defaults: { custom: { align: 'auto', cellOptions: { type: 'auto' }, inspect: false, filterable: true }, mappings: [], thresholds: { mode: 'absolute', steps: [{ color: 'green', value: null }] } }, overrides: memoryTableOverrides },
      gridPos: { h: 12, w: 24, x: 0, y: 19 },
      id: 301,
      options: { cellHeight: 'sm', footer: { countRows: false, fields: ['Request', 'Recommended', 'Potential Savings'], reducer: ['sum'], show: true }, showHeader: true, sortBy: [{ desc: false, displayName: 'Utilization' }] },
      targets: [
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'sum(kube_pod_container_resource_requests{%s}) by (namespace, pod) / 1048576 > 0' % requestSelector('memory'), format: 'table', instant: true, refId: 'request' },
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'sum(kube_pod_container_resource_limits{%s}) by (namespace, pod) / 1048576' % limitSelector('memory'), format: 'table', instant: true, refId: 'limit' },
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'avg_over_time((sum(container_memory_working_set_bytes{%s}) by (namespace, pod))[$timeWindow:5m]) / 1048576' % selector, format: 'table', instant: true, refId: 'avg' },
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'quantile_over_time(0.95, (sum(container_memory_working_set_bytes{%s}) by (namespace, pod))[$timeWindow:5m]) / 1048576' % selector, format: 'table', instant: true, refId: 'p95' },
        { datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'clamp_min(ceil(quantile_over_time(0.95, (sum(container_memory_working_set_bytes{%s}) by (namespace, pod))[$timeWindow:5m]) * 1.2 / 67108864) * 64, 64)' % selector, format: 'table', instant: true, refId: 'recommended' },
      ],
      title: 'Memory Optimization Recommendations',
      transformations: tableTransformations,
      type: 'table',
    },

    // Historical Trends Row (collapsed)
    {
      collapsed: true,
      gridPos: { h: 1, w: 24, x: 0, y: 31 },
      id: 400,
      panels: [
        // CPU Utilization Over Time
        {
          datasource: { type: 'prometheus', uid: '${datasource}' },
          description: 'CPU utilization percentage over time. Values below 30% indicate potential over-provisioning.',
          fieldConfig: { defaults: { color: { mode: 'palette-classic' }, custom: { drawStyle: 'line', fillOpacity: 10, lineWidth: 1, showPoints: 'never', spanNulls: true }, unit: 'percentunit', min: 0, max: 1, decimals: 1 } },
          gridPos: { h: 8, w: 24, x: 0, y: 32 },
          id: 401,
          options: { legend: { calcs: ['mean', 'max'], displayMode: 'table', placement: 'right' }, tooltip: { mode: 'multi', sort: 'desc' } },
          targets: [{ datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'sum(rate(container_cpu_usage_seconds_total{%s}[5m])) by (namespace,pod) / sum(kube_pod_container_resource_requests{%s}) by (namespace,pod)' % [selector, requestSelector('cpu')], legendFormat: '{{namespace}}/{{pod}}', refId: 'A' }],
          title: 'CPU Utilization Over Time',
          type: 'timeseries',
        },
        // Memory Utilization Over Time
        {
          datasource: { type: 'prometheus', uid: '${datasource}' },
          description: 'Memory utilization percentage over time. Values below 30% indicate potential over-provisioning.',
          fieldConfig: { defaults: { color: { mode: 'palette-classic' }, custom: { drawStyle: 'line', fillOpacity: 10, lineWidth: 1, showPoints: 'never', spanNulls: true }, unit: 'percentunit', min: 0, max: 1, decimals: 1 } },
          gridPos: { h: 8, w: 24, x: 0, y: 40 },
          id: 402,
          options: { legend: { calcs: ['mean', 'max'], displayMode: 'table', placement: 'right' }, tooltip: { mode: 'multi', sort: 'desc' } },
          targets: [{ datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'sum(container_memory_working_set_bytes{%s}) by (namespace,pod) / sum(kube_pod_container_resource_requests{%s}) by (namespace,pod)' % [selector, requestSelector('memory')], legendFormat: '{{namespace}}/{{pod}}', refId: 'A' }],
          title: 'Memory Utilization Over Time',
          type: 'timeseries',
        },
        // Pod Restarts
        {
          datasource: { type: 'prometheus', uid: '${datasource}' },
          description: 'Pod restarts in the last hour. Frequent restarts may indicate memory pressure or resource constraints.',
          fieldConfig: { defaults: { color: { mode: 'palette-classic' }, custom: { drawStyle: 'line', fillOpacity: 0, lineWidth: 1, showPoints: 'never' }, unit: 'none', decimals: 0 } },
          gridPos: { h: 8, w: 24, x: 0, y: 48 },
          id: 403,
          options: { legend: { calcs: ['max'], displayMode: 'table', placement: 'right' }, tooltip: { mode: 'multi', sort: 'desc' } },
          targets: [{ datasource: { type: 'prometheus', uid: '${datasource}' }, expr: 'increase(kube_pod_container_status_restarts_total{%s}[1h]) > 0' % podSelector, legendFormat: '{{namespace}}/{{pod}}', refId: 'A' }],
          title: 'Pod Restarts (1h)',
          type: 'timeseries',
        },
      ],
      title: 'Historical Trends',
      type: 'row',
    },
  ],
  refresh: '30s',
  schemaVersion: 39,
  templating: {
    list: [
      { current: { text: 'prometheus', value: 'prometheus' }, includeAll: false, label: 'Datasource', name: 'datasource', options: [], query: 'prometheus', refresh: 1, type: 'datasource' },
      { datasource: { type: 'prometheus', uid: '${datasource}' }, hide: 0, includeAll: false, label: cfg.clusterLabel, name: cfg.clusterLabel, options: [], query: 'label_values(up{job="kube-state-metrics"}, %s)' % cfg.clusterLabel, refresh: 2, sort: 1, type: 'query' },
      { current: { text: 'All', value: '$__all' }, datasource: { type: 'prometheus', uid: '${datasource}' }, definition: 'label_values(kube_pod_info{%s="$%s"}, namespace)' % [cfg.clusterLabel, cfg.clusterLabel], includeAll: true, label: 'Namespace', multi: true, name: 'namespace', options: [], query: 'label_values(kube_pod_info{%s="$%s"}, namespace)' % [cfg.clusterLabel, cfg.clusterLabel], refresh: 2, sort: 1, type: 'query' },
      { type: 'custom', name: 'timeWindow', label: 'Time Window', current: { text: '24h', value: '24h', selected: true }, options: [{ text: '24h', value: '24h', selected: true }, { text: '7d', value: '7d', selected: false }, { text: '30d', value: '30d', selected: false }], query: '24h,7d,30d', hide: 0, includeAll: false, multi: false },
    ],
  },
  tags: ['kubernetes', 'optimization', 'resources'],
  time: { from: 'now-$timeWindow', to: 'now' },
  timezone: 'browser',
  title: 'Kubernetes / Pod Resource Optimization',
  uid: 'pod-optimization',
}
