local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	-- restore v1.4.5 data
	-- -- Siege of Boralus
	-- [256627] = 20, --- Slobber Knocker (Scrimshaw Enforcer)
	-- [256663] = 20, --- Burning Tar (Blacktar Bomber)
	-- [257431] = 20, --- Meat Hook (Chopper Redhook)
	-- [275775] = 20, --- Savage Tempest (Irontide Raider)
	-- [269029] = 20, --- Clear the Deck (Dread Captain Lockwood)
	-- [272874] = 20, --- Trample (Ashvane Commander)
	-- [272426] = 20, --- Sighted Artillery
	-- [272140] = 20, --- Iron Volley
	-- [257292] = 20, --- Heavy Slash (Irontide Cleaver)
	-- [273681] = 20, --- Heavy Hitter (Chopper Redhook)
	-- [257886] = 20, --- Brine Pool (Hadal Darkfathom)
	-- -- import from ElitismHelper
	-- [257069] = 20, --- Watertight Shell (Kul Tiran Wavetender)
	-- [268260] = 20, --- Broadside (Ashvane Cannoneer)
	-- [268443] = 20, --- Dread Volley (Dread Captain Lockwood)
	-- [272713] = 20, --- Crushing Slam (Bilge Rat Demolisher)
	-- [274941] = 20, --- Banana Rampage swirlies(Bilge Rat Buccaneer)
	-- [257883] = 20, --- Break Water (Hadal Darkfathom)
	-- [276068] = 20, --- Tidal Surge (Hadal Darkfathom)
	-- [261565] = 20, --- Crashing Tide (Hadal Darkfathom)
	-- [277535] = 20, --- Viq'Goth's Wrath (Viq'Goth)
}

local mapIds = { 1162 }

AD:AddData("Siege of Boralus", mistakes, mapIds)
