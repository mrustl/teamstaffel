if(FALSE) {
 men <- get_results("M")
 women <- get_results("W")
}


#' Get Teamstaffel Results Table
#'
#' @param sex either "M" for men or "W" for women default: "M"
#' @param year default: 2022
#' @param base_url default: "https://berlin-wasserbetriebe.r.mikatiming.de"
#'
#' @return tibble with resuls
#' @export
#'
#' @examples 
#' women <- get_results("W")
#' women
#' @importFrom dplyr bind_rows 
get_results <- function(sex = "M", 
                        year = 2022, 
                    base_url = "https://berlin-wasserbetriebe.r.mikatiming.de") {


url <- sprintf("%s/%s/?page=%d&event=ALL&num_results=100&pid=list&search[sex]=%s", 
                 base_url, 
                 year, 
                 1, 
                 sex)

number_of_pages <- ceiling(get_number_of_results(url)/100)
stopifnot(number_of_pages > 0)


res_list <- lapply(seq_len(number_of_pages), function(page) {

  url <- sprintf("%s/%s/?page=%d&event=ALL&num_results=100&pid=list&search[sex]=%s", 
                 base_url, 
                 year, 
                 page, 
                 sex)

get_result(url) 

})

dplyr::bind_rows(res_list)
}

#' Get Result
#'
#' @param url 
#'
#' @return
#' @keywords internal
#' @noMd
#' @noRd
#'
#' @importFrom httr status_code POST
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_text
#' @importFrom tibble tibble
#' @importFrom stringr str_remove_all
#' @importFrom lubridate hms
get_result <- function(url) {

resp <- httr::POST(url)
url_exists <- identical(httr::status_code(resp), 200L)
  
  if(!url_exists) 
    stop(sprintf("url '%s' not existing!", url))  


tmp <- url %>%  
  xml2::read_html() %>% 
  rvest::html_nodes(".col-sm-12") %>% 
  rvest::html_nodes(".list-group-item") 
tmp <- tmp[-1]

 

tibble::tibble(place = tmp %>% 
                 rvest::html_nodes(".place-primary") %>%
                 rvest::html_text() %>% 
                 as.integer(),
               start_number = tmp %>%
                 rvest::html_nodes(".type-field") %>%
                 rvest::html_text() %>%
                 stringr::str_remove_all("^Startnr\\."),
               age_class = tmp %>%
                 rvest::html_nodes(".type-age_class") %>%
                 rvest::html_text() %>%
                 stringr::str_remove_all("^AK"),
               event_name = tmp %>%
                 rvest::html_nodes(".type-event_name") %>%
                 rvest::html_text() %>%
                 stringr::str_remove_all("^Wettbewerb"),
               finish_time = tmp %>%
                 rvest::html_nodes(".type-time") %>%
                 rvest::html_text() %>%
                 stringr::str_remove_all("^Ziel") %>% 
                 lubridate::hms()
)
}

#' Get Number of Results
#'
#' @param url url 
#'
#' @return
#' @keyords internal
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
