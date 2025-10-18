CONTEXT-AWARE SYNTAX HIGHLIGHTING
==================================

PHILOSOPHY
----------
"If everything is highlighted, nothing stands out."

This plugin implements HYBRID context highlighting:
1. Multi-level scope-based dimming (innermost scope brightest, outer scopes progressively dimmer)
2. Symbol reference highlighting (highlight all occurrences of identifier under cursor)
3. Minimal syntax highlighting (only keywords/operators within active scope)


FEATURES
--------
1. Multi-Level Scope Dimming
   - Innermost scope (cursor location): 100% brightness - fully visible
   - Parent scope: 85% brightness - slightly dimmed
   - Outer scopes: 70% brightness - moderately dimmed
   - Outside all scopes: 50% brightness - heavily dimmed

2. Symbol Reference Highlighting
   - When cursor is on an identifier (variable, function name, etc.)
   - Highlights ALL occurrences across the entire file
   - Works even in dimmed areas - symbols stand out through dimming
   - TWO MODES:
     a) LSP-based (semantic, scope-aware, read vs write detection)
     b) TreeSitter-based (text matching fallback)

3. LSP Integration (NEW!)
   - Uses LSP textDocument/documentHighlight when available
   - Semantic symbol highlighting (not just text matching)
   - Respects language scopes (same variable name in different functions = different symbols)
   - Read vs Write differentiation:
     * Blue background for reads (accessing variable)
     * Orange background for writes (assignments, declarations)
   - Automatic fallback to TreeSitter if LSP unavailable
   - Works with: lua_ls, ts_server, rust-analyzer, pyright, gopls, etc.

4. Color Scheme Integration
   - Automatically detects your current theme's background color
   - Calculates dimmed colors proportionally (not hardcoded overlays)
   - Works seamlessly with both dark and light themes
   - Updates when you change colorscheme

4. Minimal Syntax Highlighting
   - Within active scope: keywords, operators, strings highlighted (configurable)
   - Outside scope: only dimmed background, no syntax colors
   - Reduces visual noise while maintaining context

5. TreeSitter-Powered
   - Accurate scope detection using AST
   - Language-agnostic patterns work across multiple languages
   - Supports nested scopes (for loops inside functions, etc.)


HOW IT WORKS
------------
HYBRID IMPLEMENTATION:

A. Multi-Level Dimming:
   1. When cursor moves, get TreeSitter node at cursor position
   2. Walk up AST to collect all containing scopes (for loop → function → file)
   3. Create scope hierarchy: [innermost, parent, grandparent, ...]
   4. For each line in buffer, determine which scope it belongs to
   5. Apply appropriate dimming level based on scope distance from cursor:
      - Level 1 (innermost): no dimming
      - Level 2 (parent): light dimming (85% opacity)
      - Level 3+ (outer): medium dimming (70% opacity)
      - No scope: heavy dimming (50% opacity)

B. Symbol Highlighting:
   1. Get TreeSitter node at cursor position
   2. Check if it's an identifier (variable, function name, etc.)
   3. Extract the symbol text
   4. Traverse entire syntax tree to find all matching identifiers
   5. Highlight all occurrences with high-priority extmarks
   6. Symbol highlights appear above dimming layers

C. Color Scheme Integration:
   1. Read Normal highlight group to get current background color
   2. Use bitwise RGB manipulation to calculate dimmed variants
   3. For dark themes: reduce RGB values (darken)
   4. For light themes: increase RGB values (lighten)
   5. Apply dimmed backgrounds via extmarks


CURRENT STATUS
--------------
HYBRID IMPLEMENTATION - Combines scope dimming with symbol highlighting.

Evolution:
v1: Symbol occurrence highlighting only (like LSP document highlight)
v2: Scope-based dimming only (single level, outside scope dimmed)
v3: CURRENT - Hybrid approach with multi-level dimming + symbol highlighting + theme integration


STRUCTURE
---------
lua/plugins/context-highlight/
├── init.lua          Main module (coordinator, orchestrates other modules)
├── config.lua        Configuration defaults
├── scope.lua         Scope detection using TreeSitter
├── highlight.lua     Highlighting + dimming + color scheme integration
├── lsp.lua           LSP integration for semantic symbol highlighting
├── test.lua          Comprehensive test file
├── README.txt        This file (text version)
└── README.md         Markdown version (for GitHub/standalone plugin)


USAGE
-----
In lua/plugins.lua:

require('plugins.context-highlight').setup({
    enabled = true,
    debounce_ms = 100,
    dim_opacity = 0.7,    -- How dim out-of-scope code appears (0.0-1.0)
                          -- Higher = less dimming (more visible)
                          -- Recommended: 0.5-0.7 (0.3-0.4 for max focus)

    -- LSP integration (NEW!)
    use_lsp = true,  -- Use LSP documentHighlight when available
    lsp_fallback_to_treesitter = true,  -- Fallback to TreeSitter if LSP unavailable
    differentiate_read_write = true,  -- Use different colors for read vs write

    minimal_highlights = {
        keywords = true,     -- Highlight if/for/return/function/etc
        operators = true,    -- Highlight +, -, =, etc
        strings = true,      -- Highlight string literals
        numbers = false,     -- Highlight number literals
        comments = false,    -- Highlight comments
    },
})

Manual control:
:lua require('plugins.context-highlight').enable()   -- Enable
:lua require('plugins.context-highlight').disable()  -- Disable
:lua require('plugins.context-highlight').toggle()   -- Toggle (F6)
:lua require('plugins.context-highlight').debug()    -- Debug info

Testing with the test file:
:edit ~/.config/nvim/lua/plugins/context-highlight/test.lua

1. TEST MULTI-LEVEL DIMMING:
   Place cursor inside the "for index, value" loop in process_numbers():
   - Inner loop: BRIGHTEST (your focus)
   - process_numbers function: MEDIUM (context)
   - Other functions: DIMMED (background)

   Move to the nested "if value > 100" block:
   - Nested if: BRIGHTEST
   - Outer if: MEDIUM BRIGHT
   - For loop: MEDIUM
   - Function: LIGHT DIM
   - Other code: HEAVY DIM

2. TEST SYMBOL HIGHLIGHTING:
   Place cursor on "value" inside the loop:
   → All "value" occurrences highlighted (parameter, comparisons, usage)

   Place cursor on "CONFIG" global:
   → All CONFIG references highlighted across entire file (even in dimmed code!)

   Place cursor on "threshold":
   → Shows parameter definition and all usages

3. TEST SCOPE NAVIGATION:
   Move cursor between:
   - validate_data() → Other functions dim
   - process_numbers() → validate_data dims, process_numbers brightens
   - Nested if block → Parent if dims slightly
   - While loop in main() → main() brightens, others heavily dimmed

4. TEST THEME INTEGRATION:
   :colorscheme <different-theme>
   → Dimming adapts automatically to new background color


CONFIGURATION
-------------
Options passed to setup():

enabled (boolean)
  Default: true
  Enable/disable the plugin

debounce_ms (number)
  Default: 100
  Milliseconds to wait after cursor stops moving before updating
  Lower = more responsive, higher = less CPU usage
  Recommended: 50-200

dim_opacity (number)
  Default: 0.7 (changed from 0.6 in config.lua)
  Controls dimming intensity (0.0 = maximum dimming, 1.0 = no dimming)
  This value affects all dimming levels proportionally:
  - Heavy dim (outside all scopes): dim_opacity * 0.5
  - Medium dim (outer scopes): dim_opacity * 0.7
  - Light dim (parent scope): dim_opacity * 0.85
  - No dim (innermost scope): 1.0 (always fully visible)

  Recommended values:
  - 0.3-0.4: Maximum focus mode - very dark (best for testing visibility)
  - 0.5-0.6: Aggressive dimming - strong focus
  - 0.7: Balanced dimming - good default
  - 0.8: Subtle dimming - more context visible
  - 0.9+: Very subtle - minimal dimming

  IMPORTANT: Visual differences between adjacent values (0.5 vs 0.6) are subtle.
  To verify the setting is working, test extreme values like 0.3 or 0.9.

  Applying config changes:
  1. Edit dim_opacity in lua/plugins.lua
  2. Restart Neovim (colors calculated during plugin initialization)
  3. Or reload manually:
     :lua package.loaded['plugins.context-highlight'] = nil
     :lua package.loaded['plugins.context-highlight.config'] = nil
     :lua package.loaded['plugins.context-highlight.highlight'] = nil
     :lua require('plugins.context-highlight').setup({dim_opacity=0.3})

use_lsp (boolean)
  Default: true
  Enable LSP-based symbol highlighting when available
  Uses textDocument/documentHighlight LSP method
  More accurate than TreeSitter text matching

lsp_fallback_to_treesitter (boolean)
  Default: true
  When LSP unavailable or unsupported, fall back to TreeSitter highlighting
  Set to false to disable symbol highlighting entirely when LSP not available

differentiate_read_write (boolean)
  Default: true
  Use different colors for read vs write symbol references (LSP only)
  - Read: Blue-ish background
  - Write: Orange-ish background
  Set to false to use same color for all symbol references

minimal_highlights (table)
  Controls what's highlighted within the active scope:
  - keywords: if, for, return, function, class, etc (default: true)
  - operators: +, -, =, ==, &&, etc (default: true)
  - strings: String literals (default: true)
  - numbers: Number literals (default: false)
  - comments: Comments (default: false)

  Elements set to false will have NO highlighting (fg = "NONE")

Highlight groups (auto-generated in setup_highlights()):
- ContextHighlightDimHeavy: Outside all scopes (darkest)
- ContextHighlightDimMedium: Outer/grandparent scopes
- ContextHighlightDimLight: Parent scope
- ContextHighlightSymbol: Symbol under cursor (TreeSitter mode, bold + underline)
- ContextHighlightSymbolRead: Symbol read reference (LSP mode, blue background)
- ContextHighlightSymbolWrite: Symbol write reference (LSP mode, orange background + underline)
- @keyword, @operator, @string, @number, @comment: TreeSitter groups
  (configured based on minimal_highlights settings)

Colors are auto-detected from your current colorscheme!


TECHNICAL DETAILS
-----------------
Dependencies:
- nvim-treesitter (required)
- TreeSitter parser for target language (e.g. lua, python, etc.)

Key public functions:
- M.setup(opts)              Initialize plugin with configuration
- M.setup_highlights()       Define all highlight groups (auto-called)
- M.update_highlighting()    Main function: dimming + symbol highlighting
- M.setup_autocmds()         Setup cursor movement handlers
- M.toggle()                 Enable/disable plugin
- M.enable()                 Explicitly enable
- M.disable()                Explicitly disable
- M.debug()                  Show detailed debug information

Color scheme integration (local):
- get_normal_bg()            Detect current theme's background color
- adjust_color(color, factor) Darken/lighten color proportionally
                             Handles both dark and light themes

Scope detection (local):
- is_scope_node(node)              Check if TreeSitter node is a scope
- get_scope_hierarchy()            Get all scopes from cursor outward
                                   Returns: [{start_row, end_row, type}, ...]
- get_current_scope()              Backwards-compatible: innermost scope only

Multi-level dimming (local):
- apply_multi_level_dimming()      Apply 3+ dimming levels based on hierarchy
                                   - Level 1: no dim (innermost)
                                   - Level 2: light dim (parent)
                                   - Level 3+: medium dim (outer)
                                   - No scope: heavy dim

Symbol highlighting (local):
- get_node_text(node, bufnr)          Extract text from TreeSitter node
- is_highlightable_identifier(node)   Check if node is an identifier
- find_symbol_occurrences()           Find all matching identifiers
- highlight_symbol_references()       Highlight all symbol occurrences

Utilities (local):
- clear_highlights(bufnr)    Clear all namespace highlights

Autocmds (ContextHighlight group):
- CursorMoved/CursorMovedI: Debounce (100ms default), then update
- BufEnter: Update highlighting when entering buffer
- BufLeave: Clear all highlights when leaving buffer
- ColorScheme: Reapply highlight groups (adapts to new theme)

Namespaces:
- "context_highlight": For symbol highlighting
- "context_highlight_dim": For multi-level dimming extmarks

Performance optimizations:
- Debouncing prevents excessive updates during rapid cursor movement
- TreeSitter AST traversal is O(log n) for scope detection
- Extmarks are more efficient than match highlights
- Symbol search uses single tree traversal


SCOPE DETECTION
---------------
The plugin recognizes these TreeSitter node types as scopes:

Exact matches (common across languages):
- function_definition, function_declaration
- method_definition
- class_definition, class_declaration
- if_statement, for_statement, while_statement, do_statement, repeat_statement
- block, lambda, closure, chunk

Lua-specific:
- function, local_function
- for_in_statement, for_numeric_statement

Pattern matches (language-agnostic fallback):
- Any node ending in: _statement, _function, _method, _class, _block

How it works:
1. Get TreeSitter node at cursor position
2. Walk up AST collecting ALL containing scopes (not just innermost)
3. Build hierarchy: [innermost, parent, grandparent, ...]
4. Each line in buffer is classified by which scope it belongs to
5. Apply appropriate dimming level based on scope depth

Adding support for other languages:
- Add node types to SCOPE_NODE_TYPES table in scope.lua
- Or rely on pattern matching (usually works automatically)


DEBUGGING
---------
Use the built-in debug function:
:lua require('plugins.context-highlight').debug()

This will show:
- Plugin enabled status
- Current buffer number
- Dim opacity setting
- LSP client availability and name
- TreeSitter availability and language
- Node hierarchy at cursor position
- Current scope hierarchy
- Minimal highlights configuration

Manual testing:
:lua require('plugins.context-highlight').update_highlighting()

Test if TreeSitter is available:
:lua print(pcall(vim.treesitter.get_parser, 0))

Check node under cursor:
:lua local node = vim.treesitter.get_node(); print(node and node:type())

Check active extmarks (count and verify they exist):
:lua print(#vim.api.nvim_buf_get_extmarks(0, vim.api.nvim_create_namespace('context_highlight_dim'), 0, -1, {}))

Verify highlight colors:
:lua print(string.format("Heavy: %s, Medium: %s, Light: %s",
  vim.inspect(vim.api.nvim_get_hl(0, {name='ContextHighlightDimHeavy'})),
  vim.inspect(vim.api.nvim_get_hl(0, {name='ContextHighlightDimMedium'})),
  vim.inspect(vim.api.nvim_get_hl(0, {name='ContextHighlightDimLight'}))))

Reload module after changes:
:lua package.loaded['plugins.context-highlight'] = nil
:lua package.loaded['plugins.context-highlight.config'] = nil
:lua package.loaded['plugins.context-highlight.highlight'] = nil
:lua require('plugins.context-highlight').setup({dim_opacity=0.3})

Check if autocmds are registered:
:au ContextHighlight

TROUBLESHOOTING:

"Changing dim_opacity doesn't change anything"
  - Visual differences between adjacent values (0.5 vs 0.6 vs 0.7) are subtle
  - Test with extreme values: 0.3 (very dark) vs 0.9 (very bright)
  - Verify config is loaded: :lua print(require('plugins.context-highlight').config.dim_opacity)
  - Check highlight colors (should be different for each value):
    :lua print(vim.api.nvim_get_hl(0, {name='ContextHighlightDimHeavy'}).bg)
  - Restart Neovim to ensure fresh initialization
  - Colors are calculated during setup() - changes require reload

"No dimming visible at all"
  - Check if plugin is enabled: :lua print(require('plugins.context-highlight').config.enabled)
  - Verify TreeSitter parser installed: :TSInstall lua
  - Check extmarks are created: see "Check active extmarks" above
  - Ensure termguicolors is enabled: :set termguicolors

"Symbol highlighting not working"
  - Check if LSP is available: :LspInfo
  - Try TreeSitter fallback: set use_lsp = false in config
  - Cursor must be on an identifier (variable, function name, etc.)
  - Use :lua require('plugins.context-highlight').debug() to check LSP client


PERFORMANCE
-----------
- TreeSitter AST traversal is fast (O(log n))
- Debouncing prevents excessive updates during rapid cursor movement
- Extmarks are efficient for line-based highlighting
- Only updates when cursor moves to a different scope


TODO / FUTURE ENHANCEMENTS
---------------------------
- Add option to toggle symbol highlighting independently from scope dimming
- Make symbol highlight colors configurable (currently hardcoded in highlight.lua)
- Support character-based dimming instead of line-based (more granular)
- Add option to show current scope name in statusline
- Consider CursorHold mode for less aggressive updates (reduce CPU)
- Add visual indicator for scope boundaries (subtle separator lines)
- Add configuration for max scope depth to dim (currently unlimited)
- Add option to exclude certain file types or buffer types
- Performance optimization for very large files (>5000 lines)
- Add command to force highlight regeneration without restart
- Consider caching scope hierarchy to avoid recalculation on every cursor move


KNOWN LIMITATIONS
-----------------
- Requires TreeSitter parser for language (won't work on unsupported filetypes)
- Scope detection depends on TreeSitter node types
  → Some language-specific constructs may not be recognized as scopes
  → Add to SCOPE_NODE_TYPES table in scope.lua or rely on pattern matching
- Dimming is line-based (entire lines dimmed, not character-based)
  → A single statement spanning multiple scopes dims inconsistently
  → Character-based dimming would be more granular but much slower
- Symbol highlighting limitations:
  → LSP mode (default): Requires LSP server with documentHighlight support
  → TreeSitter fallback: Matches by text only, doesn't distinguish between
    different variables with same name in different scopes
  → No rename refactoring support (only visual highlighting)
- May have performance issues with very large files (>10,000 lines)
  → Multi-level dimming iterates over all lines on every cursor move
  → Consider increasing debounce_ms for large files (200-500ms)
  → Scope hierarchy calculation is fast (O(log n)) but line iteration is O(n)
- Color calculation assumes RGB color format
  → May not work with terminal colors (cterm)
  → Requires termguicolors enabled (:set termguicolors)
  → Works best with true color terminals
- Configuration changes require Neovim restart or manual module reload
  → Colors calculated during setup() and cached
  → Future: add :ContextHighlightReload command


VISUAL EXAMPLE
--------------
Imagine this code structure:

    CONFIG = { ... }              ← HEAVY DIM (outside all scopes)

    function process_numbers()    ← MEDIUM DIM (outer scope)
      for i, value in pairs() do  ← LIGHT DIM (parent scope)
        if value > 100 then       ← BRIGHT (innermost - cursor here!)
          print(value)            ← BRIGHT
        end                       ← BRIGHT
      end                         ← LIGHT DIM
    end                           ← MEDIUM DIM

    function main()               ← HEAVY DIM (outside all scopes)
      ...                         ← HEAVY DIM

If cursor is on "value" inside the if block:
  - All "value" occurrences HIGHLIGHTED (bold + underline)
  - Even in dimmed code, "value" stands out
  - Creates visual path showing how variable flows through code


REFERENCES
----------
Config files:
- lua/plugins.lua:52-70 - Plugin configuration and setup
- lua/general.lua:157 - F6 keymap for toggle
- lua/config/treesitter.lua - TreeSitter configuration

Plugin files (modular structure):
- lua/plugins/context-highlight/init.lua - Main coordinator
- lua/plugins/context-highlight/config.lua - Configuration defaults
- lua/plugins/context-highlight/scope.lua - Scope detection (TreeSitter)
- lua/plugins/context-highlight/highlight.lua - Highlighting + dimming
- lua/plugins/context-highlight/lsp.lua - LSP integration
- lua/plugins/context-highlight/test.lua - Comprehensive test file
- lua/plugins/context-highlight/README.txt - This file

Neovim APIs used:
- vim.treesitter.get_parser() - Get TreeSitter parser for buffer
- vim.api.nvim_get_hl() - Read highlight group colors
- vim.api.nvim_set_hl() - Define new highlight groups
- vim.api.nvim_create_namespace() - Create namespaces for highlights
- vim.api.nvim_buf_add_highlight() - Add symbol highlighting
- vim.api.nvim_buf_set_extmark() - Add dimming extmarks
- vim.api.nvim_buf_clear_namespace() - Clear highlights
- vim.api.nvim_create_augroup() - Create autocommand group
- vim.api.nvim_create_autocmd() - Setup cursor movement handlers

LSP APIs used:
- vim.lsp.get_clients() - Get active LSP clients for buffer
- client.supports_method() - Check if LSP supports documentHighlight
- client.request() - Make async LSP request
- vim.lsp.util.make_text_document_params() - Create LSP params
- vim.lsp.protocol.DocumentHighlightKind - Read/Write/Text enum
- vim.schedule() - Schedule highlight application on main loop

TreeSitter APIs:
- parser:parse() - Parse buffer into syntax tree
- tree:root() - Get root node
- root:descendant_for_range() - Find node at cursor
- node:range() - Get node's line range
- node:parent() - Walk up AST
- node:type() - Get node type name
- node:iter_children() - Traverse tree
