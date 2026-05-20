with estimated_purchases as (
    select * from {{ ref('int_estimated_purchases') }}
),

games as (
    select * from {{ ref('stg_games') }} 
),

joined as (
    select
        p.player_id,
        p.estimated_purchase_year,
        g.game_id,
        genre 
    from estimated_purchases p
    join games g on p.game_id = g.game_id
    -- STRING türündeki veriyi virgül ve boşluktan (, ) ayırarak array'e çevirip öyle patlatıyoruz:
    cross join unnest(split(g.genres, ', ')) as genre 
),

final_summary as (
    select
        estimated_purchase_year,
        genre,
        count(distinct player_id) as estimated_sales_count
    from joined
    where estimated_purchase_year is not null
    group by estimated_purchase_year, genre
)

select * from final_summary
order by estimated_purchase_year asc, estimated_sales_count desc