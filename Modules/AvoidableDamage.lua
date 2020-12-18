-- Based on ElitismHelper
local W, F, L, P = unpack(select(2, ...))
local AD = W:NewModule("AvoidableDamage", "AceHook-3.0", "AceEvent-3.0")

local format = format
local gsub = gsub
local pairs = pairs
local math_pow = math.pow
local sort = sort
local tinsert = tinsert
local strmatch = strmatch
local wipe = wipe

local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local GetRealmName = GetRealmName
local GetSpellLink = GetSpellLink
local GetUnitName = GetUnitName
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local SendChatMessage = SendChatMessage
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitHealthMax = UnitHealthMax
local UnitIsGroupLeader = UnitIsGroupLeader
local UnitIsPlayer = UnitIsPlayer

local C_ChatInfo_GetRegisteredAddonMessagePrefixes = C_ChatInfo.GetRegisteredAddonMessagePrefixes
local C_ChatInfo_RegisterAddonMessagePrefix = C_ChatInfo.RegisterAddonMessagePrefix
local C_ChatInfo_SendAddonMessage = C_ChatInfo.SendAddonMessage
local C_Timer_After = C_Timer.After

local LE_PARTY_CATEGORY_HOME = LE_PARTY_CATEGORY_HOME
local LE_PARTY_CATEGORY_INSTANCE = LE_PARTY_CATEGORY_INSTANCE

local wprint = function() return end
--local wprint = print

--------------------------------------------
-- Authority
--------------------------------------------
AD.prefix = "WDH_AD"
local myServerID, myPlayerUID, authorityCache

function AD:InitializeAuthority()
    local successfulRequest = C_ChatInfo_RegisterAddonMessagePrefix(self.prefix)
    assert(successfulRequest, L["The addon message prefix registration is failed."])

    local guidSplitted = {strsplit("-", UnitGUID("player"))}
    myServerID = tonumber(guidSplitted[2], 10)
    myPlayerUID = tonumber(guidSplitted[3], 16)
end

function AD:CheckAuthority(key)
    if IsInGroup() then
        if authorityCache.playerUID ~= myPlayerUID or authorityCache.serverID ~= myServerID then
            return false
        end
    end

    return true
end

do
    local channelLevel = {
        SELF = 0,
        EMOTE = 1,
        PARTY = 2
    }

    function AD:SendMyLevel()
        if IsInGroup(LE_PARTY_CATEGORY_HOME) then
            local level = self.db.notification.channel and channelLevel[self.db.notification.channel] or 0

            -- If reload the ui, the data is cleared
            if self.inRecording then
                level = level + 100
            end

            local message = format("%s;%d;%d", level, myServerID, myPlayerUID)
            C_ChatInfo_SendAddonMessage(self.prefix, message, "PARTY")
        end
    end
end

function AD:ReceiveLevel(message, sender)
    if message == "RESET_AUTHORITY" then
        self:UpdatePartyInfo()
        return
    end

    local level, serverID, playerUID = strmatch(message, "^([0-9]-);([0-9]-);([0-9]+)")
    level = tonumber(level)
    serverID = tonumber(serverID)
    playerUID = tonumber(playerUID)

    if not authorityCache then
        authorityCache = {
            level = level,
            serverID = serverID,
            playerUID = playerUID,
            name = sender
        }
        return
    end

    local needUpdate = false
    if level > authorityCache.level then -- 等级比较
        needUpdate = true
    elseif level == authorityCache.level then
        if serverID > authorityCache.serverID then -- 服务器 ID 比较
            needUpdate = true
        elseif serverID == authorityCache.serverID then
            if playerUID > authorityCache.playerUID then -- 玩家 ID 比较
                needUpdate = true
            end
        end
    end

    if needUpdate then
        authorityCache.level = level
        authorityCache.serverID = serverID
        authorityCache.playerUID = playerUID
        authorityCache.name = sender
    end
end

function AD:CHAT_MSG_ADDON(_, prefix, message, channel, sender)
    if prefix == self.prefix then
        self:ReceiveLevel(message, sender)
    end
end

do
    local waitSend = false
    function AD:UpdatePartyInfo()
        if waitSend or not IsInGroup(LE_PARTY_CATEGORY_HOME) then
            return
        end

        authorityCache = nil
        waitSend = true

        C_Timer_After(
            0.5,
            function()
                if IsInGroup(LE_PARTY_CATEGORY_HOME) then
                    AD:SendMyLevel()
                end
                waitSend = false
            end
        )
    end
end

function AD:GetActiveUser()
    return authorityCache and authorityCache.name or GetUnitName("player")
end

function AD:SendChatMessage(message)
    if not self.db.notification.enable or not IsInGroup(LE_PARTY_CATEGORY_HOME) then
        return
    end

    if authorityCache and authorityCache.playerUID ~= myPlayerUID then
        return
    end

    if self.db.notification.channel == "SELF" then
        print(message)
    elseif self.db.notification.channel == "PARTY" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(message, "PARTY")
    elseif self.db.notification.channel == "EMOTE" and IsInGroup() and not IsInGroup(LE_PARTY_CATEGORY_INSTANCE) then
        SendChatMessage(": " .. message, "EMOTE")
    end
end

--------------------------------------------
-- Database
--------------------------------------------
-- Types
local MISTAKE = {
    SPELL_DAMAGE = 1, -- 法術傷害
    AURA = 2, -- 得到錯誤的效果
    MELEE = 3 -- 近戰傷害
}
-- Data
local MistakeData = {
    ["General"] = {
        {
            -- 火山煙流
            type = MISTAKE.SPELL_DAMAGE,
            spell = 209862
        },
        {
            -- 膿血
            type = MISTAKE.SPELL_DAMAGE,
            spell = 226512
        },
        {
            -- 地震
            type = MISTAKE.SPELL_DAMAGE,
            spell = 240448
        },
        {
            -- 風暴
            type = MISTAKE.SPELL_DAMAGE,
            spell = 343520
        }
    },
    ["The Necrotic Wake"] = {
        -- Debug (死靈進門右轉法術怪)
        -- {
        --     -- 近戰攻擊
        --     type = MISTAKE.MELEE,
        --     npc = 166302
        -- },
        -- {
        --     -- 汲取體液
        --     type = MISTAKE.SPELL_DAMAGE,
        --     spell = 334749
        -- },
        -- [3] 縫補師縫肉
        {
            -- 肉鉤
            type = MISTAKE.SPELL_DAMAGE,
            spell = 327952
        },
        {
            -- 防腐黏液 (腳下污水)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320366
        },
        {
            -- 病態凝視 (追人)
            type = MISTAKE.MELEE,
            npc = 162689,
            playerDebuff = 343556
        },
        -- [4] 『霜縛者』納爾索
        {
            -- 彗星風暴
            type = MISTAKE.SPELL_DAMAGE,
            spell = 320784
        },
        {
            -- 鋒利碎冰 (大冰圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 328212
        }
    },
    ["Theater of Pain"] = {
        -- 小怪
        {
            -- 死亡之風 (會被吹下平台)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 333297
        },
        -- [3] 肉排
        {
            -- 鋸齒劈砍 (被勾上)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 323406
        },
        -- [4] 庫薩洛克
        {
            -- 幻魄寄生 (腳下圈)
            type = MISTAKE.SPELL_DAMAGE,
            spell = 319765,
            noPlayerDebuff = 319626
        },
        -- [5] 『不朽女皇』莫瑞莎
        {
            -- 鬼魅衝鋒
            type = MISTAKE.SPELL_DAMAGE,
            spell = 339751
        },
        {
            -- 戰鬥殘影
            type = MISTAKE.SPELL_DAMAGE,
            spell = 339550
        }
    }
}

--------------------------------------------
-- Triggers
--------------------------------------------
local MapTable = {
    [1663] = "Halls of Atonement",
    [1664] = "Halls of Atonement",
    [1665] = "Halls of Atonement",
    [1666] = "The Necrotic Wake",
    [1667] = "The Necrotic Wake",
    [1668] = "The Necrotic Wake",
    [1669] = "Mists of Tirna Scithe",
    [1674] = "Plaguefall",
    [1675] = "Sanguine Depths",
    [1676] = "Sanguine Depths",
    [1677] = "De Other Side",
    [1678] = "De Other Side",
    [1679] = "De Other Side",
    [1680] = "De Other Side",
    [1683] = "Theater of Pain",
    [1684] = "Theater of Pain",
    [1685] = "Theater of Pain",
    [1686] = "Theater of Pain",
    [1687] = "Theater of Pain",
    [1692] = "Spires of Ascension",
    [1693] = "Spires of Ascension",
    [1694] = "Spires of Ascension",
    [1695] = "Spires of Ascension",
    [1697] = "Plaguefall"
}

local policy = {
    spell = {},
    aura = {},
    melee = {}
}

local function GetIDByGUID(guid)
    return tonumber(strmatch(guid or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

function AD:CompilePolicy()
    for _, mistake in pairs(table) do
        if mistake.type == MISTAKE.SPELL_DAMAGE then
            policy.spell[mistake.spell] = mistake
        elseif mistake.type == MISTAKE.AURA then
            policy.aura[mistake.aura] = mistake
        elseif mistake.type == MISTAKE.MELEE then
            policy.melee[mistake.npc] = mistake
        end
    end
end

function AD:Compile()
    local mapID = C_Map.GetBestMapForUnit("player")
    local mapName = MapTable[mapID]

    policy = {
        spell = {},
        aura = {},
        melee = {}
    }

    if not mapName or not MistakeData[mapName] then
        return
    end

    self:CompilePolicy(MistakeData["General"])
    self:CompilePolicy(MistakeData[mapName])

    wprint(mapName .. " compiled")
end

-- DEBUG
function AD:GetPolicy()
    return policy
end

--------------------------------------------
-- Message Functions
--------------------------------------------
local warningMessage
local stacksMessage
local spellMessage

function AD:FormatNumber(amount)
    if not self.db or not self.db.notification then
        return
    end

    if self.db.notification.unit == "ASIA" then
        if amount > math_pow(10, 4) then
            return F.Round(amount / 10000, self.db.notification.accuracy) .. L["[UNIT] W"]
        else
            return amount
        end
    elseif self.db.notification.unit == "WESTERN" then
        if amount > math_pow(10, 3) then
            return F.Round(amount / 1000, self.db.notification.accuracy) .. L["[UNIT] K"]
        else
            return amount
        end
    end

    return amount
end

function AD:SetNotificationText()
    if self.db.custom.enable then
        warningMessage = self.db.custom.warningMessage
        stacksMessage = self.db.custom.stacksMessage
        spellMessage = self.db.custom.spellMessage
    else
        warningMessage = P.avoidableDamage.custom.warningMessage
        stacksMessage = P.avoidableDamage.custom.stacksMessage
        spellMessage = P.avoidableDamage.custom.spellMessage
    end
end

function AD:GenerateOutput(text, name, spell, stack, damage, percent)
    text = gsub(text, "%%name%%", name)
    text = gsub(text, "%%spell%%", spell)

    if stack then
        text = gsub(text, "%%stack%%", stack)
    end

    if damage then
        text = gsub(text, "%%damage%%", damage)
    end

    if percent then
        percent = F.Round(percent, self.db.notification.accuracy)
        text = gsub(text, "%%percent%%", format("%s%%%%", percent))
    end

    return text
end

--------------------------------------------
-- Statistic Functions
--------------------------------------------
local timers = {}
local timerData = {}
local combinedFails = {}

local function SortTable(t)
    sort(
        t,
        function(a, b)
            return a.value > b.value
        end
    )
end

local function PlayerHasDebuff(player, spellID)
    for i = 1, 40 do
        local debuffID = select(10, UnitDebuff(player, i))
        if debuffID == spellID then
            return true
        end
    end

    return false
end

function AD:COMBAT_LOG_EVENT_UNFILTERED()
    local _, event, _, sourceGUID, _, _, _, _, destName, _, _, param12, _, _, param15, param16, param17 =
        CombatLogGetCurrentEventInfo()

    if not UnitIsPlayer(destName) then
        return
    end

    local eventPrefix, eventSuffix = strmatch(event, "^(.-)_?([^_]*)$")

    if (strmatch(eventPrefix, "^SPELL") or strmatch(eventSuffix, "^RANGE")) and eventSuffix == "DAMAGE" then
        -- SPELL_DAMAGE | RANGE_DAMAGE | SPELL_PERIODIC_DAMAGE | SPELL_BUILDING_DAMAGE
        -- spell: 12th
        -- amount: 15th
        self:GetHit_Spell(destName, param12, param15)
    elseif eventPrefix == "SWING" and eventSuffix == "DAMAGE" then
        -- SWING_DAMAGE
        -- amount: 12th
        self:GetHit_Swing(destName, sourceGUID, param12)
    elseif eventPrefix:match("^SPELL") and eventSuffix == "MISSED" then
        -- SPELL_MISSED | SPELL_PERIODIC_MISSED
        -- spell: 12th
        -- amountMissed: 17th
        if param17 then
            self:GetHit_Spell(destName, param12, param17)
        end
    elseif event == "SPELL_AURA_APPLIED" then
        -- spell: 12th
        -- amount: 16th
        -- TODO
    elseif event == "SPELL_AURA_APPLIED_DOSE" then
    -- spell: 12th
    -- amount: 16th
    -- TODO
    end
end

function AD:GetHit_Spell(player, spellID, amount)
    if not policy.spell[spellID] then
        return
    end

    if policy.spell[spellID].noPlayerDebuff then
        if type(policy.spell[spellID].noPlayerDebuff) == "number" then
            if PlayerHasDebuff(player, policy.spell[spellID].noPlayerDebuff) then
                return
            end
        end
    end

    if timerData[player] == nil then
        timerData[player] = {}
    end

    if combinedFails[player] == nil then
        combinedFails[player] = 0
    end

    combinedFails[player] = combinedFails[player] + amount
    if timerData[player][spellID] == nil then
        timerData[player][spellID] = amount
    else
        timerData[player][spellID] = timerData[player][spellID] + amount
    end

    self:AnnounceAfterSeconds(4, player)
end

function AD:GetHit_Swing(player, sourceGUID, amount)
    local sourceID = GetIDByGUID(sourceGUID)
    if not sourceID or not policy.melee[sourceID] then
        return
    end

    -- If debuff needed
    if policy.melee[sourceID].playerDebuff then
        if type(policy.melee[sourceID].playerDebuff) == "number" then
            if not PlayerHasDebuff(player, policy.melee[sourceID].playerDebuff) then
                return
            end
        end
    end

    if not timerData[player] then
        timerData[player] = {}
    end

    if not combinedFails[player] then
        combinedFails[player] = 0
    end
    combinedFails[player] = combinedFails[player] + amount

    if not timerData[player][6603] then
        timerData[player][6603] = amount
    else
        timerData[player][6603] = timerData[player][6603] + amount
    end

    self:AnnounceAfterSeconds(4, player)
end

function AD:AnnounceAfterSeconds(sec, player)
    if not timers[player] then
        timers[player] = true
        C_Timer_After(
            sec,
            function()
                self:DamageAnnouncer(player)
            end
        )
    end
end

function AD:DamageAnnouncer(player)
    if not timerData[player] then
        return
    end

    local spellLinks = ""
    local totalDamage = 0

    for spellID, damage in pairs(timerData[player]) do
        spellLinks = spellLinks .. GetSpellLink(spellID) .. " "
        totalDamage = totalDamage + damage
    end

    timerData[player] = nil
    timers[player] = nil

    local playerMaxHealth = UnitHealthMax(player)
    local damageText = self:FormatNumber(totalDamage)
    local percentage = totalDamage / playerMaxHealth * 100

    if self.db.notification.enable and percentage >= self.db.notification.threshold then
        self:SendChatMessage(self:GenerateOutput(spellMessage, player, spellLinks, nil, damageText, percentage))
    end
end

function AD:ResetStatistic()
    wipe(combinedFails)
    wipe(timerData)
    wipe(timers)
end

--------------------------------------------
-- Toggling
--------------------------------------------

function AD:CHALLENGE_MODE_COMPLETED()
    self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    if not self.db.rank.enable then
        return
    end

    local count = 0
    for _ in pairs(combinedFails) do
        count = count + 1
    end

    if count == 0 then
        self:SendChatMessage(L["No failure damage was taken this run."])
        return
    end

    self:SendChatMessage(L["Amount of failure damage:"])

    local damageTable = {}
    for name, damage in pairs(combinedFails) do
        tinsert(damageTable, {key = name, value = damage})
    end

    SortTable(damageTable)

    for index, data in pairs(damageTable) do
        self:SendChatMessage(format("%d. %s %s", index, data.key, self:FormatNumber(data["value"])))
    end

    if self.db.rank.worst then
        self:SendChatMessage("-----------------------")
        self:SendChatMessage(format("%s: %s", self.db.rank.customWorst, damageTable[1].key))
    end

    self:ResetStatistic()
    self.inRecording = nil
end

function AD:CHALLENGE_MODE_START()
    self:SendChatMessage(L["[WDH] Avoidable damage notification enabled, glhf!"])
    self:Compile()
    self:ResetStatistic()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    self.inRecording = true
end

function AD:OnInitialize()
    self:InitializeAuthority()
    self:ProfileUpdate()
    self:SetNotificationText()
end

function AD:ProfileUpdate()
    self.db = W.db.avoidableDamage

    if self.db.enable then
        self:Compile()
        self:UpdatePartyInfo()
        self:RegisterEvent("CHAT_MSG_ADDON")
        self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdatePartyInfo")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Compile")
        self:RegisterEvent("CHALLENGE_MODE_START")
        self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        if IsInInstance() then
            self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        end
    else
        self:UnregisterEvent("CHAT_MSG_ADDON")
        self:UnregisterEvent("GROUP_ROSTER_UPDATE")
        self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
        self:UnregisterEvent("CHALLENGE_MODE_START")
        self:UnregisterEvent("CHALLENGE_MODE_COMPLETED")
        self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        self:ResetStatistic()
    end
end
