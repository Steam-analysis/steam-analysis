{{ config(
    materialized='table'
) }}

with current_year_data as (
    -- Veri setindeki en son güncel yılın genel pazar özetini alıyoruz
    select
        year,
        sum(genre_revenue_usd) as total_revenue,
        sum(genre_sales_count) as total_sales,
        -- Ortalama oyun başı ciro (Sepet hacmi hissi yaratır)
        safe_divide(sum(genre_revenue_usd), sum(genre_sales_count)) as avg_revenue_per_sale
    from {{ ref('mart_genre_performance_kpis') }}
    where year = (select max(year) from {{ ref('mart_genre_performance_kpis') }})
    group by 1
),

rising_star as (
    -- Momentum skoru en yüksek olan lider janrı çekiyoruz
    select genre as rising_genre, overall_momentum_score as max_momentum
    from {{ ref('mart_genre_lifecycle_trends') }}
    order by overall_momentum_score desc
    limit 1
),

fading_giant as (
    -- Momentum skoru en düşük olan batan janrı çekiyoruz
    select genre as fading_genre, overall_momentum_score as min_momentum
    from {{ ref('mart_genre_lifecycle_trends') }}
    order by overall_momentum_score asc
    limit 1
)

select
    c.*,
    r.rising_genre,
    r.max_momentum,
    f.fading_genre,
    f.min_momentum
from current_year_data c
cross join rising_star r
cross join fading_giant f