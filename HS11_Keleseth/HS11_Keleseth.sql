SELECT 
        a.archetype_id,
        sum(winner) AS wins,
    count(1) AS games,
    (100.0 * sum(winner) / NULLIF(count(1), 0))::decimal(5,2) AS overall_winrate,
        sum(CASE WHEN c.game_id IS NOT NULL THEN a.winner ELSE 0 END) as onCurveKelesethWins,
        sum(CASE WHEN c.game_id IS NOT NULL THEN 1 ELSE 0 END) as onCurveKelesethGames,
        (100.0 * sum(CASE WHEN c.game_id IS NOT NULL THEN a.winner ELSE 0 END) / NULLIF(sum(CASE WHEN c.game_id IS NOT NULL THEN 1 ELSE 0 END), 0))::decimal(5,2) AS onCurve_winrate,
        sum(CASE WHEN c.game_id IS NOT NULL AND c.times_played > 1 THEN a.winner ELSE 0 END) as onCurveKelesethWins_multiplePlays,
        sum(CASE WHEN c.game_id IS NOT NULL AND c.times_played > 1 THEN 1 ELSE 0 END) as onCurveKelesethGames_multiplePlays,
        (100.0 * sum(CASE WHEN c.game_id IS NOT NULL AND c.times_played > 1 THEN a.winner ELSE 0 END) / NULLIF(sum(CASE WHEN c.game_id IS NOT NULL AND c.times_played > 1 THEN 1 ELSE 0 END), 0))::decimal(5,2) AS onCurve_winrate_multiplePlays                
FROM ( -- Games where Keleseth in deck (and Archetype, and winner) 1 row per Standard game (full_deck_known)
        SELECT
                p.game_id,
                p.player_id,
                am.archetype_id,
                decode(p.final_state, 4, 1, 0) as winner
        FROM player p
        JOIN deck_archetype_map am ON am.deck_id = p.proxy_deck_id
        WHERE game_date BETWEEN '2017-10-20' AND '2017-11-20'
                AND game_type = 2
                AND full_deck_known = True
                AND CHARINDEX('45340', p.deck_list) > 0
) a
LEFT JOIN ( -- Games where Keleseth played on curve
        SELECT
                b.game_id,
                b.entity_controller,
                count(*) AS times_played
        FROM block b
        JOIN tag_change tc ON tc.game_id = b.game_id AND tc.block_id = b.id
        WHERE tc."tag" = f_enum_val('GameTag.ZONE')
                AND b.entity_dbf_id = 45340 -- Prince Keleseth
                AND tc.previous_value = f_enum_val('Zone.HAND')
                AND tc.value = f_enum_val('Zone.PLAY')
                AND b.turn IN (1, 2, 3, 4)
                AND tc.game_date BETWEEN '2017-10-20' AND '2017-11-20'
                AND b.game_date BETWEEN '2017-10-20' AND '2017-11-20'
        GROUP BY b.game_id, b.entity_controller