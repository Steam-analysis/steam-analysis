{{ config(
    materialized='table'
) }}

with game_achievements_count as (
    -- ER diyagramına göre oyunların gerçek başarım sayılarını burada hesaplıyoruz
    select 
        game_id,
        count(distinct achievement_id) as total_achievements_count
    from {{ ref('stg_achievements') }}
    group by 1
),

activity_base as (
    select 
        h.activity_year as year,
        trim(genre) as genre,
        count(distinct h.player_id) as unique_players_activity,
        count(*) as total_activity_count,
        -- 🎯 DÜZELTME: g.total_achievements_count yerine ga.total_achievements_count yaptık!
        sum(coalesce(ga.total_achievements_count, 0)) as total_possible_achievements_pool,
        count(distinct g.game_id) as total_unique_games
    from {{ ref('stg_history') }} h
    join {{ ref('stg_achievements') }} a on h.achievement_id = a.achievement_id
    join {{ ref('stg_games') }} g on a.game_id = g.game_id
    left join game_achievements_count ga on g.game_id = ga.game_id
    cross join unnest(split(g.genres, ', ')) as genre
    where h.activity_year between 2008 and 2025
    group by 1, 2
),

revenue_base as (
    select
        estimated_purchase_year as year,
        trim(genre) as genre,
        sum(estimated_sales_count) as genre_sales_count,
        sum(estimated_total_revenue_usd) as genre_revenue_usd
    from {{ ref('mart_genre_revenue_trend') }}
    where estimated_purchase_year between 2008 and 2025
    group by 1, 2
),

market_totals as (
    select
        coalesce(a.year, r.year) as year,
        coalesce(a.genre, r.genre) as genre,
        coalesce(a.unique_players_activity, 0) as unique_players_activity,
        coalesce(a.total_activity_count, 0) as total_activity_count,
        coalesce(a.total_possible_achievements_pool, 0) as total_possible_achievements_pool,
        coalesce(a.total_unique_games, 0) as total_unique_games,
        coalesce(r.genre_sales_count, 0) as genre_sales_count,
        coalesce(r.genre_revenue_usd, 0) as genre_revenue_usd,
        
        sum(coalesce(r.genre_revenue_usd, 0)) over(partition by coalesce(a.year, r.year)) as total_market_revenue_usd,
        sum(coalesce(r.genre_sales_count, 0)) over(partition by coalesce(a.year, r.year)) as total_market_sales_count
    from activity_base a
    full outer join revenue_base r on a.year = r.year and a.genre = r.genre
)

select
    year,
    genre,
    genre_revenue_usd,
    genre_sales_count,
    total_activity_count,
    total_unique_games,

    safe_divide(total_activity_count, total_possible_achievements_pool) * 100 as genre_achievement_completion_rate,
    safe_divide(total_activity_count, unique_players_activity) as genre_activity_density,
    safe_divide(genre_revenue_usd, unique_players_activity) as genre_arpu,
    safe_divide(genre_revenue_usd, genre_sales_count) as genre_average_order_value,
    safe_divide(genre_revenue_usd, total_market_revenue_usd) * 100 as genre_revenue_share_pct,
    safe_divide(genre_sales_count, total_market_sales_count) * 100 as genre_sales_share_pct

from market_totals
order by year desc, genre_revenue_usd desc