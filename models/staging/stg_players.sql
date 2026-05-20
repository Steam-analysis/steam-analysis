SELECT
    CAST(playerid AS STRING) AS player_id,

    LOWER(TRIM(country)) AS country,

    created AS created_at

FROM `steam-analiz.Steam.players`