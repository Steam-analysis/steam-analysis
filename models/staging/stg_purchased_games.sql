select

    cast(playerid as string) as player_id,
    library

from {{ source('steam_raw', 'purchased_games') }}