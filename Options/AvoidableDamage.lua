local W, F, L, P, O = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")
local name = UnitName("player")

local GetSpellLink = GetSpellLink

local tipsText =
    format(
    "%s\n%s\n%s\n%s\n%s",
    format("%s = %s", F.CreateColorString("%name%"), L["Player Name"]),
    format("%s = %s", F.CreateColorString("%spell%"), L["Spell Link"]),
    format("%s = %s", F.CreateColorString("%stack%"), L["Aura Stacks"]),
    format("%s = %s", F.CreateColorString("%damage%"), L["Damage"]),
    format("%s = %s", F.CreateColorString("%percent%"), L["Percent"])
)

O.avoidableDamage = {
    order = 3,
    name = L["Avoidable Damage"],
    type = "group",
    get = function(info)
        return W.db.avoidableDamage[info[#info]]
    end,
    set = function(info, value)
        W.db.avoidableDamage[info[#info]] = value
    end,
    args = {
        enable = {
            order = 1,
            name = L["Enable"],
            desc = L["Enables / disables the module"],
            type = "toggle",
            disabled = false,
            set = function(info, value)
                W.db.avoidableDamage[info[#info]] = value
                AD:ProfileUpdate()
                W:RefreshOptionsAfter(1)
            end
        },
        activeUser = {
            order = 2,
            name = L["Authority"],
            type = "group",
            inline = true,
            get = function(info)
                return W.db.avoidableDamage[info[#info]]
            end,
            set = function(info, value)
                W.db.avoidableDamage[info[#info]] = value
            end,
            args = {
                compatible = {
                    order = 1,
                    type = "toggle",
                    name = L["Compatible Mode"],
                    desc = L["Be compatible with ElitismHelper"],
                    set = function(info, value)
                        W.db.avoidableDamage[info[#info]] = value
                        AD:SetAddonMessagePrefix()
                        if W.db.avoidableDamage.enable then
                            AD:ResetAuthority()
                            W:RefreshOptionsAfter(2)
                        end
                    end,
                    width = 1.2
                },
                activeUser = {
                    order = 2,
                    type = "description",
                    name = function()
                        local text = F.CreateColorString(L["Active User"])
                        local activeUser = AD:GetActiveUser()
                        return text .. ": " .. activeUser
                    end,
                    width = 1.8
                }
            }
        },
        notification = {
            order = 3,
            name = L["Notifications"],
            type = "group",
            inline = true,
            get = function(info)
                return W.db[info[#info - 2]][info[#info - 1]][info[#info]]
            end,
            set = function(info, value)
                W.db[info[#info - 2]][info[#info - 1]][info[#info]] = value
            end,
            args = {
                enable = {
                    order = 1,
                    type = "toggle",
                    name = L["Enable"],
                    hidden = false
                },
                channel = {
                    order = 2,
                    name = L["Channel"],
                    type = "select",
                    values = {
                        SELF = L["Self(Chat Frame)"],
                        PARTY = L["Party"],
                        EMOTE = L["Emote"],
                        NONE = L["None"]
                    }
                },
                divider = {
                    order = 3,
                    type = "description",
                    name = "",
                    width = "full"
                },
                unit = {
                    order = 4,
                    name = L["Numeral System"],
                    type = "select",
                    values = {
                        WESTERN = L["Western - k"],
                        ASIA = L["Asia - W"],
                        NONE = L["None"]
                    }
                },
                accuracy = {
                    order = 5,
                    name = L["Accuracy"],
                    type = "range",
                    min = 0,
                    max = 5,
                    step = 1
                },
                threshold = {
                    order = 6,
                    name = L["Threshold"],
                    desc = format(
                        L["If the sum of damage over threshold, %s will notify you."],
                        L["Wind Dungeon Helper"]
                    ),
                    type = "range",
                    min = 1,
                    max = 100,
                    step = 1,
                    set = function(info, value)
                        AD.db.notification.threshold = value
                        AD.hardMinPct = AD.db.notification.threshold
                    end,
                    get = function(info)
                        return AD.db.notification.threshold
                    end
                }
            }
        },
        rank = {
            order = 4,
            name = L["Ranking"],
            type = "group",
            inline = true,
            get = function(info)
                return W.db[info[#info - 2]][info[#info - 1]][info[#info]]
            end,
            set = function(info, value)
                W.db[info[#info - 2]][info[#info - 1]][info[#info]] = value
            end,
            args = {
                enable = {
                    order = 1,
                    name = L["Enable"],
                    desc = L["Send the ranking after the dungeon completed."],
                    type = "toggle"
                },
                worst = {
                    order = 2,
                    name = L["The worst player"],
                    desc = L["Notice the worst player in ranking."],
                    type = "toggle",
                    hidden = function()
                        return not W.db.avoidableDamage.rank.enable
                    end
                },
                customWorstDefault = {
                    order = 3,
                    name = L["Defaults"],
                    type = "execute",
                    func = function()
                        W.db.avoidableDamage.rank.customWorst = P.avoidableDamage.rank.customWorst
                    end,
                    hidden = function()
                        return not W.db.avoidableDamage.rank.worst
                    end
                },
                customWorst = {
                    order = 4,
                    type = "input",
                    name = L["The worst player text"],
                    width = "full",
                    hidden = function()
                        return not W.db.avoidableDamage.rank.worst
                    end
                },
                customWorstExample = {
                    order = 5,
                    type = "description",
                    name = function()
                        local text = F.CreateColorString(L["Example"])
                        text = text .. ": " .. W.db.avoidableDamage.rank.customWorst .. ": " .. name
                        return text
                    end,
                    hidden = function()
                        return not W.db.avoidableDamage.rank.worst
                    end
                }
            }
        },
        custom = {
            order = 5,
            name = L["Customization"],
            type = "group",
            inline = true,
            get = function(info)
                return W.db[info[#info - 2]][info[#info - 1]][info[#info]]
            end,
            set = function(info, value)
                W.db[info[#info - 2]][info[#info - 1]][info[#info]] = value
                AD:SetNotificationText()
            end,
            args = {
                enable = {
                    order = 1,
                    name = L["Enable"],
                    type = "toggle"
                },
                default = {
                    order = 2,
                    name = L["Defaults"],
                    type = "execute",
                    func = function()
                        W.db.avoidableDamage.custom.warningMessage = P.avoidableDamage.custom.warningMessage
                        W.db.avoidableDamage.custom.stacksMessage = P.avoidableDamage.custom.stacksMessage
                        W.db.avoidableDamage.custom.spellMessage = P.avoidableDamage.custom.spellMessage
                    end,
                    hidden = function()
                        return not W.db.avoidableDamage.custom.enable
                    end
                },
                warningMessage = {
                    order = 3,
                    type = "input",
                    width = "full",
                    name = L["Warning message"],
                    desc = tipsText,
                    hidden = function()
                        return not W.db.avoidableDamage.custom.enable
                    end
                },
                warningMessageExample = {
                    order = 4,
                    type = "description",
                    name = function()
                        local text = F.CreateColorString(L["Example"]) .. ": "
                        text =
                            text ..
                            AD:GenerateOutput(W.db.avoidableDamage.custom.warningMessage, name, GetSpellLink(257274))
                        return text
                    end,
                    hidden = function()
                        return not W.db.avoidableDamage.custom.enable
                    end
                },
                stacksMessage = {
                    order = 5,
                    type = "input",
                    width = "full",
                    name = L["Stack message"],
                    desc = tipsText,
                    hidden = function()
                        return not W.db.avoidableDamage.custom.enable
                    end
                },
                stacksMessageExample = {
                    order = 6,
                    type = "description",
                    name = function()
                        local text = F.CreateColorString(L["Example"]) .. ": "
                        text =
                            text ..
                            AD:GenerateOutput(W.db.avoidableDamage.custom.stacksMessage, name, GetSpellLink(257274), 3)
                        return text
                    end,
                    hidden = function()
                        return not W.db.avoidableDamage.custom.enable
                    end
                },
                spellMessage = {
                    order = 7,
                    type = "input",
                    width = "full",
                    name = L["Spell message"],
                    desc = tipsText,
                    hidden = function()
                        return not W.db.avoidableDamage.custom.enable
                    end
                },
                spellMessageExample = {
                    order = 8,
                    type = "description",
                    name = function()
                        local text = F.CreateColorString(L["Example"]) .. ": "
                        text =
                            text ..
                            AD:GenerateOutput(
                                W.db.avoidableDamage.custom.spellMessage,
                                name,
                                GetSpellLink(257274),
                                nil,
                                AD:GenerateNumber(12345),
                                87
                            )
                        return text
                    end,
                    hidden = function()
                        return not W.db.avoidableDamage.custom.enable
                    end
                }
            }
        }
    }
}
