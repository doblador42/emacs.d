;; General settings
(setq inhibit-startup-message t)	;don't show the splash screen
;;(setq visible-bell t)			;Flash when the bell rings
(tool-bar-mode -1)			;Don't show tool-bar
(scroll-bar-mode -1)			;Don't show scroll bar
;; (custom-set-variables
 ;; '(initial-frame-alist (quote ((fullscreen . maximized)))))

;; Themes
(load-theme 'modus-vivendi t)		;Load the modus vivendi theme
;; (load-theme 'ef-theme t)

;; Programming
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(lsp-mode undo-tree)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
