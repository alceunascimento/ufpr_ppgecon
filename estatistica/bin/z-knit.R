## knit file
rmarkdown::render(input = "./estatistica/bin/exercicio1.Rmd", 
                  output_file = "Exerc_1-Descritiva_alceunascimento_20240418.pdf", 
                  output_dir = "./estatistica/output",
                  output_options = list(keep_tex = TRUE)
)

