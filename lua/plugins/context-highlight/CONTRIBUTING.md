# Contributing to context-highlight.nvim

Contributions are welcome. Follow these guidelines to maintain code quality and consistency.

## Code Structure

```
lua/plugins/context-highlight/
├── init.lua          # Main coordinator, setup, autocmds
├── config.lua        # Configuration defaults
├── scope.lua         # TreeSitter scope detection
├── highlight.lua     # Highlighting, dimming, color calculations
├── lsp.lua           # LSP integration for symbol highlighting
└── test.lua          # Test file for manual testing
```

## Development Setup

1. Clone or link the plugin directory
2. Install dependencies:
   - nvim-treesitter
   - TreeSitter parsers (`:TSInstall lua python`)
   - LSP servers (optional, for testing LSP integration)

3. Load plugin:
   ```lua
   require('plugins.context-highlight').setup()
   ```

## Making Changes

### Code Style

- Use 2 spaces for indentation
- Follow existing naming conventions
- Add comments for non-obvious logic
- Keep functions focused and modular

### Module Responsibilities

- `init.lua`: Orchestration only, no business logic
- `config.lua`: Configuration defaults and validation
- `scope.lua`: TreeSitter AST traversal and scope detection
- `highlight.lua`: Extmarks, highlight groups, color calculations
- `lsp.lua`: LSP client interaction, async handling

### Adding Language Support

Edit `scope.lua`:

```lua
M.SCOPE_NODE_TYPES = {
  -- Add language-specific node types
  "your_language_scope_type",
}
```

Test with `:lua require('plugins.context-highlight').debug()`

### Testing Changes

1. Reload module:
   ```lua
   package.loaded['plugins.context-highlight'] = nil
   package.loaded['plugins.context-highlight.config'] = nil
   package.loaded['plugins.context-highlight.highlight'] = nil
   require('plugins.context-highlight').setup()
   ```

2. Test with `test.lua`:
   ```vim
   :edit lua/plugins/context-highlight/test.lua
   ```

3. Run debug:
   ```lua
   require('plugins.context-highlight').debug()
   ```

## Pull Request Process

1. Test changes thoroughly
2. Update documentation (README.md and help file)
3. Add entry to TODO.md if introducing new technical debt
4. Ensure all files have copyright header
5. Submit PR with clear description of changes

## Bug Reports

Include:
- Neovim version (`:version`)
- TreeSitter parser version (`:TSInstallInfo`)
- LSP server info (`:LspInfo`)
- Output from `:lua require('plugins.context-highlight').debug()`
- Minimal reproducible example

## Performance Guidelines

- Avoid O(n²) operations
- Use debouncing for cursor movement handlers
- Prefer TreeSitter queries over regex
- Test with large files (>5000 lines)
- Profile with `:profile start` if needed

## Areas for Improvement

See TODO.md for planned enhancements and known issues.

Key areas:
- Performance optimization for large files
- Character-based dimming (currently line-based)
- Additional language support
- Configurable symbol highlight colors
- Scope boundary indicators

## Questions

Open an issue for questions or discussion before making major architectural changes.

## License

By contributing, you agree to license your contributions under the MIT License.
