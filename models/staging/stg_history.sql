-- models/staging/stg_history.sql
with raw_history as (
    select * from {{ source('bq_steam', 'history') }}
)

select
    cast(playerid as string) as player_id,
    cast(achievementid as string) as achievement_id,
    -- Zaman damgası (Timestamp) üzerinden yılı çekiyoruz
    extract(year from cast(date_acquired as timestamp)) as activity_year

from raw_history
where date_acquired is not null