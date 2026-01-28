library(tidyverse)
library(lubridate)

ff_raw <- read_csv("F-F_Research_Data_Factors_daily.csv")

ff <- ff_raw %>%
  rename(date = 1) %>%              # first column is the date
  mutate(
    date = ymd(date),               # 19260701 → Date
    `Mkt.RF` = as.numeric(`Mkt-RF`),
    RF      = as.numeric(RF),
    SMB     = as.numeric(SMB),
    HML     = as.numeric(HML)
  ) %>%
  arrange(date)

head(ff)
summary(ff$`Mkt.RF`)

library(tidyverse)
library(lubridate)

# 1. Read one stock file and clean prices
read_stock <- function(file, ticker) {
  read_csv(file, col_types = cols()) %>%
    mutate(
      Date       = mdy(Date),                 # if in m/d/Y; use ymd if 2020-01-02
      CloseLast  = as.numeric(gsub("\\$", "", `Close/Last`))
    ) %>%
    arrange(Date) %>%
    transmute(
      date   = Date,
      ticker = ticker,
      price  = CloseLast
    ) %>%
    group_by(ticker) %>%
    mutate(ret = (price / lag(price)) - 1) %>% # simple daily return
    ungroup()
}

aapl  <- read_stock("AAPL.csv", "AAPL")
amzn <- read_stock("AMZN.csv", "AMZN")
qcom <- read_stock("QCOM.csv", "QCOM")
msft <- read_stock("MSFT.csv", "MSFT")

stocks <- bind_rows(aapl, amzn, qcom, msft)
head(stocks)

library(broom)

# Merge daily returns with Fama–French factors
data_merged <- stocks %>%
  inner_join(ff, by = "date") %>%
  mutate(
    ex_ret = ret - RF/100,      # stock excess return
    mkt_rf = `Mkt.RF`/100       # market excess return
  )

# Full-sample CAPM per stock
capm_full <- data_merged %>%
  group_by(ticker) %>%
  do(tidy(lm(ex_ret ~ mkt_rf, data = .))) %>%
  ungroup()
library(broom)


capm_full

block_size <- 120

betas_block <- data_merged %>%
  arrange(ticker, date) %>%
  group_by(ticker) %>%
  mutate(block = ceiling(row_number() / block_size)) %>%
  group_by(ticker, block) %>%
  do(tidy(lm(ex_ret ~ mkt_rf, data = .))) %>%
  ungroup() %>%
  filter(term == "mkt_rf") %>%
  rename(beta_hat = estimate)

betas_block

betas_block %>%
  filter(ticker == "AAPL") %>%
  ggplot(aes(x = block, y = beta_hat)) +
  geom_line() + geom_point() +
  geom_hline(aes(yintercept = mean(beta_hat)), linetype = "dashed") +
  labs(title = "Betas for AAPL", x = "Time Block", y = "Beta-hat") + 
  theme_minimal()
betas_block %>%
  filter(ticker == "AMZN") %>%
  ggplot(aes(x = block, y = beta_hat)) +
  geom_line() + geom_point() +
  geom_hline(aes(yintercept = mean(beta_hat)), linetype = "dashed") +
  labs(title = "Betas for AMZN", x = "Time Block", y = "Beta-hat") + 
  theme_minimal()
betas_block %>%
  filter(ticker == "MSFT") %>%
  ggplot(aes(x = block, y = beta_hat)) +
  geom_line() + geom_point() +
  geom_hline(aes(yintercept = mean(beta_hat)), linetype = "dashed") +
  labs(title = "Betas for MSFT", x = "Time Block", y = "Beta-hat") + 
  theme_minimal()
betas_block %>%
  filter(ticker == "QCOM") %>%
  ggplot(aes(x = block, y = beta_hat)) +
  geom_line() + geom_point() +
  geom_hline(aes(yintercept = mean(beta_hat)), linetype = "dashed") +
  labs(title = "Betas for QCOM", x = "Time Block", y = "Beta-hat") + 
  theme_minimal()


test_constant_beta <- function(df) {
  # Restricted: single beta
  mod_r <- lm(ex_ret ~ mkt_rf, data = df)
  
  # Unrestricted: block-specific betas (interaction)
  mod_u <- lm(ex_ret ~ mkt_rf * factor(block), data = df)
  
  anova(mod_r, mod_u)
}

# Prepare blocks once

block_size <- 240
data_blocks <- data_merged %>%
  arrange(ticker, date) %>%
  group_by(ticker) %>%
  mutate(block = ceiling(row_number() / block_size)) %>%
  ungroup()

# Run test per ticker
tests <- data_blocks %>%
  group_by(ticker) %>%
  group_modify(~ broom::tidy(test_constant_beta(.x))) %>%
  ungroup()

tests


# Prepare blocks once
block_size <- 120
data_blocks <- data_merged %>%
  arrange(ticker, date) %>%
  group_by(ticker) %>%
  mutate(block = ceiling(row_number() / block_size)) %>%
  ungroup()

# Run test per ticker
tests <- data_blocks %>%
  group_by(ticker) %>%
  group_modify(~ broom::tidy(test_constant_beta(.x))) %>%
  ungroup()

tests

betas_block %>%
  filter(ticker == "QCOM") %>%
  ggplot(aes(x = block, y = beta_hat)) +
  geom_line() + geom_point() +
  geom_hline(aes(yintercept = mean(beta_hat)), linetype = "dashed") +
  labs(title = "Betas for QCOM: 120 Day Blocks", x = "Time Block", y = "Beta-hat") + 
  theme_minimal()

# Prepare blocks once
block_size <- 90
data_blocks <- data_merged %>%
  arrange(ticker, date) %>%
  group_by(ticker) %>%
  mutate(block = ceiling(row_number() / block_size)) %>%
  ungroup()

# Run test per ticker
tests <- data_blocks %>%
  group_by(ticker) %>%
  group_modify(~ broom::tidy(test_constant_beta(.x))) %>%
  ungroup()

tests
betas_block %>%
  filter(ticker == "QCOM") %>%
  ggplot(aes(x = block, y = beta_hat)) +
  geom_line() + geom_point() +
  geom_hline(aes(yintercept = mean(beta_hat)), linetype = "dashed") +
  labs(title = "Betas for QCOM: 90 Day Blocks", x = "Time Block", y = "Beta-hat") + 
  theme_minimal()

# Prepare blocks once
block_size <- 30
data_blocks <- data_merged %>%
  arrange(ticker, date) %>%
  group_by(ticker) %>%
  mutate(block = ceiling(row_number() / block_size)) %>%
  ungroup()

# Run test per ticker
tests <- data_blocks %>%
  group_by(ticker) %>%
  group_modify(~ broom::tidy(test_constant_beta(.x))) %>%
  ungroup()

tests
betas_block %>%
  filter(ticker == "QCOM") %>%
  ggplot(aes(x = block, y = beta_hat)) +
  geom_line() + geom_point() +
  geom_hline(aes(yintercept = mean(beta_hat)), linetype = "dashed") +
  labs(title = "Betas for QCOM: 30 Day Blocks", x = "Time Block", y = "Beta-hat") + 
  theme_minimal()



# full-sample beta per stock
full_beta <- data_merged %>%
  group_by(ticker) %>%
  do(tidy(lm(ex_ret ~ mkt_rf, data = .))) %>%
  filter(term == "mkt_rf") %>%
  transmute(ticker, beta_full = estimate)

# ANOVA test per stock
anova_results <- data_merged %>%
  arrange(ticker, date) %>%
  group_by(ticker) %>%
  mutate(block = ceiling(row_number() / block_size)) %>%
  group_by(ticker) %>%
  do({
    mod_r <- lm(ex_ret ~ mkt_rf, data = .)
    mod_u <- lm(ex_ret ~ mkt_rf * factor(block), data = .)
    tidy(anova(mod_r, mod_u))
  }) %>%
  filter(term == "ex_ret ~ mkt_rf * factor(block)") %>%  # keep the test row
  select(ticker, df.residual, rss, df, sumsq, statistic, p.value)

# join in the full-sample beta
anova_with_beta <- anova_results %>%
  left_join(full_beta, by = "ticker")


