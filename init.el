;;; init.el --- Personal Emacs configuration -*- lexical-binding: t; -*-

;;; ---------------------------------------------------------------------------
;;; Garbage collection
;;; ---------------------------------------------------------------------------
;; early-init.el raised gc-cons-threshold for startup. Restore something sane
;; once we're up, so interactive editing isn't a memory hog.
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

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
(setq use-package-always-ensure  t
      use-package-always-defer   nil
      use-package-expand-minimally t)

;;; ---------------------------------------------------------------------------
;;; Local extensions
;;; ---------------------------------------------------------------------------
(add-to-list 'load-path (expand-file-name "mycode/" user-emacs-directory))
(autoload 'promela-mode "promela-mode" "Major mode for Promela." t)
(add-to-list 'auto-mode-alist '("\\.pml\\'" . promela-mode))

;;; ---------------------------------------------------------------------------
;;; General UI / behavior
;;; ---------------------------------------------------------------------------
(setq inhibit-startup-message t
      visible-bell            t
      ring-bell-function      'ignore
      use-short-answers       t      ; replaces (defalias 'yes-or-no-p 'y-or-n-p)
      create-lockfiles        nil
      require-final-newline   t
      vc-follow-symlinks      t
      sentence-end-double-space nil
      read-process-output-max (* 1024 1024)  ; 1 MB — helps LSP throughput
      native-comp-async-report-warnings-errors 'silent)
(setq-default indent-tabs-mode nil
              tab-width        4)
(setq tab-always-indent 'complete)     ; TAB indents, then completes

;; Keep state files (savehist, recentf, save-place) out of the repo root.
(setq savehist-file   (expand-file-name "var/history"   user-emacs-directory)
      recentf-save-file (expand-file-name "var/recentf" user-emacs-directory)
      save-place-file (expand-file-name "var/places"    user-emacs-directory))
(make-directory (expand-file-name "var/" user-emacs-directory) t)

(savehist-mode      1)
(recentf-mode       1)
(save-place-mode    1)
(electric-pair-mode 1)

;; Demote one-time install/compile chatter so it doesn't pop a window.
;; (Lands in *Warnings* if you want to inspect it.)
(with-eval-after-load 'warnings
  (dolist (type '(package bytecomp native-compiler comp))
    (add-to-list 'warning-suppress-types (list type))))
(global-auto-revert-mode 1)
(setq global-auto-revert-non-file-buffers t)
(when (fboundp 'pixel-scroll-precision-mode) (pixel-scroll-precision-mode 1))
(when (fboundp 'repeat-mode)                  (repeat-mode 1))
(global-unset-key (kbd "C-z"))         ; avoid accidental suspend-frame freeze

;;; ---------------------------------------------------------------------------
;;; Input methods — toggle Greek <-> system layout with C-\
;;; ---------------------------------------------------------------------------
;; C-\ is the Emacs default for toggle-input-method; set explicitly for clarity.
(setq default-input-method "greek")
(global-set-key (kbd "C-\\") #'toggle-input-method)

;; Send backups and autosaves to one directory instead of strewing them around.
(let ((backup-dir (expand-file-name "backups/" user-emacs-directory)))
  (unless (file-directory-p backup-dir)
    (make-directory backup-dir t))
  (setq backup-directory-alist         `((".*" . ,backup-dir))
        auto-save-file-name-transforms `((".*" ,backup-dir t))
        backup-by-copying t
        delete-old-versions t
        version-control     t
        kept-new-versions   6
        kept-old-versions   2))

;;; ---------------------------------------------------------------------------
;;; Whitespace
;;; ---------------------------------------------------------------------------
;; Only highlight whitespace in code/text buffers — global-whitespace-mode is
;; noisy in dired, magit, and *special* buffers.
(setq whitespace-line-column 110
      whitespace-style       '(face trailing lines-tail))
(add-hook 'prog-mode-hook #'whitespace-mode)
(add-hook 'text-mode-hook #'whitespace-mode)
(add-hook 'before-save-hook #'delete-trailing-whitespace)

;;; ---------------------------------------------------------------------------
;;; Theme
;;; ---------------------------------------------------------------------------
(load-theme 'modus-vivendi t)

;;; ---------------------------------------------------------------------------
;;; Packages
;;; ---------------------------------------------------------------------------
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
  (company-idle-delay     0.2)
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
