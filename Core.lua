local AddOnName, WDH = ...
local L, B, C, DB = WDH.L, WDH.Base, WDH.Config, WDH.DataBase

function WDH:OnInitialize()
    DB.profile = LibStub("AceDB-3.0"):New(AddOnName.."DB", DB.defaults).profile
    C_ChatInfo.RegisterAddonMessagePrefix(B.AddonMsgPrefix)
    self:SetUpConfig()
    self:RegisterChatCommand("wdh", "OpenOptionFrame")
end

function WDH:SetUpConfig()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddOnName, function() return C.CreateOptionTable() end)
    self.optionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, B.AddonName)
    
    local logo = CreateFrame('Frame', nil, self.optionFrame)
    logo:SetFrameLevel(4)
    logo:SetSize(64, 64)
    logo:SetPoint('TOPRIGHT', -12, -12)
    logo:SetBackdrop({bgFile = ('Interface\\ICONS\\Achievement_Dungeon_Mythic15'):format(AddOnName)})
    self.optionFrame.logo = logo

    LibStub("LibDBIcon-1.0"):Register(L["Wind Dungeon Helper"], self.LDB, DB.profile.minimapicon)
end

function WDH:OpenOptionFrame()
    InterfaceOptionsFrame_OpenToCategory(self.optionFrame)
    InterfaceOptionsFrame_OpenToCategory(self.optionFrame)
end