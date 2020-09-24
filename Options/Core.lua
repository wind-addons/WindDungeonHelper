local ns = select(2, ...)
local W, F, L = unpack(ns)
local LibStub = _G.LibStub

local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local ADBO = LibStub("AceDBOptions-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBI = LibStub("LibDBIcon-1.0")

local C_Timer_After = C_Timer.After
local CreateFrame = CreateFrame
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory

local options = {
    type = "group",
    name = F.CreateColorString(W.AddonName) .. " - " .. W.Version,
    childGroups = "tab",
    args = {
        author = {
            order = 1,
            name = L["Author"] .. ": " .. F.CreateColorString("Tabimonk-暗影之月(TW)", 0, 1, 0.59) .. " @ 人生海海",
            type = "description"
        },
        minimapIcon = {
            order = 2,
            name = L["Minimap icon"],
            desc = L["Enables / disables Wind Dungeon Helper minimap icon"],
            type = "toggle",
            set = function(info, value)
                W.db.minimapIcon = value
                if value then
                    LDBI:Show(L["Wind Dungeon Helper"])
                else
                    LDBI:Hide(L["Wind Dungeon Helper"])
                end
            end,
            get = function()
                return W.db.minimapIcon
            end
        }
    }
}

ns[5] = options.args

function W:BuildOptions()
    local name = "WindDungeonHelper"
    ACR:RegisterOptionsTable(name, options)
    ACR:RegisterOptionsTable(name .. "Profiles", ADBO:GetOptionsTable(W.Database))
    self.OptionFrame = ACD:AddToBlizOptions(name, W.AddonName)
    self.OptionFrame.ProfilesFrame = ACD:AddToBlizOptions(name .. "Profiles", L["Profiles"], W.AddonName)

    local logoFrame = CreateFrame("Frame", nil, self.OptionFrame)
    logoFrame:SetFrameLevel(4)
    logoFrame:SetSize(54, 54)
    logoFrame:SetPoint("TOPRIGHT", -12, -12)

    local tex = logoFrame:CreateTexture(nil, "ARTWORK")
    tex:SetTexture("Interface\\Icons\\Spell_animarevendreth_buff")
    tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    tex:SetPoint("TOPLEFT", 0, 0)
    tex:SetPoint("BOTTOMRIGHT", 0, 0)
    self.OptionFrame.Logo = logoFrame

    self.DataBroker =
        LDB:NewDataObject(
        L["Wind Dungeon Helper"],
        {
            type = "data source",
            text = "WDH",
            icon = "Interface\\Icons\\Achievement_challengemode_gold",
            OnClick = function()
                W:ShowOptions()
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine("|cff00a8ff" .. L["Wind Dungeon Helper"] .. "|r")
                tooltip:AddLine(L["Click to toggle config window."])
            end
        }
    )

    LDBI:Register(L["Wind Dungeon Helper"], self.DataBroker, self.db.minimapIcon)
end

function W:ShowOptions()
    InterfaceOptionsFrame_OpenToCategory(self.OptionFrame)
end

function W:RefreshOptions()
    ACR:NotifyChange("WindDungeonHelper")
end

function W:RefreshOptionsAfter(second)
    C_Timer_After(second, self.RefreshOptions)
end
