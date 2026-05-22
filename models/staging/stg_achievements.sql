with raw_achievements as (
    select * from {{ source('bq_steam', 'achievements') }}
)

select
    cast(achievementid as string) as achievement_id,
    cast(gameid as string) as game_id,
    trim(title) as achievement_title,
    trim(description) as achievement_description
from raw_achievements