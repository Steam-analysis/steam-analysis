select
    ph.player_id,
    ph.country,
    ph.created_date,
    ph.acquired_date,
    ph.achievement_id,
    a.game_id,
    a.title as achievement_title

from {{ ref('int_player_history') }} ph

left join {{ ref('stg_achievements') }} a
    on ph.achievement_id = a.achievement_id