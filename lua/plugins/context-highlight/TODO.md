# TODO

## High Priority

### Packaging and Distribution
- [ ] Modularize plugin for standalone distribution
  - [ ] Create separate git repository
  - [ ] Setup plugin directory structure following Neovim conventions
  - [ ] Add `plugin/` directory for auto-loading
  - [ ] Move help file to `doc/` at repository root
  - [ ] Create minimal `plugin/context-highlight.lua` loader
  - [ ] Update installation instructions for plugin managers
  - [ ] Test with lazy.nvim, packer, vim-plug, native package manager

### Performance
- [ ] Optimize for large files (>10,000 lines)
  - [ ] Implement incremental dimming (only visible lines)
  - [ ] Add configurable max file size limit
  - [ ] Cache scope hierarchy between cursor moves
  - [ ] Debounce based on file size
- [ ] Profile and benchmark scope detection algorithm
- [ ] Consider virtual text instead of extmarks for dimming

### Configuration
- [ ] Add command to reload configuration without restart
  - [ ] `:ContextHighlightReload` command
  - [ ] Hot-reload dim_opacity changes
- [ ] Make symbol highlight colors configurable
  - [ ] Replace hardcoded colors with config options
  - [ ] Support hex colors and highlight group names
- [ ] Add per-filetype configuration
- [ ] Add buffer/filetype exclusion list

## Medium Priority

### Features
- [ ] Character-based dimming instead of line-based
  - [ ] More granular highlighting
  - [ ] Performance impact analysis required
- [ ] Scope boundary visual indicators
  - [ ] Optional separator lines between scopes
  - [ ] Configurable characters and colors
- [ ] Statusline integration
  - [ ] Show current scope name in statusline
  - [ ] Show scope depth indicator
- [ ] Independent symbol highlighting toggle
  - [ ] Separate enable/disable for dimming vs symbols
  - [ ] Different keybindings for each feature
- [ ] Multiple cursor location support
  - [ ] Handle visual mode selections
  - [ ] Multiple active scopes simultaneously

### Language Support
- [ ] Add TypeScript/JavaScript scope types
- [ ] Add Python scope types
- [ ] Add Rust scope types
- [ ] Add Go scope types
- [ ] Add Java scope types
- [ ] Add C/C++ scope types
- [ ] Test and document scope detection for each language

### LSP Integration
- [ ] Add timeout for LSP requests
- [ ] Implement request cancellation on cursor move
- [ ] Support multiple LSP clients simultaneously
- [ ] Add LSP server capability detection
- [ ] Implement textDocument/semanticTokens support

## Low Priority

### UI/UX
- [ ] Animation for dimming transitions
- [ ] Smooth fade-in/fade-out effects
- [ ] Color preview in configuration
- [ ] Interactive dim_opacity adjustment

### Testing
- [ ] Add automated tests
  - [ ] Unit tests for scope detection
  - [ ] Unit tests for color calculations
  - [ ] Integration tests with TreeSitter
  - [ ] LSP mock testing
- [ ] Create test suite for multiple languages
- [ ] Performance regression tests
- [ ] CI/CD pipeline setup

### Documentation
- [ ] Add GIF/video demonstrations
- [ ] Create comparison with similar plugins
- [ ] Add troubleshooting flowchart
- [ ] Document TreeSitter query patterns
- [ ] Add FAQ section

### Code Quality
- [ ] Add type annotations (using Lua LSP)
- [ ] Refactor color calculations into separate module
- [ ] Add input validation for all public functions
- [ ] Improve error messages and error handling
- [ ] Add logging framework for debugging

## Research/Experimental

- [ ] Investigate treesitter-context integration
- [ ] Explore semantic highlighting API
- [ ] Consider nvim-cmp integration for scope-aware completion
- [ ] Research telescope.nvim integration for scope navigation
- [ ] Evaluate DAP integration for debugging scope highlighting

## Known Issues

- [ ] Dimming inconsistent for multi-line statements spanning scopes
- [ ] Terminal color (cterm) support missing
- [ ] Configuration changes require module reload
- [ ] Performance degradation with very large files
- [ ] Symbol highlighting doesn't work in non-TreeSitter files
- [ ] No support for multiple windows showing same buffer

## Completed

- [x] Multi-level scope dimming
- [x] LSP documentHighlight integration
- [x] TreeSitter fallback for symbol highlighting
- [x] Read/write differentiation for LSP symbols
- [x] Automatic color scheme integration
- [x] Debouncing for cursor movement
- [x] Comprehensive help documentation
- [x] MIT license and copyright headers
- [x] Modular code structure (init, config, scope, highlight, lsp)
