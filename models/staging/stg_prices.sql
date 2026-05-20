with raw_prices as (
    select * from `steam-analiz.Steam.prices`
),

ranked_prices as (
    select
        cast(gameid as string) as game_id,
        usd as usd_price,
        cast(date_acquired as date) as price_date,
        -- Oyunun tarihteki en eski fiyatını bulmak için eskinden yeniye sıralıyoruz:
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