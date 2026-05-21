select
    h.player_id,
    p.country,
    p.created_date,
    h.achievement_id,
    h.acquired_date

from {{ ref('stg_history') }} h

left join {{ ref('stg_players') }} p
    on h.player_id = p.player_id