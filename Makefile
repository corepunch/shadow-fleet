.PHONY: test clean help

# Default target
all: test

# Run all tests
test:
	@echo "Running tests..."
	@lua5.3 tests/test_widgets.lua
	@lua5.3 tests/test_formatting.lua
	@lua5.3 tests/test_navigation.lua
	@lua5.3 tests/test_menu_formatting.lua
	@lua5.3 tests/test_upgrades.lua
	@lua5.3 tests/test_world_turn.lua
	@lua5.3 tests/test_routes_model.lua
	@lua5.3 tests/test_routes_presenter.lua
	@lua5.3 tests/test_threats.lua
	@echo ""
	@echo "All tests completed successfully!"

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
	@echo "  make test    - Run all tests"
	@echo "  make clean   - Clean up generated files"
	@echo "  make help    - Show this help message"
	@echo ""
