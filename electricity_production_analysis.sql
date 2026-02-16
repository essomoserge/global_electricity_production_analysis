-- ELECTRICITY PRODUCTION ANALYSIS ACROSS 48 COUNTRIES (2010–2023)
SELECT * FROM electricity_data LIMIT 20;

-- QUESTION 1. Which countries had the highest and lowest total electricity production each year?
-- Focus: Aggregate value by country_name and date for Net Electricity Production.
-- Relevance: Identifies global energy leaders and laggards, helping policymakers benchmark performance and prioritize investment in infrastructure.
WITH yearly_production AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        SUM(value) AS total_electricity_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
      AND product = 'Electricity'
    GROUP BY
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y'))
),
ranked_production AS (
    SELECT
        country_name,
        year,
        total_electricity_gwh,
        RANK() OVER (PARTITION BY year ORDER BY total_electricity_gwh DESC) AS rank_highest,
        RANK() OVER (PARTITION BY year ORDER BY total_electricity_gwh ASC)  AS rank_lowest
    FROM yearly_production
)
SELECT
    year,
    country_name,
    total_electricity_gwh,
    CASE
        WHEN rank_highest = 1 THEN 'Highest'
        WHEN rank_lowest = 1 THEN 'Lowest'
    END AS production_rank
FROM ranked_production
WHERE rank_highest = 1
   OR rank_lowest = 1
ORDER BY year, production_rank;

-- QUESTION 2. How has the share of renewable energy (Wind, Solar, Hydro, Combustible Renewables) evolved over time for each country?
-- Focus: Calculate Total Renewables / Net Electricity Production over time.
-- Relevance: Tracks progress towards sustainable energy targets, aiding in evaluating effectiveness of renewable energy policies.
WITH yearly_energy AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        product,
        SUM(value) AS total_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
    GROUP BY
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')),
        product
),
country_year_totals AS (
    SELECT
        country_name,
        year,
        SUM(CASE
            WHEN product = 'Electricity' THEN total_gwh
            ELSE 0
        END) AS total_electricity_gwh,
        SUM(CASE
            WHEN product IN (
                'Wind',
                'Solar',
                'Hydro',
                'Combustible Renewables'
            ) THEN total_gwh
            ELSE 0
        END) AS renewable_electricity_gwh
    FROM yearly_energy
    GROUP BY country_name, year
)
SELECT
    country_name,
    year,
    renewable_electricity_gwh,
    total_electricity_gwh,
    ROUND(
        (renewable_electricity_gwh / total_electricity_gwh) * 100,
        2
    ) AS renewable_share_percent
FROM country_year_totals
WHERE total_electricity_gwh > 0
ORDER BY country_name, year;

-- QUESTION 3. Which countries are most dependent on fossil fuels versus renewables?
-- Focus: Compare Total Combustible Fuels with Total Renewables per country.
-- Relevance: Reveals risk exposure to fossil fuel volatility and highlights countries needing accelerated energy transition.
WITH yearly_energy AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        product,
        SUM(value) AS total_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
    GROUP BY
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')),
        product
),
country_year_shares AS (
    SELECT
        country_name,
        year,
        SUM(CASE
            WHEN product = 'Electricity' THEN total_gwh
            ELSE 0
        END) AS total_electricity_gwh,
        SUM(CASE
            WHEN product IN (
                'Wind',
                'Solar',
                'Hydro',
                'Combustible Renewables'
            ) THEN total_gwh
            ELSE 0
        END) AS renewable_gwh,
        SUM(CASE
            WHEN product IN (
                'Coal, Peat and Manufactured Gases',
                'Oil and Petroleum Products',
                'Natural Gas'
            ) THEN total_gwh
            ELSE 0
        END) AS fossil_gwh
    FROM yearly_energy
    GROUP BY country_name, year
),
country_dependency AS (
    SELECT
        country_name,
        ROUND(AVG(renewable_gwh / total_electricity_gwh) * 100, 2)
            AS avg_renewable_share_pct,
        ROUND(AVG(fossil_gwh / total_electricity_gwh) * 100, 2)
            AS avg_fossil_share_pct
    FROM country_year_shares
    WHERE total_electricity_gwh > 0
    GROUP BY country_name
)
SELECT
    country_name,
    avg_renewable_share_pct,
    avg_fossil_share_pct,
    CASE
        WHEN avg_renewable_share_pct > avg_fossil_share_pct
            THEN 'Renewable-dependent'
        ELSE 'Fossil-dependent'
    END AS dependency_type
FROM country_dependency
ORDER BY avg_fossil_share_pct DESC;

-- QUESTION 4. What are the trends in coal, oil, and natural gas usage over the years globally and by country?
-- Focus: Filter product for Coal, Peat..., Oil..., Natural Gas and visualize trends over time.
-- Relevance: Helps understand decarbonization progress and forecast emissions-related challenges.
WITH yearly_fossil AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        product,
        SUM(value) AS total_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
      AND product IN (
          'Coal, Peat and Manufactured Gases',
          'Oil and Petroleum Products',
          'Natural Gas'
      )
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y')), product
),
country_trends AS (
    SELECT
        country_name,
        year,
        SUM(CASE WHEN product = 'Coal, Peat and Manufactured Gases' THEN total_gwh ELSE 0 END) AS coal_gwh,
        SUM(CASE WHEN product = 'Oil and Petroleum Products' THEN total_gwh ELSE 0 END) AS oil_gwh,
        SUM(CASE WHEN product = 'Natural Gas' THEN total_gwh ELSE 0 END) AS gas_gwh,
        SUM(total_gwh) AS total_fossil_gwh
    FROM yearly_fossil
    GROUP BY country_name, year
),
global_trends AS (
    SELECT
        year,
        SUM(coal_gwh) AS global_coal_gwh,
        SUM(oil_gwh) AS global_oil_gwh,
        SUM(gas_gwh) AS global_gas_gwh,
        SUM(total_fossil_gwh) AS global_total_fossil_gwh
    FROM country_trends
    GROUP BY year
)
-- Final output: trends by country
SELECT
    'Country' AS level,
    country_name AS name,
    year,
    coal_gwh,
    oil_gwh,
    gas_gwh,
    total_fossil_gwh
FROM country_trends
UNION ALL
-- Final output: global trends
SELECT
    'Global' AS level,
    NULL AS name,
    year,
    global_coal_gwh,
    global_oil_gwh,
    global_gas_gwh,
    global_total_fossil_gwh
FROM global_trends
ORDER BY level, name, year;

-- QUESTION 5. How does seasonal or monthly electricity production vary for major countries?
-- Focus: Extract month from date and aggregate value for each country_name and product.
-- Relevance: Supports grid management, load forecasting, and energy storage planning.
-- Step 1: Aggregate monthly electricity production per country
WITH monthly_electricity AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        MONTH(STR_TO_DATE(date, '%m/%d/%Y')) AS month,
        SUM(value) AS total_electricity_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
      AND product = 'Electricity'
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y')), MONTH(STR_TO_DATE(date, '%m/%d/%Y'))
)

-- Step 2: Optional: Rank or filter major countries by total production
, major_countries AS (
    SELECT
        country_name
    FROM monthly_electricity
    GROUP BY country_name
    HAVING SUM(total_electricity_gwh) > 50000  -- adjust threshold as needed
)

-- Step 3: Final result: monthly production for major countries
SELECT
    m.country_name,
    m.year,
    m.month,
    m.total_electricity_gwh
FROM monthly_electricity m
JOIN major_countries c
  ON m.country_name = c.country_name
ORDER BY m.country_name, m.year, m.month;

-- QUESTION 6. What is the contribution of Solar and Wind energy to total renewable energy production?
-- Focus: Calculate Wind + Solar / Total Renewables.
-- Relevance: Identifies the adoption level of intermittent renewables, critical for energy storage and policy incentives.
WITH yearly_renewables AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        SUM(CASE WHEN product IN ('Wind', 'Solar', 'Hydro', 'Combustible Renewables') 
                 THEN value ELSE 0 END) AS total_renewable_gwh,
        SUM(CASE WHEN product IN ('Wind', 'Solar') THEN value ELSE 0 END) AS wind_solar_gwh,
        SUM(CASE WHEN product = 'Wind' THEN value ELSE 0 END) AS wind_gwh,
        SUM(CASE WHEN product = 'Solar' THEN value ELSE 0 END) AS solar_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y'))
)

SELECT
    country_name,
    year,
    total_renewable_gwh,
    wind_solar_gwh,
    wind_gwh,
    solar_gwh,
    ROUND((wind_solar_gwh / total_renewable_gwh) * 100, 2) AS wind_solar_share_pct,
    ROUND((wind_gwh / total_renewable_gwh) * 100, 2) AS wind_share_pct,
    ROUND((solar_gwh / total_renewable_gwh) * 100, 2) AS solar_share_pct
FROM yearly_renewables
WHERE total_renewable_gwh > 0
ORDER BY country_name, year;

-- QUESTION 7. Which countries show the fastest growth in renewable energy production?
-- Focus: Compute year-on-year % change for Total Renewables per country.
-- Relevance: Highlights leading innovators in sustainable energy, useful for investment and technology partnerships.
WITH yearly_renewables AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        SUM(CASE WHEN product IN ('Wind', 'Solar', 'Hydro', 'Combustible Renewables') 
                 THEN value ELSE 0 END) AS total_renewable_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y'))
),

-- Step 1: Calculate year-over-year growth per country
renewable_growth AS (
    SELECT
        r1.country_name,
        r1.year,
        r1.total_renewable_gwh,
        r1.total_renewable_gwh - r2.total_renewable_gwh AS growth_gwh,
        ROUND(
            ((r1.total_renewable_gwh - r2.total_renewable_gwh) / r2.total_renewable_gwh) * 100, 2
        ) AS growth_pct
    FROM yearly_renewables r1
    LEFT JOIN yearly_renewables r2
      ON r1.country_name = r2.country_name AND r1.year = r2.year + 1
    WHERE r2.total_renewable_gwh IS NOT NULL
)

-- Step 2: Average annual growth per country
SELECT
    country_name,
    COUNT(*) AS years_observed,
    SUM(growth_gwh) AS total_growth_gwh,
    ROUND(AVG(growth_pct), 2) AS avg_annual_growth_pct
FROM renewable_growth
GROUP BY country_name
ORDER BY avg_annual_growth_pct DESC;

-- QUESTION 8. How balanced is electricity production among different sources within each country?
-- Focus: Calculate the proportion of each product relative to Net Electricity Production.
-- Relevance: Determines energy diversity and resilience to supply shocks or fuel shortages.
WITH total_by_source AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        product,
        SUM(value) AS production_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y')), product
),
country_totals AS (
    SELECT
        country_name,
        year,
        SUM(production_gwh) AS total_gwh
    FROM total_by_source
    GROUP BY country_name, year
),
shares AS (
    SELECT
        t.country_name,
        t.year,
        t.product,
        t.production_gwh,
        ROUND((t.production_gwh / c.total_gwh) * 100, 2) AS share_pct
    FROM total_by_source t
    JOIN country_totals c
      ON t.country_name = c.country_name AND t.year = c.year
)
SELECT *
FROM shares
ORDER BY country_name, year, share_pct DESC;

-- QUESTION 9. Which countries use the most electricity for pumped storage, and how has this changed over time?
-- Focus: Filter parameter = Used for pumped storage and analyze trends.
-- Relevance: Provides insights into energy storage infrastructure and efficiency improvements.

-- Compare pumped storage to total electricity production
SELECT 
    ps.country_name,
    ps.year,
    ps.pumped_storage_gwh,
    te.total_electricity_gwh,
    ROUND((ps.pumped_storage_gwh / te.total_electricity_gwh) * 100, 3) as pumped_storage_percentage
FROM (
    -- Pumped storage by year
    SELECT 
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) as year,
        SUM(value) as pumped_storage_gwh
    FROM electricity_data
    WHERE parameter = 'Used for pumped storage'
      AND product = 'Electricity'
      AND value > 0
      AND STR_TO_DATE(date, '%m/%d/%Y') IS NOT NULL
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y'))
) ps
JOIN (
    -- Total electricity production by year
    SELECT 
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) as year,
        SUM(value) as total_electricity_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
      AND product = 'Electricity'
      AND value > 0
      AND STR_TO_DATE(date, '%m/%d/%Y') IS NOT NULL
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y'))
) te ON ps.country_name = te.country_name AND ps.year = te.year
WHERE te.total_electricity_gwh > 0
ORDER BY pumped_storage_percentage DESC;

-- Complete answer: Which countries use the most electricity for pumped storage and how has it changed?
SELECT 
    country_name,
    -- Historical usage
    ROUND(SUM(value), 2) as total_historical_gwh,
    -- Recent usage (assuming 2023)
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%m/%d/%Y')) = 2023 THEN value ELSE 0 END), 2) as usage_2023_gwh,
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%m/%d/%Y')) = 2022 THEN value ELSE 0 END), 2) as usage_2022_gwh,
    ROUND(SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%m/%d/%Y')) = 2021 THEN value ELSE 0 END), 2) as usage_2021_gwh,
    -- Change calculation
    ROUND(
        (SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%m/%d/%Y')) = 2023 THEN value ELSE 0 END) -
         SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%m/%d/%Y')) = 2021 THEN value ELSE 0 END)) / 
        NULLIF(SUM(CASE WHEN YEAR(STR_TO_DATE(date, '%m/%d/%Y')) = 2021 THEN value ELSE 0 END), 0) * 100, 
        2
    ) as percent_change_2021_to_2023,
    -- Peak usage
    ROUND(MAX(value), 2) as peak_monthly_gwh,
    -- Consistency
    COUNT(DISTINCT date) as months_with_data
FROM electricity_data
WHERE parameter = 'Used for pumped storage'
  AND product = 'Electricity'
  AND value > 0
GROUP BY country_name
HAVING months_with_data >= 3  -- At least 3 months of data
ORDER BY usage_2023_gwh DESC, total_historical_gwh DESC;

-- QUESTION 10. Are there correlations between fossil fuel dependency and growth in renewable energy within countries?
-- Focus: Correlation analysis between Total Combustible Fuels and Total Renewables over years.
-- Relevance: Identifies whether countries are transitioning or merely expanding total energy production without decarbonization.
WITH yearly_energy AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        SUM(CASE WHEN product IN ('Wind','Solar','Hydro','Combustible Renewables') THEN value ELSE 0 END) AS renewable_gwh,
        SUM(CASE WHEN product IN ('Coal, Peat and Manufactured Gases','Oil and Petroleum Products','Natural Gas') THEN value ELSE 0 END) AS fossil_gwh,
        SUM(value) AS total_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y'))
),

renewable_growth AS (
    SELECT
        e1.country_name,
        e1.year,
        e1.renewable_gwh,
        e1.fossil_gwh,
        e1.total_gwh,
        ROUND((e1.fossil_gwh / e1.total_gwh) * 100, 2) AS fossil_share_pct,
        ROUND(((e1.renewable_gwh - e2.renewable_gwh)/e2.renewable_gwh)*100,2) AS renewable_growth_pct
    FROM yearly_energy e1
    LEFT JOIN yearly_energy e2
      ON e1.country_name = e2.country_name AND e1.year = e2.year + 1
    WHERE e2.renewable_gwh IS NOT NULL
)

SELECT *
FROM renewable_growth
ORDER BY country_name, year;

-- QUESTION 11. Which countries have exceeded or lagged behind in achieving proportional renewable energy targets (e.g., 30% by 2030)?
-- Focus: Calculate cumulative renewable share per country and compare to target thresholds.
-- Relevance: Measures policy effectiveness and guides international cooperation for clean energy.
WITH yearly_renewables AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        SUM(CASE WHEN product IN ('Wind','Solar','Hydro','Combustible Renewables') THEN value ELSE 0 END) AS renewable_gwh,
        SUM(value) AS total_gwh,
        ROUND((SUM(CASE WHEN product IN ('Wind','Solar','Hydro','Combustible Renewables') THEN value ELSE 0 END) / SUM(value)) * 100, 2) AS renewable_share_pct
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y'))
)

SELECT
    country_name,
    year,
    renewable_gwh,
    total_gwh,
    renewable_share_pct,
    CASE
        WHEN renewable_share_pct >= 30 THEN 'On Track / Exceeded'
        ELSE 'Lagging'
    END AS status_vs_target
FROM yearly_renewables
WHERE year <= 2030
ORDER BY country_name, year;

-- QUESTION 12. How does electricity production per capita vary across countries if population data is integrated?
-- Focus: Join with population datasets to compute Net Electricity Production / population.
-- Relevance: Evaluates energy efficiency and consumption patterns relative to population size.

-- The original Data has no population, a population data table of the countries for 2020 to 2023 was created in the electricity_production database
-- Step 1: Select databse to create table
USE electricity_production;

-- Step 2: Create the population table
CREATE TABLE country_population (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) UNIQUE NOT NULL,
    pop_2020 BIGINT,
    pop_2021 BIGINT,
    pop_2022 BIGINT,
    pop_2023 BIGINT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_country (country_name)
);

-- Step 3: Insert population data for 2020-2023 (alphabetical order)
INSERT INTO country_population (country_name, pop_2020, pop_2021, pop_2022, pop_2023) VALUES
('Argentina', 45036032, 45847428, 45510318, 45715321),
('Australia', 25670051, 25959987, 26177413, 26385697),
('Austria', 8907777, 9065484, 8939617, 8955099),
('Belgium', 11561717, 11658404, 11655930, 11680348),
('Brazil', 213196304, 214832901, 215313498, 216169532),
('Bulgaria', 6979175, 6866274, 6781953, 6705093),
('Canada', 37888705, 38261228, 38454327, 38714362),
('Chile', 19300315, 19275294, 19603733, 19623798),
('China', 1424929781, 1447065329, 1425887337, 1425744073),
('Colombia', 50930662, 51504213, 51874024, 52033684),
('Costa Rica', 5123105, 5165346, 5180829, 5205094),
('Croatia', 4096868, 4067642, 4030358, 4013122),
('Cyprus', 1237537, 1220541, 1251488, 1258207),
('Czech Republic', 10530953, 10732960, 10493986, 10493364),
('Denmark', 5825641, 5825798, 5882261, 5905121),
('Estonia', 1329444, 1324323, 1326062, 1323409),
('Finland', 5529468, 5553102, 5540745, 5544831),
('France', 64480053, 65520147, 64626628, 64730842),
('Germany', 83328988, 83975691, 83369843, 83302356),
('Greece', 10512232, 10340571, 10384971, 10349000),
('Hungary', 9750573, 9618215, 9967308, 10192921),
('Iceland', 366669, 344646, 372899, 374674),
('India', 1396387127, 1401310563, 1417173173, 1425935059),
('Ireland', 4946119, 5008554, 5023109, 5049856),
('Italy', 59500579, 60320493, 59037474, 58905514),
('Japan', 125244761, 125802521, 123951692, 123429015),
('Latvia', 1897052, 1855735, 1850651, 1834072),
('Lithuania', 2820267, 2670680, 2750055, 2723500),
('Luxembourg', 630399, 640202, 647599, 653481),
('Malta', 515357, 443646, 533286, 534420),
('Mexico', 125998302, 131046075, 127504125, 128263146),
('Netherlands', 17434557, 17195298, 17564014, 17607359),
('New Zealand', 5061133, 4883704, 5185288, 5219734),
('North Macedonia', 2111072, 2082011, 2093599, 2086966),
('Norway', 5379839, 5492570, 5434319, 5465994),
('Peru', 33304756, 33587011, 34049588, 34285146),
('Poland', 38428366, 37764461, 39857145, 41210122),
('Portugal', 10298192, 10150252, 10270865, 10252753),
('Serbia', 7358005, 8674489, 7221365, 7161948),
('Slovakia', 5456681, 5460937, 5643453, 5816436),
('Slovenia', 2117641, 2078724, 2119844, 2119675),
('South Korea', 51844690, 51331264, 51815810, 51791782),
('Spain', 47363807, 46736811, 47558630, 47528638),
('Sweden', 10368969, 10196161, 10549347, 10599215),
('Switzerland', 8638613, 8752564, 8740472, 8785085),
('Turkey', 84135428, 85484777, 85341241, 85724172),
('United Kingdom', 67059474, 68401087, 67508936, 67690467),
('United States', 335942003, 334058426, 338289857, 339622662);

-- AFTER CREATING POPULATION TABLE, NOW ANSWER QUESTION 12
-- Step 4: Calculate per capita electricity production
-- Calculate electricity production per capita for December 2023
SELECT 
    e.country_name,
    -- Monthly electricity production
    MAX(CASE WHEN e.parameter = 'Net Electricity Production' AND e.product = 'Electricity' 
             THEN e.value END) as monthly_electricity_gwh,
    -- Population
    c.pop_2023 as population,
    -- Monthly per capita (kWh)
    ROUND(
        (MAX(CASE WHEN e.parameter = 'Net Electricity Production' AND e.product = 'Electricity' 
                 THEN e.value END) * 1000000) / c.pop_2023, 
        2
    ) as monthly_kwh_per_capita,
    -- Estimated annual per capita
    ROUND(
        (MAX(CASE WHEN e.parameter = 'Net Electricity Production' AND e.product = 'Electricity' 
                 THEN e.value END) * 12 * 1000000) / c.pop_2023, 
        2
    ) as estimated_annual_kwh_per_capita
FROM electricity_data e
JOIN country_population c ON e.country_name = c.country_name
WHERE (e.date LIKE '%2023-12%' OR e.date LIKE '%12/2023%' OR e.date LIKE '%12/1/2023%')
GROUP BY e.country_name, c.pop_2023
HAVING monthly_electricity_gwh IS NOT NULL
ORDER BY estimated_annual_kwh_per_capita DESC;

-- QUESTION 13. What is the volatility of electricity production from renewable sources year-over-year?
-- Focus: Compute standard deviation of Total Renewables per country.
-- Relevance: Assesses grid stability risks from fluctuating renewable sources.
WITH yearly_renewables AS (
    SELECT
        country_name,
        YEAR(STR_TO_DATE(date, '%m/%d/%Y')) AS year,
        SUM(CASE 
            WHEN product IN ('Wind','Solar','Hydro','Combustible Renewables')
            THEN value ELSE 0 
        END) AS renewable_gwh
    FROM electricity_data
    WHERE parameter = 'Net Electricity Production'
    GROUP BY country_name, YEAR(STR_TO_DATE(date, '%m/%d/%Y'))
),

volatility AS (
    SELECT
        country_name,
        year,
        renewable_gwh,
        LAG(renewable_gwh) OVER (
            PARTITION BY country_name ORDER BY year
        ) AS prev_year_gwh
    FROM yearly_renewables
)

SELECT
    country_name,
    year,
    renewable_gwh,
    prev_year_gwh,
    ROUND(
        ((renewable_gwh - prev_year_gwh) / prev_year_gwh) * 100, 
        2
    ) AS yoy_volatility_pct
FROM volatility
WHERE prev_year_gwh IS NOT NULL
ORDER BY country_name, year;

-- 14. How do global electricity production trends compare between developed and developing nations?
-- Focus: Classify countries by development index and aggregate Net Electricity Production.
-- Relevance: Reveals energy inequality and informs international development aid strategies.

-- Step 1: First Create country clasification table
USE electricity_production;
CREATE TABLE country_classification (
    country_name VARCHAR(100) PRIMARY KEY,
    development_status VARCHAR(20)
);

-- Step 2: insert data in the table
INSERT INTO country_classification VALUES
('Australia','Developed'),
('Austria','Developed'),
('Belgium','Developed'),
('Canada','Developed'),
('Czech Republic','Developed'),
('Denmark','Developed'),
('Estonia','Developed'),
('Finland','Developed'),
('France','Developed'),
('Germany','Developed'),
('Greece','Developed'),
('Hungary','Developed'),
('Iceland','Developed'),
('Ireland','Developed'),
('Italy','Developed'),
('Japan','Developed'),
('Korea','Developed'),
('Latvia','Developed'),
('Lithuania','Developed'),
('Luxembourg','Developed'),
('Netherlands','Developed'),
('New Zealand','Developed'),
('Norway','Developed'),
('Poland','Developed'),
('Portugal','Developed'),
('Slovak Republic','Developed'),
('Slovenia','Developed'),
('Spain','Developed'),
('Sweden','Developed'),
('Switzerland','Developed'),
('United Kingdom','Developed'),
('United States','Developed'),

('Argentina','Developing'),
('Brazil','Developing'),
('Bulgaria','Developing'),
('Chile','Developing'),
('China','Developing'),
('Colombia','Developing'),
('Costa Rica','Developing'),
('Croatia','Developing'),
('Cyprus','Developing'),
('India','Developing'),
('Malta','Developing'),
('Mexico','Developing'),
('North Macedonia','Developing'),
('Peru','Developing'),
('Serbia','Developing'),
('Turkey','Developing');

SELECT * FROM country_classification;

-- Step 3: AFTER COUNTRY CLASIFICATION, NOW ANSWER QUESTION 14
WITH yearly_electricity AS (
    SELECT
        e.country_name,
        YEAR(STR_TO_DATE(e.date, '%m/%d/%Y')) AS year,
        SUM(e.value) AS total_gwh
    FROM electricity_data e
    WHERE e.parameter = 'Net Electricity Production'
      AND e.product = 'Electricity'
    GROUP BY e.country_name, YEAR(STR_TO_DATE(e.date, '%m/%d/%Y'))
),
grouped AS (
    SELECT
        c.development_status,
        y.year,
        SUM(y.total_gwh) AS group_total_gwh
    FROM yearly_electricity y
    JOIN country_classification c
      ON y.country_name = c.country_name
    GROUP BY c.development_status, y.year
)

SELECT
    development_status,
    year,
    group_total_gwh,
    LAG(group_total_gwh) OVER (PARTITION BY development_status ORDER BY year) AS prev_year_gwh,
    ROUND(
        ((group_total_gwh - LAG(group_total_gwh) OVER (
            PARTITION BY development_status ORDER BY year
        )) / LAG(group_total_gwh) OVER (
            PARTITION BY development_status ORDER BY year
        )) * 100, 2
    ) AS yoy_growth_pct
FROM grouped
ORDER BY development_status, year;


-- 15. Are there emerging trends in alternative energy sources beyond traditional renewables?
-- Focus: Track any Other category in Total Renewables or products like geothermal.
-- Relevance: Highlights innovation and future opportunities in clean energy diversification.

-- Analyzing trends in alternative energy sources beyond traditional renewables
-- Traditional renewables typically include: Hydro, Wind, Solar, Geothermal

-- Step 1: First, let's look at countries with significant "Other Combustible Non-Renewables"
-- This might include sources like waste-to-energy, industrial gases, etc.
SELECT 
    country_name,
    SUM(CASE WHEN product = 'Other Combustible Non-Renewables' THEN value ELSE 0 END) as other_non_renewable_gwh,
    SUM(CASE WHEN product = 'Electricity' THEN value ELSE 0 END) as total_production_gwh,
    ROUND(
        SUM(CASE WHEN product = 'Other Combustible Non-Renewables' THEN value ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN product = 'Electricity' THEN value ELSE 0 END), 0), 2
    ) as other_non_renewable_pct
FROM electricity_data 
WHERE parameter = 'Net Electricity Production'
    AND product IN ('Electricity', 'Other Combustible Non-Renewables')
GROUP BY country_name
HAVING SUM(CASE WHEN product = 'Other Combustible Non-Renewables' THEN value ELSE 0 END) > 0
ORDER BY other_non_renewable_pct DESC;

-- Step 2: Analyze combustible renewables (biofuels, biomass, biogas) as an alternative
SELECT 
    country_name,
    SUM(CASE WHEN product = 'Combustible Renewables' THEN value ELSE 0 END) as combustible_renewables_gwh,
    SUM(CASE WHEN product = 'Total Renewables (Hydro, Geo, Solar, Wind, Other)' THEN value ELSE 0 END) as total_renewables_gwh,
    SUM(CASE WHEN product = 'Electricity' THEN value ELSE 0 END) as total_production_gwh,
    ROUND(
        SUM(CASE WHEN product = 'Combustible Renewables' THEN value ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN product = 'Total Renewables (Hydro, Geo, Solar, Wind, Other)' THEN value ELSE 0 END), 0), 2
    ) as combustible_share_of_renewables_pct
FROM electricity_data 
WHERE parameter = 'Net Electricity Production'
    AND product IN ('Electricity', 'Combustible Renewables', 'Total Renewables (Hydro, Geo, Solar, Wind, Other)')
GROUP BY country_name
HAVING SUM(CASE WHEN product = 'Combustible Renewables' THEN value ELSE 0 END) > 0
ORDER BY combustible_share_of_renewables_pct DESC;

-- Step 3: Look at geothermal energy specifically
SELECT 
    country_name,
    SUM(CASE WHEN product = 'Geothermal' THEN value ELSE 0 END) as geothermal_gwh,
    SUM(CASE WHEN product = 'Total Renewables (Hydro, Geo, Solar, Wind, Other)' THEN value ELSE 0 END) as total_renewables_gwh,
    ROUND(
        SUM(CASE WHEN product = 'Geothermal' THEN value ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN product = 'Total Renewables (Hydro, Geo, Solar, Wind, Other)' THEN value ELSE 0 END), 0), 2
    ) as geothermal_share_of_renewables_pct
FROM electricity_data 
WHERE parameter = 'Net Electricity Production'
    AND product IN ('Geothermal', 'Total Renewables (Hydro, Geo, Solar, Wind, Other)')
GROUP BY country_name
HAVING SUM(CASE WHEN product = 'Geothermal' THEN value ELSE 0 END) > 0
ORDER BY geothermal_gwh DESC;

-- Step 4: Comprehensive view of emerging vs traditional renewables
SELECT 
    country_name,
    -- Traditional renewables (Hydro, Wind, Solar)
    SUM(CASE WHEN product IN ('Hydro', 'Wind', 'Solar') THEN value ELSE 0 END) as traditional_renewables_gwh,
    -- Emerging/alternative renewables (Geothermal, Combustible Renewables, Other Combustible Non-Renewables)
    SUM(CASE WHEN product IN ('Geothermal', 'Combustible Renewables', 'Other Combustible Non-Renewables') 
             THEN value ELSE 0 END) as emerging_alternatives_gwh,
    SUM(CASE WHEN product = 'Electricity' THEN value ELSE 0 END) as total_production_gwh,
    ROUND(
        SUM(CASE WHEN product IN ('Geothermal', 'Combustible Renewables', 'Other Combustible Non-Renewables') THEN value ELSE 0 END) * 100.0 / 
        NULLIF(SUM(CASE WHEN product = 'Electricity' THEN value ELSE 0 END), 0), 2
    ) as emerging_alternatives_share_pct
FROM electricity_data 
WHERE parameter = 'Net Electricity Production'
    AND product IN ('Electricity', 'Hydro', 'Wind', 'Solar', 'Geothermal', 'Combustible Renewables', 'Other Combustible Non-Renewables')
GROUP BY country_name
HAVING SUM(CASE WHEN product IN ('Geothermal', 'Combustible Renewables', 'Other Combustible Non-Renewables') THEN value ELSE 0 END) > 0
ORDER BY emerging_alternatives_share_pct DESC;