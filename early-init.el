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

;; Don't resize the frame when fonts load; resize by pixel, not by char cell.
(setq frame-inhibit-implied-resize t
      frame-resize-pixelwise       t)

;; Faster package loading via the quickstart autoloads file
;; (refreshed automatically when packages change).
(setq package-quickstart t)

;; Skip site-init files and the system-wide default.el.
(setq site-run-file        nil
      inhibit-default-init t)

;; --- Native compilation ----------------------------------------------------
;; Speed 2 is the highest level still safe with arbitrary elisp.
;; Speed 3 will silently miscompile any package that advises or redefines
;; built-ins, and many do.
(when (and (fboundp 'native-comp-available-p) (native-comp-available-p))
  (setq native-comp-speed                        2
        native-comp-jit-compilation              t      ; background JIT (default)
        native-comp-async-report-warnings-errors 'silent
        package-native-compile                   t      ; AOT compile at install
        load-prefer-newer                        nil))  ; don't bypass .eln

;; A handful of packages misbehave under JIT native-compilation. The deny-list
;; lives in `comp-run' on Emacs 30 (was `comp' on 29); load it lazily.
(with-eval-after-load 'comp-run
  (dolist (re '("/with-editor\\.el\\'"
                "/vterm\\.el\\'"))
    (add-to-list 'native-comp-jit-compilation-deny-list re)))
