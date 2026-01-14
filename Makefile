.PHONY: test test-unit test-integration test-edge test-infrastructure clean help

# Default target
all: test

# Run all tests
test:
	@echo "Running all tests..."
	@$(MAKE) test-infrastructure
	@$(MAKE) test-unit
	@$(MAKE) test-edge
	@$(MAKE) test-integration
	@echo ""
	@echo "All tests completed successfully!"

# Run infrastructure tests (new abstraction layers)
test-infrastructure:
	@echo "=== Infrastructure Tests ==="
	@lua5.3 tests/test_config.lua
	@lua5.3 tests/test_io_abstraction.lua
	@lua5.3 tests/test_mock_io.lua
	@echo ""

# Run unit tests (isolated module tests)
test-unit:
	@echo "=== Unit Tests ==="
	@lua5.3 tests/test_widgets.lua
	@lua5.3 tests/test_formatting.lua
	@lua5.3 tests/test_navigation.lua
	@lua5.3 tests/test_menu_formatting.lua
	@lua5.3 tests/test_upgrades.lua
	@lua5.3 tests/test_world_turn.lua
	@lua5.3 tests/test_routes_model.lua
	@lua5.3 tests/test_threats.lua
	@lua5.3 tests/test_broker_model.lua
	@lua5.3 tests/test_ship_operations.lua
	@echo ""

# Run edge case tests
test-edge:
	@echo "=== Edge Case Tests ==="
	@lua5.3 tests/test_edge_cases.lua
	@echo ""

# Run integration tests (presenter and full gameplay)
test-integration:
	@echo "=== Integration Tests ==="
	@lua5.3 tests/test_routes_presenter.lua
	@lua5.3 tests/test_display_panels.lua
	@lua5.3 tests/test_broker_presenter.lua
	@lua5.3 tests/test_ship_operations_presenter.lua
	@lua5.3 tests/test_gameplay_integration.lua
	@echo ""

# Run specific test file (usage: make test-file FILE=test_widgets)
test-file:
	@if [ -z "$(FILE)" ]; then \
		echo "Usage: make test-file FILE=test_name"; \
		echo "Example: make test-file FILE=test_widgets"; \
		exit 1; \
	fi
	@echo "Running tests/$(FILE).lua..."
	@lua5.3 tests/$(FILE).lua

# Clean up generated files
clean:
	@echo "Cleaning up..."
	@rm -f luac.out
	@echo "Clean complete!"

# Display help
help:
	@echo "Shadow Fleet - Makefile"
	@echo ""
	@echo "Available targets:"
	@echo "  make test                  - Run all tests"
	@echo "  make test-infrastructure   - Run infrastructure/abstraction tests"
	@echo "  make test-unit             - Run unit tests only"
	@echo "  make test-edge             - Run edge case tests only"
	@echo "  make test-integration      - Run integration tests only"
	@echo "  make test-file FILE=name   - Run specific test file"
	@echo "  make clean                 - Clean up generated files"
	@echo "  make help                  - Show this help message"
	@echo ""
	@echo "Examples:"
	@echo "  make test-file FILE=test_widgets"
	@echo "  make test-unit"
	@echo ""
