SELECT
    p.player_id,
    p.country,
    p.created_at,

    a.total_achievements_unlocked,
    a.first_achievement_at,
    a.last_achievement_at,
    a.days_since_last_achievement,

    CASE
        WHEN a.days_since_last_achievement > 90 THEN 'Churn Risk'
        WHEN a.days_since_last_achievement > 30 THEN 'Inactive'
        ELSE 'Active'
    END AS engagement_status

FROM {{ ref('stg_players') }} p

LEFT JOIN {{ ref('int_player_achievement_activity') }} a
    ON p.player_id = a.player_id