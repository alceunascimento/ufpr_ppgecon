# knit file

# Gerar a data e hora atual no formato YYYY_MM_DD_HHMMSS
data_hora_atual <- format(Sys.time(), "%Y_%m_%d_%H%M%S")

# Definir o nome do arquivo de saída incluindo a data e hora atual
arquivo_saida <- paste0("ufpr_artigo_", data_hora_atual, ".pdf")

#knit
rmarkdown::render(input = "./ufpr_artigo_template.Rmd", 
                  output_file = arquivo_saida, 
                  output_dir = "./output",
                  output_options = list(keep_tex = TRUE)
)

