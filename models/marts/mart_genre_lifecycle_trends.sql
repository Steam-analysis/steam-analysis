{{ config(
    materialized='table'
) }}

with genre_yearly_shares as (
    -- Her janrın her yıldaki ciro ve aktivite pazar payını çekiyoruz
    select 
        year,
        genre,
        genre_revenue_usd,
        total_activity_count,
        genre_revenue_share_pct,
        -- Aktivite pazar payını da oran olarak hesaplayalım
        safe_divide(total_activity_count, sum(total_activity_count) over(partition by year)) * 100 as genre_activity_share_pct
    from {{ ref('mart_genre_performance_kpis') }}
),

genre_statistical_trends as (
    -- Regresyon eğimi (Slope) ve son dönem güncel hacimlerini (Ortalama Pazar Payı) hesaplıyoruz
    select
        genre,
        -- 📈 Aktivite Trendleri (Zaman serisi doğrusal eğimi)
        regr_slope(genre_activity_share_pct, year) as activity_slope,
        avg(case when year >= 2022 then genre_activity_share_pct else null end) as recent_activity_share,

        -- 💰 Ciro Trendleri (Zaman serisi doğrusal eğimi)
        regr_slope(genre_revenue_share_pct, year) as revenue_slope,
        avg(case when year >= 2022 then genre_revenue_share_pct else null end) as recent_revenue_share
    from genre_yearly_shares
    group by 1
),

market_benchmarks as (
    -- Eşik değerleri: Eğimin sıfırdan büyük olması büyüme, son dönem payı medyanı ise büyüklük göstergesidir
    select
        percentile_cont(recent_activity_share, 0.5) over() as median_activity_share,
        percentile_cont(recent_revenue_share, 0.5) over() as median_revenue_share
    from genre_statistical_trends
    limit 1
)

select
    t.genre,
    t.activity_slope,
    t.recent_activity_share,
    t.revenue_slope,
    t.recent_revenue_share,

    -- 🎯 MATEMATİKSEL YAŞAM DÖNGÜSÜ KATEGORİZASYONU (CIRO TABANLI)
    case 
        when t.revenue_slope >= 0 and t.recent_revenue_share >= b.median_revenue_share 
            then 'Popülerken Popüler Kalan (Sektörün Lokomotifleri)'
        when t.revenue_slope >= 0 and t.recent_revenue_share < b.median_revenue_share 
            then 'Popüler Değilken Popüler Olan (Yükselen Yıldızlar / Atılımdakiler)'
        when t.revenue_slope < 0 and t.recent_revenue_share >= b.median_revenue_share 
            then 'Popülerken Kan Kaybeden (Zirveden Düşen Devler)'
        else 'Düşük Popülaritede Kalan (Niş / İlgi Görmeyen Türler)'
    end as revenue_lifecycle_category,

    -- 🎯 MATEMATİKSEL YAŞAM DÖNGÜSÜ KATEGORİZASYONU (AKTİVİTE TABANLI)
    case 
        when t.activity_slope >= 0 and t.recent_activity_share >= b.median_activity_share 
            then 'Aktifken Aktif Kalan (Oyuncuların Vazgeçilmezleri)'
        when t.activity_slope >= 0 and t.recent_activity_share < b.median_activity_share 
            then 'Aktivitesi Yeni Parlayanlar (Trend Yakalayanlar)'
        when t.activity_slope < 0 and t.recent_activity_share >= b.median_activity_share 
            then 'Oyuncunun Elini Çektiği Eski Alışkanlıklar'
        else 'Süreklilik Yakalayamayan Niş Türler'
    end as activity_lifecycle_category

from genre_statistical_trends t
cross join market_benchmarks b