#============================================================================
#### SCRIPT FOR A WORKBENCH ####
#============================================================================

# SETUP ----
## definir notação cientifica off em numeros menores que 1.000.000.000.000 ----
## definir qual o tipo do separador (ponto ou virgula) ----
options(scipen = 10, digits = 10, OutDec = ".")

# MAINTENANCE ----
## limpar a bancada de trabalho ----
rm(list = ls())
## remover algo específico ----
rm()

# WORKBENCH ----

## settings ----
set.seed()

## work 01 ----

### simulated data ----
sim.df <- 
  tibble(
  "Numerico" = 1:100,
  "Categorico" = sample(
    x = c("Cat1", "Cat2", "Cat3", "Cat4", "Cat5"),
    size = 100,
    replace = TRUE
  )
)

### loading data ----
df <- 
  read_csv(
    file = "./data/[x].csv",
    show_col_types = FALSE
  )
df <- 
  read_csv2(                  # use 2 quando o separador é ";" e decimal ","
    file = "./data/[x].csv",
    show_col_types = FALSE
  )

url <- "http://gattonweb.uky.edu/sheather/book/docs/datasets/magazines.csv"
nyc <- read_csv(url)
glimpse(nyc)




### working with data ----