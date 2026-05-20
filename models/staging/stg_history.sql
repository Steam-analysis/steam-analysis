select
    cast(playerid as string) as player_id,
    cast(achievementid as string) as achievement_id,
    cast(date_acquired as date) as acquired_date

from {{ source('steam', 'history') }}

where playerid is not null
  and achievementid is not null
  and date_acquired is not null