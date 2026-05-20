select
    cast(gameid as string) as game_id,
    title,
    developers,
    cast(release_date as date) as release_date

from {{ source('steam', 'games') }}

where gameid is not null
  and title is not null