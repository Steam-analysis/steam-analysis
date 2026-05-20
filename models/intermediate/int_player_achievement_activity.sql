SELECT
    player_id,
    COUNT(achievement_id) AS total_achievements_unlocked,
    MIN(acquired_at) AS first_achievement_at,
    MAX(acquired_at) AS last_achievement_at,
    DATE_DIFF(CURRENT_DATE(), DATE(MAX(acquired_at)), DAY) AS days_since_last_achievement
FROM {{ ref('stg_history') }}
GROUP BY player_id