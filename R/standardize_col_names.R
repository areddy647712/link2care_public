# =============================================================================
# standardize_col_names
# 2021-07-12
# =============================================================================

# Used to do an initial cleaning of the QDS column names.
#   * Remove _v{1, 2, 3} and v{1, 2, 3} from column names
#   * Replace spaces with underscores
#   * Convert to lower case
#   * Add underscore in-between the abbreviated tool name and question number
# This won’t be perfect, but it will drastically reduce the number of manual changes we have to make.

standardize_col_names <- function(.data) {
  # Get the existing column names
  # When used inside of rename_with(), the column names are automatically
  # passed into the function with/as .data. There is no need for names(.data).
  old_names <- .data
  # Create a string that contains _V1 through _V5 and V1 through V5 to pass to
  # the regular expression below
  v_num <- paste0("_V", 1:5, collapse = "|")
  vnum <- paste0("V", 1:5, collapse = "|")
  v_pattern <- paste(paste(v_num, vnum, sep = "|"), collapse = "|")
  # Remove _v{1, 2, 3} from column name
  # Remove v{1, 2, 3} at end of column name (e.g., DEM1v3)
  new_names <- stringr::str_replace(old_names, v_pattern, "")
  # Replace spaces with underscores
  new_names <- stringr::str_replace_all(new_names, " ", "_")
  # Convert to lower case
  new_names <- stringr::str_to_lower(new_names)
  # Add underscore in-between the abbreviated tool name and question number
  new_names <- stringr::str_replace(new_names, "([a-z])(\\d)", "\\1_\\2")
  
  # Check for duplicate names
  # -------------------------
  if (!length(new_names) == length(unique(new_names))) {
    name_counts <- table(new_names)
    dup_names <- name_counts[name_counts > 1]
    dup_names <- names(dup_names)
    # Create a vector of names to follow-up on and change manually
    names_to_check <- vector(mode = "character")
    # Set the column names back to their original names
    for (i in seq_along(dup_names)) {
      index <- which(new_names == dup_names[[i]])
      new_names[index] <- old_names[index]
      # Add column names to follow-up on to names_to_check
      names_to_check <- c(names_to_check, old_names[index])
    }
    # Assign names_to_check to the global environment
    # assign("names_to_check", names_to_check, envir = .GlobalEnv)
    # Print a message letting the user know what happened
    warning(
      "Warning: The following column name(s) could not be standardized because it/they would have created a duplicate column name: ", 
      paste(names_to_check, collapse = ", "), "\n"
    )
  }
  
  # Return character vector of standardized column names
  new_names
}

# For testing
# standardize_col_names(names(v2))
# rename_with(v2, standardize_col_names)