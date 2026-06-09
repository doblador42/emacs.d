# Emacs Configuration

A personal, performance-tuned GNU Emacs configuration for Linux with native compilation, LSP scaffolding, LaTeX, and a Greek/English input toggle.

## What's inside

- **Native compilation tuning** — `early-init.el` enables AOT + background JIT at `native-comp-speed` 2, with a deny-list for packages that misbehave under JIT.
- **Startup optimizations** — deferred `file-name-handler-alist`, raised GC threshold during init, `package-quickstart`, and `gcmh` for adaptive GC. Sub-second startup on modern hardware.
- **`use-package`** with `use-package-always-ensure` for declarative, auto-installing package configuration.
- **`modus-vivendi`** dark theme.
- **Magit** for Git, bound to `C-x g`.
- **LSP scaffolding** — `lsp-mode` with the `C-c l` prefix, `company` for completion, and tuned `read-process-output-max` for throughput.
- **AUCTeX** with `luatex` as the engine, `latexmk` as the build command, and Zathura for PDF viewing. `auctex-latexmk` wires the two together.
- **Greek/English input toggle** on `C-\` via the built-in `greek` input method.
- **`claude-code.el`** integration — invokes the `claude` CLI in an `eat` terminal buffer under the `C-c c` prefix.
- **Quality-of-life** — `ace-window`, `undo-tree`, `recentf`, `savehist`, `save-place`, `electric-pair-mode`, `so-long`, pixel-precision scrolling, and file-association modes for CSV / Markdown / YAML.

## Prerequisites

- **Emacs 30+** built with native compilation (`--with-native-compilation`).
- **Linux** — paths and external tools (Zathura, latexmk) assume a Linux environment.
- **`claude` CLI** on `$PATH` for the `claude-code.el` integration.
- **Network access** to MELPA on first launch.
- Optional: a TeX Live install (with `latexmk` and `lualatex`) for AUCTeX, and `zathura` for PDF preview.

## Installation

```bash
git clone https://github.com/ermisdoulos/emacs-config ~/.config/emacs
emacs
```

On first launch the package system refreshes MELPA and installs every `use-package` declaration automatically. Subsequent launches use the cached, natively-compiled `.eln` files.

## Customization notes

- `custom.el` (settings written by `M-x customize`) is `.gitignore`d — keep machine-specific tweaks there.
- `var/` holds runtime state: `history`, `recentf`, `places`.
- `backups/` holds backup files, autosaves, and the `undo-tree` history.
- Local Elisp lives under `mycode/` (e.g. `promela-mode`) and is added to `load-path` automatically.

## Keybindings

| Key           | Command                  | Notes                                |
|---------------|--------------------------|--------------------------------------|
| `M-o`         | `ace-window`             | Jump between windows                 |
| `C-x g`       | `magit-status`           | Git status buffer                    |
| `C-\`         | `toggle-input-method`    | Switch between Greek and system layout |
| `C-c c`       | `claude-code-command-map`| Prefix for `claude-code.el`          |
| `C-c l`       | `lsp-command-map`        | Prefix for `lsp-mode`                |

## License

MIT — Ermis Doulos
