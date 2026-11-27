;; -*- lexical-binding: t; -*-
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

(elpaca elpaca-use-package
  (elpaca-use-package-mode))

(use-package emacs
  :demand t
  :ensure nil
  :init
  (setq use-package-always-defer t)
  (setq use-package-compute-statistics t)
  (setq use-package-hook-name-suffix nil)

  ;; Turn this shi off
  (global-unset-key (kbd "<f10>"))
  (setq use-dialog-box nil)
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)
  (setq inhibit-startup-message t)
  ;; (global-hl-line-mode 1)
  (blink-cursor-mode -1)

  (setq select-enable-clipboard t)

  ;; Vim-esque
  (global-set-key (kbd "<escape>") 'keyboard-escape-quit)

  ;; Force good tabs everywhere
  (setq-default indent-tabs-mode nil)
  (setq-default tab-width 2)
  (setq-default standard-indent 2)

  (setq-default show-trailing-whitespace nil)
  (add-hook 'find-file-hook (lambda ()
                              (when buffer-file-name
                                (setq-local show-trailing-whitespace t))))
  (add-hook 'message-mode-hook (lambda ()
                                 (when (derived-mode-p 'message-mode)
                                   (setq-local show-trailing-whitespace t))))

  (setq make-backup-files nil) ; TODO: maybe move to a directory in $HOME
  (setq auto-save-default nil)
  (setq create-lockfiles nil)

  (setq scroll-conservatively 1000
        scroll-margin 10)

  (if (string-equal system-name "homestation")
      (set-frame-font "IBM Plex Mono 9" nil t)
    (set-frame-font "UW Ttyp0 9" nil t))
  (setq enable-recursive-minibuffers t)
  (setq frame-inhibit-implied-resize t)

  (setq sentence-end-double-space nil)

  ;; NO PROPORTIONAL FONTS EVER!!!
  (setq shr-use-fonts nil)

  ;; IDK if I even need this
  (set-charset-priority 'unicode)
  (setq locale-coding-system 'utf-8
        coding-system-for-read 'utf-8
        coding-system-for-write 'utf-8)
  (set-terminal-coding-system 'utf-8)
  (set-keyboard-coding-system 'utf-8)
  (set-selection-coding-system 'utf-8)
  (prefer-coding-system 'utf-8)
  (setq default-process-coding-system '(utf-8-unix . utf-8-unix))

  ;; (setq byte-compile-warnings '(not free-vars unresolved noruntime lexical make-local))
  (setq native-comp-async-query-on-exit t)
  (setq confirm-kill-processes t)
  (setq native-comp-async-report-warnings-errors t)
  (setq load-prefer-newer t)
  (setq package-native-compile t)

  (setq default-input-method 'russian-computer)

  (setq-default bidi-display-reordering 'left-to-right
                bidi-paragraph-direction 'left-to-right)
  (setq bidi-inhibit-bpa t)

  (setq redisplay-skip-fontification-on-input t)

  (setq read-process-output-max (* 8 1024 1024))

  (setq-default cursor-in-non-selected-windows nil)
  (setq highlight-nonselected-windows nil)

  ;; Don't really like when this messes up the pdf buffer width
  ;; TODO Maybe find a way to blacklist specific buffers
  (setq window-combination-resize t)

  (show-paren-mode t)

  ;; TODO Fix weird triple quote bug in eshell
  (electric-pair-mode 1))

(use-package meow
  :ensure t
  :demand t
  :config
  (setq select-enable-clipboard t
        meow-use-clipboard t)
  (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
  (meow-motion-define-key
   '("j" . meow-next)
   '("k" . meow-prev)
   '("h" . meow-left)
   '("l" . meow-right)
   '("<escape>" . ignore))
  (meow-leader-define-key
   ;; Use SPC (0-9) for digit arguments.
   '("1" . meow-digit-argument)
   '("2" . meow-digit-argument)
   '("3" . meow-digit-argument)
   '("4" . meow-digit-argument)
   '("5" . meow-digit-argument)
   '("6" . meow-digit-argument)
   '("7" . meow-digit-argument)
   '("8" . meow-digit-argument)
   '("9" . meow-digit-argument)
   '("0" . meow-digit-argument)
   '("/" . meow-keypad-describe-key)
   '("w j" . windmove-down)
   '("w k" . windmove-up)
   '("w h" . windmove-left)
   '("w l" . windmove-right)
   '("w J" . windmove-swap-states-down)
   '("w K" . windmove-swap-states-up)
   '("w H" . windmove-swap-states-left)
   '("w L" . windmove-swap-states-right)
   '("w v" . split-window-right)
   '("w s" . split-window-below)
   '("w q" . delete-window)
   '("w +" . enlarge-window)
   '("w >" . enlarge-window-horizontally)
   '("w -" . shrink-window)
   '("w <" . shrink-window-horizontally)
   '("w b" . balance-windows)
   '("b p" . next-buffer)
   '("b n" . previous-buffer)
   '("b b" . switch-to-buffer)
   '("b l" . ibuffer)
   '("b r" . rename-buffer)
   '("b x" . kill-current-buffer)
   '("?" . meow-cheatsheet))
  (meow-normal-define-key
   '("0" . meow-expand-0)
   '("9" . meow-expand-9)
   '("8" . meow-expand-8)
   '("7" . meow-expand-7)
   '("6" . meow-expand-6)
   '("5" . meow-expand-5)
   '("4" . meow-expand-4)
   '("3" . meow-expand-3)
   '("2" . meow-expand-2)
   '("1" . meow-expand-1)
   '("-" . negative-argument)
   '(";" . meow-reverse)
   '("," . meow-inner-of-thing)
   '("." . meow-bounds-of-thing)
   '("[" . meow-beginning-of-thing)
   '("]" . meow-end-of-thing)
   '("a" . meow-append)
   '("A" . meow-open-below)
   '("b" . meow-back-word)
   '("B" . meow-back-symbol)
   '("c" . meow-change)
   '("d" . meow-delete)
   '("D" . meow-backward-delete)
   '("e" . meow-next-word)
   '("E" . meow-next-symbol)
   '("f" . meow-find)
   '("g" . meow-cancel-selection)
   '("G" . meow-grab)
   '("h" . meow-left)
   '("H" . meow-left-expand)
   '("i" . meow-insert)
   '("I" . meow-open-above)
   '("j" . meow-next)
   '("J" . meow-next-expand)
   '("k" . meow-prev)
   '("K" . meow-prev-expand)
   '("l" . meow-right)
   '("L" . meow-right-expand)
   '("m" . meow-join)
   '("n" . meow-search)
   '("o" . meow-block)
   '("O" . meow-to-block)
   '("p" . meow-yank)
   '("q" . meow-quit)
   '("Q" . meow-goto-line)
   '("r" . meow-replace)
   '("R" . meow-swap-grab)
   '("s" . meow-kill)
   '("t" . meow-till)
   '("u" . meow-undo)
   '("U" . meow-undo-in-selection)
   '("v" . meow-visit)
   '("w" . meow-mark-word)
   '("W" . meow-mark-symbol)
   '("x" . meow-line)
   '("X" . meow-goto-line)
   '("y" . meow-save)
   '("Y" . meow-sync-grab)
   '("z" . meow-pop-selection)
   '("'" . repeat)
   '(">" . indent-rigidly-right-to-tab-stop)
   '("<" . indent-rigidly-left-to-tab-stop)
   '("<escape>" . ignore))
  (meow-thing-register 'angle
                       '(pair ("<") (">"))
                       '(pair ("<") (">")))
  (add-to-list 'meow-char-thing-table '(?a . angle))

  (meow-global-mode 1))

(use-package pdf-tools
  :ensure t
  :magic ("%PDF" . pdf-view-mode)
  ;; Not sure if it's really required
  :hook (pdf-view-mode-hook . (lambda ()
                                (setq-local scroll-margin 0)))
  :bind
  (:map pdf-view-mode-map
        ("s w" . my/pdf-view-fit-window-to-page))
  :config
  (setq pdf-view-use-scaling t
        pdf-view-display-size 'fit-page
        pdf-view-continuous nil)
  (defun my/pdf-view-fit-window-to-page ()
    "Resize window horizontally to page width."
    (interactive)
    (unless (derived-mode-p 'pdf-view-mode)
      (user-error "Buffer not in PDFView mode"))
    (let* ((target-width (+ (car (pdf-view-image-size t)) 4))
           (delta (window-resizable nil (- target-width (window-body-width nil t)) t nil t)))
      (window-resize nil delta t nil t)
      (window-preserve-size nil t t)))
  ;; Compiles epdfinfo if needed without prompting, and registers modes
  (pdf-tools-install :no-query))

(use-package org
  :init
  (setq org-startup-truncated nil))

;; TODO Rework sloppy code
(use-package org-clock
  :config
  (defun my/org-get-file-project-id (file)
    "Get PROJECT_ID from FILE using Org's Property API, falling back to filename."
    (with-current-buffer (find-file-noselect file)
      (or (org-entry-get (point-min) "PROJECT_ID" t)
          (file-name-base file))))

  (defun my/org-clocktable-leaf-entries (entries)
    "Return only leaf entries with positive clocked time from ENTRIES."
    (delq nil
          (cl-mapcar
           (pcase-lambda ((and entry `(,level ,_ ,_ ,_ ,mins . ,_))
                          `(,next-level . ,_))
             (and (> mins 0)
                  (or (null next-level) (<= next-level level))
                  entry))
           entries
           (append (cdr entries) '(nil)))))

  (defun my/urv-format-table (table)
    "Format all leaf entries in a single file's clocktable TABLE."
    (pcase-let* ((`(,file ,_ ,entries) table)
                 (proj-id (my/org-get-file-project-id file)))
      (mapcar (pcase-lambda ( `(,_ ,headline ,_ ,_ ,mins . ,_))
                (format "%.1f %s %s" (/ (float mins) 60.0) proj-id headline))
              (my/org-clocktable-leaf-entries entries))))

  (defun my/urv-clocktable-formatter (ipos tables _params)
    "Insert URV report at IPOS by flat-mapping =my/urv-format-table' over TABLES."
    (goto-char ipos)
    (insert (string-join (mapcan #'my/urv-format-table tables) "\n")))

  (defun my/urv-compose-report (&optional date-str)
    "Prompt for a date, generate the URV clocktable report, and draft a mu4e email."
    (interactive)
    (require 'mu4e)
    (let* ((date (or date-str (org-read-date nil nil nil "URV Report Date: ")))
           (parsed-time (org-time-string-to-time date))
           (subject (format-time-string "УРВ_%d.%m.%y" parsed-time))
           (report-body
            (with-temp-buffer
              (org-mode)
              (org-dblock-write:clocktable
               (list :scope 'agenda
                     :block date
                     :formatter #'my/urv-clocktable-formatter))
              (string-trim (buffer-string)))))
      (if (string-empty-p report-body)
          (user-error "No clocked time found in agenda files for %s" date)
        (mu4e-context-switch nil "int-sys")
        (compose-mail "time@int-sys.ru" subject)
        (message-goto-body)
        (insert report-body "\n")))))

(use-package ob-shell
  :defer t
  :commands (org-babel-execute:sh
             org-babel-execute:bash
             org-babel-execute:zsh
             org-babel-execute:fish
             org-babel-execute:dash)
  :config
  (setq org-babel-sh-prompt ">>> "))

(use-package org-inlinetask
  :commands
  org-inlinetask-insert-task)

(use-package eshell
  :commands eshell
  :after meow
  :init
  (meow-leader-define-key
   '("t" . eshell))
  :init
  (setq eshell-visual-commands '())
  (setq eshell-visual-subcommands '())
  (setq eshell-visual-options '())
  (setq eshell-scroll-to-bottom-on-input t)
  (setq eshell-history-size 10000)
  (setq eshell-save-history-on-exit t)
  (setq eshell-hist-ignoredups t))

(use-package esh-module
  :after eshell
  :config
  (add-to-list 'eshell-modules-list 'eshell-tramp)
  (add-to-list 'eshell-modules-list 'eshell-elecslash))

;; TODO revise all the supposed performance enhancements copy-pasted from the web
(use-package tramp
  :config
  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process)

  (setq remote-file-name-inhibit-locks t
        tramp-use-scp-direct-remote-copying t
        remote-file-name-inhibit-auto-save-visited t)
  (setq tramp-use-connection-share nil))

;; TODO fix lazy load
(use-package incus-tramp
  :ensure t
  :demand t
  :after tramp
  :config
  (incus-tramp-add-method)
  (tramp-set-completion-function incus-tramp-method
                                 '((incus-tramp-completion-function-alist))))

;; Lazy loads perfectly on eshell start
(use-package eat
  :ensure t
  :defer t
  :demand nil
  :commands eat
  :hook ((eshell-load-hook . eat-eshell-mode)
         (eat-exec-hook . (lambda (_) (eat-char-mode))))
  :config
  (setq eat-term-name "xterm-256color"))

;; Lazy loads perfectly, but the colors are dependent on the theme
;; (currently marquardt), so maybe find a way to move them to the
;; theme block
(use-package avy
  :ensure t
  :commands avy-goto-char-2
  :config
  (set-face-attribute 'avy-lead-face nil
                      :background "NavyBlue"
                      :foreground "bisque")
  (set-face-attribute 'avy-lead-face-0 nil
                      :background "steelblue"
                      :foreground "bisque")
  (set-face-attribute 'avy-goto-char-timer-face nil
                      :background "NavyBlue"
                      :foreground "bisque")
  :init
  (setq avy-background t)
  (setq avy-keys (number-sequence ?a ?z))
  (meow-motion-define-key
   '("F" . avy-goto-char-timer))
  (meow-normal-define-key
   '("F" . avy-goto-char-timer)))

(use-package vertico
  :hook
  (minibuffer-mode-hook . vertico-mode-enable-once)
  :init
  (defun vertico-mode-enable-once () (vertico-mode)
         (remove-hook 'minibuffer-mode-hook #'vertico-mode-enable-once ))
  :ensure t)

;; TODO find way to lazy load this on first C-n input
(use-package corfu
  :commands completion-at-point
  :ensure t
  :after meow
  :bind
  (:map meow-insert-state-keymap
        ("C-n" . completion-at-point)
        :map corfu-map
        ("C-n" . corfu-next)
        ("C-p" . corfu-previous)
        ("C-y" . corfu-complete))
  :config
  (set-face-attribute 'corfu-default nil
                      :background "bisque3")
  (set-face-attribute 'corfu-current nil
                      :background "bisque")
  (global-corfu-mode))

(use-package dired
  :hook
  (dired-mode-hook . dired-hide-details-mode)
  :config
  (defvar dired-dedicated-other-window nil
    "A window marked to display files opened in dired.")

  (defun my/dired-mark-window ()
    "Marks currently selected window as preferred for dired"
    (interactive)
    (setq dired-dedicated-other-window (or (selected-window) dired-dedicated-other-window)))

  (defun my/dired-find-file-marked-window (&optional focus)
    "Opens a file in a remembered window or creates one if necessary. Switches focus if optional arg is not nil."
    (interactive)
    (if (not (window-valid-p dired-dedicated-other-window))
        (setq dired-dedicated-other-window (or (window-in-direction 'below)
                                               (window-in-direction 'right)
                                               (next-window)
                                               (split-window-vertically))))
    (set-window-buffer dired-dedicated-other-window (find-file-noselect (dired-get-file-for-visit)))
    (if focus (select-window dired-dedicated-other-window)))

  (add-to-list 'display-buffer-alist
               (cons "\\*Async Shell Command\\*.*" (cons #'display-buffer-no-window nil)))

  (setq async-shell-command-buffer "rename-buffer")

  (setq dired-guess-shell-alist-user
        (append '(("\\.\\(jpe?g\\|png\\|gif\\|bmp\\|webp\\|svg\\)$" "swayimg")
                  ("\\.\\(pdf\\|djvu\\|ps\\)$" "zathura")
                  ("\\.\\(docx?\\|xlsx?\\|pptx?\\|f?od\\(t\\|s\\|p\\|g\\|f\\)\\)$" "libreoffice --norestore --nologo")
                  ("\\.\\(mp4\\|mkv\\|avi\\|mov\\|wmv\\|flv\\|mpg\\)$" "mpv"))
                dired-guess-shell-alist-user))

  (defun my/dired-open ()
    "Open dired marked files in an external program according to `shell-command-guess'
Show an error message and exit if no matching shell command is found"
    (interactive)
    (let* ((files (dired-get-marked-files t current-prefix-arg nil nil t))
           (shell-command-list (shell-command-guess files)))
      (message "%s" shell-command-list)
      (if (null shell-command-list)
          (message "No open command associated with %s" files)
        (message "Trying to open %s with %s" files (car shell-command-list))
        (dired-do-async-shell-command (car shell-command-list) "" files))))

  (meow-leader-define-key
   '("d m" . my/dired-mark-window))
  (keymap-set dired-mode-map "-" 'dired-up-directory)
  (keymap-set dired-mode-map "E" 'my/dired-open)
  (keymap-set dired-mode-map "o" 'my/dired-find-file-marked-window)
  (keymap-set dired-mode-map "C-o" (lambda () (interactive) (dired-find-file-marked-window t))))

(use-package eglot
  :config
  (setq eldoc-echo-area-prefer-doc-buffer t)
  ;; Long timeout specifically for slow cold startup julia LSP
  (setq eglot-connect-timeout 120)
  (setq eglot-ignored-server-capabilities '(:inlayHintProvider)))

(use-package color-theme-modern
  :ensure t
  :init
  (load-theme 'marquardt t)
  ;; This fixes the specifically ugly white fringes in an otherwise
  ;; beautiful marquardt theme
  (set-face-attribute 'fringe nil
                      :foreground nil
                      :background "bisque2")
  (set-face-attribute 'variable-pitch nil
                      :family 'unspecified
                      :inherit 'default)
  (set-face-attribute 'fixed-pitch nil
                      :family 'unspecified
                      :inherit 'default)
  (set-face-attribute 'fixed-pitch-serif nil
                      :family 'unspecified
                      :inherit 'default))

;; TODO This is required to kill the ugly font faces in the mu4e
;; buffers that use gnus-art under the hood. Needs some work to make
;; sure all ugly faces are reset.
(use-package gnus-art
  :after color-theme-modern
  :config
  (dolist (face (face-list))
    (when (string-match-p "^\\(gnus\\|message\\|mu4e\\|shr\\)-" (symbol-name face))
      (set-face-attribute face nil :family 'unspecified :height 'unspecified))))

(use-package pinentry
  :ensure t
  :init
  (pinentry-start))

(use-package diff-hl-mode
  :ensure
  (:host github :repo "dgutov/diff-hl" :main "diff-hl.el")
  :commands diff-hl-mode
  :after color-theme-modern
  :hook
  (dired-mode-hook . diff-hl-dired-mode)
  (vc-dir-mode-hook . turn-on-diff-hl-mode)
  :init
  (meow-leader-define-key
   '("v v" . diff-hl-mode)
   '("v s" . diff-hl-stage-dwim))
  :config
  (setq diff-hl-show-staged-changes nil)
  (set-face-attribute 'diff-hl-insert nil
                      :foreground nil
                      :background "ForestGreen")
  (set-face-attribute 'diff-hl-change nil
                      :foreground nil
                      :background "DarkGoldenrod")
  (set-face-attribute 'diff-hl-delete nil
                      :foreground nil
                      :background "Orchid"))

(use-package mm-decode
  :config
  (add-to-list 'mm-discouraged-alternatives "image/.*" t)
  (add-to-list 'mm-discouraged-alternatives "text/html" t)
  (add-to-list 'mm-discouraged-alternatives "text/richtext" t))

(use-package password-store
  :ensure t
  :defer t)

(use-package gptel
  :ensure t
  :defer t
  :after meow
  :preface
  (defun routerai-key ()
    "RouterAI API key"
    (require 'password-store)
    (string-trim (password-store-get "routerai.ru/api-key-corporate")))
  :init
  (setq gptel-default-mode 'org-mode
        gptel-stream t)
  (meow-leader-define-key
   '("a a" . gptel)
   '("a c" . gptel-add)
   '("a r" . gptel-mode))
  :config
  (setq gptel-display-buffer-action '(display-buffer-same-window)
        gptel-model '~google/gemini-pro-latest
        gptel-backend
        (gptel-make-openai "RouterAI"
          :host "routerai.ru"
          :endpoint "/api/v1/chat/completions"
          :protocol "https"
          :stream t
          :key #'routerai-key
          :models '(~deepseek/deepseek-v4-pro-latest
                    ~google/gemini-pro-latest)
          :request-params '(:plugins [(:id "web" :max_results 5)])))
  (setf (alist-get 'org-mode gptel-prompt-prefix-alist) "** "
        (alist-get 'org-mode gptel-response-prefix-alist) "** AI response\n"
        (alist-get 'default gptel-directives)
        "You are an AI assistant living inside Emacs. Be very concise and
straight to the point in your responses. Don't try to have a
conversation or ever respond with a question. Always format responses in
Markdown, even if you see org-mode syntax in conversation history. You
responses are being converted to org-mode by a postprocessor.")
  (defun my/gptel-org-fix-response-headers (beg end)
    (when (and (derived-mode-p 'org-mode) (< beg end))
      (save-excursion
        (let ((end-marker (copy-marker end))
              (min-level nil)
              (start-pos beg))
          (goto-char beg)
          (when (looking-at "^** AI response")
            (forward-line 1)
            (setq start-pos (point)))
          (while (re-search-forward "^\\(\\*+\\) " end-marker t)
            (unless (org-in-src-block-p)
              (let ((level (length (match-string 1))))
                (setq min-level (if min-level (min min-level level) level)))))
          (when min-level
            (let ((shift (max (- 3 min-level) 0)))
              (when (> shift 0)
                (let ((starts (make-string shift ?*)))
                  (goto-char start-pos)
                  (while (re-search-forward "^\\(\\*+\\) " end-marker t)
                    (unless (org-in-src-block-p)
                      (replace-match (concat stars "\\1") t nil nil 1)))))))
          (set-marker end-marker nil))))))

(use-package gptel-context
  :ensure nil
  :config
  (set-face-attribute 'gptel-context-highlight-face nil
                      :background 'unspecified
                      :foreground 'unspecified
                      :inherit nil
                      :extend nil))

(use-package mu4e
  :commands mu4e-transient-menu
  :after meow
  :init
  (meow-leader-define-key
   '("e m" . mu4e-transient-menu))
  :config
  (setq mu4e-split-view 'single-window)
  (setq mu4e-compose-switch 'window)
  (add-to-list 'display-buffer-alist
               '("\\*mu4e-.*"
                 (display-buffer-same-window)))

  (setq mail-user-agent 'mu4e-user-agent)
  (setq mu4e-maildir "~/mail")

  (setq mu4e-get-mail-command "mbsync -a"
        mu4e-index-lazy-check nil       ; Maybe do it lazily and make it do a non-lazy
                                        ; update based on a timer somewhere in the
                                        ; mu4e-update-pre-hook
        mu4e-update-interval nil)

  (setq mu4e-contexts
        (list
         (make-mu4e-context
          :name "int-sys"
          :match-func
          (lambda (msg)
            (when msg
              (string-prefix-p "/int-sys" (mu4e-message-field msg :maildir))))
          :vars '((user-mail-address            . "g.cherdakly@int-sys.ru")
                  (user-full-name               . "Герман Чердакли")
                  (mu4e-inbox-folder            . "/int-sys/INBOX")
                  (mu4e-drafts-folder           . "/int-sys/Drafts")
                  (mu4e-sent-folder             . "/int-sys/Sent")
                  (mu4e-trash-folder            . "/int-sys/Trash")
                  (smtpmail-smtp-user           . "g.cherdakly")
                  (smtpmail-smtp-server         . "smtp.int-sys.ru")
                  (smtpmail-default-smtp-server . "smtp.int-sys.ru")
                  (smtpmail-smtp-service        . 465)
                  (smtpmail-stream-type         . 'tls)
                  ))))

  (setq mu4e-context-policy 'ask)

  (setq mu4e-attachment-dir "~/downloads")

  (setq sendmail-program           "/usr/bin/msmtp"
        send-mail-function         'sendmail-send-it
        message-send-mail-function 'sendmail-send-it)

  (add-to-list
   'mu4e-view-actions '("ViewBrowser" . mu4e-action-view-in-browser) t)

  :hook
  ((mu4e-compose-mode-hook . (lambda ()
                               (set-fill-column 72)))
   (dired-mode  . turn-on-gnus-dired-mode)))


(use-package compile-angel
  :ensure t
  :demand t
  :hook
  (emacs-lisp-mode-hook . compile-angel-on-save-local-mode)
  :config
  (setq compile-angel-verbose nil)
  (push "/init.el" compile-angel-excluded-path-suffixes)
  (push "/early-init.el" compile-angel-excluded-path-suffixes)
  (compile-angel-on-load-mode 1))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auth-source-save-behavior nil)
 '(custom-safe-themes
   '("623e9fe0532cc3a0bb31929b991a16f72fad7ad9148ba2dc81e395cd70afc744"
     "0f691b0fef27fdeffb52131f21914b6819044659c785109060dbfb72d6b38246"
     default))
 '(org-agenda-files
   '("~/org/work/orgvopros.org"
     "~/org/work/bokino.org")))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
