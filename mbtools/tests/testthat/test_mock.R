context("mock diagnostics")

# A small mock table
taxa <- data.frame(
    kingdom = sample(letters[1:3], 100, replace = TRUE),
    genus = sample(letters[4:10], 100, replace = TRUE),
    species = sample(letters[11:26], 100, replace = TRUE)
)

test_that("taxa can be found and counted", {
    fi <- taxa_metrics(taxa, taxa)
    expect_equivalent(fi$found, rep(1, 3))
    expect_equal(nrow(fi), 3)

    fi <- taxa_metrics(taxa, taxa[-1, ])
    expect_true(all(fi$found <= 1))
    expect_equal(nrow(fi), 3)
})

test_that("taxa quantification can be calculated", {
    taxa <- cbind(taxa, runif(100))
    q <- taxa_quants(taxa, taxa)
    expect_equal(colnames(q), c("level", "name", "measured", "reference"))
    expect_true(all(q$level %in% names(taxa)[-4]))
    expect_equal(q$measured, q$reference)

    p <- mock_plot(taxa, taxa)
    expect_true("ggplot" %in% class(p))
})
