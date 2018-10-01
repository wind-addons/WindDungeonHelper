local AddOnName, WDH = ...
local L, B, C, DB = WDH.L, WDH.Base, WDH.Config, WDH.DataBase

function WDH:OnInitialize()
    DB.profile = LibStub("AceDB-3.0"):New(AddOnName.."DB", DB.defaults).profile
    self:SetUpConfig()
end

function WDH:SetUpConfig()
    LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(AddOnName, function() return C.CreateOptionTable() end)
    local optionFrame = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(AddOnName, B.AddonName)
    
    local logo = CreateFrame('Frame', nil, optionFrame)
    logo:SetFrameLevel(4)
    logo:SetSize(64, 64)
    logo:SetPoint('TOPRIGHT', -12, -12)
    logo:SetBackdrop({bgFile = ('Interface\\ICONS\\Achievement_Dungeon_Mythic15'):format(AddOnName)})
    optionFrame.logo = logo
end