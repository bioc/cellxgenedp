## package-global variables

.CELLXGENE_PRODUCTION_HOST <- "api.cellxgene.cziscience.com"

.CELLXGENE_PRODUCTION_ENDPOINT <- paste0("https://", .CELLXGENE_PRODUCTION_HOST)

.DATASETS <- paste0(.CELLXGENE_PRODUCTION_ENDPOINT, "/curation/v1/datasets/")

.COLLECTIONS <- paste0(.CELLXGENE_PRODUCTION_ENDPOINT, "/curation/v1/collections/")

.CELLXGENE_EXPLORER <- "https://cellxgene.cziscience.com/e/"

#' @importFrom httr GET write_disk progress status_code
#'     stop_for_status content headers
.cellxgene_GET <-
    function(uri)
{
    response <- GET(uri)
    stop_for_status(response)
    response
}

## for testing purposes
.cellxgene_HEAD <-
    function(uri)
{
    response <- httr::HEAD(uri)
    stop_for_status(response)
    response
}

#' @importFrom tools R_user_dir
.cellxgene_cache_path <-
    function(base_path = R_user_dir("cellxgenedp", "cache"))
{
    path <- file.path(base_path, "curation", "v1")
    if (!dir.exists(path))
        dir.create(path, recursive = TRUE)
    path
}

#' @importFrom tools file_path_sans_ext
#'
#' @importFrom dplyr as_tibble .data
.cellxgene_cache_annotate <-
    function(cellxgene_db = db())
{
    path <- .cellxgene_cache_path()
    info <-
        file.info(dir(path, full.names = TRUE)) |>
        as_tibble(rownames = "path") |>
        mutate(file = basename(path)) |>
        select(-c("isdir", "mode"))

    collections <- collections(cellxgene_db)
    files <- files(cellxgene_db)
    info |>
        mutate(
            type = ifelse(file == "collections", "collections", NA_character_),
            type = ifelse(
                file %in% collections$collection_id, "collection", .data$type
            ),
            type = ifelse(
                file_path_sans_ext(file) %in% files$file_id, "file", .data$type
            )
        ) |>
        select("file", "type", everything())
}

.cellxgene_cache_get <-
    function(
        uri, file = basename(uri), progress = FALSE, overwrite = FALSE,
        cache_path = .cellxgene_cache_path())
{
    path <- file.path(cache_path, file)
    if (overwrite || !file.exists(path)) {
        ## download to path0 and then copy / unlink to path to avoid
        ## overwriting file with failed attempt. Don't use
        ## file.rename() since this will fail when tempfile() and
        ## cache are on separate file systems.
        path0 <- tempfile()
        response <- GET(
            uri,
            if (progress) progress(),
            write_disk(path0, overwrite = overwrite)
        )
        if (status_code(response) >= 400L) {
            unlink(path0)
            stop_for_status(response)
        }
        success <- file.copy(path0, path, overwrite = TRUE)
        if (!success) {
            stop(
                "failed to copy uri from local path to cache.\n",
                "  uri: '", uri, "\n",
                "  local path: ", path0, "\n",
                "  cache path: ", path
            )
        }
        unlink(path0)
    }
    path
}
