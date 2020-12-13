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

local Spells = {
    -- Necrotic Wake | 死靈戰地 | 通灵战潮
    -- [3] 縫肉
    [327952] = true, --肉鉤
    [320366] = true, --防腐黏液 (腳下污水)
    -- [4] 『霜縛者』納爾索
    [320784] = true, --彗星風暴
    [328212] = true --鋒利碎冰 (大冰圈)
}

local SpellsNotTank = {}

local Auras = {}

local AurasNotTank = {}

local Swing = {}

local SwingNotTank = {}

local warningMessage
local stacksMessage
local spellMessage

local allUsers = {}
local timers = {}
local timerData = {}
local combinedFails = {}

local activeUser
local playerName = GetUnitName("player", true) .. "-" .. gsub(GetRealmName(), " ", "")

local function SortTable(t)
    sort(
        t,
        function(a, b)
            return a.value > b.value
        end
    )
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

function AD:GenerateNumber(amount)
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

function AD:GetIDByGUID(guid)
    return tonumber(strmatch(guid or "", "Creature%-.-%-.-%-.-%-.-%-(.-)%-"))
end

function AD:SetAddonMessagePrefix()
    -- compatible mode
    self.prefix = self.db.compatible and "ElitismHelper" or W.AddonMsgPrefix

    if self.db.compatible then
        local registeredPrefixs = C_ChatInfo_GetRegisteredAddonMessagePrefixes()

        for _, registeredPrefix in pairs(registeredPrefixs) do
            if self.prefix == registeredPrefix then
                return
            end
        end

        C_ChatInfo_RegisterAddonMessagePrefix(self.prefix)
    end
end

function AD:SendAddonMessage(message)
    if IsInGroup(LE_PARTY_CATEGORY_HOME) and not IsInRaid() then
        C_ChatInfo_SendAddonMessage(self.prefix, message, "PARTY")
    end
end

function AD:SendChatMessage(message)
    if not self.db.notification.enable or activeUser ~= playerName then
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

function AD:SpellDamage(dstName, spellID, damageAmount, sourceGUID)
    if not UnitIsPlayer(dstName) then
        return
    end

    local isTank = UnitGroupRolesAssigned(dstName) == "TANK"

    if spellID then
        if not Spells[spellID] and not (SpellsNotTank[spellID] and not isTank) then
            return
        end
    else
        local npcID = sourceGUID and self:GetIDByGUID(sourceGUID)
        if npcID then
            if not Swing[npcID] and not (SwingNotTank[npcID] and not isTank) then
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
    local damageText = self:GenerateNumber(totalDamage)
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

    if Auras[spellID] or (AurasNotTank[spellID] and not isTank) then
        if auraAmount then
            self:SendChatMessage(self:GenerateOutput(stacksMessage, dstName, GetSpellLink(spellID), auraAmount))
        else
            self:SendChatMessage(self:GenerateOutput(warningMessage, dstName, GetSpellLink(spellID)))
        end
    end
end

function AD:ResetAuthority()
    wipe(allUsers)
    activeUser = nil

    if IsInGroup(LE_PARTY_CATEGORY_HOME) then
        self:SendAddonMessage("VREQ")
    else
        activeUser = playerName
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
        self:SendChatMessage(format("%d. %s %s", index, data.key, self:GenerateNumber(data["value"])))
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

function AD:CHAT_MSG_ADDON(_, prefix, message, channel, sender)
    if prefix ~= self.prefix then
        return
    end

    if message == "VREQ" then
        self:SendAddonMessage("VANS")
    elseif message:match("^VANS") then
        allUsers[sender] = true
        for userName in pairs(allUsers) do
            if activeUser == nil then
                activeUser = userName
            end
            if userName < activeUser then
                activeUser = userName
            end
        end
    end
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
    self.db = W.db.avoidableDamage

    self:SetAddonMessagePrefix()
    self:SetNotificationText()
    self:ProfileUpdate()
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
