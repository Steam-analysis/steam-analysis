with history as (
    select * from {{ ref('stg_history') }}
),

achievements as (
    select * from {{ ref('stg_achievements') }}
),

-- 1. Adım: Başarımlar üzerinden oyuncunun aktivitesine oyun ID'sini bağlıyoruz
history_with_game as (
    select
        h.player_id,
        a.game_id,
        h.activity_date
    from history h
    join achievements a on h.achievement_id = a.achievement_id
)

-- 2. Adım: Oyuncu ve Oyun bazında gruplayıp tahmini satın alma yılını hesaplıyoruz
select
    player_id,
    game_id,
    min(activity_date) as estimated_purchase_date,
    extract(year from min(activity_date)) as estimated_purchase_year
from history_with_game
group by player_id, game_id