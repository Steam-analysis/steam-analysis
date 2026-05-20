select
    cast(playerid as string) as player_id,
    lower(country) as country,
    cast(created as date) as created_date

from {{ source('steam', 'players') }}

where playerid is not null