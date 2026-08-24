# E-Commerce Customer & Revenue Analytics

SQL + Power BI analysis of 99,441 orders from the Olist Brazilian E-Commerce dataset, focused on customer segmentation, retention, revenue trends, and delivery risk.

## Overview
This project analyzes a real, relational e-commerce dataset (9 tables, 99K+ orders) to answer four business questions: who are our most valuable customers, how well do we retain them, how is revenue trending, and where does delivery risk actually concentrate. Built entirely in MySQL 8.0, visualized in Power BI.

## Dataset
[Olist Brazilian E-Commerce Public Dataset](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce) — 99,441 orders, 2016–2018, across 9 relational tables (orders, customers, order items, payments, reviews, products, sellers, geolocation, category translations).

## Tech Stack
MySQL 8.0 · SQL (CTEs, window functions, multi-table joins) · Power BI

## Key Findings

**1. Customer Segmentation (RFM)**
- 0 customers met "Champion" criteria (frequency ≥2, recency ≤90 days, spend ≥₹500)
- 40.6% of total revenue comes from "At-Risk" customers (inactive 6–12 months)

**2. Retention**
- Cohort retention drops from 100% to 0.48% within a single month across 93K+ customers
- Cross-validates the RFM finding — this is a structurally one-time-buyer platform, not a data artifact

**3. Revenue Trend**
- Excluded Oct–Dec 2016 pre-launch data (<₹50K combined, non-representative)
- 2017: strong growth phase, ~9x revenue increase over 11 months
- 2018: growth plateaus into single-digit/flat months, signaling market maturation

**4. Delivery Risk**
- All states show negative average delivery delay (early on average) — but late-order % tells a different story
- Alagoas (AL): 20.8% late-delivery rate — 2x some top-performing states — despite a negative average delay
- Shows average delay alone is a misleading reliability metric

**5. Delivery Delay vs. Review Score**
- Audio category: highest late-delivery rate (11.6%) AND lowest average review
- 
