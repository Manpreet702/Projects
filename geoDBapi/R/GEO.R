#'
#' title: GEO API Client
#'
#' description: Reference class for interacting with the GeoDB API.
#'
#' @importFrom httr GET content
#' @importFrom jsonlite fromJSON
#' @importFrom stringr str_detect
#' @importFrom tidygeocoder geo
#' @importFrom methods setRefClass
#' @importFrom methods new
#' @import countrycode
#'
#' @rawNamespace export(GEO)
#' @exportClass GEO
GEO <- setRefClass("GEO",
  fields = list(api_key = "character", max_limit = "numeric", base_url = "character"),

  methods = list(

    initialize = function(api_key = "", max_limit = 10){
      "description: This is the constructor for this class.\\cr
       param - api_key (not required) : (character string) Only pass your api key if you are using the pro version, otherwise don't change this parameter and the free version is automatically used.\\cr
       param - max_limit : (numeric integer) The default limit value for calling records from the GEO DB api, check  with your plan to see what your maximum is.
      "

      api_key <<- api_key
      max_limit <<- max_limit
      base_url <<- "http://geodb-free-service.wirefreethought.com/v1/geo/"

      if(nchar(api_key) > 0){
        base_url <<- "https://wft-geo-db.p.rapidapi.com/v1/geo/"
      }
    },

    makeRequest = function(url){
      "description: Helper method to make api request to the given url.\\cr
       param - url (required): (string) of the url to make the request\\cr
       return value: returns the response in JSON format"

      if(!is.null(api_key) && nchar(api_key) > 0){
        request <-  GET(url, add_headers( `X-RapidAPI-Key` = api_key,`X-RapidAPI-Host` = "wft-geo-db.p.rapidapi.com"))
      }
      else{
        request <- GET(url)
      }

      response <- fromJSON(content(request, as = "text", encoding = "UTF-8"))

      if(request$status_code >= 300){
        print(paste0("API request status: ",request$status_code, ", for endpoint GET: ", url))
        print("Response Message:")
        print(response)
      }

      return (response)
    },

    renderChart = function(df, title = NULL){
      "description: Helper method to render a quick ggplot chart for returned data frames.\\cr
       param - df (required): (data.frame) returned data frame\\cr
       param - title: (character string) plot title\\cr
       return value: invisible ggplot object, or NULL if it can't be plotted"

      if(is.null(df) || !is.data.frame(df) || nrow(df) < 1){
        return (invisible(NULL))
      }

      lat_col <- intersect(c("latitude","lat"), names(df))
      lon_col <- intersect(c("longitude","lon","lng"), names(df))
      pop_col <- intersect(c("population","pop"), names(df))
      name_col <- intersect(c("name","city","country","region"), names(df))

      if(length(lat_col) > 0 && length(lon_col) > 0){

        x <- lon_col[1]
        y <- lat_col[1]

        if(length(pop_col) > 0){
          s <- pop_col[1]
          p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[x]], y = .data[[y]])) +
            ggplot2::geom_point(ggplot2::aes(size = .data[[s]]), alpha = 0.7) +
            ggplot2::scale_size_continuous(name = "Population") +
            ggplot2::coord_fixed() +
            ggplot2::labs(title = title, x = "Longitude", y = "Latitude") +
            ggplot2::theme_minimal()
        } else {
          p <- ggplot2::ggplot(df, ggplot2::aes(x = .data[[x]], y = .data[[y]])) +
            ggplot2::geom_point(alpha = 0.7) +
            ggplot2::coord_fixed() +
            ggplot2::labs(title = title, x = "Longitude", y = "Latitude") +
            ggplot2::theme_minimal()
        }

        print(p)
        return (invisible(p))
      }

      if(length(name_col) > 0 && length(pop_col) > 0){

        n <- name_col[1]
        s <- pop_col[1]

        tmp <- df
        tmp[[s]] <- suppressWarnings(as.numeric(tmp[[s]]))
        tmp <- tmp[!is.na(tmp[[s]]), ]
        if(nrow(tmp) < 1){
          return (invisible(NULL))
        }

        tmp <- tmp[order(tmp[[s]], decreasing = TRUE), ]
        tmp <- utils::head(tmp, 10)

        p <- ggplot2::ggplot(tmp, ggplot2::aes(x = stats::reorder(.data[[n]], .data[[s]]), y = .data[[s]])) +
          ggplot2::geom_col() +
          ggplot2::coord_flip() +
          ggplot2::labs(title = title, x = NULL, y = "Population") +
          ggplot2::theme_minimal()

        print(p)
        return (invisible(p))
      }

      return (invisible(NULL))
    },


    getCountryNamesAndCodes = function(){
      "description: Helper method to get a dataframe of all country names and country codes.\\cr
       return value: returns the dataframe with columns: name, code2, and code3"

      df = (data.frame(
        name = as.character(codelist$country.name.en),
        code2 = as.character(codelist$iso2c),
        code3 = as.character(codelist$iso3c)
      ))
      df$name = tolower(df$name)

      return (df)
    },

    getClosestMatchingCountryNamesOrCodes = function(countries){
      "description: Helper method to get a list of the corresponding country codes of a given list of country names and/or codes.\\cr
       param - countries (required): (character vector or character array) the given country codes and/or country names\\cr
       return value: returns a comma delimited string of the matching country codes, or NULL if none matched"

      countriesLookup <- getCountryNamesAndCodes()

      if(is.atomic(countries) && length(countries) == 1 && !is.array(countries)){
        countries = c(as.character(countries))
      }

      codes <- character()

      for (country in countries){

        matchCode <- toupper(country)
        matchName <- tolower(country)

        matches <- countriesLookup[!is.na(countriesLookup$code2) & countriesLookup$code2 == matchCode, ]
        if(nrow(matches) > 0){
          codes = c(codes, as.character(matches[1,2]))
          next
        }

        matches <- countriesLookup[!is.na(countriesLookup$name) & countriesLookup$name == matchName, ]
        if(nrow(matches) > 0){
          codes = c(codes, as.character(matches[1,2]))
          next
        }

        matches <- countriesLookup[!is.na(countriesLookup$name) & startsWith(countriesLookup$name, matchName), ]
        if(nrow(matches) > 0){
          codes = c(codes, as.character(matches[1,2]))
          next
        }

        matches <- countriesLookup[!is.na(countriesLookup$name) & str_detect(countriesLookup$name, matchName), ]
        if(nrow(matches) > 0){
          codes = c(codes, as.character(matches[1,2]))
          next
        }
      }

      if(length(codes) > 0){
        return (paste(codes, collapse = ","))
      }
      return (NULL)
    },

    convertLongitudeLatitudeToISO = function(lat, long){
      "description: Helper method to convert lat and long numeric valies to the ISO lat/long formatted string.\\cr
       param - lat (required): (numeric) the latitude value\\cr
       param - long (required): (numeric) the longitude value\\cr
       return value: returns the ISO formatted string of the long and lat coordinates"

      lat <- sprintf("%2.4f", lat)
      long <- sprintf("%3.4f", long)

      if(lat >= 0){ lat <- paste0("%2B",lat)}
      if(long >= 0){ long <- paste0("%2B",long)}

      return (paste0(lat,long))
    },

    getLongitudeLatitude = function(location){
      "description: Helper method to get the ISO formatted long/lat string of a given address or place name.\\cr
       param - location (required): (character  string) the latitude value\\cr
       return value: returns the ISO formatted string of the given location"

      geocoded_address <- geo(address = location, method='osm', lat=latitude,long=longitude)

      return (convertLongitudeLatitudeToISO(geocoded_address[1,2],geocoded_address[1,3]))
    },

    FindCountries = function(chart = FALSE,
                                  currencyCode = NULL,
                                  includeAllColumns = FALSE,
                                  columns = NULL,
                                  namePrefix = NULL,
                                  name = NULL,
                                  offset = 0,
                                  limit = max_limit){
      "description: Method used to find all countries and their data using the GEO db cities api\\cr
       param - chart: (boolean) if TRUE render a chart before returning data\\cr
       param - currencyCode: (character string) Filter by ISO currency code\\cr
       param - includeAllColumns: (boolean) Logical return all columns\\cr
       param - columns: (character vector) column names to include in returned dataframe
       param - namePrefix: (character string) Prefix match on country name\\cr
       param - name: (character string) Exact country name (takes priority over 'namePrefix', see vignette for more details.)\\cr
       param - offset: (numeric integer) Returned data offset, default is 0\\cr
       param - limit: (numeric integer) Maximum number of results, equal to 'max_limit' field by default\\cr
       return value: A list with `count` for number of returned records, and `data` for the clean dataframe"

      request_url = paste0(base_url,"countries?offset=",offset)

      if(!is.null(limit)){
        request_url <- paste0(request_url,"&limit=",limit)
      }
      #if(!is.null(sort)){
      #request_url <- paste0(request_url,"&sort=",sort)
      #}

      if(!is.null(name)){
        request_url <- paste0(request_url,"&namePrefix=",name)
      }
      else if(!is.null(namePrefix)){
        request_url <- paste0(request_url,"&namePrefix=",namePrefix)
      }

      if(!is.null(currencyCode)){
        request_url <- paste0(request_url,"&currencyCode=",currencyCode)
      }

      response <- makeRequest(request_url)
      data <- as.data.frame(response$data)
      count <- response$metadata$totalCount

      if(!is.null(name)){
        data = data[data$name == name, ]
      }
      if(!is.null(columns) && count > 0){
        data <- data[columns]
      }
      else if(!includeAllColumns){
        extraColumns = c("city")
        data <- data[, !(names(data) %in% extraColumns)]
      }

      if(chart){
        renderChart(as.data.frame(data), title = "Countries")
      }

      return (list(count = count, data = as.data.frame(data)))
    },

    FindPlaces.NearPlace = function(chart = FALSE, placeId = NULL,
                                         placeName = NULL,
                                         placeAddress = NULL,
                                         includeDistricts = TRUE,
                                         includeCities = TRUE,
                                         includeIslands = TRUE,
                                         includeAllColumns = FALSE,
                                         columns = NULL,
                                         includeDeleted = NULL,
                                         namePrefix = NULL,
                                         name = NULL,
                                         maxPopulation = NULL,
                                         minPopulation = NULL,
                                         excludedCountries = NULL,
                                         includedCountries = NULL,
                                         excludedCountryIds = NULL,
                                         includedCountryIds = NULL,
                                         distanceUnit = "KM",
                                         radius = NULL,
                                         offset = 0,
                                         limit = max_limit){
      "description: Method used to find all places near a given place and their data using the GEO db api\\cr
       param - chart: (boolean) if TRUE render a chart before returning data\\cr
       param - charts: (boolean) true to return a chart map, false otherwise\\cr
       param - placeId (conditionally required): (character string) the wikidataId or native 'id' of the nearby place, (this takes priority over placeName and placeAddress, see vignette for more details)\\cr
       param - placeName (conditionally required): (character string) the name of the nearby place, (this is only used if placeId is NULL, see vignette for more details)\\cr
       param - placeAddress (conditionally required): (character string) the address of the nearby place, (this is only used if placeId is NULL, see vignette for more details)\\cr
       param - includeDistricts : (boolean) True if you would like to include districts in the returned places, false otherwise.\\cr
       param - includeCities : (boolean) True if you would like to include cities in the returned places, false otherwise.\\cr
       param - includeIslands : (boolean) True if you would like to include islands in the returned places, false otherwise.\\cr
       param - includeAllColumns: (boolean) Logical return all columns\\cr
       param - columns: (character vector) column names to include in returned dataframe\\cr
       param - includeDeleted: (string either ALL, or NONE, or SINCE_YESTERDAY or SINCE_LAST_WEEK, default is NONE), used to include places that were deleted\\cr
       param - namePrefix: (character string) Prefix match on country name\\cr
       param - name: (character string) Exact country name (takes priority over 'namePrefix', see vignette for more details.)\\cr
       param - maxPopulation: (numeric integer) filter by max population of places.\\cr
       param - minPopulation: (numeric integer) filter by min population of places.\\cr
       param - excludedCountries: (character vector) vector of excluded country names (will not include places from these countries)\\cr
       param - excludedCountryIds: (character vector) vector of excluded country wikiDataId's or codes (will not include places from these countries)\\cr
       param - includedCountries: (character vector) vector of included country names (only include places from these countries)\\cr
       param - includedCountryIds: (character vector) vector of included country wikiDataId's or codes (only include places from these countries)\\cr
       param - distanceUnit: (character string MI or KM) default value is KM, determines if distances are measured in Kilometres or Miles\\cr
       param - radius: (numeric integer) radius from nearby places to find place, measured in distanceUnit, default is the max radius of your plan\\cr
       param - offset: (numeric integer) Returned data offset, default is 0\\cr
       param - limit: (numeric integer) Maximum number of results, equal to 'max_limit' field by default\\cr
       return value: A list with `count` for number of returned records, and `data` for the clean dataframe"

      if(is.null(placeAddress) && is.null(placeId) && is.null(placeName)){
        print("ERROR: Either placeId, placeAddress, or placeName is required")

        return (NULL)
      }

      id <- NULL
      if(!is.null(placeId)){
        id <- placeId
      }
      else if(!is.null(placeAddress)){
        places <- FindPlaces(locationAddress = placeAddress, name = placeName)
        if(is.null(places) || places$count < 1){
          print(paste0("ERROR: No matching place found."))
          return (NULL)
        }
        places$distance =  as.numeric(places$distance)
        places$data <- places$data[order(places$data$distance, decreasing = FALSE), ]
        id <- (places$data[1,'wikiDataId'])
      }
      else{
        places <- FindPlaces(name = placeName)
        if(is.null(places) || places$count < 1){
          print(paste0("ERROR: No matching place found."))
          return (NULL)
        }
        id <- (places$data[1,'wikiDataId'])
      }

      request_url = paste0(base_url,"places/",id,"/nearbyPlaces?offset=",offset,"&distanceUnit=",distanceUnit)

      if(!is.null(limit)){
        request_url <- paste0(request_url,"&limit=",limit)
      }
      #if(!is.null(sort)){
      #request_url <- paste0(request_url,"&sort=",sort)
      #}

      if(!is.null(name)){
        request_url <- paste0(request_url,"&namePrefix=",name)
      }
      else if(!is.null(namePrefix)){
        request_url <- paste0(request_url,"&namePrefix=",namePrefix)
      }

      if(!is.null(maxPopulation)){
        request_url <- paste0(request_url,"&maxPopulation=",format(maxPopulation, scientific = FALSE))
      }
      if(!is.null(minPopulation)){
        request_url <- paste0(request_url,"&minPopulation=",format(minPopulation, scientific = FALSE))
      }
      if(!is.null(radius)){
        request_url <- paste0(request_url,"&radius=", format(radius, scientific = FALSE))
      }

      typeVec = character()

      if(includeDistricts){
        typeVec = c(typeVec, as.character(c("ADM2")))
      }
      if(includeCities){
        typeVec = c(typeVec, as.character(c("CITY")))
      }
      if(includeIslands){
        typeVec = c(typeVec, as.character(c("ISLAND")))
      }

      if(length(typeVec) == 0){
        return (list(count = 0, data = data.frame()))
      }
      else if(length(typeVec) < 3){
        request_url <- paste0(request_url,"&types=",paste(typeVec, collapse = ","))
      }

      if(!is.null(includeDeleted)){
        request_url <- paste0(request_url,"&includeDeleted=", includeDeleted)
      }

      iCountries = character()

      if(!is.null(includedCountryIds)){
        iCountries = c(iCountries, as.character(c(includedCountryIds)))
      }

      if(!is.null(includedCountries)){
        codes = getClosestMatchingCountryNamesOrCodes(includedCountries)
        iCountries = c(iCountries, as.character(c(codes)))
      }

      if(length(iCountries) > 0){
        request_url <- paste0(request_url,"&countryIds=",paste(iCountries, collapse = ","))
      }

      eCountries = character()

      if(!is.null(excludedCountryIds)){
        eCountries = c(eCountries, as.character(c(excludedCountryIds)))
      }

      if(!is.null(excludedCountries)){
        codes = getClosestMatchingCountryNamesOrCodes(excludedCountries)
        eCountries = c(eCountries, as.character(c(codes)))
      }

      if(length(eCountries) > 0){
        request_url <- paste0(request_url,"&excludedCountryIds=",paste(eCountries, collapse = ","))
      }

      response <- makeRequest(request_url)
      data <- as.data.frame(response$data)
      count <- response$metadata$totalCount

      if(!is.null(name)){
        data = data[data$name == name, ]
      }
      if(!is.null(columns) && count > 0){
        data <- data[columns]
      }
      else if(!includeAllColumns){
        extraColumns = c("city")
        data <- data[, !(names(data) %in% extraColumns)]
      }

      if(chart){
        renderChart(as.data.frame(data), title = "Nearby Places")
      }

      return (list(count = count, data = as.data.frame(data)))
    },

    FindPlaces = function(chart = FALSE,
                               includeDistricts = TRUE,
                               includeCities = TRUE,
                               includeIslands = TRUE,
                               includeAllColumns = FALSE,
                               columns = NULL,
                               includeDeleted = NULL,
                               namePrefix = NULL,
                               name = NULL,
                               maxPopulation = NULL,
                               minPopulation = NULL,
                               excludedCountries = NULL,
                               includedCountries = NULL,
                               excludedCountryIds = NULL,
                               includedCountryIds = NULL,
                               distanceUnit = "KM",
                               radius = NULL,
                               longitude = NULL,
                               latitude = NULL,
                               locationAddress = NULL,
                               offset = 0,
                              sort = NULL,
                               limit = max_limit){
      "description: Method used to find all places and their data using the GEO db api\\cr
       param - chart: (boolean) if TRUE render a chart before returning data\\cr
       param - charts: (boolean) true to return a chart map, false otherwise\\cr
       param - includeDistricts : (boolean) True if you would like to include districts in the returned places, false otherwise.\\cr
       param - includeCities : (boolean) True if you would like to include cities in the returned places, false otherwise.\\cr
       param - includeIslands : (boolean) True if you would like to include islands in the returned places, false otherwise.\\cr
       param - includeAllColumns: (boolean) Logical return all columns\\cr
       param - columns: (character vector) column names to include in returned dataframe\\cr
       param - includeDeleted: (string either ALL, or NONE, or SINCE_YESTERDAY or SINCE_LAST_WEEK, default is NONE), used to include places that were deleted\\cr
       param - namePrefix: (character string) Prefix match on place name\\cr
       param - name: (character string) Exact place name (takes priority over 'namePrefix', see vignette for more details.)\\cr
       param - maxPopulation: (numeric integer) filter by max population of places.\\cr
       param - minPopulation: (numeric integer) filter by min population of places.\\cr
       param - excludedCountries: (character vector) vector of excluded country names (will not include places from these countries)\\cr
       param - excludedCountryIds: (character vector) vector of excluded country wikiDataId's or codes (will not include places from these countries)\\cr
       param - includedCountries: (character vector) vector of included country names (only include places from these countries)\\cr
       param - includedCountryIds: (character vector) vector of included country wikiDataId's or codes (only include places from these countries)\\cr
       param - distanceUnit: (character string MI or KM) default value is KM, determines if distances are measured in Kilometres or Miles\\cr
       param - radius: (numeric integer) radius from location to find place, measured in distanceUnit, default is the max radius of your plan\\cr
       param - longitude: (numeric) longitude value of the nearby location in which to find places (this takes priority over locationAddress, see vignette for more details)\\cr
       param - latitude: (numeric) latitude value of the nearby location in which to find places (this takes priority over locationAddress, see vignette for more details)\\cr
       param - locationAddress: (character string) the address or name of location in which to find places (only used if longitude or latitude is NULL, see vignette for more details)\\cr
       param - offset: (numeric integer) Returned data offset, default is 0\\cr
       param - limit: (numeric integer) Maximum number of results, equal to 'max_limit' field by default\\cr
       return value: A list with `count` for number of returned records, and `data` for the clean dataframe"

      request_url = paste0(base_url,"places?offset=",offset,"&distanceUnit=",distanceUnit)

      if(!is.null(limit)){
        request_url <- paste0(request_url,"&limit=",limit)
      }
      if(!is.null(sort)){
      request_url <- paste0(request_url,"&sort=",sort)
      }

      if(!is.null(name)){
        request_url <- paste0(request_url,"&namePrefix=",name)
      }
      else if(!is.null(namePrefix)){
        request_url <- paste0(request_url,"&namePrefix=",namePrefix)
      }

      if(!is.null(maxPopulation)){
        request_url <- paste0(request_url,"&maxPopulation=",format(maxPopulation, scientific = FALSE))
      }
      if(!is.null(minPopulation)){
        request_url <- paste0(request_url,"&minPopulation=",format(minPopulation, scientific = FALSE))
      }
      if(!is.null(radius)){
        request_url <- paste0(request_url,"&radius=", format(radius, scientific = FALSE))
      }

      if(!is.null(latitude) && !is.null(longitude)){
        request_url <- paste0(request_url,"&location=", convertLongitudeLatitudeToISO(latitude, longitude))

      }
      else if(!is.null(locationAddress)){
        locationAddress <- getLongitudeLatitude(locationAddress)
        request_url <- paste0(request_url,"&location=",locationAddress)
      }

      typeVec = character()

      if(includeDistricts){
        typeVec = c(typeVec, as.character(c("ADM2")))
      }
      if(includeCities){
        typeVec = c(typeVec, as.character(c("CITY")))
      }
      if(includeIslands){
        typeVec = c(typeVec, as.character(c("ISLAND")))
      }

      if(length(typeVec) == 0){
        return (list(count = 0, data = data.frame()))
      }
      else if(length(typeVec) < 3){
        request_url <- paste0(request_url,"&types=",paste(typeVec, collapse = ","))
      }

      if(!is.null(includeDeleted)){
        request_url <- paste0(request_url,"&includeDeleted=", includeDeleted)
      }

      iCountries = character()

      if(!is.null(includedCountryIds)){
        iCountries = c(iCountries, as.character(c(includedCountryIds)))
      }

      if(!is.null(includedCountries)){
        codes = getClosestMatchingCountryNamesOrCodes(includedCountries)
        iCountries = c(iCountries, as.character(c(codes)))
      }

      if(length(iCountries) > 0){
        request_url <- paste0(request_url,"&countryIds=",paste(iCountries, collapse = ","))
      }

      eCountries = character()

      if(!is.null(excludedCountryIds)){
        eCountries = c(eCountries, as.character(c(excludedCountryIds)))
      }

      if(!is.null(excludedCountries)){
        codes = getClosestMatchingCountryNamesOrCodes(excludedCountries)
        eCountries = c(eCountries, as.character(c(codes)))
      }

      if(length(eCountries) > 0){
        request_url <- paste0(request_url,"&excludedCountryIds=",paste(eCountries, collapse = ","))
      }

      response <- makeRequest(request_url)
      data <- as.data.frame(response$data)
      count <- response$metadata$totalCount

      if(!is.null(name)){
        data = data[data$name == name, ]
      }
      if(!is.null(columns) && count > 0){
        data <- data[columns]
      }
      else if(!includeAllColumns){
        extraColumns = c("city")
        data <- data[, !(names(data) %in% extraColumns)]
      }

      if(chart){
        renderChart(as.data.frame(data), title = "Places")
      }

      return (list(count = count, data = as.data.frame(data)))
    },

    FindIslands = function(...){
      "description: Method used to find all Islands and their data using the GEO db api\\cr
       param - charts: (boolean) true to return a chart map, false otherwise\\cr
       param - includeAllColumns: (boolean) Logical return all columns\\cr
       param - columns: (character vector) column names to include in returned dataframe\\cr
       param - includeDeleted: (string either ALL, or NONE, or SINCE_YESTERDAY or SINCE_LAST_WEEK, default is NONE), used to include places that were deleted\\cr
       param - namePrefix: (character string) Prefix match on Island name\\cr
       param - name: (character string) Exact country name (takes priority over 'namePrefix', see vignette for more details.)\\cr
       param - maxPopulation: (numeric integer) filter by max population of islands\\cr
       param - minPopulation: (numeric integer) filter by min population of islands\\cr
       param - excludedCountries: (character vector) vector of excluded country names (will not include places from these countries)\\cr
       param - excludedCountryIds: (character vector) vector of excluded country wikiDataId's or codes (will not include places from these countries)\\cr
       param - includedCountries: (character vector) vector of included country names (only include places from these countries)\\cr
       param - includedCountryIds: (character vector) vector of included country wikiDataId's or codes (only include places from these countries)\\cr
       param - distanceUnit: (character string MI or KM) default value is KM, determines if distances are measured in Kilometres or Miles\\cr
       param - radius: (numeric integer) radius from location to find place, measured in distanceUnit, default is the max radius of your plan\\cr
       param - longitude: (numeric) longitude value of the nearby location in which to find places (this takes priority over locationAddress, see vignette for more details)\\cr
       param - latitude: (numeric) latitude value of the nearby location in which to find places (this takes priority over locationAddress, see vignette for more details)\\cr
       param - locationAddress: (character string) the address or name of location in which to find places (only used if longitude or latitude is NULL, see vignette for more details)\\cr
       param - offset: (numeric integer) Returned data offset, default is 0\\cr
       param - limit: (numeric integer) Maximum number of results, equal to 'max_limit' field by default\\cr
       return value: A list with `count` for number of returned records, and `data` for the clean dataframe"

      return (FindPlaces(includeCities = FALSE, includeDistricts = FALSE, ...))
    },

    FindDistricts = function(...){
      "description: Method used to find all Districts and their data using the GEO db api\\cr
       param - charts: (boolean) true to return a chart map, false otherwise\\cr
       param - includeAllColumns: (boolean) Logical return all columns\\cr
       param - columns: (character vector) column names to include in returned dataframe\\cr
       param - includeDeleted: (string either ALL, or NONE, or SINCE_YESTERDAY or SINCE_LAST_WEEK, default is NONE), used to include places that were deleted\\cr
       param - namePrefix: (character string) Prefix match on Districts name\\cr
       param - name: (character string) Exact Districts name (takes priority over 'namePrefix', see vignette for more details.)\\cr
       param - maxPopulation: (numeric integer) filter by max population of Districts\\cr
       param - minPopulation: (numeric integer) filter by min population of Districts\\cr
       param - excludedCountries: (character vector) vector of excluded country names (will not include Districts from these countries)\\cr
       param - excludedCountryIds: (character vector) vector of excluded country wikiDataId's or codes (will not include Districts from these countries)\\cr
       param - includedCountries: (character vector) vector of included country names (only include Districts from these countries)\\cr
       param - includedCountryIds: (character vector) vector of included country wikiDataId's or codes (only include Districts from these countries)\\cr
       param - distanceUnit: (character string MI or KM) default value is KM, determines if distances are measured in Kilometres or Miles\\cr
       param - radius: (numeric integer) radius from location to find place, measured in distanceUnit, default is the max radius of your plan\\cr
       param - longitude: (numeric) longitude value of the nearby location in which to find places (this takes priority over locationAddress, see vignette for more details)\\cr
       param - latitude: (numeric) latitude value of the nearby location in which to find places (this takes priority over locationAddress, see vignette for more details)\\cr
       param - locationAddress: (character string) the address or name of location in which to find places (only used if longitude or latitude is NULL, see vignette for more details)\\cr
       param - offset: (numeric integer) Returned data offset, default is 0\\cr
       param - limit: (numeric integer) Maximum number of results, equal to 'max_limit' field by default\\cr
       return value: A list with `count` for number of returned records, and `data` for the clean dataframe"

      return (FindCities(includeCities = FALSE, ...))
    },

    FindCities = function(chart = FALSE,
                               includeDistricts = FALSE,
                               includeCities = TRUE,
                               includeAllColumns = FALSE,
                               columns = NULL,
                               includeDeleted = NULL,
                               namePrefix = NULL,
                               name = NULL,
                               maxPopulation = NULL,
                               minPopulation = NULL,
                               excludedCountries = NULL,
                               includedCountries = NULL,
                               excludedCountryIds = NULL,
                               includedCountryIds = NULL,
                               distanceUnit = "KM",
                               radius = NULL,
                               longitude = NULL,
                               latitude = NULL,
                               locationAddress = NULL,
                               offset = 0,
                               limit = max_limit){
      "description: Method used to find all Cities and their data using the GEO db api\\cr
       param - chart: (boolean) if TRUE render a chart before returning data\\cr
       param - charts: (boolean) true to return a chart map, false otherwise\\cr
       param - includeDistricts : (boolean) Default is false. True if you would like to include districts in the returned places, false otherwise.\\cr
       param - includeCities : (boolean)Default is true, True if you would like to include cities in the returned places, false otherwise.\\cr
       param - includeAllColumns: (boolean) Logical return all columns\\cr
       param - columns: (character vector) column names to include in returned dataframe\\cr
       param - includeDeleted: (string either ALL, or NONE, or SINCE_YESTERDAY or SINCE_LAST_WEEK, default is NONE), used to include places that were deleted\\cr
       param - namePrefix: (character string) Prefix match on Cities name\\cr
       param - name: (character string) Exact City name (takes priority over 'namePrefix', see vignette for more details.)\\cr
       param - maxPopulation: (numeric integer) filter by max population of City\\cr
       param - minPopulation: (numeric integer) filter by min population of City\\cr
       param - excludedCountries: (character vector) vector of excluded country names (will not include City from these countries)\\cr
       param - excludedCountryIds: (character vector) vector of excluded country wikiDataId's or codes (will not include City from these countries)\\cr
       param - includedCountries: (character vector) vector of included country names (only include City from these countries)\\cr
       param - includedCountryIds: (character vector) vector of included country wikiDataId's or codes (only include City from these countries)\\cr
       param - distanceUnit: (character string MI or KM) default value is KM, determines if distances are measured in Kilometres or Miles\\cr
       param - radius: (numeric integer) radius from location to find place, measured in distanceUnit, default is the max radius of your plan\\cr
       param - longitude: (numeric) longitude value of the nearby location in which to find places (this takes priority over locationAddress, see vignette for more details)\\cr
       param - latitude: (numeric) latitude value of the nearby location in which to find places (this takes priority over locationAddress, see vignette for more details)\\cr
       param - locationAddress: (character string) the address or name of location in which to find places (only used if longitude or latitude is NULL, see vignette for more details)\\cr
       param - offset: (numeric integer) Returned data offset, default is 0\\cr
       param - limit: (numeric integer) Maximum number of results, equal to 'max_limit' field by default\\cr
       return value: A list with `count` for number of returned records, and `data` for the clean dataframe"

      request_url = paste0(base_url,"cities?offset=",offset,"&distanceUnit=",distanceUnit)

      if(!is.null(limit)){
        request_url <- paste0(request_url,"&limit=",limit)
      }
      #if(!is.null(sort)){
      #request_url <- paste0(request_url,"&sort=",sort)
      #}

      if(!is.null(name)){
        request_url <- paste0(request_url,"&namePrefix=",name)
      }
      else if(!is.null(namePrefix)){
        request_url <- paste0(request_url,"&namePrefix=",namePrefix)
      }

      if(!is.null(maxPopulation)){
        request_url <- paste0(request_url,"&maxPopulation=",format(maxPopulation, scientific = FALSE))
      }
      if(!is.null(minPopulation)){
        request_url <- paste0(request_url,"&minPopulation=",format(minPopulation, scientific = FALSE))
      }
      if(!is.null(radius)){
        request_url <- paste0(request_url,"&radius=", format(radius, scientific = FALSE))
      }

      if(!is.null(latitude) && !is.null(longitude)){
        request_url <- paste0(request_url,"&location=", convertLongitudeLatitudeToISO(latitude, longitude))

      }
      else if(!is.null(locationAddress)){
        locationAddress <- getLongitudeLatitude(locationAddress)
        request_url <- paste0(request_url,"&location=",locationAddress)
      }

      if(!includeCities && !includeDistricts){
        return (list(count = 0, data = data.frame()))
      }
      else if(!includeDistricts && includeCities){
        request_url <- paste0(request_url,"&types=", "CITY")
      }
      else if(includeDistricts && !includeCities){
        request_url <- paste0(request_url,"&types=", "ADM2")
      }

      if(!is.null(includeDeleted)){
        request_url <- paste0(request_url,"&includeDeleted=", includeDeleted)
      }

      iCountries = character()

      if(!is.null(includedCountryIds)){
        iCountries = c(iCountries, as.character(c(includedCountryIds)))
      }

      if(!is.null(includedCountries)){
        codes = getClosestMatchingCountryNamesOrCodes(includedCountries)
        iCountries = c(iCountries, as.character(c(codes)))
      }

      if(length(iCountries) > 0){
        request_url <- paste0(request_url,"&countryIds=",paste(iCountries, collapse = ","))
      }

      eCountries = character()

      if(!is.null(excludedCountryIds)){
        eCountries = c(eCountries, as.character(c(excludedCountryIds)))
      }

      if(!is.null(excludedCountries)){
        codes = getClosestMatchingCountryNamesOrCodes(excludedCountries)
        eCountries = c(eCountries, as.character(c(codes)))
      }

      if(length(eCountries) > 0){
        request_url <- paste0(request_url,"&excludedCountryIds=",paste(eCountries, collapse = ","))
      }

      response <- makeRequest(request_url)
      data <- as.data.frame(response$data)
      count <- response$metadata$totalCount

      if(!is.null(name)){
        data = data[data$name == name, ]
      }
      if(!is.null(columns) && count > 0){
        data <- data[columns]
      }
      else if(!includeAllColumns){
        extraColumns = c("city")
        data <- data[, !(names(data) %in% extraColumns)]
      }

      if(chart){
        renderChart(as.data.frame(data), title = "Cities")
      }

      return (list(count = count, data = as.data.frame(data)))
    },

    FindPlaces.By.CountryAndRegion = function(chart = FALSE,
                                                   includeDistricts = TRUE,
                                                   includeCities = TRUE,
                                                   includeIslands = TRUE,
                                                   includeAllColumns = FALSE,
                                                   columns = NULL,
                                                   country = NULL,
                                                   region = NULL,
                                                   countryId = NULL,
                                                   regionId = NULL,
                                                   includeDeleted = NULL,
                                                   namePrefix = NULL,
                                                   name = NULL,
                                                   maxPopulation = NULL,
                                                   minPopulation = NULL,
                                                   offset = 0,
                                                   limit = max_limit){
      "description: Method used to find all places in a given country and region using the GEO db api\\cr
       param - chart: (boolean) if TRUE render a chart before returning data\\cr
       param - charts: (boolean) true to return a chart map, false otherwise\\cr
       param - country (conditionally required): (character string) name of the given Country (only used if countryId is NULL, see vignette for more details)\\cr
       param - countryId (conditionally required): (character string) wikidataId or country code of given country (takes priority over country param, see vignette for more details)\\cr
       param - region (conditionally required): (character string) name of the given Region (only used if regionId is NULL, see vignette for more details)\\cr
       param - regionId (conditionally required): (character string) wikidataId or region code of given region (takes priority over region param, see vignette for more details)\\cr
       param - includeDistricts : (boolean) True if you would like to include districts in the returned places, false otherwise.\\cr
       param - includeCities : (boolean) True if you would like to include cities in the returned places, false otherwise.\\cr
       param - includeIslands : (boolean) True if you would like to include islands in the returned places, false otherwise.\\cr
       param - includeAllColumns: (boolean) Logical return all columns\\cr
       param - columns: (character vector) column names to include in returned dataframe\\cr
       param - includeDeleted: (string either ALL, or NONE, or SINCE_YESTERDAY or SINCE_LAST_WEEK, default is NONE), used to include places that were deleted\\cr
       param - namePrefix: (character string) Prefix match on place name\\cr
       param - name: (character string) Exact place name (takes priority over 'namePrefix', see vignette for more details.)\\cr
       param - maxPopulation: (numeric integer) filter by max population of places.\\cr
       param - minPopulation: (numeric integer) filter by min population of places.\\cr
       param - offset: (numeric integer) Returned data offset, default is 0\\cr
       param - limit: (numeric integer) Maximum number of results, equal to 'max_limit' field by default\\cr
       return value: A list with `count` for number of returned records, and `data` for the clean dataframe"

      if((is.null(country) && is.null(countryId)) || (is.null(region) && is.null(regionId))){
        print("ERROR: either country or countryId is required, and either region or regionId is required.")
        return (NULL)
      }

      cId <- NULL
      if(!is.null(countryId)){
        cId <- countryId
      }
      else{
        countryMatches <- FindCountries(name = country)

        if(is.null(countryMatches) || countryMatches$count < 1){
          print(paste0("ERROR: No matching country '",country,"' found."))
          return (NULL)
        }
        cId <- (countryMatches$data[1,'wikiDataId'])
      }

      rId <- NULL
      if(!is.null(regionId)){
        rId <- regionId
      }
      else{
        regionMatches <- FindRegions.ByCountry(countryId = as.character(cId), name = region)

        if(is.null(regionMatches) || regionMatches$count < 1){
          print(paste0("ERROR: No matching region '",region,"' found."))
          return (NULL)
        }
        rId <- (regionMatches$data[1,'isoCode'])
      }

      request_url = paste0(base_url,"countries/",cId,"/regions/",rId,"/places?offset=",offset)

      if(!is.null(limit)){
        request_url <- paste0(request_url,"&limit=",limit)
      }
      #if(!is.null(sort)){
      #request_url <- paste0(request_url,"&sort=",sort)
      #}

      if(!is.null(name)){
        request_url <- paste0(request_url,"&namePrefix=",name)
      }
      else if(!is.null(namePrefix)){
        request_url <- paste0(request_url,"&namePrefix=",namePrefix)
      }

      if(!is.null(maxPopulation)){
        request_url <- paste0(request_url,"&maxPopulation=",format(maxPopulation, scientific = FALSE))
      }
      if(!is.null(minPopulation)){
        request_url <- paste0(request_url,"&minPopulation=",format(minPopulation, scientific = FALSE))
      }

      typeVec = character()

      if(includeDistricts){
        typeVec = c(typeVec, as.character(c("ADM2")))
      }
      if(includeCities){
        typeVec = c(typeVec, as.character(c("CITY")))
      }
      if(includeIslands){
        typeVec = c(typeVec, as.character(c("ISLAND")))
      }

      if(length(typeVec) == 0){
        return (list(count = 0, data = data.frame()))
      }
      else if(length(typeVec) < 3){
        request_url <- paste0(request_url,"&types=",paste(typeVec, collapse = ","))
      }

      if(!is.null(includeDeleted)){
        request_url <- paste0(request_url,"&includeDeleted=", includeDeleted)
      }

      response <- makeRequest(request_url)
      data <- as.data.frame(response$data)
      count <- response$metadata$totalCount

      if(!is.null(name)){
        data = data[data$name == name, ]
      }
      if(!is.null(columns) && count > 0){
        data <- data[columns]
      }
      else if(!includeAllColumns){
        extraColumns = c("city")
        data <- data[, !(names(data) %in% extraColumns)]
      }

      if(chart){
        renderChart(as.data.frame(data), title = "Places by Country/Region")
      }


      return (list(count = count, data = as.data.frame(data)))
    },

    FindRegions.ByCountry = function(chart = FALSE, includeAllColumns = FALSE, columns = NULL, country = NULL, countryId = NULL, limit = max_limit, offset = 0, name = NULL){
      "description: Method used to find all Regions and their data in a given country using the GEO db api\\cr
       param - chart: (boolean) if TRUE render a chart before returning data\\cr
       param - country (conditionally required): (character string) name of the given Country (only used if countryId is NULL, see vignette for more details)\\cr
       param - countryId (conditionally required): (character string) wikidataId or country code of given country (takes priority over country param, see vignette for more details)\\cr
       param - includeAllColumns: (boolean) Logical return all columns\\cr
       param - columns: (character vector) column names to include in returned dataframe\\cr
       param - name: (character string) Exact place name (takes priority over 'namePrefix', see vignette for more details.)\\cr
       param - offset: (numeric integer) Returned data offset, default is 0\\cr
       param - limit: (numeric integer) Maximum number of results, equal to 'max_limit' field by default\\cr
       return value: A list with `count` for number of returned records, and `data` for the clean dataframe"

      if(is.null(country) && is.null(countryId)){
        print("ERROR: Either 'country' or 'countryId' parameter is required for this function.")
        return (NULL)
      }

      id <- NULL
      if(!is.null(countryId)){
        id <- countryId
      }
      else{
        countryMatches <- FindCountries(name = country)

        if(is.null(countryMatches) || countryMatches$count < 1){
          print(paste0("ERROR: No matching country '",country,"' found."))
          return (NULL)
        }
        id <- (countryMatches$data[1,'wikiDataId'])
      }

      request_url = paste0(base_url,"countries/",id,"/regions/?offset=",offset)

      if(!is.null(limit)){
        request_url <- paste0(request_url,"&limit=",limit)
      }

      response <- makeRequest(request_url)
      data <- as.data.frame(response$data)
      count <- response$metadata$totalCount

      if(!is.null(name)){
        data = data[data$name == name | data$isoCode == name, ]
      }
      if(!is.null(columns) && count > 0){
        data <- data[columns]
      }
      else if(!includeAllColumns){
        extraColumns = c("city")
        data <- data[, !(names(data) %in% extraColumns)]
      }

      if(chart){
        renderChart(as.data.frame(data), title = "Regions by Country")
      }


      return (list(count = count, data = as.data.frame(data)))
    },

    Distance.Between.Places = function(distanceUnit = "KM",fromId = NULL , fromAddress = NULL, fromName= NULL, toId= NULL, toAddress= NULL, toName= NULL){
      "description: Method used to determine the distance between 2 places\\cr
       param - fromId (conditionally required): (character string) the wikidataId of the from place. (Takes priority over fromName and fromAddress, see vignette for more details)\\cr
       param - fromName (conditionally required): (character string) the Name of the from place. (Only used if fromId is NULL, see vignette for more details)\\cr
       param - fromAddress (conditionally required): (character string) the Name of the from place. (Only used if fromId is NULL, see vignette for more details)\\cr
       param - toId (conditionally required): (character string) the wikidataId of the to place. (Takes priority over toName and toAddress, see vignette for more details)\\cr
       param - toName (conditionally required): (character string) the Name of the to place. (Only used if toId is NULL, see vignette for more details)\\cr
       param - toAddress (conditionally required): (character string) the Name of the to place. (Only used if toId is NULL, see vignette for more details)\\cr
       param - distanceUnit (default is KM) : (character string either KM or MI) determines if distances are measured in miles or kilometres.
       return value: The numeric value of the distance between the 2 places.
      "

      if((is.null(fromId) && is.null(fromName) && is.null(fromAddress)) ||(is.null(toId) && is.null(toName) && is.null(toAddress)) ){
        print("ERROR: Both a from and to parameter are required")

        return (NULL)
      }

      fid <- NULL
      if(!is.null(fromId)){
        fid <- fromId
      }
      else if(!is.null(fromAddress)){
        places <- FindPlaces(locationAddress = fromAddress, name = fromName)

        if(is.null(places) || places$count < 1){
          print(paste0("ERROR: No matching from place found."))
          return (NULL)
        }

        places$distance =  as.numeric(places$distance)
        places$data <- places$data[order(places$data$distance, decreasing = FALSE), ]
        fid <- (places$data[1,'wikiDataId'])
      }
      else{
        places <- FindPlaces(name = fromName)

        if(is.null(places) || places$count < 1){
          print(paste0("ERROR: No matching from place found."))
          return (NULL)
        }
        fid <- (places$data[1,'wikiDataId'])
      }

      tid <- NULL
      if(!is.null(toId)){
        tid <- toId
      }
      else if(!is.null(toAddress)){
        places <- FindPlaces(locationAddress = toAddress, name = toName)

        if(is.null(places) || places$count < 1){
          print(paste0("ERROR: No matching to place found."))
          return (NULL)
        }
        places$distance =  as.numeric(places$distance)
        places$data <- places$data[order(places$data$distance, decreasing = FALSE), ]
        tid <- (places$data[1,'wikiDataId'])
      }
      else{
        places <- FindPlaces(name = toName)

        if(is.null(places) || places$count < 1){
          print(paste0("ERROR: No matching to place found."))
          return (NULL)
        }
        tid <- (places$data[1,'wikiDataId'])
      }

      request_url = paste0(base_url,"places/",fid,"/distance/?toPlaceId=",tid,"&distanceUnit=",distanceUnit)

      response <- makeRequest(request_url)

      return (response$data)
    }
  )
)
