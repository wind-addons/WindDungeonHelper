local W, F, L = unpack(select(2, ...))
local EP = W:NewModule("EnemyProgress", "AceHook-3.0")
local LOP = LibStub("LibObjectiveProgress-1.0")

local _G = _G
local floor = floor
local next = next
local select = select
local tonumber = tonumber
local tostring = tostring

local GameTooltip = _G.GameTooltip

local function CheckElvUIWindTools()
	if IsAddOnLoaded("ElvUI_WindTools") then
		local E = _G.ElvUI and _G.ElvUI[1]
		if E and E.private.WT.tooltips.objectiveProgress then
			return true
		end
	end
end

function EP:AddObjectiveProgress(tt)
	if CheckElvUIWindTools() then
		return
	end

	if not tt or not tt.NumLines or tt:NumLines() == 0 then
		return
	end

	local name, unit = tt:GetUnit()
	if not unit then
		return
	end

	local GUID = UnitGUID(unit)
	if not GUID or GUID == "" then
		return
	end

	local npcID = select(6, ("-"):split(GUID))
	if not npcID or npcID == "" then
		return
	end

	local weightsTable = LOP:GetNPCWeightByCurrentQuests(tonumber(npcID))
	if not weightsTable then
		return
	end

	for questID, npcWeight in next, weightsTable do
		local questTitle = C_TaskQuest_GetQuestInfoByQuestID(questID)
		for j = 1, tt:NumLines() do
			if _G["GameTooltipTextLeft" .. j] and _G["GameTooltipTextLeft" .. j]:GetText() == questTitle then
				_G["GameTooltipTextLeft" .. j]:SetText(
					_G["GameTooltipTextLeft" .. j]:GetText() .. " - " .. tostring(floor((npcWeight * 100) + 0.5) / 100) .. "%"
				)
			end
		end
	end
end

function EP:RefreshOption()
	LibStub("AceConfigRegistry-3.0"):NotifyChange("WindDungeonHelper")
end

function EP:OnInitialize()
	self.db = W.db.enemyProgress
	self:ProfileUpdate()
end

function EP:ProfileUpdate()
	if self.db and self.db.enable then
		if not self:IsHooked(GameTooltip, "OnTooltipSetUnit") then
			self:SecureHookScript(GameTooltip, "OnTooltipSetUnit", "AddObjectiveProgress")
		end
	else
		if self:IsHooked(GameTooltip, "OnTooltipSetUnit") then
			self:Unhook(GameTooltip, "OnTooltipSetUnit")
		end
	end
end