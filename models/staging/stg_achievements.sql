select
    cast(achievementid as string) as achievement_id,
    cast(gameid as string) as game_id,
    title

from {{ source('steam', 'achievements') }}

where achievementid is not null
  and gameid is not null
  and title is not null