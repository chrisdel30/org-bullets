;;; org-bullets.el --- Show bullets in org-mode as UTF-8 characters
;;; Version: 0.1
;;; Author: sabof
;;; URL: https://github.com/sabof/org-bullets

;; This file is NOT part of GNU Emacs.
;;
;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 3, or (at
;; your option) any later version.
;;
;; This program is distributed in the hope that it will be useful, but
;; WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
;; General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program ; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 59 Temple Place - Suite 330,
;; Boston, MA 02111-1307, USA.

;;; Commentary:

;; The project is hosted at https://github.com/sabof/org-bullets
;; The latest version, and all the relevant information can be found there.

;;; Code:

(eval-when-compile (require 'cl))

(defgroup org-bullets nil
  "Use different background for even and odd lines."
  :group 'org-appearance)

;; A nice collection of unicode bullets:
;; http://nadeausoftware.com/articles/2007/11/latency_friendly_customized_bullets_using_unicode_characters
(defcustom org-bullets-bullet-list
  '(;;; Large
    "◉"
    "○"
    "✸"
    "✿"
    ;; ♥ ● ◇ ✚ ✜ ☯ ◆ ♠ ♣ ♦ ☢ ❀ ◆ ◖ ▶
    ;;; Small
    ;; ► • ★ ▸
    )
  "This variable contains the list of bullets.
It can contain any number of symbols, which will be repeated."
  :group 'org-bullets
  :type '(repeat (string :tag "Bullet character")))

(defcustom org-bullets-face-name nil
  "This variable allows the org-mode bullets face to be
 overridden. If set to a name of a face, that face will be
 used. Otherwise the face of the heading level will be used."
  :group 'org-bullets
  :type 'symbol)

(defun org-bullets-level-char (level)
  (nth (mod (1- level)
            (length org-bullets-bullet-list))
       org-bullets-bullet-list))

(defun org-bullets-ptp (iter &rest args)
  (apply 'put-text-property
         (+ iter (match-beginning 0))
         (+ iter (match-beginning 0) 1)
         args))

;;;###autoload
(define-minor-mode org-bullets-mode
    "UTF8 Bullets for org-mode"
  nil nil nil
  (let* (( keyword
           `(("^\\*+ "
              (0 (let (( offset 0)
                       ( level
                         (- (match-end 0)
                            (match-beginning 0) 1)))
                   (dotimes (iter level)
                     (if (= (1- level) iter)
                         (progn
                           (compose-region
                            (+ iter (match-beginning 0))
                            (+ iter (match-beginning 0) 1)
                            (org-bullets-level-char level))
                           (if (facep org-bullets-face-name)
                               (org-bullets-ptp 'face org-bullets-face-name)))
                         (org-bullets-ptp 'face org-bullets-face-name)
                         (put-text-property
                          (+ iter (match-beginning 0))
                          (+ iter (match-beginning 0) 1)
                          'face (list :foreground
                                      (face-attribute 'default :background))
                          ))
                     (put-text-property
                      (match-beginning 0)
                      (match-end 0)
                      'keymap
                      '(keymap
                        (mouse-1 . org-cycle)
                        (mouse-2
                         . (lambda (e)
                             (interactive "e")
                             (mouse-set-point e)
                             (org-cycle))))))
                   nil))))))
    (if org-bullets-mode
        (progn (font-lock-add-keywords nil keyword)
               (font-lock-fontify-buffer))
        (save-excursion
          (goto-char (point-min))
          (font-lock-remove-keywords nil keyword)
          (while (re-search-forward "^\\*+ " nil t)
            (decompose-region (match-beginning 0) (match-end 0))))
        )))

(provide 'org-bullets)

;;; org-bullets.el ends here
