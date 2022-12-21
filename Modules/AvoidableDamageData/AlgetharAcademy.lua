local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {}
local mapIds = {2097, 2098, 2099}

AD:AddData("Algeth'ar Academy", mistakes, mapIds)
