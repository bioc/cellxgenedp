#' @importFrom dplyr bind_rows mutate arrange desc
#'
#' @importFrom rjsoncons j_pivot
.db <-
    function(overwrite)
{
    path <- .cellxgene_cache_get(
        .COLLECTIONS, "collections", overwrite = overwrite
    )
    readLines(path) |>
        j_pivot(as = "tibble") |>
        bind_rows()
}

#' @importFrom cli cli_progress_bar cli_progress_update
#'     cli_progress_done
.db_detail <-
    function(collection_id, overwrite)
{
    n_collections <- length(collection_id)
    result <- vector("list", n_collections)
    cli_progress_bar("Collections", total = n_collections)
    for (i in seq_len(n_collections)) {
        ## be sure to return a result & check for errors
        result[[i]] <- tryCatch({
            uri <- paste0(.COLLECTIONS, collection_id[[i]])
            path <- .cellxgene_cache_get(uri, overwrite = overwrite)
            readLines(path)
        }, error = identity)
        cli_progress_update()
    }
    cli_progress_done()
    result
}

.db_first <- local({
    first <- TRUE
    function() {
        if (first && interactive()) {
            repeat {
                response <- readline("Update database and collections [yn]? ")
                response <- tolower(response)
                if (response %in% c("y", "n")) break
            }
            status <- identical(response, "y")
        } else {
            status <- FALSE
        }
        first <<- FALSE
        status
    }
})

#' @importFrom curl nslookup
.db_online <-
    function()
{
    response <- nslookup(.CELLXGENE_PRODUCTION_HOST, error = FALSE)
    !is.null(response)
}

#' @rdname db
#' @title Retrieve updated cellxgene database metadata
#'
#' @details The database is retrieved from the cellxgene data portal
#'     web site. 'collections' metadata are retrieved on each call;
#'     metadata on each collection is cached locally for re-use.
#'
#' @param overwrite logical(1) indicating whether the database of
#'     collections should be updated from the internet (the default,
#'     when internet is available and, in an interactive session, the
#'     user requests the update), or read from disk (assuming previous
#'     successful access to the internet).  `overwrite = FALSE` might
#'     be useful for reproducibility, testing, or when working in an
#'     environment with restricted internet access.
#'
#' @return `db()` returns an object of class 'cellxgene_db',
#'     summarizing available collections, datasets, and files.
#'
#' @examples
#' db()
#'
#' @export
db <-
    function(overwrite = .db_online() && .db_first())
{
    stopifnot(
        .is_scalar_logical(overwrite)
    )

    if (overwrite)
        message("updating database and collections...")
    db <- .db(overwrite)
    details <- .db_detail(db$collection_id, overwrite)
    errors <- vapply(details, inherits, logical(1), "error")
    if (any(errors)) {
        stop(
            sum(errors), " error(s) updating database; first error:\n",
            "  ", conditionMessage(details[[head(which(errors), 1L)]])
        )
    }
    details <- sprintf("[%s]", paste(details, collapse=","))

    class(details) <- c("cellxgene_db", class(details))
    details
}


#' @importFrom utils head
#'
#' @export
print.cellxgene_db <-
    function(x, ...)
{
    cat(
        head(class(x), 1L), "\n",
        "number of collections(): ", .jmes_to_r(x, "length([])"), "\n",
        "number of datasets(): ", .jmes_to_r(x, "length([].datasets[])"), "\n",
        "number of files(): ",
        .jmes_to_r(x, "length([].datasets[].assets[])"), "\n",
        sep = ""
    )
}
