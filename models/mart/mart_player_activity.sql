select
    player_id,
    country,
    created_date,
    count(distinct achievement_id) as total_achievements,
    count(distinct game_id) as total_games_played,
    min(acquired_date) as first_activity_date,
    max(acquired_date) as last_activity_date

from {{ ref('int_player_games') }}

group by
    player_id,
    country,
    created_date