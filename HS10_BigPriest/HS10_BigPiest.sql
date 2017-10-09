SELECT
        f_card_name(s.dbf_id) AS barnes_created_entity,
        f_card_name(COALESCE(c.created_entity_dbf_id, c2.dbf_id)) AS created_entity_creation,
        count(*) AS num_occurances,
        (100.0 * sum(decode(p.final_state, 4, 1, 0)) / count(*))::decimal(5,2) AS win_rate
FROM player p
JOIN block b ON b.game_id = p.game_id AND b.entity_controller = p.player_id
JOIN entity s ON s.game_id = p.game_id AND s.creation_block_id = b.id AND s.creator = b.entity_id
LEFT JOIN (
        SELECT
                b.game_id,
                b.entity_id,
                b.turn,
                e.dbf_id AS created_entity_dbf_id
        FROM block b
        JOIN entity e ON b.game_id = e.game_id AND e.creation_block_id = b.id AND e.creator = b.entity_id
        WHERE b.block_type IN (f_enum_val('BlockType.TRIGGER'), f_enum_val('BlockType.POWER'))
        AND b.game_date BETWEEN '2017-09-01' AND '2017-09-15'
        AND e.game_date BETWEEN '2017-09-01' AND '2017-09-15'
        AND e.cardtype != f_enum_val('CardType.ENCHANTMENT')
) c ON c.game_id = p.game_id AND c.entity_id = s.id AND c.turn = b.turn
LEFT JOIN (
        SELECT
                b.game_id,
                b.entity_id,
                b.turn,
                e.dbf_id
        FROM block b 
        JOIN tag_change tc ON tc.game_id = b.game_id AND tc.block_id = b.id
        JOIN entity e ON e.game_id = tc.game_id AND e.id = tc.entity_id
        WHERE tc."tag" = f_enum_val('GameTag.ZONE')
        AND b.entity_dbf_id = 38312 -- Y'Shaarj
        AND tc.previous_value = f_enum_val('Zone.DECK')
        AND tc.value = f_enum_val('Zone.PLAY')
        AND e.cardtype != f_enum_val('CardType.ENCHANTMENT')
        AND tc.game_date BETWEEN '2017-09-01' AND '2017-09-15'
        AND b.game_date BETWEEN '2017-09-01' AND '2017-09-15'
        AND e.game_date BETWEEN '2017-09-01' AND '2017-09-15'
) c2 ON c2.game_id = p.game_id AND c2.entity_id = s.id AND c2.turn = b.turn
WHERE b.block_type = f_enum_val('BlockType.POWER')
AND f_player_turn(b.turn) = 4
AND b.entity_dbf_id = f_dbf_id('Barnes')
AND b.game_date BETWEEN '2017-09-01' AND '2017-09-15'
AND p.game_date BETWEEN '2017-09-01' AND '2017-09-15'
AND s.game_date BETWEEN '2017-09-01' AND '2017-09-15'
AND s.cardtype != f_enum_val('CardType.ENCHANTMENT')
AND p.player_class = f_enum_val('CardClass.PRIEST')
AND p.game_type = 2
GROUP BY s.dbf_id, COALESCE(c.created_entity_dbf_id, c2.dbf_id)
HAVING count(*) >= 100
ORDER BY 4 DESC;