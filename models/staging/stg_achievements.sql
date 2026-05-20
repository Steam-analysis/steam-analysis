with raw_achievements as (
    select * from {{ source('bq_steam', 'achievements') }}
)

select
    cast(gameid as string) as game_id,
    cast(achievementid as string) as achievement_id,
    title,
    description
from raw_achievements