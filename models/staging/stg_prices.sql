with raw_prices as (
    select * from {{ source('bq_steam', 'prices') }} -- 👈 Sabit isim yerine source yapısına çektik
),

ranked_prices as (
    select
        cast(gameid as string) as game_id,
        cast(usd as float64) as usd_price,
        cast(date_acquired as date) as price_date,
        row_number() over (
            partition by gameid 
            order by date_acquired asc
        ) as rn_earliest
    from raw_prices
),

earliest_prices as (
    select game_id, usd_price as base_price 
    from ranked_prices 
    where rn_earliest = 1
)

select
    r.game_id,
    r.usd_price,
    r.price_date,
    e.base_price
from ranked_prices r
join earliest_prices e on r.game_id = e.game_id