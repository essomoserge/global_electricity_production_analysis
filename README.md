<h2>Global Electricity Production Analysis (2010–2023)</h2>

<p>
Data analytics project examining electricity production across 48 countries using Python, SQL, and PowerPoint to uncover global energy trends, renewable transition dynamics, and fossil fuel dependencies, providing strategic insights for policymakers and energy analysts.
</p>

<h3>📊 Overview</h3>
<p>
This comprehensive data analytics project analyzes electricity production trends across 48 countries over a 14-year period (2010–2023). The goal is to evaluate the global energy landscape, track the renewable energy transition, identify fossil fuel dependencies, and provide actionable insights for strategic decision-making. The analysis transforms raw International Energy Agency (IEA) data into an executive-level dashboard using Python for data processing, SQL for structured validation, and PowerPoint for professional presentation.
</p>

<h3>📁 Dataset</h3>
<p>
<strong>Source:</strong> International Energy Agency (IEA) – Monthly Electricity Statistics, 2024<br>
<strong>Period:</strong> January 2010 – December 2023<br>
<strong>Records:</strong> 121,074 monthly production logs<br>
<strong>Countries:</strong> 48 nations across developed and developing economies
</p>
<p>
<strong>Key Variables:</strong> Country Name, Date, Parameter (Net Electricity Production), Product Type (16 energy sources), Production Value (GWh), Unit of Measurement<br>
<strong>Energy Sources:</strong> Coal, Oil, Natural Gas, Nuclear, Hydro, Wind, Solar, Other Renewables, Total Combustible Fuels, Total Electricity
</p>

<h3>🛠️ Tools &amp; Technologies</h3>
<ul>
<li><strong>Python (pandas, numpy, matplotlib, seaborn):</strong> Data cleaning, exploratory analysis, feature engineering, visualization</li>
<li><strong>MySQL & SQL Server:</strong> Relational database integration, aggregation queries, validation</li>
<li><strong>SQLAlchemy:</strong> Python-SQL database connectivity</li>
<li><strong>PowerPoint:</strong> Executive dashboard design and presentation</li>
<li><strong>Jupyter Notebook:</strong> Interactive development and documentation</li>
</ul>

<h3>📈 Project Steps</h3>

<h4>1. Data Loading &amp; Initial Inspection</h4>
<ul>
<li>Load raw IEA dataset into Python using pandas</li>
<li>Inspect data structure, missing values, and data types</li>
<li>Generate summary statistics and unique value counts</li>
<li>Validate data consistency across 121,074 records</li>
</ul>

<pre>
import pandas as pd
df = pd.read_csv("global_electricity_production_data.csv")
df.info()
df.describe(include='all')
</pre>

<h4>2. Data Cleaning &amp; Transformation (Python)</h4>
<ul>
<li>Remove 14 null values from production records</li>
<li>Convert date column to datetime format</li>
<li>Extract year and month features for temporal analysis</li>
<li>Standardize product categories for consistent grouping</li>
<li>Create renewable energy flag for source classification</li>
</ul>

<pre>
df_clean = df.dropna(subset=['value'])
df_clean['date'] = pd.to_datetime(df_clean['date'])
df_clean['year'] = df_clean['date'].dt.year
df_clean['month'] = df_clean['date'].dt.month
</pre>

<h4>3. Database Integration (MySQL/SQL Server)</h4>
<ul>
<li>Establish database connection using SQLAlchemy</li>
<li>Create relational schema for efficient querying</li>
<li>Load cleaned data into production table</li>
<li>Validate data integrity with sample queries</li>
</ul>

<pre>
from sqlalchemy import create_engine
engine = create_engine("mysql+pymysql://username:password@localhost:3306/electricity_production")
df_clean.to_sql("electricity_data", engine, if_exists="replace", index=False)
</pre>

<h4>4. Analytical Framework Development</h4>
<ul>
<li>Define 15 strategic analytical questions addressing production trends, renewable transition, and policy relevance</li>
<li>Develop Python functions for KPI calculations</li>
<li>Create SQL queries for aggregation and validation</li>
<li>Structure analysis around temporal, geographic, and source-based dimensions</li>
</ul>

<h4>5. Exploratory Data Analysis</h4>
<ul>
<li>Identify highest and lowest producing countries annually</li>
<li>Calculate renewable energy share evolution over time</li>
<li>Determine fossil fuel dependency rankings</li>
<li>Analyze coal, oil, and natural gas usage trends</li>
<li>Examine seasonal and monthly production variations</li>
<li>Evaluate solar and wind contribution to renewable mix</li>
<li>Identify fastest-growing renewable markets</li>
<li>Assess energy source diversity and balance</li>
<li>Analyze pumped storage utilization trends</li>
<li>Investigate correlation between fossil dependency and renewable growth</li>
<li>Compare developed vs. developing nation trajectories</li>
<li>Integrate population data for per capita analysis</li>
<li>Measure renewable production volatility</li>
<li>Evaluate progress toward 30% renewable targets</li>
<li>Identify emerging alternative energy trends</li>
</ul>

<h4>6. Executive Dashboard Development (PowerPoint)</h4>
<ul>
<li>Design 11-slide dashboard following executive presentation principles</li>
<li>Create visual hierarchy with strategic KPIs on overview slide</li>
<li>Develop color-coded metrics (green for positive trends, red for risks)</li>
<li>Build comparative tables for cross-country analysis</li>
<li>Incorporate trend visualizations and growth rate indicators</li>
<li>Structure content into three sections: Global Overview, Country-Level Analysis, Strategic Outlook</li>
<li>Include actionable policy recommendations based on findings</li>
</ul>

<h4>7. Reporting &amp; Documentation</h4>
<ul>
<li>Document methodology and code in Jupyter notebooks</li>
<li>Create comprehensive README with project details</li>
<li>Prepare executive summary of key findings</li>
<li>Translate dashboard into German for international accessibility</li>
<li>Develop LinkedIn content strategy for professional sharing</li>
</ul>

<h3>📊 Dashboard Preview</h3>
<p>
The executive dashboard is organized into 11 slides across three thematic sections, enabling decision-makers to quickly grasp global energy dynamics and identify strategic priorities.
</p>

<p><strong>Section 1: Global Overview</strong><br>
Slide 1: Executive Dashboard – Global KPIs at a glance<br>
Slide 2: Production Leadership Shift – China's rise as global leader<br>
Slide 3: Developed vs. Developing Nations – Contrasting growth trajectories
</p>

<p><strong>Section 2: Country-Level Analysis</strong><br>
Slide 4: Fossil Fuel Dependency – Most vulnerable nations<br>
Slide 5: Renewable Growth Leaders – Fastest-growing markets<br>
Slide 6: Energy Storage Infrastructure – Pumped storage capacity<br>
Slide 7: Per Capita Production – Consumption patterns by population
</p>

<p><strong>Section 3: Strategic Outlook</strong><br>
Slide 8: The Transition Challenge – Positive trends vs. persistent challenges<br>
Slide 9: Policy Implications – Data-driven recommendations<br>
Slide 10: Outlook to 2030 – Projections and targets<br>
Slide 11: Thank You – Sources and contact
</p>

<h3>📋 Key Results &amp; Insights</h3>
<ul>
<li><strong>⚡ Leadership Shift:</strong> China overtook the United States in 2015 as the world's largest electricity producer, now generating 9.09M GWh annually</li>
<li><strong>🌍 Development Divide:</strong> Developing nations now produce 30% more electricity than developed countries, up from near-parity in 2015</li>
<li><strong>⛽ Fossil Dependency Risk:</strong> 20+ countries remain >60% dependent on fossil fuels; Malta (88.7%) and Cyprus (87.3%) most vulnerable</li>
<li><strong>📈 Renewable Growth Leaders:</strong> South Korea (+15.2%), Netherlands (+14.3%), and United Kingdom (+13.1%) show fastest renewable adoption rates</li>
<li><strong>🔋 Storage Infrastructure:</strong> Spain (+88%) and Portugal (+84%) demonstrate massive investment in pumped storage capacity</li>
<li><strong>👥 Per Capita Disparity:</strong> Iceland leads with 53,076 kWh/person annually; global average ranges from 6,500–12,000 kWh</li>
<li><strong>⚠️ Transition Challenge:</strong> 15 countries show >10% annual renewable growth, but growth often supplements rather than replaces fossil fuels</li>
<li><strong>🔍 Correlation Insight:</strong> Countries with highest fossil fuel dependency show slower renewable adoption rates, suggesting a "lock-in" effect requiring policy intervention</li>
</ul>

<h3>🚀 How to Run This Project</h3>

<h4>Prerequisites</h4>
<p>
Python 3.8+, MySQL Server (optional), Power BI Desktop (optional), Jupyter Notebook or preferred IDE
</p>

<h4>Setup Instructions</h4>
<p>
Clone the repository:
</p>

<pre>
git clone https://github.com/yourusername/electricity-production-analysis.git
cd electricity-production-analysis
</pre>

<p>
Install dependencies:
</p>

<pre>
pip install pandas numpy matplotlib seaborn sqlalchemy pymysql psycopg2-binary jupyter
</pre>

<p>
Download the IEA Monthly Electricity Statistics dataset and place it in the <code>data/raw/</code> folder.
</p>

<p>
Run the data preparation notebook:
</p>

<pre>
jupyter notebook notebooks/01_data_preparation.ipynb
</pre>

<p>
For database integration (optional):
</p>

<pre>
# Configure database connection in scripts/database_integration.py
python scripts/database_integration.py
</pre>

<p>
Generate analytical outputs:
</p>

<pre>
python scripts/kpi_calculations.py
</pre>

<p>
View the executive dashboard at <code>presentation/Electricity_Production_Analysis.pptx</code>
</p>

<h3>📁 Repository Structure</h3>

<pre>
electricity-production-analysis/
├── data/
│   ├── raw/                         # Original IEA dataset
│   └── processed/                    # Cleaned data files
├── notebooks/
│   ├── 01_data_preparation.ipynb     # Initial data cleaning
│   ├── 02_exploratory_analysis.ipynb # EDA and visualizations
│   └── 03_advanced_analytics.ipynb   # Growth rates, correlations
├── scripts/
│   ├── data_cleaning.py              # Automated cleaning pipeline
│   ├── database_integration.py       # MySQL/SQL Server loading
│   └── kpi_calculations.py           # Key metric calculations
├── sql/
│   ├── create_tables.sql             # Database schema
│   ├── production_queries.sql        # Analytical queries
│   └── renewable_analysis.sql        # Renewable-specific queries
├── presentation/
│   ├── Electricity_Production_Analysis.pptx    # Executive dashboard
│   ├── Electricity_Production_Analysis_DE.pptx # German version
│   └── assets/                                  # Images and icons
├── outputs/
│   ├── tables/                          # Generated data tables
│   └── charts/                           # Visualization exports
├── config/
│   └── db_config.yaml                    # Database configuration
├── requirements.txt                       # Python dependencies
├── README.md                              # Project documentation
└── LICENSE                                # MIT License
</pre>

<h3>📄 License</h3>
<p>
This project is for educational and portfolio purposes. Dataset sourced from the International Energy Agency (IEA) Monthly Electricity Statistics, 2024.
</p>

<h3>👤 Author</h3>
<p>
<strong>Serge Essomo</strong><br>
<a href="https://github.com/essomoserge">https://github.com/essomoserge</a> | <a href="https://www.linkedin.com/in/serge-essomo-5946b8142">https://www.linkedin.com/in/serge-essomo-5946b8142</a> | <a href="https://www.kaggle.com/sergio2cm">https://www.kaggle.com/sergio2cm</a>
</p>

<h3>🙏 Acknowledgments</h3>
<p>
International Energy Agency (IEA) for providing the comprehensive dataset<br>
Open-source community for Python, SQL, and data visualization tools<br>
All contributors and reviewers who provided valuable feedback
</p>

<hr>

<p align="center">
If you find this project useful, please consider giving it a ⭐ on GitHub!
</p>
