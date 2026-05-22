{{ config(
    materialized='table'
) }}

with genre_yearly_shares as (
    -- Her janrın her yıldaki ciro, aktivite ve satış adedi pazar payını hesaplarken isimleri Türkçeleştiriyoruz
    select 
        year,
        case 
            when genre = 'Action' then 'Aksiyon'
            when genre = 'Adventure' then 'Macera'
            when genre = 'Casual' then 'Gündelik (Casual)'
            when genre = 'Strategy' then 'Strateji'
            when genre = 'Simulation' then 'Simülasyon'
            when genre = 'Massively Multiplayer' then 'MMO (Çok Oyunculu)'
            when genre = 'Early Access' then 'Erken Erişim'
            when genre = 'Free To Play' then 'Ücretsiz (Free to Play)'
            when genre = 'Sports' then 'Spor'
            when genre = 'Racing' then 'Yarış'
            when genre = 'Utilities' then 'Araçlar (Utilities)'
            when genre = 'Design & Illustration' then 'Tasarım ve Çizim'
            when genre = 'Animation & Modeling' then 'Animasyon ve Modelleme'
            when genre = 'Video Production' then 'Video Üretimi'
            when genre = 'Audio Production' then 'Ses Üretimi'
            when genre = 'Software Training' then 'Yazılım Eğitimi'
            when genre = 'Education' then 'Eğitim'
            when genre = 'Web Publishing' then 'Web Yayıncılığı'
            when genre = 'Game Development' then 'Oyun Geliştirme'
            when genre = 'Photo Editing' then 'Fotoğraf Düzenleme'
            when genre = 'Violent' then 'Şiddet'
            when genre = 'Gore' then 'Kan/Vahşet'
            when genre = 'Nudity' then 'Çıplaklık'
            when genre = 'Sexual Content' then 'Cinsel İçerik'
            when genre = 'Movie' then 'Film'
            else genre 
        end as genre,
        genre_revenue_usd,
        genre_sales_count,
        total_activity_count,
        genre_revenue_share_pct,
        safe_divide(total_activity_count, sum(total_activity_count) over(partition by year)) * 100 as genre_activity_share_pct,
        safe_divide(genre_sales_count, sum(genre_sales_count) over(partition by year)) * 100 as genre_sales_share_pct
    from {{ ref('mart_genre_performance_kpis') }}
),

genre_statistical_trends as (
    -- 1. Aşama: Ham slope ve yakın dönem share değerlerini hesaplıyoruz
    select
        genre,
        
        -- Ciro Trendi
        safe_divide(count(*) * sum(year * genre_revenue_share_pct) - sum(year) * sum(genre_revenue_share_pct), count(*) * sum(year * year) - sum(year) * sum(year)) as revenue_slope,
        avg(case when year >= 2022 then genre_revenue_share_pct else null end) as recent_revenue_share,

        -- Aktivite Trendi
        safe_divide(count(*) * sum(year * genre_activity_share_pct) - sum(year) * sum(genre_activity_share_pct), count(*) * sum(year * year) - sum(year) * sum(year)) as activity_slope,
        avg(case when year >= 2022 then genre_activity_share_pct else null end) as recent_activity_share,

        -- Satış Trendi
        safe_divide(count(*) * sum(year * genre_sales_share_pct) - sum(year) * sum(genre_sales_share_pct), count(*) * sum(year * year) - sum(year) * sum(year)) as sales_slope,
        avg(case when year >= 2022 then genre_sales_share_pct else null end) as recent_sales_share
    from genre_yearly_shares
    group by 1
),

global_stats as (
    -- 2. Aşama: Eşit ağırlıklandırma (Z-Score) için pazar genelindeki ortalama ve standart sapmaları buluyoruz
    select
        avg(revenue_slope) as avg_rev_slope, stddev(revenue_slope) as std_rev_slope,
        avg(activity_slope) as avg_act_slope, stddev(activity_slope) as std_act_slope,
        avg(sales_slope) as avg_sal_slope, stddev(sales_slope) as std_sal_slope
    from genre_statistical_trends
),

normalized_trends as (
    -- 3. Aşama: Her janrın eğimini standartlaştırıp (Z-Score) 3 metriğin "Overall" ortalamasını alıyoruz
    select
        t.*,
        safe_divide(t.revenue_slope - g.avg_rev_slope, g.std_rev_slope) as z_revenue_slope,
        safe_divide(t.activity_slope - g.avg_act_slope, g.std_act_slope) as z_activity_slope,
        safe_divide(t.sales_slope - g.avg_sal_slope, g.std_sal_slope) as z_sales_slope
    from genre_statistical_trends t
    cross join global_stats g
),

final_scores as (
    -- 4. Aşama: Bileşik momentum skorunu ve güncel genel pazar payı ağırlığını (Share) hesaplıyoruz
    select
        genre,
        revenue_slope, recent_revenue_share,
        activity_slope, recent_activity_share,
        sales_slope, recent_sales_share,
        
        -- 🌟 ÜÇ METRİĞİN EŞİT AĞIRLIKLI BİLEŞİK MOMENTUM SKORU (OVERALL SLOPE)
        (z_revenue_slope + z_activity_slope + z_sales_slope) / 3.0 as overall_momentum_score,
        
        -- Güncel genel hacim büyüklüğü (3 pazar payının basit ortalaması)
        (recent_revenue_share + recent_activity_share + recent_sales_share) / 3.0 as overall_recent_share
    from normalized_trends
)

select
    f.*,
    -- 🎯 3 METRİGE GÖRE ULTIMATE YAŞAM DÖNGÜSÜ KATEGORİZASYONU
    case 
        when f.overall_momentum_score >= 0 and f.overall_recent_share >= (percentile_cont(f.overall_recent_share, 0.5) over()) 
            then 'Kusursuz Devler (Ciro, Satış ve Oyuncuda Zirve)'
        when f.overall_momentum_score >= 0 and f.overall_recent_share < (percentile_cont(f.overall_recent_share, 0.5) over()) 
            then 'Yükselen Yıldızlar (Her Alanda Atılım Yapanlar)'
        when f.overall_momentum_score < 0 and f.overall_recent_share >= (percentile_cont(f.overall_recent_share, 0.5) over()) 
            then 'Hacimli Ama Kan Kaybedenler (Eski Gücünü Yitirenler)'
        else 'Düşük Performanslı Niş Türler'
    end as overall_lifecycle_category
from final_scores f