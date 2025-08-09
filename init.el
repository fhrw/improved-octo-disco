;;; init.el --- Emacs configuration

;;; Package archives
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)

;;; Bootstrap use-package if missing
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

;;; UI tweaks
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(load-theme 'modus-vivendi-deuteranopia t)
(global-auto-revert-mode +1)

;; Set default font to Iosevka
(set-face-attribute 'default nil
                    :family "Iosevka"
                    :height 140) ;; 120 = 12pt, adjust as needed

;; Optional: ensure new frames also use it
(add-to-list 'default-frame-alist '(font . "Iosevka-14"))

;;; Basic settings
(setq inhibit-startup-message t
      custom-file "~/.emacs.d/custom-file.el"
      ring-bell-function 'ignore
      select-enable-clipboard t
      backup-directory-alist '(("." . "~/.emacs.d/.saves")))

(when (file-exists-p custom-file)
  (load-file custom-file))

(toggle-truncate-lines +1)
(electric-pair-mode 1)

(use-package modus-themes
  :ensure t)

;;; Vertico & completion setup
(use-package vertico
  :ensure t
  :init (vertico-mode)
  :custom (vertico-cycle t))

(use-package savehist
  :ensure t
  :init (savehist-mode))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles basic partial-completion)))))

;;; Window management
(use-package ace-window
  :ensure t)

;;; Consult
(use-package consult
  :ensure t)

;;; Evil setup — loaded early but deferred activation
(use-package evil
  :ensure t
  :init
  ;; Set Evil settings before loading
  (setq evil-want-keybinding nil)
  (setq evil-want-C-u-scroll t)
  (setq evil-undo-system 'undo-redo)
  :config
  (evil-mode 1))  ;; Enable Evil mode once everything is ready

(use-package evil-collection
  :ensure t
  :after evil
  :custom (evil-collection-setup-minibuffer t)
  :config
  ;; Optional: prevent known corfu conflicts
  (setq evil-collection-company-use-tng nil)
  (evil-collection-init))

(use-package evil-surround
  :ensure t
  :after evil
  :config (global-evil-surround-mode 1))

(use-package key-chord
  :ensure t
  :after evil
  :config
  (key-chord-mode 1)
  (key-chord-define evil-insert-state-map "jk" 'evil-normal-state))

;;; General for keybindings
(use-package general
  :ensure t
  :after evil
  :config
  (general-evil-setup)
  (general-auto-unbind-keys)
  (general-define-key
   :states '(normal visual motion emacs)
   :keymaps 'override
   :prefix-map 'uni-map
   :prefix "SPC"
   :non-normal-prefix "M-SPC")

  (general-create-definer fhrw/uni-def
    :states '(normal visual motion emacs)
    :keymaps 'override
    :prefix "SPC"
    :non-normal-prefix "M-SPC")

  (fhrw/uni-def
    "x" '("M-x" . execute-extended-command)
    "o" '("Other window" . ace-window)
    "sv" '("Vertical split" . evil-window-vsplit)
    "sh" '("Horizontal split" . evil-window-split)
    "q" '("Delete Window" . evil-window-delete)
    "j" '("Jump to char" . avy-goto-char)
    "b" '("change to buffer" . consult-buffer)
    "kb" '("kill buffer" . kill-current-buffer)
    "SPC" '("find file in project" . project-find-file)
    "g" '("ripgrep" . consult-ripgrep)
    "w" '("save" . save-buffer)
    "n" '("next warning" . flymake-goto-next-error)
    "p" '("previous warning" . flymake-goto-prev-error)
    "c" '("LSP code actions" . eglot-code-actions))

  (general-define-key
   :states 'normal
   :keymaps 'override
   "K" 'eldoc-box-help-at-point))

;;; Corfu setup
(use-package corfu
  :ensure t
  :after evil  ;; ← This helps avoid early conflicts
  :custom
  (corfu-auto t)
  (corfu-cycle t)
  (corfu-auto-prefix 1)
  :init
  (global-corfu-mode))

;;; Cape — don't trigger early
(use-package cape
  :ensure t
  :defer t
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file))

(use-package eldoc-box)

(use-package eglot
  :ensure t
  :commands (eglot eglot-ensure)
  :config
  (setq-default eglot-workspace-configuration
                '((haskell
                   (plugin
                    (stan
                     (globalOn . :json-false))))))  ;; disable stan
  (add-to-list 'eglot-server-programs
	       '(purescript-mode . ("purescript-language-server" "--stdio"))))

(use-package consult-eglot
  :ensure t
  :after (consult eglot))

(use-package paredit
  :ensure t
  :hook ((emacs-lisp-mode
          lisp-mode
          lisp-interaction-mode
          scheme-mode
          clojure-mode
          ;; add other Lisp modes you use here
          )
         . paredit-mode))

(use-package envrc
  :ensure t
  :hook
  (after-init . envrc-global-mode))


(use-package slime
  :ensure t)

(setq inferior-lisp-program "sbcl")

(setq org-default-notes-file "~/org/inbox.org")

(use-package org-pomodoro
  :ensure t)

(use-package haskell-mode
  :ensure t
  :hook
  ((haskell-mode . eglot-ensure)))

(use-package consult-hoogle
  :ensure t)

(use-package ormolu
  :ensure t)

(use-package purescript-mode
  :ensure t
  :mode "\\.purs\\'"
  :hook
  ((purescript-mode . turn-on-purescript-indentation)
   (purescript-mode . eglot-ensure)))

(provide 'init)
;;; init.el ends here
