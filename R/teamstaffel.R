if(FALSE) {
 men <- get_results("M")
 women <- get_results("W")
}


#' Get Teamstaffel Results Table
#'
#' @param sex either "M" for men or "W" for women default: "M"
#' @param year default: 2022
#' @param event return overall results ("ALL") or of a selected starting day (i.e.
#' "ST1", "ST2" or "ST3"), (default: "ALL")
#' @param base_url default: "https://berlin-wasserbetriebe.r.mikatiming.de"
#'
#' @return tibble with results
#' @export
#'
#' @examples
#' women <- get_results("W")
#' women
#' @importFrom dplyr bind_rows
get_results <- function(sex = "M",
                        year = 2022,
                        event = "ALL",
                    base_url = "https://berlin-wasserbetriebe.r.mikatiming.de") {


stopifnot(event %in% c("ALL", paste0("ST", 1:3)))

url <- sprintf("%s/%s/?page=%d&event=%s&num_results=100&pid=list&search[sex]=%s",
               base_url,
               year,
               1,
               event,
               sex)

number_of_pages <- ceiling(get_number_of_results(url)/100)
stopifnot(number_of_pages > 0)


res_list <- lapply(seq_len(number_of_pages), function(page) {

  url <- sprintf("%s/%s/?page=%d&event=%s&num_results=100&pid=list&search[sex]=%s",
                 base_url,
                 year,
                 page,
                 event,
                 sex)

get_result(url)

})

dplyr::bind_rows(res_list)
}

#' Get Result
#'
#' @param url url
#'
#' @return reults for one page (i.e. at maximum 100)
#' @keywords internal
#' @noMd
#' @noRd
#'
#' @importFrom httr status_code POST
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_text
#' @importFrom tibble tibble
#' @importFrom stringr str_remove_all
#' @importFrom rlang .data
get_result <- function(url) {


resp <- httr::POST(url)
url_exists <- identical(httr::status_code(resp), 200L)

  if(!url_exists)
    stop(sprintf("url '%s' not existing!", url))


tmp <- url %>%
  xml2::read_html() %>%
  rvest::html_nodes(".col-sm-12")


tmp <- url %>%
  xml2::read_html() %>%
  rvest::html_nodes(".col-sm-12.row-xs") %>%
  rvest::html_nodes(".list-group-item")
tmp <- tmp[-1]

res <- tibble::tibble(place = tmp %>%
                 rvest::html_nodes(".place-primary") %>%
                 rvest::html_text() %>%
                 as.integer(),
               team = tmp %>%
                 rvest::html_nodes(".type-fullname") %>%
                 rvest::html_text(),
               start_number = tmp %>%
                 rvest::html_nodes(".type-field") %>%
                 rvest::html_text() %>%
                 stringr::str_remove_all("^Startnr\\."),
               age_class = tmp %>%
                 rvest::html_nodes(".type-age_class") %>%
                 rvest::html_text() %>%
                 stringr::str_remove_all("^AK"),
               finish_time = tmp %>%
                 rvest::html_nodes(".type-time") %>%
                 rvest::html_text() %>%
                 stringr::str_remove_all("^Ziel")
               )

is_overall_result <- grepl("ALL", url)

if(is_overall_result) {
res <- dplyr::bind_cols(res,
                        tibble::tibble(event_name = tmp %>%
                                         rvest::html_nodes(".type-event_name") %>%
                                         rvest::html_text() %>%
                                         stringr::str_remove_all("^Wettbewerb")
                        ))
}

res
}

#' Get Number of Results
#'
#' @param url url
#'
#' @return number of results
#' @keywords internal
#' @noMd
#' @noRd
#' @importFrom stringr str_extract
get_number_of_results <- function(url) {
  url %>%
    xml2::read_html() %>%
    rvest::html_nodes(".list-info") %>%
    rvest::html_text() %>%
    stringr::str_extract(pattern = "[1-9][0-9]{0,6}") %>%
    as.integer()
}
