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
                        h_mult = 2*context.other_card.base.nominal,
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
                debt = 50,
                earnings = 0,
            }
        },
        loc_vars = function(self,info_queue,card)
            return {
                vars = {card.ability.valup, card.ability.extra.debt, card.ability.extra.earnings}
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
            card.ability.extra.earnings = math.floor((sell_cost)/5)
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
        calc_dollar_bonus = function(self, card)
            return card.ability.extra.earnings
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

    
----------------------------------------------
------------MOD CODE END----------------------
