# IBuffer Dynamic Groups
Update `ibuffer-filter-groups` to the filter groups generated by `ibuffer-dynamic-groups-generate` each time ibuffer is updated.

## Usage
toggle ibuffer-dynamic-groups:

```
  M-x ibuffer-dynamic-groups
```

It can be enabled explicitly in configuration by calling:

```elisp
  (ibuffer-dynamic-groups t)
```

Similarly to disable it:

```elisp
  (ibuffer-dynamic-groups nil)
```

Note: Disabling ibuffer-dynamic-groups will not unset `ibuffer-filter-groups` but simply leaves it at the last generation.


### But wait a minute... nothing happened.
but by default the list of filter groups returned is empty

### So how do I make these "dynamic" "filter groups" I came here for?
however you want, I recommend advising the `ibuffer-dynamic-groups-generate` function. like so:

```elisp
  (require 'advice)
  (advice-add 'ibuffer-dynamic-groups-generate
              :filter-return (lambda (groups)
                               (append groups '(("System" (name . "^\\*.*\\*$")))))
              '((name . 'system-group) (depth . 25)))
```

Or with convience function

```elisp
  (ibuffer-dynamic-groups-add (lambda (groups)
                                (append groups '(("System" (name . "^\\*.*\\*$")))))
                              '((name . system-group) (depth . 25)))
```

This will add the "System" group to the end of our list of filter groups.

#### Optional advice properties
* `depth` property determines when this function is ran in relation to other functions. default is 0, 100 is run first and -100 is ran last.
* `name` property can be used to remove this advice later if needed.

see `(describe-function 'add-function)` for more information

### that's not dynamic.
how about these examples:

```elisp
  (require 'ibuffer-projectile)
  (ibuffer-dynamic-groups-add (lambda (groups)
                                (append (ibuffer-projectile-generate-filter-groups) groups))
                              '((name . ibuffer-projectile-groups)))
```
This will generate projectile filter groups and add them to the top of our list of filter groups

```elisp
  (require 'seq)
  (ibuffer-dynamic-groups-add (lambda (groups)
                                (seq-remove (lambda (g)
                                              (string= "Boring Useless Group" (car g))
                                            groups))
                              '((name . 'projecta-non-gratas)
                                (depth . 24)))
```

This will remove entries from filter groups named "Boring Useless Group"
NOTE: set depth of 24 so it's ran after 'system-groups

### the "Systems" group is silly. how do I get rid of it.
Harsh. but there are a few ways of doing that

With advice remove:

```elisp
  (require 'advice)
  (advice-remove 'ibuffer-dynamic-groups-generate
                 (lambda (groups)
                   (append groups '(("System" (name . "^\\*.*\\*$")))))
  ;; Or since we named it
  (advice-remove 'ibuffer-dynamic-groups-generate 'system-groups)
```

Or with the convenience function `ibuffer-dynamic-groups-remove'

```elisp
  (ibuffer-dynamic-groups-remove (lambda (groups)
                                   (append groups '(("System" (name . "^\\*.*\\*$")))))
  ;; Or since we named it
  (ibuffer-dynamic-groups-remove 'system-groups)
```
### Is there anything else?
no, not really
