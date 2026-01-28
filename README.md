# 5630FinalProject
# Time-Varying CAPM Betas and Their Implications  
**STSCI 5630 – Operational Research Tools for Financial Engineering**

This repository contains my final project for **STSCI 5630 (Financial Engineering)** at Cornell University. The project empirically investigates whether the **constant-beta assumption of the Capital Asset Pricing Model (CAPM)** holds in practice by analyzing beta stability across time using historical equity and market factor data.

---

## Project Motivation

The CAPM assumes that an asset’s systematic risk (β) is constant over time. While this assumption simplifies asset pricing and risk estimation, empirical evidence often suggests otherwise. This project asks:

- Is observed beta variation simply estimation noise?
- Or does beta genuinely change over time?
- What are the implications for CAPM-based risk and valuation models?

Understanding beta stability is critical for portfolio construction, risk management, and performance attribution in real-world financial applications.

---

## Data

- **Equity Data:** Daily adjusted closing prices for  
  - Apple (AAPL)  
  - Amazon (AMZN)  
  - Microsoft (MSFT)  
  - Qualcomm (QCOM)

- **Market Factors:**  
  - Fama–French daily factors (Market Excess Return, Risk-Free Rate)

- **Sources:**  
  - Kenneth R. French Data Library  
  - Nasdaq historical equity data  

Raw price and factor files are referenced but not included in this repository.

---

## Methodology

### 1. Excess Return Construction
- Computed daily stock returns
- Calculated excess returns relative to the risk-free rate
- Matched stock returns to daily market excess returns

### 2. Baseline CAPM Estimation
For each stock:
\[
R_{j,t} - R_{f,t} = \alpha_j + \beta_j (R_{m,t} - R_{f,t}) + \varepsilon_{j,t}
\]

Estimated full-sample CAPM betas using time-series regression.

---

### 3. Block-Based Beta Estimation
To examine time variation, the sample was partitioned into rolling time blocks of varying lengths:

- 30 days  
- 90 days  
- 120 days  
- 240 days  

Within each block, CAPM betas were re-estimated, producing a time series of beta estimates per stock.

---

### 4. Statistical Testing of Beta Stability

To test whether beta variation exceeds estimation error, likelihood ratio (ANOVA) tests were performed:

- **Restricted model:** Single beta over the full sample
- **Unrestricted model:** Block-specific betas via interaction terms

**Null Hypothesis:** Beta is constant across time  
**Alternative Hypothesis:** At least one block beta differs significantly

---

## Results

- Across most stocks and time horizons, beta variation was **statistically significant**
- Observed beta fluctuations cannot be fully explained by estimation noise
- Shorter block lengths exhibited greater beta volatility
- The constant-beta assumption of CAPM is frequently violated in practice

---

## Implications

- CAPM-based risk estimates may be materially misleading when beta is assumed constant
- Beta should be treated as **time- and horizon-dependent** in applied settings
- Results support the use of richer factor models (e.g., Fama–French) or dynamic risk frameworks

---

## Tools & Technologies

- **Language:** R
- **Key Packages:**
  - `tidyverse`
  - `lubridate`
  - `broom`
  - `ggplot2`

- **Outputs:**
  - Time-series beta visualizations
  - Likelihood ratio tests
  - Final presentation summarizing empirical findings

---

## Files

- `5630FinalProject.R`  
  Full data processing, regression analysis, block estimation, and hypothesis testing.

- `5630FinalPresentation.pptx`  
  Final presentation summarizing methodology, results, and implications.

---

## Limitations & Extensions

- Analysis focuses on a small set of large-cap equities
- Future work could:
  - Expand to cross-sectional stock samples
  - Model beta dynamics explicitly (e.g., state-space models)
  - Compare CAPM to multi-factor alternatives

---

## Author

**Kimberly Bond**  
MPS Applied Statistics & Data Science  
Cornell University
