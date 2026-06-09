;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

;;; ---------------------------------------------------------------------------
;;; Garbage collection
;;; ---------------------------------------------------------------------------
;; early-init.el raised gc-cons-threshold for startup. Restore something sane
;; once we're up, so interactive editing isn't a memory hog.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold  (* 16 1024 1024)
                  gc-cons-percentage 0.1
                  file-name-handler-alist
                  (delete-dups
                   (append file-name-handler-alist
                           my--file-name-handler-alist-original)))))

;;; ---------------------------------------------------------------------------
;;; Custom file
;;; ---------------------------------------------------------------------------
;; Keep customize-generated settings out of init.el.
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file nil t))

;;; ---------------------------------------------------------------------------
;;; Package system
;;; ---------------------------------------------------------------------------
(require 'package)
(add-to-list 'package-archives '("melpa"        . "https://melpa.org/packages/")        t)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;; use-package is built in on Emacs 29+. Default to auto-installing packages.
(require 'use-package)
(setq use-package-always-ensure   t
      use-package-always-defer    nil
      use-package-expand-minimally t)

;;; ---------------------------------------------------------------------------
;;; Local extensions
;;; ---------------------------------------------------------------------------
(add-to-list 'load-path (expand-file-name "mycode/" user-emacs-directory))
(autoload 'promela-mode "promela-mode" "Major mode for Promela." t)
(add-to-list 'auto-mode-alist '("\\.pml\\'" . promela-mode))

;;; ---------------------------------------------------------------------------
;;; Editor defaults
;;; ---------------------------------------------------------------------------
(setq inhibit-startup-message       t
      visible-bell                  t
      ring-bell-function            'ignore
      use-short-answers             t     ; replaces (defalias 'yes-or-no-p 'y-or-n-p)
      create-lockfiles              nil
      require-final-newline         t
      vc-follow-symlinks            t
      sentence-end-double-space     nil
      vc-handled-backends           '(Git)         ; skip SVN/Hg/Bzr/etc. probes
      auto-mode-case-fold           nil            ; skip second case-insensitive pass
      idle-update-delay             1.0            ; slow non-critical mode-line pollers
      process-adaptive-read-buffering nil          ; smoother LSP I/O
      read-process-output-max       (* 1024 1024)  ; 1 MB — LSP throughput
      tab-always-indent             'complete)     ; TAB indents, then completes
(setq-default indent-tabs-mode nil
              tab-width        4)

;;; ---------------------------------------------------------------------------
;;; Performance — redisplay, bidi, jit-lock, long lines
;;; ---------------------------------------------------------------------------
;; Bidirectional text: Greek is LTR (Unicode class L), so forcing LTR is safe.
;; Only RTL scripts (Arabic, Hebrew) would render logical-order with these on.
(setq-default bidi-display-reordering 'left-to-right
              bidi-paragraph-direction 'left-to-right)
(setq bidi-inhibit-bpa t)

;; Scroll/redisplay shortcuts.
(setq fast-but-imprecise-scrolling           t
      redisplay-skip-fontification-on-input  t
      auto-window-vscroll                    nil
      cursor-in-non-selected-windows         nil
      highlight-nonselected-windows          nil
      inhibit-compacting-font-caches         t)  ; keep multi-font caches in memory

;; jit-lock: fontify visible area first, finish in the background.
(setq jit-lock-defer-time   0
      jit-lock-stealth-time 2
      jit-lock-stealth-nice 0.5
      jit-lock-chunk-size   4096)

;; Long lines: enable C-level shortcuts in xdisp.c.
(setq long-line-threshold     1000
      large-hscroll-threshold 1000
      syntax-wholeline-max    1000)

(when (fboundp 'pixel-scroll-precision-mode) (pixel-scroll-precision-mode 1))
(when (fboundp 'repeat-mode)                  (repeat-mode 1))

;;; ---------------------------------------------------------------------------
;;; Built-in modes
;;; ---------------------------------------------------------------------------
(use-package savehist
  :ensure nil
  :init
  (make-directory (expand-file-name "var/" user-emacs-directory) t)
  (setq savehist-file (expand-file-name "var/history" user-emacs-directory))
  :config
  (savehist-mode 1))

(use-package recentf
  :ensure nil
  :init
  (setq recentf-save-file (expand-file-name "var/recentf" user-emacs-directory))
  :config
  (recentf-mode 1))

(use-package saveplace
  :ensure nil
  :init
  (setq save-place-file (expand-file-name "var/places" user-emacs-directory))
  :config
  (save-place-mode 1))

(use-package elec-pair
  :ensure nil
  :config
  (electric-pair-mode 1))

(use-package autorevert
  :ensure nil
  :init
  (setq global-auto-revert-non-file-buffers t
        auto-revert-verbose                 nil  ; no minibuffer spam on every revert
        auto-revert-interval                1    ; poll fallback: 1s instead of 5s
        auto-revert-avoid-polling           t    ; pure inotify, skip polling entirely
        auto-revert-check-vc-info           t)   ; refresh VC info (magit/mode-line)
  :config
  (global-auto-revert-mode 1))

(use-package whitespace
  :ensure nil
  :hook ((prog-mode   . whitespace-mode)
         (text-mode   . whitespace-mode)
         (before-save . delete-trailing-whitespace))
  :init
  ;; Only highlight whitespace in code/text buffers — global-whitespace-mode is
  ;; noisy in dired, magit, and *special* buffers.
  (setq whitespace-line-column 110
        whitespace-style       '(face trailing lines-tail)))

(use-package so-long
  :ensure nil
  :init
  (setq so-long-threshold 400
        so-long-max-lines 100)
  :config
  (global-so-long-mode 1))

;;; ---------------------------------------------------------------------------
;;; Backups / autosaves
;;; ---------------------------------------------------------------------------
(let ((backup-dir (expand-file-name "backups/" user-emacs-directory)))
  (unless (file-directory-p backup-dir)
    (make-directory backup-dir t))
  (setq backup-directory-alist         `((".*" . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,backup-dir t))
        backup-by-copying   t
        delete-old-versions t
        version-control     t
        kept-new-versions   6
        kept-old-versions   2))

;;; ---------------------------------------------------------------------------
;;; Warning suppression
;;; ---------------------------------------------------------------------------
;; Demote install/compile chatter — lands in *Warnings* but doesn't pop a window.
(with-eval-after-load 'warnings
  (dolist (type '(package bytecomp native-compiler comp))
    (add-to-list 'warning-suppress-types (list type))))

;;; ---------------------------------------------------------------------------
;;; Theme
;;; ---------------------------------------------------------------------------
(load-theme 'modus-vivendi t)

;;; ---------------------------------------------------------------------------
;;; Input methods — toggle Greek <-> system layout with C-\
;;; ---------------------------------------------------------------------------
;; C-\ is the Emacs default for toggle-input-method; set explicitly for clarity.
(setq default-input-method "greek")
(global-set-key (kbd "C-\\") #'toggle-input-method)

;;; ---------------------------------------------------------------------------
;;; Unbind C-z
;;; ---------------------------------------------------------------------------
(global-unset-key (kbd "C-z"))             ; avoid accidental suspend-frame freeze

;;; ---------------------------------------------------------------------------
;;; Third-party packages
;;; ---------------------------------------------------------------------------
(use-package gcmh
  :init
  (setq gcmh-idle-delay              'auto
        gcmh-auto-idle-delay-factor  10
        gcmh-high-cons-threshold     (* 64 1024 1024))
  :config (gcmh-mode 1))

(use-package undo-tree
  :init  (global-undo-tree-mode)
  :custom
  (undo-tree-history-directory-alist
   `(("." . ,(expand-file-name "backups/undo-tree/" user-emacs-directory)))))

(use-package ace-window
  :bind ("M-o" . ace-window))

(use-package magit
  :bind ("C-x g" . magit-status))

(use-package company
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay            0.2)
  (company-minimum-prefix-length 2))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :init (setq lsp-keymap-prefix "C-c l"))

;; File-association-only modes — :mode implies :defer t.
(use-package csv-mode      :mode "\\.csv\\'")
(use-package markdown-mode :mode ("\\.md\\'" "\\.markdown\\'"))
(use-package yaml-mode     :mode "\\.ya?ml\\'")

;;; ---------------------------------------------------------------------------
;;; LaTeX / AUCTeX
;;; ---------------------------------------------------------------------------
(use-package tex
  :ensure auctex
  :defer t
  :custom
  (TeX-engine    'luatex)
  (LaTeX-command "latexmk")
  (TeX-view-program-list '(("Zathura" ("zathura") "")))
  (TeX-view-program-selection
   '(((output-dvi has-no-display-manager) "dvi2tty")
     ((output-dvi style-pstricks) "dvips and gv")
     (output-dvi "xdvi")
     (output-pdf "Zathura")
     (output-html "xdg-open"))))

(use-package auctex-latexmk
  :after tex
  :config (auctex-latexmk-setup))

;;; ---------------------------------------------------------------------------
;;; AI agent integration
;;; ---------------------------------------------------------------------------
;; claude-code.el runs the `claude' CLI in an `eat' terminal. `:bind-keymap'
;; defers loading until the prefix is pressed, so startup cost stays zero.
(use-package inheritenv
  :vc (:url "https://github.com/purcell/inheritenv" :rev :newest)
  :defer t)

(use-package eat                       ; pure-elisp terminal backend (no compile)
  :defer t)

(use-package claude-code
  :vc (:url "https://github.com/stevemolitor/claude-code.el" :rev :newest)
  :bind-keymap ("C-c c" . claude-code-command-map)
  :bind (:repeat-map my-claude-code-map ("M" . claude-code-cycle-mode))
  :config
  (setq claude-code-terminal-backend 'eat)
  (claude-code-mode))

;;; ---------------------------------------------------------------------------
;;; Helper commands
;;; ---------------------------------------------------------------------------
(defun screenshot-svg ()
  "Save a screenshot of the current frame as an SVG image.
Saves to a temp file and puts the filename in the kill ring."
  (interactive)
  (let* ((filename (make-temp-file "Emacs" nil ".svg"))
         (data (x-export-frames nil 'svg)))
    (with-temp-file filename
      (insert data))
    (kill-new filename)
    (message filename)))

(defun delete-non-displayable ()
  "Delete characters in the buffer that have no displayable glyph."
  (interactive)
  (require 'descr-text)
  (save-excursion
    (goto-char (point-min))
    (while (not (eobp))
      (if (or (eolp)
              (looking-at "\t")
              (describe-char-display (point) (char-after)))
          (forward-char)
        (delete-char 1)))))

(provide 'init)
;;; init.el ends here
