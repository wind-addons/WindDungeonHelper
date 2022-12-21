local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {}
local mapIds = {2093}

AD:AddData("The Nokhud Offensive", mistakes, mapIds)
