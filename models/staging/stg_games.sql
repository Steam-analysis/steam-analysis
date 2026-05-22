with raw_games as (
    select * from {{ source('bq_steam', 'games') }}
)

select
    cast(gameid as string) as game_id,
    trim(title) as game_title,
    regexp_replace(genres, r"[\[\]']", "") as genres,
    extract(year from cast(release_date as date)) as release_year

from raw_games
where genres is not null 
  and trim(genres) != ""
  and genres != "[]"
  and extract(year from cast(release_date as date)) between 1995 and 2026