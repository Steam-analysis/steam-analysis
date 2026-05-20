with raw_games as (
    select * from {{ source('bq_steam', 'games') }}
)

select
    cast(game_id as string) as game_id,
    trim(title) as game_title,
    trim(genres) as genres, -- 'genre' yerine 'genres' olarak düzelttik
    -- Çıkış tarihinden yılı ayıklıyoruz
    extract(year from cast(release_date as date)) as release_year 

from raw_games
where genres is not null  -- Burayı da güncelledik
  and release_date is not null