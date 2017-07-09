-- This query extracts the cards people have in there deck by rank.
-- Specifically its the total number of games played with a card in a deck (not plays).
-- I am assuming included_card_stats contains data for all cards in a deck.
SELECT sum(total_games) AS games_played_with_card_in_deck,
       CASE
         WHEN c.rank = 0 THEN 'Legend'
         WHEN c.rank < 5 THEN 'GrindToLegend'
         WHEN c.rank = 5 THEN 'Rank5'
         WHEN c,rank < 10 THEN 'GrindTo5'
         WHEN c.rank = 10 THEN 'Rank10'
         WHEN c.rank < 15 THEN 'GrindTo10'
         WHEN c.rank = 15 THEN 'Rank15'
         WHEN c.rank < 20 THEN 'GrindTo15'
         ELSE 'other'
       END AS rank_category,
       f_card_name(c.dbf_id) AS card_name
FROM included_card_stats c
WHERE c.game_date > 'fake-date-here'
  AND c.game_type = f_enum_val('BnetGameType.BGT_RANKED_STANDARD')
  AND c.rank < 20
GROUP BY CASE
           WHEN c.rank = 0 THEN 'Legend'
           WHEN c.rank < 5 THEN 'GrindToLegend'
           WHEN c.rank = 5 THEN 'Rank5'
           WHEN c,rank < 10 THEN 'GrindTo5'
           WHEN c.rank = 10 THEN 'Rank10'
           WHEN c.rank < 15 THEN 'GrindTo10'
           WHEN c.rank = 15 THEN 'Rank15'
           WHEN c.rank < 20 THEN 'GrindTo15'
         ELSE 'other'
       END,
       c.dbf_id
HAVING sum(total_games) > 100
