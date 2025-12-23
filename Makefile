.PHONY: all clean deps build dashboards alerts rules lint

JSONNET_DIR := jsonnet
CHART_DIR := chart
ALERTS_DIR := $(CHART_DIR)/alerts
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
build: dashboards alerts rules

# Generate dashboards JSON
dashboards:
	@mkdir -p $(DASHBOARDS_DIR)
	@echo "Generating dashboards..."
	$(JSONNET) -J $(JSONNET_DIR)/vendor -m $(DASHBOARDS_DIR) \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").grafanaDashboards'

# Generate alert rules JSON
alerts:
	@mkdir -p $(ALERTS_DIR)
	@echo "Generating alerts..."
	$(JSONNET) -J $(JSONNET_DIR)/vendor -m $(ALERTS_DIR) \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").alerts'

# Generate recording rules JSON
rules:
	@mkdir -p $(RULES_DIR)
	@echo "Generating recording rules..."
	$(JSONNET) -J $(JSONNET_DIR)/vendor -m $(RULES_DIR) \
		-e '(import "$(JSONNET_DIR)/mixin.libsonnet").rules'

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
	rm -rf $(ALERTS_DIR) $(DASHBOARDS_DIR) $(RULES_DIR)

# Helm package
package: build
	helm package $(CHART_DIR)

# Helm template (dry-run)
template: build
	helm template gitops-mixin $(CHART_DIR)
