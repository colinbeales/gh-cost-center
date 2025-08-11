# Makefile for gh-cost-center development

.PHONY: help install lint fmt test clean check ci

# Default target
help:
	@echo "Available targets:"
	@echo "  install  - Install development dependencies"
	@echo "  lint     - Run shellcheck on all shell scripts"
	@echo "  fmt      - Format shell scripts with shfmt"
	@echo "  test     - Run tests with bats"
	@echo "  check    - Run lint and test"
	@echo "  ci       - Run full CI pipeline (lint + fmt + test)"
	@echo "  clean    - Clean temporary files"

# Install development dependencies
install:
	@echo "Checking for required tools..."
	@command -v shellcheck >/dev/null 2>&1 || { echo "Installing shellcheck..."; brew install shellcheck; }
	@command -v shfmt >/dev/null 2>&1 || { echo "Installing shfmt..."; brew install shfmt; }
	@command -v bats >/dev/null 2>&1 || { echo "Installing bats..."; brew install bats-core; }
	@echo "Development dependencies ready!"

# Lint shell scripts
lint:
	@echo "Running shellcheck..."
	shellcheck gh-cost-center lib/*.sh test/*.bats || true

# Format shell scripts
fmt:
	@echo "Formatting shell scripts..."
	shfmt -w -i 4 gh-cost-center lib/*.sh

# Check formatting without changing files
fmt-check:
	@echo "Checking shell script formatting..."
	shfmt -d -i 4 gh-cost-center lib/*.sh

# Run tests
test:
	@echo "Running tests..."
	@if command -v bats >/dev/null 2>&1; then \
		bats test/; \
	else \
		echo "bats not found. Run 'make install' first."; \
		exit 1; \
	fi

# Quick check (lint + format check)
check: lint fmt-check

# Full CI pipeline
ci: lint fmt-check test

# Clean temporary files
clean:
	@echo "Cleaning temporary files..."
	find . -name "*.tmp" -delete
	find . -name "*.bak" -delete

# Development shortcut - test the current script
dev-test:
	@echo "Testing current implementation..."
	./gh-cost-center --help
