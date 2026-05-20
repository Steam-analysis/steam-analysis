with raw_history as (
    select * from {{ source('bq_steam', 'history') }}
)

select
    cast(playerid as string) as player_id,
    cast(achievementid as string) as achievement_id,
    extract(year from cast(date_acquired as timestamp)) as activity_year

from raw_history
where date_acquired is not null
  -- Sadece şemada vaat edilen güvenli aktivite yıllarını alıyoruz
  and extract(year from cast(date_acquired as timestamp)) between 2008 and 2025