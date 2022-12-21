local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {}
local mapIds = {2094, 2095}

AD:AddData("Ruby Life Pools", mistakes, mapIds)
