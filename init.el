;; General settings
(setq inhibit-startup-message t)	;don't show the splash screen
;;(setq visible-bell t)			;Flash when the bell rings
(tool-bar-mode -1)			;Don't show tool-bar
(scroll-bar-mode -1)			;Don't show scroll bar
(defalias 'yes-or-no-p 'y-or-n-p)	;Change requiring Yes or No to y or n when asked about something.
(savehist-mode t)			;Save history, amongst emacs sessions.
;; Whitespace & line wrapping.
(global-whitespace-mode t)
(with-eval-after-load "whitespace"
  (setq whitespace-line-column 110) ; When text flows past 110 chars, highlight it.
  ;; whitespace-mode by default highlights all whitespace. Show only tabs and trailing spaces.
  (setq whitespace-style '(face trailing lines-tail)))
(add-hook 'before-save-hook 'delete-trailing-whitespace)


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
 '(LaTeX-command "latexmk")
 '(TeX-engine 'luatex)
 '(package-selected-packages '(auctex-latexmk auctex company lsp-mode undo-tree)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
(require 'auctex-latexmk)
(auctex-latexmk-setup)
