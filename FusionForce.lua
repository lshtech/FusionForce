--- STEAMODDED HEADER
--- MOD_NAME: Fusion Force
--- MOD_ID: FusionForce
--- PREFIX: fuseforce
--- MOD_AUTHOR: [LunaAstraCassiopeia]
--- MOD_DESCRIPTION: Adds 15 new Fusion Jokers
--- BADGE_COLOR: BD597A
--- VERSION: 1.0.0
--- DEPENDENCIES: [FusionJokers]

----------------------------------------------
------------MOD CODE -------------------------



    SMODS.Atlas({
        key = 'fuseforce_jokers',
        path = 'Jokers.png',
        px = 71,
        py = 95
    })

    SMODS.Joker({
        key = "Clairvoyant", atlas = "fuseforce_jokers", pos = {x = 0, y = 0}, rarity = "fusion", blueprint_compat = true, cost = 8,
        calculate = function(self,card,context)
            if context.after and #G.consumeables.cards + G.GAME.consumeable_buffer < G.consumeables.config.card_limit then
                local sixes = 0
                for i = 1, #context.scoring_hand do
                    if context.scoring_hand[i]:get_id() == 6 then sixes = sixes + 1 end
                end
                if sixes >= 1 and next(context.poker_hands["Straight"]) then
                    local card_type = 'Spectral'
                    G.GAME.consumeable_buffer = G.GAME.consumeable_buffer + 1
                    G.E_MANAGER:add_event(Event({
                        trigger = 'before',
                        delay = 0.0,
                        func = (function()
                                local card = create_card(card_type,G.consumeables, nil, nil, nil, nil, nil, 'clairvoyant')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                            return true
                        end)}))
                    return {
                        message = localize('k_plus_spectral'),
                        colour = G.C.SECONDARY_SET.Spectral,
                        card = card
                    }
                end
            end
        end
    })

    FusionJokers.fusions:add_fusion("j_seance", nil, false, "j_sixth_sense", nil, false, "j_fuseforce_Clairvoyant", 8)

    local add_tagref = add_tag
    function add_tag(_tag)
        for i = 1, #G.GAME.tags do
          G.GAME.tags[i]:apply_to_run({type = 'tag_add', tag = _tag})
        end
        for i = 1, #G.jokers.cards do
            if G.jokers.cards[i].ability.extra.active then
                G.jokers.cards[i]:calculate_joker({ fuseforce_add_tag = true, added_tag = _tag})
                G.jokers.cards[i].ability.extra.active = false
            end
        end
        return add_tagref(_tag)
      end

    SMODS.Joker({
        key = "PowerPop", atlas = "fuseforce_jokers", pos = {x = 1, y = 0}, rarity = "fusion", blueprint_compat = true, cost = 8,
        config = {
            x_mult = 1,
            extra = {
                x_mult_mod = 0.3,
                active = true
            }
        },
        update = function(self, card, dt)
            card.ability.x_mult = 1 + G.GAME.skips*card.ability.extra.x_mult_mod
        end,
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.x_mult, card.ability.extra.x_mult_mod}
            }
        end,
        calculate = function(self,card,context)
            print(card.ability.extra.active)
            if context.joker_main then
                if card.ability.x_mult > 1 then
                    return {
                        message = localize{type='variable',key='a_xmult',vars={card.ability.x_mult}},
                        Xmult_mod = card.ability.x_mult
                    }
                end
            elseif context.skip_blind then
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        card_eval_status_text(card, 'extra', nil, nil, nil, {
                            message = localize{type = 'variable', key = 'a_xmult', vars = {card.ability.x_mult}},
                                colour = G.C.RED,
                            card = card
                        }) 
                        card.ability.extra.active = true
                        return true
                    end}))
            elseif context.fuseforce_add_tag then
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        if context.added_tag.ability and context.added_tag.ability.orbital_hand then
                            G.orbital_hand = context.added_tag.ability.orbital_hand
                        end
                        add_tag(Tag(context.added_tag.key))
                        G.orbital_hand = nil
                        play_sound('generic1', 0.9 + math.random()*0.1, 0.8)
                        play_sound('holo1', 1.2 + math.random()*0.1, 0.4)
                        return true
                    end)
                }))
            end
        end
    })

    FusionJokers.fusions:add_fusion("j_diet_cola", nil, false, "j_throwback", nil, false, "j_fuseforce_PowerPop", 8)

    
----------------------------------------------
------------MOD CODE END----------------------
