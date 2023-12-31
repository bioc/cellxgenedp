test_that("files() works", {
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    files <- files()

    FILES_COLUMNS <- c(
        dataset_id = "character",
        filesize = "numeric",
        filetype = "character",
        url = "character"
    )
    column_names <- names(FILES_COLUMNS)
    expect_true(all(column_names %in% names(files)))
    columns <- vapply(files[column_names], class, character(1))
    expect_identical(columns, FILES_COLUMNS)
})

test_that("files_download() works", {
    ## mockery does not appear to support applying two stubs to one function
    skip("files_download() not tested due to mockery limitation")
    db_exists <- tryCatch({ db(); TRUE }, error = isTRUE)
    skip_if_not(db_exists)

    files <- files() |> head(2)
    mockery::stub(
        files_download,
        ".file_presigned_url",
        identity
    )
    mockery::stub(
        files_download,
        ".cellxgene_cache_get",
        function(x, y, progress) { names(x) <- y; x }
    )
    object <- files_download(files, dry.run = FALSE)

    expected <- with(files, paste0(.DATASETS, dataset_id, "/asset/", file_id))
    names(expected) <- with(
        files, paste0(dataset_id, ".", file_id, ".", filetype)
    )
    expect_identical(object, expected)
})

test_that("files_download() returns named character vector on 0 inputs", {
    tbl <- data.frame(
        dataset_id = character(), filetype = character(), url = character()
    )
    expect_identical(files_download(tbl), setNames(character(), character()))
})

test_that("files_download() pays attention to cache.path", {
    tbl <- data.frame(
        dataset_id = character(), filetype = character(), url = character()
    )
    cache_path <- tempfile()
    ## directory does not exist
    expect_error(files_download(tbl, cache.path = cache_path))
    dir.create(cache_path)
    expect_identical(
        files_download(tbl, cache.path = cache_path),
        setNames(character(), character())
    )
})
