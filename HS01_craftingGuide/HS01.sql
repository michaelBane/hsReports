SELECT 
    f_enum_name('CardClass', p.player_class) AS player_class,
    c.name AS card_name,
    f_enum_name('Rarity', max(c.rarity)) AS rarity,       
    f_enum_name('Zone', es_before.zone) AS before_zone,
    count(b.id) AS times_played, 
    ROUND(CAST(100*SUM(CASE WHEN p.final_state = f_enum_val('PlayState.WON') THEN 1 ELSE 0 END) AS FLOAT) / count(b.id),2) AS win_percentage
FROM block b
JOIN game g ON g.id = b.game_id
JOIN player p ON p.game_id = b.game_id and p.player_id = b.entity_controller
JOIN entity_state es_before ON b.game_id = es_before.game_id AND es_before.before_block_id = b.id AND b.entity_controller = es_before.controller
JOIN entity_state es_after ON b.game_id = es_after.game_id AND es_after.after_block_id = b.id AND b.entity_controller = es_after.controller AND es_after.entity_id = es_before.entity_id
JOIN card c ON es_before.dbf_id = c.dbf_id
WHERE g.game_date = DATE '2016-12-02'
    AND g.game_type = f_enum_val('BnetGameType.BGT_RANKED_STANDARD')
    AND p.rank <= 20
    AND c.rarity IN (f_enum_val('Rarity.LEGENDARY'), f_enum_val('Rarity.EPIC'))
    AND es_before.zone IN (f_enum_val('Zone.HAND'),f_enum_val('Zone.DECK'))
    AND es_after.zone = f_enum_val('Zone.PLAY')
    AND es_before.entity_in_initial_entities = True
GROUP BY p.player_class, c.name, es_before.zone
HAVING count(b.id) >= 100
ORDER BY player_class, win_percentage DESC; 