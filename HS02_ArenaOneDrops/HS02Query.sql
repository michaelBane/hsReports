SELECT SUM(pg.player_wins) AS games_won,
       COUNT(pg.game_id) AS games_played,
       pg.is_first AS went_first,
       bc.name AS card_played,
       f_enum_name('CardClass', pg.player_class) AS player_class
FROM
  (-- Find all the arena games where a player had a 1 drop in their deck (and the full deck is known). Collect players class, whether they won or not, and whether they went first 
   SELECT p.game_id,
          p.player_id,
          p.is_first,
          p.player_class,
          CASE
              WHEN p.final_state = f_enum_val('PlayState.WON') THEN 1
              ELSE 0
          END AS player_wins
   FROM player p
   WHERE p.game_date = DATE '2017-01-23' -- Depending on sample, this should prob be a range.
     AND p.full_deck_known = TRUE
     AND p.game_type = f_enum_val('BnetGameType.BGT_ARENA')
     AND f_count_cards_of_cost(1, p.deck_list) > 0
) pg
LEFT JOIN  -- Left join so that we return all games played, including those with no turn 1 play
  (-- Find all of the turn 1 plays (card associated with a block with transition from hand to play).
   SELECT b.entity_controller,
          b.game_id,
          c.name
   FROM block b
   JOIN card c ON b.entity_dbf_id = c.dbf_id
   WHERE b.game_date = DATE '2017-01-23'
    AND b.block_type = f_enum_val('BlockType.PLAY')
    AND b.turn = 1
) bc ON pg.game_id = bc.game_id AND pg.player_id = bc.entity_controller
GROUP BY pg.is_first,
         bc.name,
         f_enum_name('CardClass', pg.player_class)