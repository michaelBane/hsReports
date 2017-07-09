WITH questing_players AS (
        SELECT 
                b.game_id,
                b.entity_controller AS player_id
        FROM block b
        WHERE b.game_date >= '2017-04-06' 
        AND b.block_type = f_enum_val('BlockType.PLAY')
        AND b.entity_dbf_id IN (41222,41494,41499,41868,41099,41368,41427,41168,41856)
), played_cards AS (
        SELECT 
                p.player_class,
                b.entity_dbf_id AS dbf_id,
                p.final_state,
                b.game_id
        FROM block b 
        JOIN questing_players qp ON qp.game_id = b.game_id AND qp.player_id = b.entity_controller
        JOIN player p ON p.game_id = b.game_id AND p.player_id = b.entity_controller
        WHERE b.block_type = f_enum_val('BlockType.PLAY')
        AND b.game_date >= '2017-04-06'
        AND p.game_Date >= '2017-04-06'
        AND p.game_type = 2
        AND b.entity_dbf_id IS NOT NULL
)
SELECT
        f_enum_name('CardClass', pc.player_class) AS player_class,
        f_card_name(pc.dbf_id) AS card_name,
        count(*) AS times_played,
        sum(decode(pc.final_state, 4, 1, 0)) AS times_won,
        count(distinct pc.game_id) AS num_games,
        (100.0 * sum(decode(pc.final_state, 4, 1, 0))/ count(*))::decimal(5,2) AS win_rate
FROM played_cards pc
GROUP BY pc.player_class, pc.dbf_id
ORDER BY pc.player_class, count(*) DESC