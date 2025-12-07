input_raw <- readLines("07/input")
# Part 1

# Interpret the input as one big character matrix
mx <- do.call(rbind, purrr::map(strsplit(input_raw, split = ""), \(row) matrix(row, nrow = 1)))

fill_beams <- function(mx) {
    splits <- 0
    # Skip the first row
    for (row in seq_len(nrow(mx) - 1) + 1) {
        for (col in seq_len(ncol(mx))) {
            if (mx[row - 1, col] == "S") {
                mx[row, col] <- "|"
            }
            if (mx[row, col] == "." && mx[row - 1, col] == "|") {
                mx[row, col] <- "|"
            }
            if (mx[row, col] == "^" && mx[row - 1, col] == "|") {
                splits <- splits + 1
                mx[row, col - 1] <- "|"
                mx[row, col + 1] <- "|"
            }
        }
    }
    list(mx = mx, count = splits)
}
res <- fill_beams(mx)

# part one:
res$count


# part two

# too slow naive recursive sol

# follow_beam_paths <- function(mx) {
#     follow <- function(row, col) {
#         if (row >= nrow(mx)) {
#             1
#         } else if (mx[row, col] == "^") {
#             Recall(row, col - 1) + Recall(row, col + 1)
#         } else {
#             Recall(row + 1, col)
#         }
#     }
#     follow(2, which(mx[1, ] == "S"))
# }
# follow_beam_paths(mx)

# Calculate the number of paths,
# Store counts in a table we fill "bottom up"
calculate_path_possibilities <- function(mx) {
    paths <- matrix(0L, nrow(mx), ncol(mx))
    paths[nrow(mx), ] <- 1
    # Skip the last row
    for (row in rev(seq_len(nrow(mx) - 1))) {
        # First scan: the empty cells
        for (col in seq_len(ncol(mx))) {
            if (mx[row, col] %in% c("S", ".")) {
                paths[row, col] <- paths[row + 1, col]
            }
        }
        # Second scan: splitters
        for (col in seq_len(ncol(mx))) {
            if (mx[row, col] == "^") {
                paths[row, col] <- paths[row, col - 1] + paths[row, col + 1]
            }
        }
    }
    # Result is the number of paths in the start
    list(paths = paths, count = paths[1, which(mx[1, ] == "S")])
}
res <- calculate_path_possibilities(mx)
sprintf("%.10f", res$count)
