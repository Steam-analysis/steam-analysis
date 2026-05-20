with raw_history as (
    select * from {{ source('bq_steam', 'history') }}
)

select
    cast(playerid as string) as player_id,
    cast(achievementid as string) as achievement_id,
    cast(date_acquired as timestamp) as activity_date,
    extract(year from cast(date_acquired as timestamp)) as activity_year

from raw_history
where date_acquired is not null
  and extract(year from cast(date_acquired as timestamp)) between 2008 and 2025