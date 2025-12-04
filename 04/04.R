input_raw <- readLines("04/input")
"@." == "@_"
mx <- do.call(rbind, purrr::map(strsplit(input_raw, split = ""), \(row) matrix(row, nrow = 1)))

find_accessible <- function(mx) {
    # For any @ add a 1 to their neighbors
    surrounded <- matrix(0L, nrow(mx) + 2, ncol(mx) + 2)
    dirs <- expand.grid(c(-1, 0, 1), c(-1, 0, 1))[-5, ]
    for (dir_i in seq_len(nrow(dirs))) {
        dir <- unlist(dirs[dir_i,])
        rows <- 1 + dir[1] + seq_len(nrow(mx))
        cols <- 1 + dir[2] + seq_len(ncol(mx))
        surrounded[rows, cols] <- surrounded[rows, cols] + (mx == "@")
    }
    real_spots <- surrounded[c(-1, -nrow(surrounded)), c(-1, -ncol(surrounded))]
    real_spots < 4 & mx == "@"
}

# Part 1
sum(find_accessible(mx))

reduce_as_long_as_possible <- function(mx) {
    removed.total <- 0
    while(TRUE) {
        access <- find_accessible(mx)
        removed.total <- removed.total + sum(access)
        if (!any(access)) {
            return(list(mx = mx, rem = removed.total))
        }
        mx[access] <- "."
    }
}
# Part two
reduce_as_long_as_possible(mx)$rem
