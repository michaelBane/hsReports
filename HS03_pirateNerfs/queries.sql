-- What kills STB query
SELECT f_enum_name('CardClass', p.player_class) AS predator_class,
       f_card_name(es.last_affected_by_dbf_id) AS predator_name,
       count(*) AS num_patches_killed
FROM entity_state es
JOIN player p ON p.game_id = es.game_id AND p.player_id != es.controller
WHERE es.game_date BETWEEN '2017-02-17' AND '2017-02-22'
  AND p.game_date BETWEEN '2017-02-17' AND '2017-02-22'
  AND p.game_type = f_enum_val('BnetGameType.BGT_RANKED_STANDARD')
  AND p.rank <= 15
  AND es.dbf_id = f_dbf_id('Small-Time Buccaneer')
  AND es.turn = es.entered_zone_on
  AND es.zone = f_enum_val('Zone.GRAVEYARD')
  AND es.last_affected_by_dbf_id IS NOT NULL
GROUP BY p.player_class, es.last_affected_by_dbf_id
ORDER BY count(*) DESC;

-- Cards played
-- STB/Claws play and win-rate.
SELECT f_enum_name('CardClass', p.player_class) AS player_class,
        f_card_name(b.entity_dbf_id) AS card_name,
       count(b.id) AS times_played,
       SUM(CASE WHEN p.final_state = f_enum_val('PlayState.WON') THEN 1 ELSE 0 END) AS wins
FROM block b
JOIN player p ON p.game_id = b.game_id AND p.player_id = b.entity_controller
WHERE p.game_date BETWEEN '2017-02-17' AND '2017-02-22'
    AND b.game_date BETWEEN '2017-02-17' AND '2017-02-22'
  AND p.game_type = f_enum_val('BnetGameType.BGT_RANKED_STANDARD')
  AND p.rank <= 15
  AND b.block_type = f_enum_val('BlockType.PLAY') -- Does this include weapon plays? Patches Summons?
GROUP BY p.player_class, b.entity_dbf_id
HAVING count(b.id) >= 100
ORDER BY count(b.id) DESC;