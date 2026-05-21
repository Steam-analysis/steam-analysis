select
    acquired_date,

    count(distinct achievement_id) as total_achievements_earned,

    count(distinct player_id) as active_players

from {{ ref('int_player_games') }}

group by
    acquired_date

order by
    acquired_date