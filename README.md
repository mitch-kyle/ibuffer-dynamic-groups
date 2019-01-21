# IBuffer Dynamic Groups
Make ibuffer update it's filter groups each time it is invoked according to a and/or functions which return filter groups and/or static filter groups.

Specifically this was made to work with ibuffer-projectile so other groups can be added e.g:
```elisp
(require 'ibuffer-dynamic-groups)
(require 'ibuffer-projectile)
(setq ibuffer-dynamic-filter-groups '((("Irc" . (mode . erc-mode)))
                                      ibuffer-projectile-generate-filter-groups
                                      my-dynamic-filter-groups
                                      (("System" . (name . "^\\*.*\\*$")))))
(ibuffer-dynamic-groups t)
```

If you want to do pre or post processing on the generated list of filter groups just advise `ibuffer-dynamic-groups-compile`
```elisp
(advice-add 'ibuffer-dynamic-groups-compile :around (lambda (f &rest args)
                                                      (my-sort (apply f args))))
```
