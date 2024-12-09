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

    SMODS.Joker({
        key = "ReachTheStars", atlas = "fuseforce_jokers", pos = {x = 2, y = 0}, rarity = "fusion", blueprint_compat = true, cost = 8,
        calculate = function(self,card,context)
            if context.cardrea == G.hand then
                if context.other_card.debuff then
                    return {
                        message = localize('k_debuffed'),
                        colour = G.C.RED,
                        card = card,
                    }
                elseif context.other_card.ability.effect ~= 'Stone Card' then
                    return {
                        h_mult = context.other_card.base.nominal,
                        card = card
                    }
                end
            end
        end
    })

    FusionJokers.fusions:add_fusion("j_shoot_the_moon", nil, false, "j_raised_fist", nil, false, "j_fuseforce_ReachTheStars", 8)
    
    SMODS.Joker({
        key = "RewardsCard", atlas = "fuseforce_jokers", pos = {x = 3, y = 0}, rarity = "fusion", blueprint_compat = true, cost = 8,
        config = {
            extra = {
                valup = 1,
                debt = 0,
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.valup, card.ability.extra.debt}
            }
        end,
        update = function(self, card, dt)
            if G.STAGE == G.STAGES.RUN then
            local sell_cost = 0
            for i = 1, #G.jokers.cards do
                if G.jokers.cards[i].area and G.jokers.cards[i].area == G.jokers then
                    sell_cost = sell_cost + G.jokers.cards[i].sell_cost
                end
            end
            card.ability.extra.debt = math.floor((sell_cost)/5)
        end
        end,
        calculate = function(self,card,context)
            if context.end_of_round then
                for k, v in ipairs(G.jokers.cards) do
                    if v.set_cost then 
                        v.ability.extra_value = (v.ability.extra_value or 0) + card.ability.extra.valup
                        v:set_cost()
                    end
                end
                for k, v in ipairs(G.consumeables.cards) do
                    if v.set_cost then 
                        v.ability.extra_value = (v.ability.extra_value or 0) + card.ability.extra.valup
                        v:set_cost()
                    end
                end
                return {
                    message = localize('k_val_up'),
                    colour = G.C.MONEY
                }
            end
        end,
        add_to_deck = function(self, card, from_debuff)
            G.GAME.bankrupt_at = G.GAME.bankrupt_at - card.ability.extra.debt
        end,
        remove_from_deck = function(self, card, from_debuff)
            G.GAME.bankrupt_at = G.GAME.bankrupt_at + card.ability.extra.debt
        end
    })

    FusionJokers.fusions:add_fusion("j_gift_card", nil, false, "j_credit_card", nil, false, "j_fuseforce_RewardsCard", 8)

    SMODS.Joker({
        key = "MasterDegree", atlas = "fuseforce_jokers", pos = {x = 4, y = 0}, rarity = "fusion", blueprint_compat = true, cost = 8,
        config = {
            extra = {
                chips = 25,
                mult = 5
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.chips, card.ability.extra.mult}
            }
        end,
        calculate = function(self,card,context)
            if context.first_hand_drawn then
                G.E_MANAGER:add_event(Event({
                    func = function() 
                        local _suit = pseudorandom_element({'S','H','D','C'}, pseudoseed('degree_create'))
                        local cen_pool = {}
                        for k, v in pairs(G.P_CENTER_POOLS["Enhanced"]) do
                            if v.key ~= 'm_stone' then 
                                cen_pool[#cen_pool+1] = v
                            end
                        end
                        local _card = create_playing_card({
                            front = G.P_CARDS[_suit..'_'.._rank], 
                            center =  pseudorandom_element(cen_pool, pseudoseed('spe_card'))}, G.hand, nil, nil, {G.C.SECONDARY_SET.Enhanced})
                        G.GAME.blind:debuff_card(_card)
                        G.hand:sort()
                        if context.blueprint_card then context.blueprint_card:juice_up() else card:juice_up() end
                        return true
                    end}))
                playing_card_joker_effects({true})
                elseif context.individual and context.cardarea == G.play then
                    if context.other_card:get_id() == 14 then
                        return {
                            chips = card.ability.extra.chips,
                            mult = card.ability.extra.mult,
                            card = card
                        }
                    end
                end
        end,
    })

    FusionJokers.fusions:add_fusion("j_certificate", nil, false, "j_scholar", nil, false, "j_fuseforce_MasterDegree", 8)

    local Cardset_price = Card.set_cost
    function Card:set_cost()
        Cardset_price(self)
        if (
            (self.ability.set == 'Planet' or self.ability.set == 'Tarot') or 
            (self.ability.set == 'Booster' and (self.ability.name:find('Celestial') or self.ability.name:find('Arcana')))) 
            and #find_joker('j_fuseforce_Soothsayer') > 0 then self.cost = 0 end
    end

    SMODS.Joker({
        key = "Soothsayer", atlas = "fuseforce_jokers", pos = {x = 0, y = 1}, rarity = "fusion", blueprint_compat = true, cost = 8,
        config = {
            extra = {}
        },
        calculate = function(self, card, context)
            if context.setting_blind and not (context.blueprint or card).getting_sliced then
                G.E_MANAGER:add_event(Event({
                    func = (function()
                        G.E_MANAGER:add_event(Event({
                            func = function() 
                                local card = create_card('Tarot',G.consumeables, nil, nil, nil, nil, nil, 'soothsayer')
                                card:add_to_deck()
                                G.consumeables:emplace(card)
                                G.GAME.consumeable_buffer = 0
                                return true
                            end}))   
                            card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_tarot'), colour = G.C.PURPLE})                       
                        return true
                    end)}))
                    G.E_MANAGER:add_event(Event({
                        func = (function()
                            G.E_MANAGER:add_event(Event({
                                func = function() 
                                    local card = create_card('Planet',G.consumeables, nil, nil, nil, nil, nil, 'soothsayer')
                                    card:add_to_deck()
                                    G.consumeables:emplace(card)
                                    G.GAME.consumeable_buffer = 0
                                    return true
                                end}))   
                                card_eval_status_text(context.blueprint_card or card, 'extra', nil, nil, nil, {message = localize('k_plus_planet'), colour = G.C.SECONDARY_SET.Planet})                       
                            return true
                        end)}))
            end
        end
    })

    FusionJokers.fusions:add_fusion("j_astronomer", nil, false, "j_cartomancer", nil, false, "j_fuseforce_Soothsayer", 8)


    local refisface = Card.is_face
    function Card:is_face(from_boss)
        if self.debuff and not from_boss then return end
        if next(find_joker('j_fuseforce_Prosopagnosia')) then
            return true
        end
        return refisface(self, from_boss)
    end

    SMODS.Joker({
        key = "Prosopagnosia", atlas = "fuseforce_jokers", pos = {x = 1, y = 1}, rarity = "fusion", blueprint_compat = true, cost = 8,
        config = {
            extra = {
                dollars = 1
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.dollars}
            }
        end,
        calculate = function(self, card, context)
            if context.discard then
                if context.other_card:is_face() then
                    ease_dollars(card.ability.extra.dollars)
                    return {
                        message = localize('$')..card.ability.extra.dollars,
                        colour = G.C.MONEY,
                        card = card
                    }
                end
            end
        end
    })

    FusionJokers.fusions:add_fusion("j_pareidolia", nil, false, "j_faceless_joker", nil, false, "j_fuseforce_Prosopagnosia", 8)

    SMODS.Joker({
        key = "EnergyDrink", atlas = "fuseforce_jokers", pos = {x = 1, y = 1}, rarity = "fusion", blueprint_compat = true, cost = 8,
        config = {
            extra = {
                chips = 0,
                chip_mod = 3,
                chips_mod = 30,
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.chips, card.ability.extra.chip_mod, card.ability.extra.chips_mod}
            }
        end,
        calculate = function(self, card, context)
            if context.cardarea == G.jokers then
                if context.before and not context.blueprint and next(context.poker_hands['Straight']) then
                    card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chips_mod
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.CHIPS,
                        card = card
                    }
                elseif context.after and not context.blueprint then
                    if card.ability.extra.chips - card.ability.extra.chip_mod <= 0 then 
                        G.E_MANAGER:add_event(Event({
                            func = function()
                                play_sound('tarot1')
                                card.T.r = -0.2
                                card:juice_up(0.3, 0.4)
                                card.states.drag.is = true
                                card.children.center.pinch.x = true
                                G.E_MANAGER:add_event(Event({trigger = 'after', delay = 0.3, blockable = false,
                                    func = function()
                                            G.jokers:remove_card(card)
                                            card:remove()
                                            card = nil
                                        return true; end}))
                                return true
                            end
                        })) 
                        return {
                            message = localize('k_drunk_ex'),
                            colour = G.C.CHIPS
                        }
                    else
                        card.ability.extra.chips = card.ability.extra.chips - card.ability.extra.chip_mod
                        return {
                            message = localize{type='variable',key='a_chips_minus',vars={card.ability.extra.chip_mod}},
                            colour = G.C.CHIPS
                        }
                    end
                elseif context.joker_main then
                    return {
                        message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                        chip_mod = card.ability.extra.chips, 
                        colour = G.C.CHIPS
                    }
                end
            end
        end
    })

    FusionJokers.fusions:add_fusion("j_runner", 'chips', true, "j_ice_cream", nil, false, "j_fuseforce_EnergyDrink", 8)

    SMODS.Joker({
        key = "BoxerShorts", atlas = "fuseforce_jokers", pos = {x = 2, y = 1}, rarity = "fusion", blueprint_compat = true, cost = 8,
        config = {
            mult = 0,
            extra = {
                chips = 0,
                chip_mod = 9,
                mult_mod = 4,
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.mult, card.ability.extra.chips ,card.ability.extra.chip_mod,card.ability.extra.mult_mod}
            }
        end,
        calculate = function(self, card, context)
            if context.cardarea == G.jokers then
                if context.before and not context.blueprint and (next(context.poker_hands['Two Pair']) or next(context.poker_hands['Full House'])) and #context.full_hand == 4 then
                    card.ability.extra.chips = card.ability.extra.chips + card.ability.extra.chip_mod
                    card.ability.mult = card.ability.extra.mult_mod + card.ability.mult
                    return {
                        message = localize('k_upgrade_ex'),
                        colour = G.C.PURPLE,
                        card = card
                    }
                elseif context.joker_main then
                    card_eval_status_text(context.blueprint_card or card, 'jokers', nil, nil, nil, {message = localize{type='variable',key='a_mult',vars={card.ability.mult}}, colour = G.C.MULT})
                    return {
                        message = localize{type='variable',key='a_chips',vars={card.ability.extra.chips}},
                        chip_mod = card.ability.extra.chips, 
                        mult_mod = card.ability.mult,
                        colour = G.C.CHIPS
                    }
                end
            end
        end
    })

    FusionJokers.fusions:add_fusion("j_spare_trousers", 'mult', false, "j_square_joker", 'chips', true, "j_fuseforce_BoxerShorts", 8)

    SMODS.Joker({
        key = "OverandOut", atlas = "fuseforce_jokers", pos = {x = 3, y = 1}, rarity = "fusion", blueprint_compat = true, cost = 8,
        config = {
            extra = {
                chips = 10,
                mult = 4,
                Xmult = 1.5
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.extra.chips, card.ability.extra.mult,card.ability.extra.Xmult}
            }
        end,
        calculate = function(self, card, context)
            if context.individual and context.cardarea == G.play and (context.other_card:get_id() == 10 or context.other_card:get_id() == 4) then
                if G.GAME.current_round.hands_left == 0 then
                    return {
                        chips = card.ability.extra.chips,
                        mult = card.ability.extra.mult,
                        x_mult = card.ability.extra.Xmult,
                        card = card
                    }
                else
                    return {
                        chips = card.ability.extra.chips,
                        mult = card.ability.extra.mult,
                        card = card
                    }
                end
            end
        end
    })

    FusionJokers.fusions:add_fusion("j_walkie_talkie", nil, false, "j_acrobat", nil, false, "j_fuseforce_OverandOut", 8)

    
----------------------------------------------
------------MOD CODE END----------------------
