input_raw <- readLines("06/input")
# Part 1
only_single_spaces <- trimws(gsub(" +", " ", input_raw))
mx <- t(do.call(rbind, purrr::map(strsplit(only_single_spaces, split = " "), \(row) matrix(row, nrow = 1))))

op <- mx[, (ncol(mx))]
numbers <- matrix(as.numeric(mx[, -(ncol(mx))]), nrow = nrow(mx))


res <- numeric(nrow(numbers))

add <- op == "+"
mul <- op == "*"

res[add] <- rowSums(numbers[add, ])
res[mul] <- apply(numbers[mul, ] , 1, prod)
sprintf("%.10f", sum(res))

# Part 2

# Interpret the input as one big charachter matrix
str_mx <- do.call(rbind, purrr::map(strsplit(input_raw, split = ""), \(row) matrix(row, nrow = 1)))

# mx must the submatrix
parse_problem <- function(mx) {
    op <- mx[nrow(mx), 1]
    numeric_parts <- mx[-nrow(mx), ]
    # Dont want empty numbers
    numeric_parts <- numeric_parts[, colSums(numeric_parts != " ") >= 1]
    # Concat each col as one string
    nums <- apply(numeric_parts, 2, paste0, collapse = "")
    # Parse strings as numbers and apply the op
    if (op == "*") {
        prod(as.numeric(nums))
    } else {
        sum(as.numeric(nums))
    }
}

# Identifies the subproblem-matrices
cephalopod_reading <- function(str_mx) {
    problems <- list()
    problem_begin <- NULL
    op_row <- nrow(str_mx)
    for (col in seq_len(ncol(str_mx))) {
        if (str_mx[op_row, col] != " ") {
            if (!is.null(problem_begin)) {
                problems <- c(problems, list(parse_problem(str_mx[, problem_begin:(col - 1)])))
            }
            problem_begin <- col
        }
    }
    problems <- c(problems, list(parse_problem(str_mx[, problem_begin:ncol(str_mx)])))
    problems
}
res <- cephalopod_reading(str_mx)
sprintf("%.10f", sum(unlist(res)))
