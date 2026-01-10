# Changelog

## [0.10.0](https://github.com/monkescience/gitops-mixin/compare/0.9.0...0.10.0) (2026-01-10)


### Features

* **argocd:** enable multi-cluster support in dashboards ([62718d9](https://github.com/monkescience/gitops-mixin/commit/62718d979c3d6d8893a56cbc4daa6b63562cd071))
* **kubernetes:** enable multi-cluster support in dashboards ([ee7ec36](https://github.com/monkescience/gitops-mixin/commit/ee7ec361d9cf512aa7cc9079090d716e3bb5d024))
* **node-exporter:** enable multi-cluster support in dashboards ([d452638](https://github.com/monkescience/gitops-mixin/commit/d452638624aab36bf40afc09dc74ba2315ba835a))


### Bug Fixes

* **alloy:** add logsFilterSelector to fix Loki query error ([98ea3df](https://github.com/monkescience/gitops-mixin/commit/98ea3dfb2c8cff29771c46d410398164cba89d5a))

## [0.9.0](https://github.com/monkescience/gitops-mixin/compare/0.8.0...0.9.0) (2026-01-09)


### Features

* enhance pod optimization dashboard and alerts ([5f67674](https://github.com/monkescience/gitops-mixin/commit/5f6767401d287094ffb672e3838de2100970215e))

## [0.8.0](https://github.com/monkescience/gitops-mixin/compare/0.7.0...0.8.0) (2026-01-02)


### Features

* add missing resource requests table to pod optimization dashboard ([fdc2286](https://github.com/monkescience/gitops-mixin/commit/fdc22865a202c53cd913a60970d453b7b91787e1))

## [0.7.0](https://github.com/monkescience/gitops-mixin/compare/0.6.0...0.7.0) (2026-01-01)


### Features

* enhance resource optimization alerts and dashboards ([be3e0b9](https://github.com/monkescience/gitops-mixin/commit/be3e0b9804fba160c565e9c6ba79471d35b872e6))
* update pod optimization dashboard with mappings and $__range adjustments ([b2c2e8d](https://github.com/monkescience/gitops-mixin/commit/b2c2e8d7156918d9b2327b73a9d0b3bb4d1b2b7a))

## [0.6.0](https://github.com/monkescience/gitops-mixin/compare/0.5.0...0.6.0) (2025-12-26)


### Features

* add support for cross-namespace Grafana dashboard imports ([c959667](https://github.com/monkescience/gitops-mixin/commit/c95966724bc49ccaf22385b43b3bc7b0bc75290e))

## [0.5.0](https://github.com/monkescience/gitops-mixin/compare/0.4.0...0.5.0) (2025-12-26)


### Features

* improve instanceSelector handling in Grafana dashboard configuration ([517857c](https://github.com/monkescience/gitops-mixin/commit/517857c4059296f0afe4ecf7e8345614bd05ef0e))

## [0.4.0](https://github.com/monkescience/gitops-mixin/compare/0.3.0...0.4.0) (2025-12-26)


### Features

* update Grafana dashboard configuration to clarify instanceSelector usage ([75f7f3a](https://github.com/monkescience/gitops-mixin/commit/75f7f3af7a963d1b395f06aafebe659524e38aaf))

## [0.3.0](https://github.com/monkescience/gitops-mixin/compare/0.2.0...0.3.0) (2025-12-23)


### Features

* add Alloy, Mimir, and Tempo mixins with alerts, rules, and dashboards ([fc71f7c](https://github.com/monkescience/gitops-mixin/commit/fc71f7cc812e6c208d5942b22c77cb659e925cd3))
* add Loki mixin with alerts, rules, and platform-specific dashboards ([cf60a45](https://github.com/monkescience/gitops-mixin/commit/cf60a457947329a45598505909a21080f303819d))
* add Renovate automation workflow and configuration ([4e7eb0a](https://github.com/monkescience/gitops-mixin/commit/4e7eb0acb05dbf78e6f9d30a2a2b9056bd79b860))
* enable Windows and additional platform-specific dashboards, refine Grafana and Prometheus configuration ([98671af](https://github.com/monkescience/gitops-mixin/commit/98671afb741b5b26a6a35cdc51d21359b0013b6c))
* enhance mixin configuration for Grafana and Prometheus with improved alert and dashboard management ([bd12558](https://github.com/monkescience/gitops-mixin/commit/bd125582ab75a6fd64bda8077b225597f6697794))
* extend resource optimization alerts with overutilization rules and update underutilization thresholds ([e3a8b99](https://github.com/monkescience/gitops-mixin/commit/e3a8b99fa68aa21a799480cd738c912382691899))


### Bug Fixes

* simplify Grafana instance selector configuration in values.yaml ([15d2d85](https://github.com/monkescience/gitops-mixin/commit/15d2d85a8979eaa57f66a7c561bd1ef18fbac028))
* update job selectors in Jsonnet config to simplify and standardize naming conventions ([1e71864](https://github.com/monkescience/gitops-mixin/commit/1e718645fbce43f7ed092a620d959d52f9d2c8bf))

## [0.2.0](https://github.com/monkescience/gitops-mixin/compare/0.1.0...0.2.0) (2025-12-13)


### Features

* add folder support for Grafana dashboards configuration ([29c82d6](https://github.com/monkescience/gitops-mixin/commit/29c82d6d6a0a38f9a058df0bd333215cb0943e1e))
* add GitOps mixin with alerts, dashboards, and CI/CD setup ([7dc87ca](https://github.com/monkescience/gitops-mixin/commit/7dc87ca49328777778697980c3562ccd6249224f))
* enhance resource optimization dashboards with improved transformations, visuals, and filtering options ([52edd2b](https://github.com/monkescience/gitops-mixin/commit/52edd2ba59bde5eb9aec43928b449f969d49840e))
* refine pod optimization dashboards with unit updates, precision adjustments, and new calculations ([3caaef2](https://github.com/monkescience/gitops-mixin/commit/3caaef24c4fe61e91cdc01995a925876a7c4203e))


### Bug Fixes

* apply configuration overlay to imported Jsonnet mixins ([998e446](https://github.com/monkescience/gitops-mixin/commit/998e44614b04b32065027bcf1f31f0e417828ba8))
* remove restrictive label selector for Grafana dashboards ([939323d](https://github.com/monkescience/gitops-mixin/commit/939323d6436d80e5171986660bd6a8716dbf6025))
* replace Jsonnet Action with manual installation in release workflow ([90db1aa](https://github.com/monkescience/gitops-mixin/commit/90db1aa996b3dba80514ab2c28c0a9478d609de8))
* simplify Jsonnet installation command in release workflow ([4945cc2](https://github.com/monkescience/gitops-mixin/commit/4945cc29d1e9f111b28d98e42ef05023b78fe451))
* update Jsonnet setup and install jsonnet-bundler manually in release workflow ([3b67c7d](https://github.com/monkescience/gitops-mixin/commit/3b67c7d505b500c44f864e535833c2d2ca43ff00))
