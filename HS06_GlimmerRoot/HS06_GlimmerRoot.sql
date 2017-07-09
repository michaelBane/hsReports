WITH valid_choice_blocks AS (
    SELECT
        c.game_id,
        c.block_id
    FROM choices c
    WHERE c.source_entity_dbf_id = f_dbf_id('Curious Glimmerroot')
    AND c.entity_dbf_id IS NOT NULL
    AND c.game_date BETWEEN '2017-05-20' AND '2017-05-27'
    GROUP BY c.game_id, c.block_id
    HAVING count(*) = 3
)
SELECT 
    f_enum_name('BnetGameType', CASE WHEN p.game_type = 7 THEN 10 ELSE p.game_type END) AS game_type,
    p.rank,
    f_enum_name('CardClass', o.player_class) AS opponent_class,
    f_player_turn(b.turn) AS player_turn,
    b.id AS glimmerroot_power_block_id,
    c.choices_block_id AS glimmerroot_choices_block_id,
    c.entity_dbf_id AS choice_entity_dbf_id,
    f_card_name(c.entity_dbf_id) AS choice_entity_name,
    c.chosen AS card_picked,
    CASE WHEN c.chosen AND es.zone = f_enum_val('Zone.HAND') THEN True ELSE False END AS is_correct
FROM player p 
JOIN player o ON o.game_id = p.game_id AND o.player_id != p.player_id
JOIN block b ON b.game_id = p.game_id AND b.entity_controller = p.player_id AND b.block_type = f_enum_val('BlockType.POWER')
JOIN valid_choice_blocks cb ON cb.game_id = p.game_id AND cb.block_id = b.id
JOIN choices c ON p.game_id = c.game_id AND c.player_entity_id = p.entity_id
JOIN entity_state es ON es.game_id = p.game_id AND es.entity_id = c.entity_id AND es.block_id = b.id AND es.is_before_block = False AND es.entity_id != b.entity_id
WHERE b.block_type = f_enum_val('BlockType.POWER')
AND b.entity_dbf_id = f_dbf_id('Curious Glimmerroot')
AND p.options_visible
AND p.rank BETWEEN (CASE WHEN p.game_type = 2 OR p.game_type = 30 THEN 0 ELSE -1 END) AND 25
AND p.game_date BETWEEN '2017-05-20' AND '2017-05-27'
AND o.game_date BETWEEN '2017-05-20' AND '2017-05-27'
AND b.game_date BETWEEN '2017-05-20' AND '2017-05-27'
AND c.game_date BETWEEN '2017-05-20' AND '2017-05-27'
AND es.game_date BETWEEN '2017-05-20' AND '2017-05-27';