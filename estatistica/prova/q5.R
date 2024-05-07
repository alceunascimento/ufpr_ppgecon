rm(list = ls())

# q5 geral
alpha <- 0.05

n <- 1000
n_sqrt <- sqrt(n)

t <- qt(p = alpha/2, df = (n-1), lower.tail = FALSE)


# q5 - qty
m_qty <- 14.564
sd_qty <- 3.956964
m_qty_lower <- m_qty - ( t * (sd_qty / n_sqrt) )
m_qty_upper <- m_qty + ( t * (sd_qty / n_sqrt) )
m_qty_upper
m_qty_lower

# q5 - preco
m_p <- 54.45
sd_p <- 69.4559
m_p_lower <- m_p - ( t * (sd_p / n_sqrt) )
m_p_upper <- m_p + ( t * (sd_p / n_sqrt) )
m_p_upper
m_p_lower

# q5 - receita
m_r <- 752.3
sd_r <- 928.0333808
m_r_lower <- m_r - ( t * (sd_r / n_sqrt) )
m_r_upper <- m_r + ( t * (sd_r / n_sqrt) )
m_r_upper
m_r_lower


# q5 b

res.b <- prob <- 1 - pnorm(815, mean = m_r, sd = sd_r)
