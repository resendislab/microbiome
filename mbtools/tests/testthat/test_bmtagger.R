context("H. sapiens sequence removal")

test_that("bmtagger index files can be created", {
    with_mock(
        system2 = function(...) print("system2"),
        expect_output(build_index(where = tempdir(),
                      genome_file = "mock.fa"), "system2")
    )
})

test_that("sequences can be removed", {
    d <- tempdir()
    seqs <- replicate(100,
        paste(sample(c("A", "C", "G", "T"), 100, replace = TRUE),
                     collapse = ""))
    quals <- replicate(100, paste(rep("@", 100), collapse = ""))
    sr <- ShortReadQ(sread = DNAStringSet(seqs),
                     quality = BStringSet(quals),
                     id = BStringSet(paste0("S", 1:100)))
    old_files <- list.files(d, "fastq", recursive = TRUE, full.names = TRUE)
    file.remove(old_files)
    writeFastq(sr, file.path(d, "f.fastq.gz"))
    writeFastq(sr, file.path(d, "r.fastq.gz"))
    writeFastq(sr, file.path(d, "i.fastq.gz"))

    reads <- file.path(d, c("f.fastq.gz", "r.fastq.gz"))
    index <- file.path(d, "i.fastq.gz")
    write("S1", file = file.path(d, "human.txt"))
    dir.create(file.path(d, "nh"), showWarnings = FALSE)

    with_mock(system2 = function(...) print("system2"),
        out <- capture.output(counts <- remove_human(reads, index,
            file.path(d, "nh"), d)),
        expect_true(grepl("system2", out)),
        expect_equal(counts, c(reads = 99, removed = 1))
    )
})
