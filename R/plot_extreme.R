#' plot_extreme
#'
#' Graphs a line plot of a row with the highest metric in a matrix, produced by
#' \code{\link{daily_response}} function.
#'
#' @param result_daily_response a list with three objects as produced by
#' daily_response function
#' @param title logical, if set to FALSE, no plot title is displayed
#' @param ylimits limit of the y axes. It should be given as ylimits = c(0,1)
#' @param reference_window character string, the reference_window argument describes,
#' how each calculation is referred. There are three different options: 'start'
#' (default), 'end' and 'middle'. If the reference_window argument is set to 'start',
#' then each calculation is related to the starting day of window. If the
#' reference_window argument is set to 'middle', each calculation is related to the
#' middle day of window calculation. If the reference_window argument is set to
#' 'end', then each calculation is related to the ending day of window calculation.
#' For example, if we consider correlations with window from DOY 15 to DOY 35. If
#' reference window is set to ‘start’, then this calculation will be related to the
#' DOY 15. If the reference window is set to ‘end’, then this calculation will be
#' related to the DOY 35. If the reference_window is set to 'middle', then this
#' calculation is related to DOY 25.
#'
#' @return A ggplot2 object containing the plot display
#'
#' @examples
#' \dontrun{
#' data(LJ_daily_temperatures)
#' data(example_proxies_1)
#' Example1 <- daily_response(response = example_proxies_1,
#' env_data = LJ_daily_temperatures, method = "lm", metric = "r.squared",
#' fixed_width = 90, previous_year = TRUE, row_names_subset = TRUE)
#' plot_extreme(Example1)
#'
#' Example2 <- daily_response(response = example_proxies_1,
#' env_data = LJ_daily_temperatures, method = "brnn",
#' metric = "adj.r.squared", lower_limit = 50, upper_limit = 55, neurons = 1,
#' row_names_subset = TRUE, previous_year = TRUE)
#' plot_extreme(Example2)
#'
#' # Example with negative correlations
#' data(data_TRW_1)
#' LJ_daily_temperatures_subset = LJ_daily_temperatures[-c(53:55), ]
#' Example3 <- daily_response(response = data_TRW_1,
#' env_data = LJ_daily_temperatures_subset, method = "lm", metric = "adj.r.squared",
#' lower_limit = 35, upper_limit = 40, previous_year = TRUE, row_names_subset = TRUE)
#' plot_extreme(Example3)
#'
#' Example4 <- daily_response(response = example_proxies_1,
#' env_data = LJ_daily_temperatures, method = "lm",
#' metric = "r.squared", lower_limit = 30, upper_limit = 120, neurons = 1,
#' row_names_subset = TRUE, previous_year = TRUE)
#' plot_extreme(Example4)
#' }
#'
#' @keywords internal

plot_extreme <- function(result_daily_response, title = TRUE, ylimits = NULL, reference_window = "start") {

  # Short description of the function. It
  # - extracts matrix (the frst object of a list)
  # - in case of method == "cor" (second object of a list), calculates the
  # highest minimum and maximum and compare its absolute values. If absolute
  # minimum is higher than maximum, we have to plot minimum correlations.
  # - query the information about windows width (row names of the matrix) and
  # starting day of the highest (absolute) metric (column names of the matrix).
  # - draws a ggplot line plot.

  # A) Extracting a matrix from a list and converting it into a data frame
  result_daily_element1 <- data.frame(result_daily_response[[1]])

  # With the following chunk, overall_maximum and overall_minimum values of
  # result_daily_element1 matrix are calculated.
  overall_max <- max(result_daily_element1, na.rm = TRUE)
  overall_min <- min(result_daily_element1, na.rm = TRUE)

  # absolute vales of overall_maximum and overall_minimum are compared and
  # one of the following two if functions is used
    # There are unimportant warnings produced:
    # no non-missing arguments to max; returning -Inf
    # Based on the answer on the StackOverlow site:
    # https://stackoverflow.com/questions/24282550/no-non-missing-arguments-warning-when-using-min-or-max-in-reshape2
    # Those Warnings could be easily ignored
  if ((abs(overall_max) > abs(overall_min)) == TRUE) {

    # maximum value is located. Row indeces are needed to query information
    # about the window width used to calculate the maximum. Column name is
    # needed to query the starting day.
    max_result <- suppressWarnings(which.max(apply(result_daily_element1,
      MARGIN = 2, max, na.rm = TRUE)))
    plot_column <- max_result
    max_index <- which.max(result_daily_element1[, names(max_result)])
    row_index <- row.names(result_daily_element1)[max_index]
    temporal_vector <- unlist(result_daily_element1[max_index, ])
    temporal_vector <- data.frame(temporal_vector)
    calculated_metric <- round(max(temporal_vector, na.rm = TRUE), 3)

    # Here we remove missing values at the end of the temporal_vector.
    # It is important to remove missing values only at the end of the
    # temporal_vector!
    row_count <- nrow(temporal_vector)
    delete_rows <- 0
    while (is.na(temporal_vector[row_count, ] == TRUE)){
      delete_rows <- delete_rows + 1
      row_count <-  row_count - 1
    }
    # To check if the last row is a missing value
    if (is.na(temporal_vector[nrow(temporal_vector), ] == TRUE)) {
      temporal_vector <-  temporal_vector[-c(row_count:(row_count +
                                                            delete_rows)), ]
    }
    temporal_vector <- data.frame(temporal_vector)
  }

  if ((abs(overall_max) < abs(overall_min)) == TRUE) {

    # minimum value is located. Row indeces are needed to query information
    # about the window width used to calculate the minimum. Column name is
    # needed to query the starting day.
    min_result <- suppressWarnings(which.min(apply(result_daily_element1,
      MARGIN = 2, min, na.rm = TRUE)))
    plot_column <- min_result
    min_index <- which.min(result_daily_element1[, names(min_result)])
    row_index <- row.names(result_daily_element1)[min_index]
    temporal_vector <- unlist(result_daily_element1[min_index, ])
    temporal_vector <- data.frame(temporal_vector)
    calculated_metric <- round(min(temporal_vector, na.rm = TRUE), 3)

    # Here we remove missing values
    # We remove missing values at the end of the temporal_vector.
    # It is important to remove missing values only at the end of the
    # temporal_vector!

    row_count <- nrow(temporal_vector)
    delete_rows <- 0
    while (is.na(temporal_vector[row_count, ] == TRUE)){
      delete_rows <- delete_rows + 1
      row_count <-  row_count - 1
    }
    # To check if the last row is a missing value
    if (is.na(temporal_vector[nrow(temporal_vector), ] == TRUE)) {
      temporal_vector <-  temporal_vector[-c(row_count:(row_count +
                                                            delete_rows)), ]
    }
    temporal_vector <- data.frame(temporal_vector)
}
  # In case of previous_year == TRUE, we calculate the day of a year
  # (plot_column), considering 366 days of previous year.
  if (nrow(temporal_vector) > 366 & plot_column > 366) {
    plot_column_extra <- plot_column %% 366
  } else {
    plot_column_extra <- plot_column
  }

  # The final plot is being created. The first part of a plot is the same,
  # the second part is different, depending on temporal.vector, plot_column,
  # method and metric string stored in result_daily_response. The second part
  # defines xlabs, xlabs and ggtitles.

  # The definition of theme
  journal_theme <- theme_bw() +
    theme(axis.text = element_text(size = 16, face = "bold"),
          axis.title = element_text(size = 18), text = element_text(size = 18),
          plot.title = element_text(size = 16,  face = "bold"))

  if (title == FALSE){
    journal_theme <- journal_theme +
      theme(plot.title = element_blank())
  }


  # Here we define a data frame of dates and corresponing day of year (doi). Later
  # this dataframe will be used to describe tht optimal sequence od days
  doy <- seq(1:730)
  date <- seq(as.Date('2013-01-01'),as.Date('2014-12-31'), by = "+1 day")
  # date[366] <- as.Date('2015-12-31')
  date <- format(date, "%b %d")
  date_codes <- data.frame(doy = doy, date = date)

  # Here, there is a special check if optimal window width is divisible by 2 or not.
  if (as.numeric(row_index)%%2 == 0){
    adjustment_1 = 0
    adjustment_2 = 1
  } else {
    adjustment_1 = 1
    adjustment_2 = 2
  }

  if (reference_window == "start"){
    Optimal_string <- paste("\nOptimal Selection:",
    as.character(date_codes[plot_column_extra, 2]),"-",
    as.character(date_codes[plot_column_extra + as.numeric(row_index) - 1, 2]))
  } else if (reference_window == "end") {
    Optimal_string <- paste("\nOptimal Selection:",
    as.character(date_codes[plot_column_extra - as.numeric(row_index) + 1, 2]),"-",
    as.character(date_codes[plot_column_extra, 2]))
  } else if (reference_window == "middle") {
    Optimal_string <- paste("\nOptimal Selection:",
    as.character(date_codes[(round2((plot_column_extra - as.numeric(row_index)/2)) - adjustment_1), 2]),"-",
    as.character(date_codes[(round2((plot_column_extra + as.numeric(row_index)/2)) - adjustment_2), 2]))
  }

  # in the next chunk, warnings are supressed. At the end of the vector,
  # there are always missing values, which are a result of changing window
  # width calclulations. Those warnings are not important and do not affect
  # our results at all
  final_plot <- suppressWarnings(
  ggplot(temporal_vector, aes(y = temporal_vector,
    x = seq(1, length(temporal_vector)))) + geom_line(lwd = 1.2) +
     geom_vline(xintercept = plot_column, col = "red") +
     scale_x_continuous(breaks = sort(c(seq(0, nrow(temporal_vector), 50)), decreasing = FALSE),
       labels = sort(c(seq(0, nrow(temporal_vector), 50)))) +
     scale_y_continuous(limits = ylimits) +
       annotate("label", label = as.character(calculated_metric),
         y = calculated_metric, x = plot_column + 15) +
    annotate("label", label = paste("Day", as.character(plot_column), sep = " "),
             y = min(temporal_vector, na.rm = TRUE) + 0.2*min(temporal_vector, na.rm = TRUE), x = plot_column + 15) +
    journal_theme)

  # If previous_year = TRUE, we add a vertical line with labels of
  # previous and current years
  if (ncol(result_daily_element1) > 366) {
    final_plot <- final_plot +
      annotate(fontface = "bold", label = 'Previous Year', geom = 'label',
               x = 366 - ncol(result_daily_element1) / 12.8,
               y = calculated_metric - (calculated_metric/5)) +
      annotate(fontface = "bold", label = 'Current Year', geom = 'label',
               x = 366 + ncol(result_daily_element1) / 13.5,
               y = calculated_metric -(calculated_metric/5)) +
      geom_vline(xintercept = 366, size = 1)
  }

  # Here we define titles. They differ importantly among methods and arguments
  # in the final output list from daily_response() function
  if (result_daily_response[[2]] == "cor"){
    y_lab <- "Correlation Coefficient"
  } else if (result_daily_response[[3]] == "r.squared"){
    y_lab <- "Explained Variance"
  } else if (result_daily_response[[3]] == "adj.r.squared"){
    y_lab <- "Adjusted Explained Variance"
  }

  if (nrow(temporal_vector) > 366){
    x_lab <- "Day of Year  (Including Previous Year)"
  } else if (nrow(temporal_vector) <= 366){
    x_lab <- "Day of Year"
  }

  if (reference_window == 'start' &&  plot_column > 366 && nrow(temporal_vector) > 366){
    reference_string <- paste0("\nStarting Day of Optimal Window Width: Day ",
                         plot_column_extra, " of Current Year")}

  if (reference_window == 'start' &&  plot_column <= 366 && nrow(temporal_vector) > 366){
    reference_string <- paste0("\nStarting Day of Optimal Window Width: Day ",
                               plot_column_extra, " of Previous Year")}

  if (reference_window == 'start' &&  plot_column <=  366 && nrow(temporal_vector) <=  366){
    reference_string <- paste0("\nStarting Day of Optimal Window Width: Day ",
                               plot_column_extra)}


  if (reference_window == 'end' &&  plot_column > 366 && nrow(temporal_vector) > 366){
    reference_string <- paste0("\nEnding Day of Optimal Window Width: Day ",
                               plot_column_extra, " of Current Year")}

  if (reference_window == 'end' &&  plot_column  <= 366 && nrow(temporal_vector) > 366){
    reference_string <- paste0("\nEnding Day of Optimal Window Width: Day ",
                               plot_column_extra, " of Previous Year")}

  if (reference_window == 'end' &&  plot_column  <=  366 && nrow(temporal_vector) <=  366){
    reference_string <- paste0("\nEnding Day of Optimal Window Width: Day ",
                               plot_column_extra)}


  if (reference_window == 'middle' &&  plot_column > 366 && nrow(temporal_vector) > 366){
    reference_string <- paste0("\nMiddle Day of Optimal Window Width: Day ",
                               plot_column_extra, " of Current Year")}

  if (reference_window == 'middle' &&  plot_column  <= 366 && nrow(temporal_vector) > 366){
    reference_string <- paste0("\nMiddle Day of Optimal Window Width: Day ",
                               plot_column_extra, " of Previous Year")}

  if (reference_window == 'middle' &&  plot_column  <=  366 && nrow(temporal_vector) <=  366){
    reference_string <- paste0("\nMiddle Day of Optimal Window Width: Day ",
                               plot_column_extra)}

  optimal_window_string <- paste0("\nOptimal Window Width: ", as.numeric(row_index),
                                  " Days")

  optimal_calculation <- paste0("\nThe Highest ", y_lab,": " , calculated_metric)

  period_string <- paste0("Analysed Period: ", result_daily_response[[4]])

  if (result_daily_response[[2]] == 'cor'){
    method_string <- paste0("\nMethod: Pearson Correlation")
  } else if (result_daily_response[[2]] == 'lm'){
    method_string <- paste0("\nMethod: Linear Regression")
  } else if (result_daily_response[[2]] == 'brnn'){
    method_string <- paste0("\nMethod: ANN with Bayesian Regularization")
  }

  final_plot <- final_plot +
    ggtitle(paste0(period_string, method_string, optimal_calculation,
                   optimal_window_string, reference_string, Optimal_string)) +
    xlab(x_lab) +
    ylab(y_lab)

  final_plot

}
