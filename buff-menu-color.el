;;; buff-menu-color.el --- Colorize Buffer Menu buffers -*- lexical-binding: t -*-

;; Copyright (C) 2020 by Masahiro Nakamura

;; Author: Masahiro Nakamura <tsuucat@icloud.com>
;; Version: 0.1.1
;; URL: https://github.com/tsuu32/buff-menu-color
;; Package-Requires: ((emacs "26.1"))
;; Keywords: convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;; This package colorize Buffer Menu buffers.

;; To use this package, add following code to your init file:
;;
;;  (buff-menu-color-mode)

;; This package is based on
;; https://gist.github.com/s-fubuki/551f1ba58dc4bd202665a19d588ca40e.
;; See https://qiita.com/s-fubuki/items/d2d2d831ef336a247d02 (in Japanese).

;;; Code:

(defgroup buff-menu-color nil
  "Colorize Buffer Menu buffers."
  :group 'Buffer-menu)

(defface buff-menu-color-tramp
  '((((class color) (background light))
     :foreground "#110099")
    (((class color) (background dark))
     :foreground "#7B6BFF"))
  "Face used by Buffer Menu for tramp.")
(defvar buff-menu-color-tramp-face 'buff-menu-color-tramp
  "Face name used by Buffer Menu for tramp.")

(defface buff-menu-color-dired
  '((t :inherit font-lock-function-name-face))
  "Face used by Buffer Menu for directory.")
(defvar buff-menu-color-dired-face 'buff-menu-color-dired
  "Face name used by Buffer Menu for directory.")

(defface buff-menu-color-scratch
  '((t :inherit font-lock-doc-face))
  "Face used by Buffer Menu for scratch.")
(defvar buff-menu-color-scratch-face 'buff-menu-color-scratch
  "Face name used by Buffer Menu for scratch.")

(defface buff-menu-color-shell
  '((t :inherit minibuffer-prompt))
  "Face used by Buffer Menu for shell.")
(defvar buff-menu-color-shell-face 'buff-menu-color-shell
  "Face name used by Buffer Menu for shell.")

(defface buff-menu-color-nonfile-buffer
  '((t :inherit shadow))
  "Face used by Buffer Menu for nonfile buffer.")
(defvar buff-menu-color-nonfile-buffer-face 'buff-menu-color-nonfile-buffer
  "Face name used by Buffer Menu for nonfile buffer.")

(defface buff-menu-color-magit
  '((t :foreground "#F14E32"))
  "Face used by Buffer Menu for magit.")
(defvar buff-menu-color-magit-face 'buff-menu-color-magit
  "Face name used by Buffer Menu for magit.")

(defface buff-menu-color-read-only
  '((t :inherit font-lock-constant-face))
  "Face used by Buffer Menu for read-only file.")
(defvar buff-menu-color-read-only-face 'buff-menu-color-read-only
  "Face name used by Buffer Menu for read-only file.")

(defcustom buff-menu-color-font-lock-keywords
  '((".*\\(/.+:.+:.+\\)"
     (0 buff-menu-color-tramp-face))
    ("^....\\(.+\\)\s+\\([0-9]+\\)\s\\(Dired\s\\(by\sname\\|by\sdate\\|.*\\)\\)\s.*"
     (1 buff-menu-color-dired-face)
     (2 buff-menu-color-dired-face)
     (3 buff-menu-color-dired-face))
    ("^....\\(.+\\)\s+\\([0-9]+\\)\sMagit.*"
     (0 buff-menu-color-magit-face))
    ("^....[*]e?shell.*"
     (0 buff-menu-color-shell-face))
    (".*\\(\\*scratch\\*\\)\s+\\([0-9]+\\)+.*"
     (0 buff-menu-color-scratch-face))
    ("^....\\(\\*.*\\)\s+\\([0-9]+\\).*"
     (0 buff-menu-color-nonfile-buffer-face)))
  "Font lock keywords to highlight `Buffer-menu-mode' buffers."
  ;; FIXME: improve value-type.
  :type '(repeat
          (choice (regexp :tag "matcher")
                  (cons :tag "(matcher . facename)" regexp symbol)
                  (cons :tag "(matcher highlight ...)" regexp sexp)))
  :initialize #'custom-initialize-default
  :set #'buff-menu-color-font-lock-keywords--setter)

(defun buff-menu-color-font-lock-keywords--setter (sym val)
  (set-default sym val)
  ;; Refresh Buffer Menu buffers' font lock.
  (dolist (b (buffer-list))
    (with-current-buffer b
      (when (derived-mode-p 'Buffer-menu-mode)
        (font-lock-refresh-defaults)))))

(defun buff-menu-color--Buffer-menu--pretty-name (name)
  (propertize name 'mouse-face 'highlight))

(defun buff-menu-color--set-font-lock-defaults ()
  (setq-local font-lock-defaults
              '(buff-menu-color-font-lock-keywords t)))

;;;###autoload
(define-minor-mode buff-menu-color-mode
  "Toggle Buffer Menu color mode on or off.
Turn Buffer Menu color mode on if ARG is positive, off otherwise.
Turning on Buffer Menu color mode colorize `buffer-menu', `list-buffers'
and `electric-buffer-list' buffers."
  :global t
  (if buff-menu-color-mode
      ;; Enable
      (progn
        (advice-add 'Buffer-menu--pretty-name :override
                    #'buff-menu-color--Buffer-menu--pretty-name)
        (add-hook 'Buffer-menu-mode-hook #'buff-menu-color--set-font-lock-defaults))
    ;; Disable
    (advice-remove 'Buffer-menu--pretty-name
                   #'buff-menu-color--Buffer-menu--pretty-name)
    (remove-hook 'Buffer-menu-mode-hook #'buff-menu-color--set-font-lock-defaults)))

(provide 'buff-menu-color)

;; Local Variables:
;; indent-tabs-mode: nil
;; End:

;;; buff-menu-color.el ends here
