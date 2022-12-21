local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {}
local mapIds = {761, 762, 763}

AD:AddData("Court of Stars", mistakes, mapIds)
