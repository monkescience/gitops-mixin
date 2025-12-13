.PHONY: all clean deps build dashboards alerts lint

JSONNET_DIR := jsonnet
CHART_DIR := chart
DASHBOARDS_DIR := $(CHART_DIR)/dashboards
RULES_DIR := $(CHART_DIR)/rules

# Tools
JB := jb
JSONNET := jsonnet
JSONNETFMT := jsonnetfmt

all: deps build

# Install jsonnet dependencies
deps:
	cd $(JSONNET_DIR) && $(JB) install

# Update jsonnet dependencies
update:
	cd $(JSONNET_DIR) && $(JB) update

# Build all outputs
build: dashboards alerts

# Generate dashboards JSON
dashboards:
	@mkdir -p $(DASHBOARDS_DIR)
	@echo "Generating dashboards..."
	$(JSONNET) -J $(JSONNET_DIR)/vendor -m $(DASHBOARDS_DIR) \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").grafanaDashboards'

# Generate alert rules YAML (per-mixin files)
alerts:
	@mkdir -p $(RULES_DIR)
	@echo "Generating alerts and rules..."
	# Kubernetes mixin
	$(JSONNET) -J $(JSONNET_DIR)/vendor \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").kubernetesAlerts' \
		| yq -P > $(RULES_DIR)/kubernetes-alerts.yaml
	$(JSONNET) -J $(JSONNET_DIR)/vendor \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").kubernetesRules' \
		| yq -P > $(RULES_DIR)/kubernetes-rules.yaml
	# Node Exporter mixin
	$(JSONNET) -J $(JSONNET_DIR)/vendor \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").nodeExporterAlerts' \
		| yq -P > $(RULES_DIR)/node-exporter-alerts.yaml
	$(JSONNET) -J $(JSONNET_DIR)/vendor \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").nodeExporterRules' \
		| yq -P > $(RULES_DIR)/node-exporter-rules.yaml
	# ArgoCD mixin
	$(JSONNET) -J $(JSONNET_DIR)/vendor \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").argoCdAlerts' \
		| yq -P > $(RULES_DIR)/argocd-alerts.yaml
	$(JSONNET) -J $(JSONNET_DIR)/vendor \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").argoCdRules' \
		| yq -P > $(RULES_DIR)/argocd-rules.yaml
	# Resource Optimization mixin
	$(JSONNET) -J $(JSONNET_DIR)/vendor \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").resourceOptimizationAlerts' \
		| yq -P > $(RULES_DIR)/resource-optimization-alerts.yaml

# Format jsonnet files
fmt:
	find $(JSONNET_DIR) -name '*.libsonnet' -o -name '*.jsonnet' | \
		xargs -I {} $(JSONNETFMT) -i {}

# Lint jsonnet files
lint:
	find $(JSONNET_DIR) -name '*.libsonnet' -o -name '*.jsonnet' | \
		xargs -I {} $(JSONNET) -J $(JSONNET_DIR)/vendor --lint {}

# Clean generated files
clean:
	rm -rf $(DASHBOARDS_DIR) $(RULES_DIR)
	rm -rf $(JSONNET_DIR)/vendor

# Helm package
package: build
	helm package $(CHART_DIR)

# Helm template (dry-run)
template: build
	helm template gitops-mixin $(CHART_DIR)
