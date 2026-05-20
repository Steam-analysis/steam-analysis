-- models/staging/stg_games.sql
with raw_games as (
    select * from {{ source('bq_steam', 'games') }}
)

select
    cast(gameid as string) as game_id,
    trim(title) as game_title,
    
    -- Köşeli parantezleri [ ] ve tek tırnakları ' temizliyoruz
    regexp_replace(genres, r"[\[\]']", "") as genres,
    regexp_replace(developers, r"[\[\]']", "") as developers,
    regexp_replace(publishers, r"[\[\]']", "") as publishers,
    
    extract(year from cast(release_date as date)) as release_year 

from raw_games
where genres is not null 
  and genres != "[]" -- Boş listeleri eliyoruz
  and release_date is not null