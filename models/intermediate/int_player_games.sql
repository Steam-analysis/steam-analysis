select
    pa.player_id,
    pa.country,
    pa.created_date,
    pa.acquired_date,
    pa.achievement_id,
    pa.achievement_title,
    g.game_id,
    g.title as game_title,
    g.developers,
    g.release_date

from {{ ref('int_player_achievements') }} pa

left join {{ ref('stg_games') }} g
    on pa.game_id = g.game_id