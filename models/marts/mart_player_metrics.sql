with players as (

    select *
    from {{ ref('stg_players') }}

),

purchased as (

    select
        player_id,
        count(*) as purchased_games_count
    from {{ ref('stg_purchased_games') }}
    group by player_id

),

friends as (

    select
        player_id,
        count(*) as friends_count
    from {{ ref('stg_friends') }}
    group by player_id

),
achievement_counts as (

    select *
    from {{ ref('int_player_achievements') }}

)

select

    players.player_id,
    players.country,
    players.created_year,
    coalesce(purchased.purchased_games_count, 0) as purchased_games_count,
    coalesce(friends.friends_count, 0) as friends_count

from players
left join purchased
    on players.player_id = purchased.player_id
left join friends
    on players.player_id = friends.player_id
left join achievement_counts
    on players.player_id = achievement_counts.player_id