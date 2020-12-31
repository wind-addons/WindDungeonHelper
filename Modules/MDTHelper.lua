local W, F, L = unpack(select(2, ...))
local MH = W:NewModule("MDTHelper", "AceHook-3.0", "AceEvent-3.0")

local _G = _G
local format = format
local pairs = pairs

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded

local C_Timer_After = C_Timer.After

local TypeDict = {
    ["Humanoid"] = L["Humanoid"],
    ["Beast"] = L["Beast"],
    ["Undead"] = L["Undead"],
    ["Elemental"] = L["Elemental"],
    ["Aberration"] = L["Aberration"],
    ["Not specified"] = L["Not specified"],
    ["Mechanical"] = L["Mechanical"],
    ["Dragonkin"] = L["Dragonkin"]
}

function MH:GetNPCNameByID(id)
    local cache = W.Database.locale

    if not cache.mdtHelper then
        cache.mdtHelper = {}
    end

    if cache.mdtHelper[id] then
        return cache.mdtHelper[id]
    end

    if not _G.WDHScanTooltip then
        CreateFrame("GameTooltip", "WDHScanTooltip", _G.UIParent, "GameTooltipTemplate")
        _G.WDHScanTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")
    end
    _G.WDHScanTooltip:SetHyperlink(format("unit:Creature-0-0-0-0-%d", id))

    if _G.WDHScanTooltipTextLeft1 and _G.WDHScanTooltipTextLeft1.GetText then
        local name = _G.WDHScanTooltipTextLeft1:GetText()
        cache.mdtHelper[id] = name
        return name
    end
end

function MH:Translate()
    if not self.db or not self.db.enable or not self.db.translate then
        return
    end

    if not _G.MDT or not _G.MDT.dungeonEnemies then
        return
    end

    for mapID, NPCs in pairs(_G.MDT.dungeonEnemies) do
        if mapID >= 29 and NPCs then
            for _, NPC in pairs(NPCs) do
                if NPC.id and NPC.name then
                    local name = self:GetNPCNameByID(NPC.id)
                    if name then
                        NPC.name = name
                    end
                end
                if NPC.creatureType then
                    NPC.creatureType = TypeDict[NPC.creatureType] or NPC.creatureType
                end
            end
        end
    end
end

function MH:MDTLoaded()
    if not self.db or not self.db.enable then
        return
    end
    self:Translate()
end

function MH:ProfileUpdate()
    self.db = W.db.mdtHelper

    if IsAddOnLoaded("MythicDungeonTools") then
        self:MDTLoaded()
    else
        self:RegisterEvent("ADDON_LOADED", "MDTLoaded")
    end
end

MH.OnInitialize = MH.ProfileUpdate
