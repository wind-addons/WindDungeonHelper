local W, F, L, P, O = unpack(select(2, ...))
local LibStub = _G.LibStub

local ACD = LibStub("AceConfigDialog-3.0")
local ACR = LibStub("AceConfigRegistry-3.0")
local ADBO = LibStub("AceDBOptions-3.0")
local LDB = LibStub("LibDataBroker-1.1")
local LDBI = LibStub("LibDBIcon-1.0")

local CreateFrame = CreateFrame
local InterfaceOptionsFrame_OpenToCategory = InterfaceOptionsFrame_OpenToCategory

O = {
    type = "group",
    name = F.CreateColorString(W.AddonName) .. " - " .. W.Version,
    args = {
        author = {
            order = 1,
            name = L["Author"] .. ": " .. W.ColorString("Tabimonk-暗影之月(TW)", 0, 1, 0.59) .. " @ 人生海海",
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

function W:BuildOptions()
    local name = "WindDungeonHelper"
    ACR:RegisterOptionsTable(name, O)
    ACR:RegisterOptionsTable(name .. "Profiles", ADBO:GetOptionsTable(W.Database))
    self.OptionFrame = ACD:AddToBlizOptions(name, W.AddonName)
    self.OptionFrame.ProfilesFrame = ACD:AddToBlizOptions(name .. "Profiles", L["Profiles"], W.AddonName)

    local logo = CreateFrame("Frame", nil, self.OptionFrame, "BackdropTemplate")
    logo:SetFrameLevel(4)
    logo:SetSize(64, 64)
    logo:SetPoint("TOPRIGHT", -12, -12)
    logo:SetBackdrop(
        {
            bgFile = "Interface\\ICONS\\SPELL_ANIMAREVENDRETH_BUFF",
            insets = {left = 5, right = 5, top = 5, bottom = 5}
        }
    )
    self.OptionFrame.Logo = logo

    self.DataBroker =
        LDB:NewDataObject(
        L["Wind Dungeon Helper"],
        {
            type = "data source",
            text = "WDH",
            icon = "Interface\\ICONS\\Achievement_Challengemode_Gold",
            OnClick = function()
                W:ShowOptions()
            end,
            OnTooltipShow = function(tooltip)
                tooltip:AddLine("|cff00a8ff" .. L["Wind Dungeon Helper"] .. "|r")
                tooltip:AddLine(L["Click to toggle config window."])
            end
        }
    )
    LibStub("LibDBIcon-1.0"):Register(L["Wind Dungeon Helper"], DataBroker, self.db.minimapIcon)
end

function W:ShowOptions()
    InterfaceOptionsFrame_OpenToCategory(self.OptionFrame)
end
