;;; early-init.el --- Pre-init startup tweaks -*- lexical-binding: t; -*-

;; Bump GC during startup; init.el restores a sane value afterward.
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)

;; Defer file-name-handler-alist — major startup win on configs that load
;; many .el files. init.el restores it on emacs-startup-hook.
(defvar my--file-name-handler-alist-original file-name-handler-alist)
(setq file-name-handler-alist nil)

;; Suppress UI elements *before* they are drawn (no flash, faster startup).
(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(fullscreen . maximized) default-frame-alist)

;; Don't resize the frame when fonts load.
(setq frame-inhibit-implied-resize t)

;; Faster package loading via the quickstart autoloads file
;; (refreshed automatically when packages change).
(setq package-quickstart t)

;; Skip site-init files; init.el owns all configuration.
(setq site-run-file nil)
