-- models/intermediate/int_genre_popularity_by_year.sql
with games as (
    select * from {{ ref('stg_games') }}
),

history as (
    select * from {{ ref('stg_history') }}
),

achievements as (
    select * from {{ ref('stg_achievements') }}
),

-- Temizlenmiş tür listesini satırlara patlatıyoruz
flattened_genres as (
    select
        game_id,
        game_title,
        trim(single_genre) as genre,
        release_year
    from games,
    unnest(split(genres, ',')) as single_genre
),

player_activities as (
    select
        h.player_id,
        h.activity_year,
        a.game_id
    from history h
    join achievements a on h.achievement_id = a.achievement_id
)

select
    pa.activity_year as analysis_year,
    g.genre,
    count(*) as total_activity_count,
    count(distinct pa.player_id) as unique_player_count
from player_activities pa
join flattened_genres g on pa.game_id = g.game_id
where pa.activity_year between 2008 and 2025
group by 1, 2