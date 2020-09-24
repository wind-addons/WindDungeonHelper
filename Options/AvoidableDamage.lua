local W, F, L, _, O = unpack(select(2, ...))

O.avoidableDamage = {
    order = 3,
    name = L["Avoidable Damage"],
    type = "group",
    args = {
        enable = {
            order = 1,
            name = L["Enable"],
            desc = L["Enables / disables the module"],
            type = "toggle",
            width = "full",
            set = function(info, value)
                AD.db.enable = value
                AD:ToggleModule()
                C_Timer.After(1, function() return AD:RefreshOption() end)
            end,
            get = function(info) return AD.db.enable end
        },
        activeUser = {
            order = 2,
            type = "description",
            width = "full",
            hidden = function(info) return not AD.db.enable end,
            name = function()
                return AD.activeUser and B.ColorString(L["Active announcer"], 0, 1, 0.59) .. ": " ..
                           AD.activeUser
            end
        }, 
        notification = {
            order = 2,
            name = L["Notifications"],
            type = "group",
            inline = true,
            hidden = function() return not AD.db.enable end,
            args = {
                enable = {
                    order = 11,
                    name = L["Damage notifications"],
                    desc = L["Enables / disables damage notifications"],
                    type = "toggle",
                    set = function(info, value) AD.db.notification.enable = value end,
                    get = function(info) return AD.db.notification.enable end
                },
                threshold = {
                    order = 12,
                    name = L["Damage threshold"],
                    desc = L["If the sum of damage over threshold, WDH will notify you."],
                    type = "range",
                    disabled = function(info) return not AD.db.notification.enable end,
                    min = 1,
                    max = 100,
                    step = 1,
                    set = function(info, value)
                        AD.db.notification.threshold = value;
                        AD.hardMinPct = AD.db.notification.threshold
                    end,
                    get = function(info) return AD.db.notification.threshold end
                },
                outputmode = {
                    order = 13,
                    name = L["Messeage Output"],
                    desc = L["Define output channel"],
                    disabled = function(info) return not AD.db.notification.enable end,
                    type = "select",
                    set = function(info, value) AD.db.notification.outputmode = value end,
                    get = function(info) return AD.db.notification.outputmode end,
                    values = {
                        ["self"] = L["Self(Chat Frame)"],
                        ["party"] = L["Party"],
                        ["emote"] = L["Emote"],
                        ["none"] = L["None"]
                    }
                },
                unit = {
                    order = 14,
                    name = L["Numeral System"],
                    disabled = function(info) return not AD.db.notification.enable end,
                    type = "select",
                    set = function(info, value) AD.db.notification.unit = value end,
                    get = function(info) return AD.db.notification.unit end,
                    values = {["western"] = L["Western - k"], ["asia"] = L["Asia - W"]}
                },
                accuracy = {
                    order = 15,
                    name = L["Damage accuracy"],
                    type = "range",
                    disabled = function(info) return not AD.db.notification.enable end,
                    min = 0,
                    max = 5,
                    step = 1,
                    set = function(info, value) AD.db.notification.accuracy = value end,
                    get = function(info) return AD.db.notification.accuracy end
                },
                compatible = {
                    order = 16,
                    name = L["Be compatible with ElitismHelper"],
                    desc = L["Use 'ElitismHelper' as addon message prefix."],
                    disabled = function(info) return not AD.db.notification.enable end,
                    type = "toggle",
                    width = "full",
                    get = function(info) return AD.db.notification.compatible end,
                    set = function(info, value)
                        AD.db.notification.compatible = value
                        AD:UnregisterEvent("CHAT_MSG_ADDON")
                        AD:SetAddonMessagePrefix()
                        AD.activeUser = nil
                        AD.allUsers = {}
                        if AD.db.enable then
                            AD:RegisterEvent("CHAT_MSG_ADDON")
                            if IsInGroup() then
                                AD:SendAddonMessage("VREQ")
                            else
                                AD.activeUser = AD.playerUser
                            end
                            C_Timer.After(2, function() return AD:RefreshOption() end)
                        end
                    end
                }
            }
        },
        rank = {
            order = 3,
            name = L["Ranking"],
            type = "group",
            inline = true,
            hidden = function() return not AD.db.enable end,
            args = {
                enable = {
                    order = 16,
                    name = L["Enable"],
                    desc = L["Enables / disables ranking after dungeon completed."],
                    type = "toggle",
                    set = function(info, value) AD.db.rank.enable = value end,
                    get = function(info) return AD.db.rank.enable end
                },
                worst = {
                    order = 17,
                    name = L["The worst player"],
                    desc = L["Enables / disables show the worst player in ranking."],
                    type = "toggle",
                    set = function(info, value) AD.db.rank.worst = value end,
                    get = function(info) return AD.db.rank.worst end
                },
                worst_custom = {
                    order = 18,
                    type = "input",
                    hidden = function(info) return not AD.db.rank.worst end,
                    name = L["The worst player text"],
                    get = function(info) return AD.db.rank.custom_worst end,
                    set = function(info, value) AD.db.rank.custom_worst = value end
                },
                worst_custom_default = {
                    order = 19,
                    name = L["Defaults"],
                    hidden = function(info) return not AD.db.rank.worst end,
                    type = "execute",
                    func = function()
                        AD.db.rank.custom_worst = DB.defaults.profile.modules.AvoidableDamage.rank.custom_worst
                    end
                },
                worst_example = {
                    order = 20,
                    type = "description",
                    hidden = function(info) return not AD.db.rank.worst end,
                    name = function()
                        return B.ColorString(L["Example"]) .. ": " .. AD.db.rank.custom_worst .. ": " .. AD.playerUser
                    end
                }
            }
        },
        customization = {
            order = 4,
            name = L["Customization"],
            type = "group",
            inline = true,
            hidden = function() return not AD.db.enable end,
            disabled = function() return not AD.db.custom.enable end,
            args = {
                enable = {
                    order = 41,
                    name = L["Enable"],
                    type = "toggle",
                    disabled = false,
                    set = function(info, value)
                        AD.db.custom.enable = value;
                        AD:SetNotificationText()
                    end,
                    get = function(info) return AD.db.custom.enable end
                },
                default = {
                    order = 42,
                    name = L["Defaults"],
                    type = "execute",
                    func = function()
                        AD.db.custom.warningMsg = DB.defaults.profile.modules.AvoidableDamage.custom.warningMsg
                        AD.db.custom.stacksMsg = DB.defaults.profile.modules.AvoidableDamage.custom.stacksMsg
                        AD.db.custom.spellMsg = DB.defaults.profile.modules.AvoidableDamage.custom.spellMsg
                    end
                },
                warning = {
                    order = 43,
                    type = "input",
                    width = "full",
                    name = L["Warning message text"],
                    desc = function() return AD.Tips end,
                    get = function(info) return AD.db.custom.warningMsg end,
                    set = function(info, value)
                        AD.db.custom.warningMsg = value;
                        AD:SetNotificationText()
                    end
                },
                warningex = {
                    order = 44,
                    type = "description",
                    name = function()
                        return B.ColorString(L["Example"]) .. ": " ..
                                   AD:GenerateOutput(AD.db.custom.warningMsg, AD.playerUser, GetSpellLink(257274))
                    end
                },
                stack = {
                    order = 45,
                    type = "input",
                    name = L["Stack message text"],
                    desc = function() return AD.Tips end,
                    width = 'full',
                    get = function(info) return AD.db.custom.stacksMsg end,
                    set = function(info, value)
                        AD.db.custom.stacksMsg = value;
                        AD:SetNotificationText()
                    end
                },
                stackgex = {
                    order = 46,
                    type = "description",
                    name = function()
                        return B.ColorString(L["Example"]) .. ": " ..
                                   AD:GenerateOutput(AD.db.custom.stacksMsg, AD.playerUser, GetSpellLink(257274), 3)
                    end
                },
                spell = {
                    order = 47,
                    type = "input",
                    name = L["Spell message text"],
                    desc = function() return AD.Tips end,
                    width = 'full',
                    get = function(info) return AD.db.custom.spellMsg end,
                    set = function(info, value)
                        AD.db.custom.spellMsg = value;
                        AD:SetNotificationText()
                    end
                },
                spellex = {
                    order = 48,
                    type = "description",
                    name = function()
                        return B.ColorString(L["Example"]) .. ": " ..
                                   AD:GenerateOutput(AD.db.custom.spellMsg, AD.playerUser, GetSpellLink(257274), nil,
                                                     AD:GenerateNumber(25000), "18%%")
                    end
                }
            }
        }
    }
}
