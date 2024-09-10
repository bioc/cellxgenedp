# cellxgenedp 1.10

SIGNIFICANT USER-VISIBLE CHANGES

* (v.1.9.1) Add progress bar when updated `db()`

# cellxgenedp 1.8

SIGNIFICANT USER-VISIBLE CHANGES

* (v 1.7.2) Add vignette 'Case studies', include identifying dataset
  authors and using ontolgies to identify datasets

* (v 1.7.1) Update vignette section on dataset visualization to

BUG FIXES

* (v 1.7.3) Use all collections, datasets, files to determine
  available columns


# cellxgenedp 1.6

SIGNIFICANT USER-VISIBLE CHANGES

* (v 1.6.1) Update vignette section on dataset visualization to
  accomodate changes in the 'Discover' API.
  https://github.com/mtmorgan/cellxgenedp/issues/15

# cellxgenedp 1.6

* (v 1.5.2) use CELLxGENE 'Discover' API, changing column names of
  some return values. See 'API changes' of the 'Discover and download
  datasets...' vignette.

BUG FIXES

* (v 1.6.2) Use all collections, datasets, and files when
  identifying available columns.

# cellxgenedp 1.4

SIGNIFICANT USER-VISIBLE CHANGES

* (v 1.3.3) add publisher_metadata(), authors(), and links() to make access
  to nested 'collections()' data more straight-forward

# cellxgenedp 1.2

SIGNIFICANT USER-VISIBLE CHANGES

* (v. 1.1.4) allow custom files_download() cache. Thanks @stemangiola,
  https://github.com/mtmorgan/cellxgenedp/pull/9

* (v. 1.1.6) datasets `ethnicity` field renamed to
  `self_reported_ethnicity`

* (v. 1.1.7) use zellkonverter's basilisk-based Python parser to read
  H5AD files in the vignette, see
  https://github.com/theislab/zellkonverter/issues/78

OTHER

* (v. 1.1.2) reset cache on build machines weekly
  
* (v. 1.1.6) use {rjsoncons} CRAN package for queries, rather than
  local implementation. Thanks @LiNk-NY,
  https://github.com/mtmorgan/cellxgenedp/pull/12

# cellxgenedp 0.0.7

* (v. 0.0.7) make errors during local cache update more accessible;
  see https://github.com/mtmorgan/cellxgenedp/issues/1
