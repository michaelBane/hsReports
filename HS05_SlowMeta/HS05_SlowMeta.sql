-- Turn game ended by player_class/pirate warrior
-- Run twice, once for late MSOG, once for early UNG
SELECT count(g.id) AS n_games,
       g.num_turns,
       p.player_class
FROM game g
JOIN player p
ON g.id = p.game_id
WHERE g.game_type = f_enum_val('BnetGameType.BGT_RANKED_STANDARD')
  AND g.game_date BETWEEN 'date1' AND 'date2'
GROUP BY g.num_turns, p.player_class

-- Stats on board by turn and class
-- Run twice, once for late MSOG, once for early UNG
SELECT avg(es.atk) AS average_attack,
       avg(es.health) AS average_health,
       es.class -- *
       es.turn
FROM entity_state es
WHERE es.game_type = f_enum_val('BnetGameType.BGT_RANKED_STANDARD')
  AND es.game_date BETWEEN 'date1' AND 'date2'
  AND es.zone = f_enum_val('Zone.PLAY')
  AND es.step = f_enum_val('Step.MAIN_READY')
GROUP BY es.turn, es.class

-- * I think entity_state.class is the card class, not the controller class? It looks like i would need to join on block (entity_controller) and than game then player to get the class of the player that controlls the entity. Seems tricky, is there a better way?