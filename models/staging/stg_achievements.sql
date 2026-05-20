with raw_achievements as (
    select * from {{ source('bq_steam', 'achievements') }}
)

select
    cast(achievementid as string) as achievement_id,
    cast(gameid as string) as game_id
    
from raw_achievements