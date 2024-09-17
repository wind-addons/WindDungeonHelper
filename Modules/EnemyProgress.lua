local W, F, L = unpack(select(2, ...))
local EP = W:NewModule("EnemyProgress", "AceHook-3.0")

local _G = _G

local format = format
local select = select
local tonumber = tonumber

local GameTooltip = _G.GameTooltip

local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local TooltipDataProcessor_AddTooltipPostCall = TooltipDataProcessor.AddTooltipPostCall

local Enum_TooltipDataType_Unit = Enum.TooltipDataType.Unit

local icon1 = F.GetIconString(132147, 14)
local icon2 = F.GetIconString(5926319, 14)

local function isWindToolsLoaded()
	if C_AddOns_IsAddOnLoaded("ElvUI_WindTools") then
		local E = _G.ElvUI and _G.ElvUI[1]
		if E and E.private and E.private.WT and E.private.WT.tooltips and E.private.WT.tooltips.objectiveProgress then
			return true
		end
	end
end

function EP:AddEnemyProgress(tt, data)
	if not _G.MDT or not _G.MDT.GetEnemyForces or not self.db or not self.db.enable then
		return
	end

	if isWindToolsLoaded() or not tt or not tt == _G.GameTooltip and not tt.NumLines or tt:NumLines() == 0 then
		return
	end

	local accuracy = self.db.accuracy
	local npcID = select(6, strsplit("-", data.guid))
	if not npcID or npcID == "" then
		return
	end

	npcID = tonumber(npcID)

	local count, max = _G.MDT:GetEnemyForces(npcID)

	if count and max and count > 0 and max > 0 then
		local left = format("%s |cff00d1b2%s|r |cffffffff-|r |cffffdd57%s|r", icon1, count, max)
		local right = format("%s |cff209cee%s|r|cffffffff%%|r", icon2, F.Round(100 * count / max, accuracy))

		-- If the line already exists, update it
		if GameTooltip.__windEnemyProgress then
			for i = 1, tt:NumLines() do
				local leftTextObj = _G["GameTooltipTextLeft" .. i]
				local rightTextObj = _G["GameTooltipTextRight" .. i]
				local leftText = leftTextObj and leftTextObj:GetText()
				if leftText and rightTextObj and strfind(leftText, "^" .. icon1) then
					leftTextObj:SetText(left)
					rightTextObj:SetText(right)
					return
				end
			end
		end

		GameTooltip:AddDoubleLine(left, right)
		GameTooltip:Show()
		GameTooltip.__windEnemyProgress = true
	end
end

function EP:ProfileUpdate()
	self.db = W.db.enemyProgress

	if self.db and self.db.enable then
		TooltipDataProcessor_AddTooltipPostCall(Enum_TooltipDataType_Unit, function(...)
			self:AddEnemyProgress(...)
		end)

		GameTooltip:HookScript("OnTooltipCleared", function(tt)
			tt.__windEnemyProgress = nil
		end)
	end
end

EP.OnInitialize = EP.ProfileUpdate
