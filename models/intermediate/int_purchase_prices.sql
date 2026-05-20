with purchases as (
    select * from {{ ref('int_estimated_purchases') }}
),

prices as (
    select * from {{ ref('stg_prices') }}
),

joined_history as (
    select
        p.player_id,
        p.game_id,
        p.estimated_purchase_date,
        p.estimated_purchase_year,
        pr.usd_price,
        -- Eğer geçmiş fiyat bulunamadıysa sistem hata vermesin diye MAX() veya pencere fonksiyonu için base_price'ı koruyoruz:
        pr.base_price, 
        row_number() over (
            partition by p.player_id, p.game_id
            order by pr.price_date desc
        ) as rn
    from purchases p
    left join prices pr on p.game_id = pr.game_id 
        and pr.price_date <= cast(p.estimated_purchase_date as date)
),

-- Fiyatı eşleşenleri netleştiriyoruz, eşleşmeyenler için ana tablodan base_price çekeceğiz
final_prices as (
    select
        player_id,
        game_id,
        estimated_purchase_year,
        usd_price,
        base_price
    from joined_history
    where rn = 1
)

select
    f.player_id,
    f.game_id,
    f.estimated_purchase_year,
    -- EĞER DÖNEMSEL FİYAT YOKSA (0 veya NULL ise), OYUNUN EN ESKİ TABAN FİYATINI BAS:
    case 
        when f.usd_price is null or f.usd_price = 0 then coalesce(f.base_price, (select avg(base_price) from prices where game_id = f.game_id))
        else f.usd_price
    end as purchase_price_usd
from final_prices f