;;; ibuffer-dynamic-groups.el --- Extensible dynamic filter groups for ibuffer -*- lexical-binding: t -*-
;;; Commentary:

;; Make ibuffer update it's filter groups each time it is invoked according to a
;; list of static filter groups and/or functions which return filter groups.

;; Specifically this was made to work with ibuffer-projectile so other groups can be added e.g:

;;   (require 'ibuffer)
;;   (require 'ibuffer-projectile)
;;   (setq ibuffer-dynamic-filter-groups '((("Irc" . (mode . erc-mode)))
;;                                         ibuffer-projectile-generate-filter-groups
;;     				           my-dynamic-filter-groups
;;                                         (("System" . (name . "^\\*.*\\*$")))))
;;   (ibuffer-dynamic-groups t)

;; If you want to do pre or post processing on the generated list of filter groups
;; just advise `ibuffer-dynamic-groups-compile`

;;   (advice-add 'ibuffer-dynamic-groups-compile :around (lambda (f &rest args)
;;   						           (my-sort (apply f args))))

;;;; Code:
(require 'advice)
(require 'ibuffer)

(defvar ibuffer-dynamic-groups-filter-groups '()
  "List of sets of filter groups and/or functions which may return a set of
ibuffer filter groups when called with no argument.")

(defun ibuffer-dynamic-groups-compile (filter-groups-and-functions)
  "compile dynamic filter groups from filter-groups-and-functions.
advise this function for things list filtering and sorting.

filter-groups-and-functions - is a list of ibuffer filter groups and/or a
                              function which called with no argument returns
                              a list of filter groups"
  (reduce #'append
	  (mapcar (lambda (fg)
		    (if (functionp fg)
			(funcall fg)
		      fg))
		  filter-groups-and-functions)))

(defun ibuffer-dynamic-groups--compile-and-set (&rest _)
  "compile and set the ibuffer filter groups."
  (setq ibuffer-filter-groups
	(ibuffer-dynamic-groups-compile ibuffer-dynamic-groups-filter-groups))
  (ibuffer-update nil t))

(defun ibuffer-dynamic-groups-enabled? ()
  (advice-member-p #'ibuffer-dynamic-groups--compile-and-set 'ibuffer))

(defun ibuffer-dynamic-groups-enable ()
  (unless (ibuffer-dynamic-groups-enabled?)
    (advice-add 'ibuffer :after #'ibuffer-dynamic-groups--compile-and-set)
    (message "ibuffer dynamic groups enabled")))

(defun ibuffer-dynamic-groups-disable ()
  (when (ibuffer-dynamic-groups-enabled?)
    (advice-remove 'ibuffer #'ibuffer-dynamic-groups--compile-and-set)
    (message "ibuffer dynamic groups disabled")))

;;;###autoload
(defun ibuffer-dynamic-groups (&rest args)
  "Toggle dynamic ibuffer groups.

args - if there is some argument the set according to it, else toggle."
  (interactive)
  (if args
      (if (car args)
	  (ibuffer-dynamic-groups-enable)
	(ibuffer-dynamic-groups-disable))
    (if (ibuffer-dynamic-groups-enabled?)
	(ibuffer-dynamic-groups-disable)
      (ibuffer-dynamic-groups-enable))))

(provide 'ibuffer-dynamic-groups)
;;; ibuffer-dynamic-groups.el ends here
