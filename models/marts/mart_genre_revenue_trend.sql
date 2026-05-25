with purchase_prices as (
    select * from {{ ref('int_purchase_prices') }}
),

games as (
    select * from {{ ref('stg_games') }} 
),

joined as (
    select
        p.player_id,
        p.estimated_purchase_year,
        g.game_id,
        p.purchase_price_usd,
        genre 
    from purchase_prices p
    join games g on p.game_id = g.game_id
    cross join unnest(split(g.genres, ', ')) as genre 
),

final_summary as (
    select
        estimated_purchase_year,
        genre,
        count(distinct player_id) as estimated_sales_count,
        -- Dönemsel fiyat üzerinden gerçekçi ciro hesabı:
        sum(purchase_price_usd) as estimated_total_revenue_usd
    from joined
    where estimated_purchase_year is not null
    group by estimated_purchase_year, genre
)

select 
    estimated_purchase_year,
    genre,
    estimated_sales_count,
    estimated_total_revenue_usd,
    -- O yılın toplam cirosuna bölerek her türün pazar payını (%) hesaplıyoruz:
    estimated_total_revenue_usd / sum(estimated_total_revenue_usd) over(partition by estimated_purchase_year) as estimated_revenue_share
from final_summary
order by estimated_purchase_year asc, estimated_total_revenue_usd desc