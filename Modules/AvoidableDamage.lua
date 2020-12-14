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
            local message = format("%s;%d;%d", level, myServerID, myPlayerUID)
            C_ChatInfo_SendAddonMessage(self.prefix, message, "PARTY")
        end
    end
end

function AD:ReceiveLevel(message)
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
            playerUID = playerUID
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
    SPELL_DAMAGE = 1,
    MELEE = 2
}
-- Data
local MistakeData = {
    ["The Necrotic Wake"] = {
        -- [3] 縫補師縫肉
        {
            -- 肉鉤
            Type = MISTAKE.SPELL_DAMAGE,
            SpellID = 327952
        },
        {
            -- 防腐黏液 (腳下污水)
            Type = MISTAKE.SPELL_DAMAGE,
            SpellID = 320366
        },
        {
            -- 病態凝視
            Type = MISTAKE.MELEE,
            NPCID = 162689,
            PlayerNeedDebuff = 343556
        },
        -- [4] 『霜縛者』納爾索
        {
            -- 彗星風暴
            Type = MISTAKE.SPELL_DAMAGE,
            SpellID = 320784
        },
        {
            -- 鋒利碎冰 (大冰圈)
            Type = MISTAKE.SPELL_DAMAGE,
            SpellID = 328212
        }
    }
}

--------------------------------------------
-- Compile triggers
--------------------------------------------
local MapID = {
    [1666] = "The Necrotic Wake",
    [1667] = "The Necrotic Wake",
    [1668] = "The Necrotic Wake"
}

local function GetIDByGUID(guid)
    return tonumber(strmatch(guid or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

local warningMessage
local stacksMessage
local spellMessage

local allUsers = {}
local timers = {}
local timerData = {}
local combinedFails = {}

local activeUser
local playerName = GetUnitName("player", true) .. "-" .. gsub(GetRealmName(), " ", "")

--------------------------------------------
-- Message Functions
--------------------------------------------
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
local function SortTable(t)
    sort(
        t,
        function(a, b)
            return a.value > b.value
        end
    )
end

function AD:SpellDamage(dstName, spellID, damageAmount, sourceGUID)
    if not UnitIsPlayer(dstName) then
        return
    end

    local isTank = UnitGroupRolesAssigned(dstName) == "TANK"

    if spellID then
        if not Spells[spellID] or (isTank and Spells[spellID] == MISTAKE.NOT_TANK) then
            return
        end
    else
        local npcID = sourceGUID and self:GetIDByGUID(sourceGUID)
        if npcID then
            if not Swing[spellID] or (isTank and Swing[spellID] == MISTAKE.NOT_TANK) then
                return
            end
            spellID = 6603 -- Set same id for melee attack
        else
            return
        end
    end
    -- Initialize TimerData and CombinedFails for Timer shot
    if timerData[dstName] == nil then
        timerData[dstName] = {}
    end

    if combinedFails[dstName] == nil then
        combinedFails[dstName] = 0
    end

    -- Add this event to TimerData / CombinedFails
    combinedFails[dstName] = combinedFails[dstName] + damageAmount
    if timerData[dstName][spellID] == nil then
        timerData[dstName][spellID] = damageAmount
    else
        timerData[dstName][spellID] = timerData[dstName][spellID] + damageAmount
    end

    -- If there is no timer yet, start one with this event
    if timers[dstName] == nil then
        timers[dstName] = true
        C_Timer_After(
            4,
            function()
                self:SpellDamageAnnouncer(dstName)
            end
        )
    end
end

function AD:SpellDamageAnnouncer(player)
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

function AD:AuraApply(dstName, spellID, auraAmount)
    if not UnitIsPlayer(dstName) or not self.db.notification.enable then
        return
    end

    local isTank = UnitGroupRolesAssigned(dstName) == "TANK"

    if Auras[spellID] or (Auras[spellID] == MISTAKE.NOT_TANK and not isTank) then
        if auraAmount then
            self:SendChatMessage(self:GenerateOutput(stacksMessage, dstName, GetSpellLink(spellID), auraAmount))
        else
            self:SendChatMessage(self:GenerateOutput(warningMessage, dstName, GetSpellLink(spellID)))
        end
    end
end

function AD:ResetStatistic()
    wipe(combinedFails)
    wipe(timerData)
    wipe(timers)
end

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
end

function AD:CHALLENGE_MODE_START()
    self:SendChatMessage(L["[WDH] Avoidable damage notification enabled, glhf!"])
    self:ResetStatistic()
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

function AD:COMBAT_LOG_EVENT_UNFILTERED()
    local _, type, _, sourceGUID, _, _, _, _, destName, _, _, spellId, _, _, info15, info16, info17 =
        CombatLogGetCurrentEventInfo()
    local eventPrefix, eventSuffix = strmatch(type, "^(.-)_?([^_]*)$")

    if (eventPrefix:match("^SPELL") or eventPrefix:match("^RANGE")) and eventSuffix == "DAMAGE" then
        self:SpellDamage(destName, spellId, info15)
    elseif eventPrefix == "SWING" and eventSuffix == "DAMAGE" then
        self:SpellDamage(destName, nil, spellId, sourceGUID)
    elseif eventPrefix:match("^SPELL") and eventSuffix == "MISSED" then
        if info17 then
            self:SpellDamage(destName, spellId, info17)
        end
    elseif type == "SPELL_AURA_APPLIED" then
        self:AuraApply(destName, spellId)
    elseif type == "SPELL_AURA_APPLIED_DOSE" then
        self:AuraApply(destName, spellId, info16)
    end
end

function AD:OnInitialize()
    self:ProfileUpdate()
    self:SetNotificationText()
end

function AD:ProfileUpdate()
    self.db = W.db.avoidableDamage

    if self.db.enable then
        self:ResetAuthority()
        self:RegisterEvent("CHAT_MSG_ADDON")
        self:RegisterEvent("GROUP_ROSTER_UPDATE", "ResetAuthority")
        self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ResetAuthority")
        self:RegisterEvent("CHALLENGE_MODE_START")
        self:RegisterEvent("CHALLENGE_MODE_COMPLETED")
        self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
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

function AD:GetActiveUser()
    return activeUser
end
