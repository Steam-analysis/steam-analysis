# 🎮 Steam Market & Genre Dynamics Analytics Pipeline

An end-to-end data analytics and predictive modeling project built with the **Modern Data Stack**. Raw multi-platform gaming logs were ingested into **Google BigQuery**, transformed via **dbt**, processed with **Python (Google Colab)** for Machine Learning modeling, and served through an interactive **Looker Studio** BI dashboard.

The project combines domain-specific metrics (revenue share, unit sales, pricing models) with machine learning techniques (**Holt Exponential Smoothing** for time-series forecasting and **K-Means Clustering** for strategic genre segmentation).

---

## 🏗️ Data Architecture & Pipeline

```text
[ Kaggle Raw Data (~60GB Multi-Platform) ]
                │
                ▼  (Extract & Filter Steam Logs)
[ Google BigQuery ] ──( Landing / Raw Data Layer )
                │
                ▼  (Transformation & Data Modeling)
[ dbt (data build tool) ] ──( Staged Data Marts )
                │
                ▼  (Cleaned Analytics Datasets)
[ Google BigQuery ] 
                │
                ▼  (Export for Advanced Analytics)
[ Google Colab / Python ] ──( ML Modeling: Holt Forecasting & K-Means )
                │
                ▼  (Write Back ML Predictions & Clusters)
[ Google BigQuery ] ──( Final Analytics & ML Data Marts )
                │
                ▼  (Visualization & Reporting)
[ Looker Studio ] ──( Interactive Dashboard & Business Insights )
```

---

## 🛠️ Tech Stack & Methods

* **Data Source:** Kaggle - Gaming Profiles (Steam subset selected from ~60GB multi-platform dataset)
* **Data Warehouse:** Google BigQuery
* **Data Transformation:** dbt (data build tool)
* **Machine Learning & Scripting:** Python, Google Colab (Pandas, Scikit-Learn, Statsmodels)
* **Visualization:** Looker Studio
* **Predictive Algorithms:** Holt Exponential Smoothing Time-Series Forecasting, K-Means Clustering, Logistic Regression / TF-IDF (NLP)

---

## 📌 Project Highlights & Key Insights

### 1. 📈 Steam Market & Genre Dynamics (Primary Contribution)

* **KPI Metrics & Financial Dominance:** Action, Adventure, and Indie genres lead overall revenue generation, with Action alone capturing 27.22% of total market revenue ($1.27M) and 21.27% of sales volume. Indie and Casual genres demonstrate value-driven dynamics with high unit volume relative to price points.
* **Historical Trend Analysis (Post-2019 Growth):** Market expansion accelerated rapidly after 2019, deepening the revenue gap between top-tier genres and niche markets. Action's market share contracted from 50% down to 25% due to genre diversification.
* **Forecasting (Holt Model vs. Baseline):** Replaced equal-weighted Linear Regression with a Holt Exponential Smoothing model trained via Python in Google Colab to prioritize recent market trends. Achieved a 14x reduction in error rate compared to the baseline (Baseline MAPE: 1,727% vs. Holt Model MAPE: 121%).
* **Genre Clustering (K-Means Segmentation):** Applied K-Means clustering evaluated with a Silhouette Score of 0.53 (improving over baseline -0.30):
  * **Star Genres (High Revenue, High Growth):** Action, Adventure, RPG — Core drivers for large-budget projects.
  * **Emerging Potential:** Simulation (high growth momentum) and Early Access titles (driven by high average pricing).

### 2. 🌐 Team Collaboration Modules

* **Player Behavior & Churn Risk:** Country-level engagement tracking (US, Brazil, Russia lead active counts) and cohort retention monitoring.
* **Review Sentiment & Risk Scoring:** TF-IDF keyword extraction paired with Logistic Regression (61.5% accuracy, 96% Bug Recall) to score publisher operational risk.
* **Purchasing Power (Turkey Focus):** Economic indexing evaluating minimum wage to game price ratios and working-hour conversion metrics.

---

## 👤 My Role & Specific Contributions

As part of a 4-5 member collaborative team, I took ownership of the Steam Market & Genre Dynamics vertical:

* **dbt Data Modeling:** Built transformation pipelines in dbt to clean raw Steam logs, structure revenue/sales aggregates, and publish staging tables to BigQuery.
* **Machine Learning (Google Colab & Python):** Exported cleaned dbt outputs to Google Colab, engineered the Holt Forecasting Model for revenue projections, built the K-Means Genre Clustering algorithm, and wrote prediction outputs back to BigQuery.
* **Dashboard Design:** Designed interactive Looker Studio dashboard pages (Revenue Heatmaps, Time-Series Projections, and Cluster Scatterplots).
* **Code Review & Feedback:** Conducted iterative peer reviews on team dbt transformations and dashboard layouts to maintain metric consistency.

---

## 📁 Repository Structure

```text
.
├── README.md                 # Project documentation and analytical insights
├── docs/                     # Presentation slides (PDF) and dashboard screenshots
└── dbt_project/              # Complete dbt transformation framework
    ├── models/               # Staging cleanups and Data Mart models
    ├── macros/               # Custom SQL transformation macros
    ├── tests/                # Custom data quality tests
    ├── seeds/                # Static lookup CSVs
    └── dbt_project.yml       # dbt project config
```

---

## 📊 Dashboards & Media

* 🔗 **Interactive Looker Studio Board:** [Canlı Looker Studio Linkiniz]
* 📄 **High-Res Screenshots & PDF Report:** Available under the `/docs` folder.

---

## 👥 Contributors

* **Ertuğrul Karamanlı** - [LinkedIn](https://www.linkedin.com/in/ertugrulkaramanli/) | [GitHub](https://github.com/ErtugrulKaramanli)
* **Yudum Ergün** - [LinkedIn](https://www.linkedin.com/in/yudum-erg%C3%BCn/) | [GitHub](https://github.com/yudumerg)
* **Müge Nazlı** - [LinkedIn](https://www.linkedin.com/in/m%C3%BCge-nazl%C4%B1-a244b7290/) | [GitHub](https://github.com/MugeNazli)
* **Özge Efe** - [LinkedIn](https://www.linkedin.com/in/aozgeefe/) | [GitHub](https://github.com/ozgeefe)
* **Sengül Özaydın** - [LinkedIn](https://www.linkedin.com/in/sengulozaydin/) | [GitHub](https://github.com/sengulozaydin)
