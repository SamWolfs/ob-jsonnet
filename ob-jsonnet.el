;;; ob-jsonnet.el --- Babel Functions for Jsonnet -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023 Sam Wolfs
;;
;; Author: Sam Wolfs <be.samwolfs@gmail.com>
;; Maintainer: Sam Wolfs <be.samwolfs@gmail.com>
;; Created: December 10, 2023
;; Modified: December 10, 2023
;; Version: 0.0.1
;; Keywords: org, babel, jsonnet, literate programming
;; Homepage: https://github.com/SamWolfs/ob-jsonnet
;; Package-Requires: ((org "8"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Babel functions for Jsonnet
;;
;;; Code:
(require 'ob)

(defconst org-babel-header-args:jsonnet
  '((jpaths . :any))
  "Jsonnet header arguments.")

(defvar org-babel-tangle-lang-exts)
(add-to-list 'org-babel-tangle-lang-exts '("jsonnet" . "libsonnet"))

(defvar org-babel-default-header-args:jsonnet '())

(defvar org-babel-jsonnet-command "jsonnet" "Name of the Jsonnet executable command.")

(defun org-babel-execute:jsonnet (code options)
  "Execute a block of Jsonnet CODE with org-babel, given OPTIONS.
This function is called by `org-babel-execute-src-block'."
  (let* ((jpaths (ob-jsonnet-build-paths options))
         (vars (org-babel-variable-assignments:jsonnet options))
         (flags (mapconcat #'identity
                           (list jpaths vars)
                           " "))
         (code-file (org-babel-temp-file "jsonnet-")))
    (with-temp-file code-file (insert code))
    (ob-jsonnet-eval code-file flags)))

(defun ob-jsonnet-eval (file flags)
  "Execute jsonnet command on FILE with FLAGS."
  (org-babel-eval
   (format "%s %s %s"
           "jsonnet"
           flags
           (org-babel-process-file-name file)) ""))

(defun org-babel-prep-session:jsonnet (_session _params)
  "Return an error if the :session header argument is set.
Jsonnet does not support sessions."
  (error "Jsonnet sessions are nonsensical"))

;; helper functions
(defun org-babel-variable-assignments:jsonnet (options)
  "Return string of jsonnet variable assignments defined in OPTIONS."
  (mapconcat (lambda (pair)
               (format "-V %s=%s"
                       (car pair)
                       (cdr pair)))
             (org-babel--get-vars options)
             " "))

(defun ob-jsonnet-build-paths (options)
  "Return string of Jsonnet library paths defined in OPTIONS."
  (let ((jpaths (cdr (assq :jpaths options))))
         (mapconcat (lambda (path)
                      (format "-J %s" path))
                    (if (listp jpaths) jpaths (list jpaths))
                    " ")))

(provide 'ob-jsonnet)
;;; ob-jsonnet.el ends here
