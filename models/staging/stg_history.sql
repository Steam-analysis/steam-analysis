SELECT
    CAST(playerid AS STRING) AS player_id,

    achievementid AS achievement_id,

    date_acquired AS acquired_at

FROM `steam-analiz.Steam.history`