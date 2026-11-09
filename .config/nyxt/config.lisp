;; (define-configuration buffer ((default-modes (pushnew 'nyxt/mode/emacs:emacs-mode %slot-value%))))

;; vi keybinds
(define-configuration buffer
  ((default-modes
			 (pushnew 'nyxt/mode/vi:vi-normal-mode %slot-value%))))

(define-configuration web-buffer
  ((default-modes
			 (pushnew 'nyxt/mode/blocker:blocker-mode %slot-value%))))

;; (define-configuration web-buffer
;;   ((default-modes
;;     (pushnew 'nyxt/mode/reduce-tracking:reduce-tracking-mode %slot-value%))))

(define-configuration nyxt/mode/hint:hint-mode
  ((nyxt/mode/hint:hints-alphabet "AJSKDLQUWIEOZNXMC")
   ;; (nyxt/mode/hint:show-hint-scope-p t)
   (nyxt/mode/hint:hinting-type :vi)))

(in-package #:nyxt-user)

(defvar *my-search-engines*
  (list (make-instance 'search-engine
                       :name "Google"
                       :shortcut "goo"
                       :search-url "https://google.com")
        (make-instance 'search-engine
                       :name "DuckDuckGo"
                       :shortcut "ddg"
                       :search-url "https://duckduckgo.com/?q=~a")
        (make-instance 'search-engine
                       :name "Disroot"
                       :shortcut "dis"
                       :search-url "https://search.disroot.org/search?q=~a")))

;; Set the global search engines list
(define-configuration web-buffer
  ((search-engines *my-search-engines*)))

(define-configuration browser
  ((theme (make-instance 'theme:theme
                         :dark-p t
                         :background-color "black"
                         :on-background-color "white"
                         :primary-color "rgb(170, 170, 170)"
                         :on-primary-color "black"
                         :secondary-color "rgb(100, 100, 100)"
                         :on-secondary-color "white"
                         :accent-color "#37A8E4"
                         :on-accent-color "black"))))

(define-configuration nyxt/mode/proxy:proxy-mode
     ((nyxt/mode/proxy:proxy (make-instance 'nyxt:proxy
                                            ;; :url (quri:uri "socks5://127.0.0.1:10801")
                                            :url (quri:uri "http://proxy.hq.int-sys.ru:3128")
                                            :allowlist '("localhost" "127.0.0.1")
                                            :proxied-downloads-p t))))

(define-configuration web-buffer
    ((default-modes (append '(nyxt/mode/proxy:proxy-mode blocker-mode) %slot-value%))))
