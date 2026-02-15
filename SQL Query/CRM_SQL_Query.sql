-- 1. Create SQL Database to import table usring python pipeline
create database CRM_database;
use CRM_database;

-- 2. Write SQL queries to answer the following:
-- 1. Total number of leads generated per month.
SELECT
    DATE_FORMAT(contact_created_date, '%Y-%m') AS lead_month,
    COUNT(DISTINCT contact_id) AS total_leads
FROM contacts_tbl
GROUP BY lead_month
ORDER BY lead_month;

-- 2. Conversion rate from lead → opportunity → deal.
SELECT
    COUNT(DISTINCT contact_id) AS total_leads,
    COUNT(DISTINCT deal_id) AS total_opportunities,
    COUNT(DISTINCT CASE 
        WHEN deal_stage = 'Closed Won' THEN deal_id 
    END) AS total_deals,

    ROUND(COUNT(DISTINCT deal_id) / COUNT(DISTINCT contact_id) * 10, 2) 
        AS lead_to_opportunity_rate,

    ROUND(COUNT(DISTINCT CASE 
        WHEN deal_stage = 'Closed Won' THEN deal_id 
    END) / COUNT(DISTINCT deal_id) * 100, 2) 
        AS opportunity_to_deal_rate
FROM deals_tbl;


-- 3. Top-performing sales reps by closed revenue

select deals_sales_rep, sum(deal_amount) as total_closed_revenue
from deals_tbl
where deal_stage="Closed Won" 
group by deals_sales_rep
order by total_closed_revenue desc;

-- 4. Average deal size and duration.
select Round(avg(deal_amount),2) as avg_deal_size, 
	    ROUND(AVG(DATEDIFF(closed_date, deal_created_date)), 2) AS avg_duration
from deals_tbl;

-- 3. Write 5 advanced SQL queries including:
-- 1. A CTE ( means monthly customer activity)to find monthly active contacts.
select date_format(contact_created_date, '%Y-%m') AS activity_months,
	   count(distinct contact_id) as monthly_active_contacts
from contacts_tbl
group by activity_months
order by monthly_active_contacts;

-- 2. A window function to rank sales reps by revenue.
select deals_sales_rep, sum(deal_amount) as revenue,
	   RANK() OVER (ORDER BY SUM(deal_amount) DESC) AS revenue_rank
from deals_tbl
WHERE deal_stage = 'Closed Won'
group by deals_sales_rep
order by revenue_rank;

-- 3. Subqueries to calculate CLV (customer_lifetime_value).
SELECT
     contact_id, sum(deal_amount) as customer_lifetime_value
FROM (
    SELECT
	contact_id,  deal_amount
    FROM deals_tbl
    WHERE deal_stage = 'Closed Won'
) closed_deals
GROUP BY contact_id
ORDER BY customer_lifetime_value DESC;

-- 4. Subqueries to calculate customer churn probability (probability of getting No activity in the last 3 months).
SELECT
    COUNT(CASE
        WHEN last_activity < DATE_SUB(CURDATE(), INTERVAL 3 MONTH)
        THEN 1 END
    ) / COUNT(*) AS churn_probability
FROM (
    SELECT
        contact_id,
        MAX(response_time) AS last_activity
    FROM activities_tbl
    GROUP BY contact_id
) customer_activity;

-- 5. How many records exist at each funnel stage?
SELECT
    deal_stage,
    COUNT(*) AS stage_count
FROM deals_tbl
WHERE deal_stage IN (
    'Prospecting',
    'Qualified',
    'Negotiation',
    'Proposal',
    'Closed Lost',
    'Closed Won'
)
GROUP BY deal_stage
ORDER BY stage_count DESC;


