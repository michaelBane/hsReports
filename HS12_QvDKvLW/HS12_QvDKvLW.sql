-- KPIs by card for Quests, DKs & Weapons.
SELECT a.*,
       b.total_games
FROM

(-- Deck include rate
-- Win rate by date
SELECT sum(total_games) AS deck_games_qDkLw, -- assuming this is deck include rate
       sum(total_wins) AS wins,
       game_date, 
       game_type,
       f_card_name(dbf_id)
FROM included_card_stats
WHERE dbf_id IN (42987, 43392, 43398, 43406, 43408, 43415, 43417, 43419, 43423, 43369, 43426, 45528, 46077, 46107, 46299, 46263, 46305, 47035, 41168, 41222, 41099, 41856, 41368, 41427, 41494, 41499, 41868) -- Quests, DKs and Leg Weapons
  AND (game_date BETWEEN '2017-04-06' AND '2017-04-13'
       OR game_date BETWEEN '2017-08-10' AND '2017-04-17'
       OR game_date BETWEEN '2017-12-07' AND '2017-12-14')
  AND game_type IN (2, 30) -- Ranked Standard and Wild
GROUP BY game_date,
         dbf_id,
         game_type) a

JOIN

(SELECT sum(total_games) AS total_games,
       game_date, 
       game_type
FROM included_card_stats
WHERE (game_date BETWEEN '2017-04-06' AND '2017-04-13'
       OR game_date BETWEEN '2017-08-10' AND '2017-04-17'
       OR game_date BETWEEN '2017-12-07' AND '2017-12-14')
  AND game_type IN (2, 30) -- Ranked Standard and Wild
GROUP BY game_date,
         dbf_id,
         game_type) b on a.game_date = b.game_date and a.game_type = b.game_type