WITH player_cohorts AS (

    SELECT
        player_id,
        DATE_TRUNC(DATE(created_at), MONTH) AS signup_month
    FROM {{ ref('stg_players') }}
    WHERE created_at IS NOT NULL

),

player_activity AS (

    SELECT
        player_id,
        DATE_TRUNC(DATE(acquired_at), MONTH) AS activity_month
    FROM {{ ref('stg_history') }}
    WHERE acquired_at IS NOT NULL

),

cohort_activity AS (

    SELECT
        c.signup_month,
        a.activity_month,
        DATE_DIFF(a.activity_month, c.signup_month, MONTH) AS cohort_index,
        COUNT(DISTINCT a.player_id) AS active_players
    FROM player_cohorts c
    JOIN player_activity a
        ON c.player_id = a.player_id
    GROUP BY 1, 2, 3

),

cohort_size AS (

    SELECT
        signup_month,
        COUNT(DISTINCT player_id) AS cohort_size
    FROM player_cohorts
    GROUP BY 1

)

SELECT
    ca.signup_month,
    ca.activity_month,
    ca.cohort_index,
    cs.cohort_size,
    ca.active_players,
    ROUND(SAFE_DIVIDE(ca.active_players, cs.cohort_size) * 100, 2) AS retention_rate
FROM cohort_activity ca
JOIN cohort_size cs
    ON ca.signup_month = cs.signup_month
WHERE ca.cohort_index >= 0
ORDER BY ca.signup_month, ca.cohort_index