local AddOnName, WDH = ...
local L, B, C, DB = WDH.L, WDH.Base, WDH.Config, WDH.DataBase
local AD = WDH:NewModule("AvoidableDamage", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")

DB.defaults.profile.modules.AvoidableDamage = {
    enable = true,
    loud = true,
    custom_text = false,
    outputmode = "default"
}

C.ModulesOrder.AvoidableDamage = 20
C.ModulesOption.AvoidableDamage = {
    name = L["Avoidable Damage"],
    type = "group",
    args = {
        enable = {
            order = 1,
            name = L["Enable"],
            desc = L["Enables / disables the module"],
            type = "toggle",
            set = function(info,value) DB.profile.modules.AvoidableDamage.enable = value end,
            get = function(info) return DB.profile.modules.AvoidableDamage.enable end
        },
    }
}

local Users = {}
local Timers = {}
local TimerData = {}
local CombinedFails = {}
local activeUser = nil
local playerUser = GetUnitName("player",true).."-"..GetRealmName():gsub(" ", "")
local hardMinPct = 40

local Spells = {
	-- Debug
	--[252144] = 1,
	--[252150] = 1,

	-- Affixes
	[209862] = 20,		-- Volcanic Plume (Environment)
	[226512] = 20,		-- Sanguine Ichor (Environment)

	-- Freehold
	[272046] = 20,		--- Dive Bomb (Sharkbait)
	[257426] = 20,		--- Brutal Backhand (Irontide Enforcer)
	[258352] = 20,		--- Grapeshot (Captain Eudora)
	[272374] = 20,		--- Whirlpool of Blades
	[256546] = 20,		--- Shark Tornado
	[257310] = 20,		--- Cannon Barrage
	[257902] = 20,		--- Shell Bounce (Ludwig Von Tortollan)
	[258199] = 20,		--- Ground Shatter (Irontide Crusher)
	[276061] = 20,		--- Boulder Throw (Irontide Crusher)
	[258779] = 20,		--- Sea Spout (Irontide Oarsman)
	[274400] = 20,		--- Duelist Dash (Cutwater Duelist)
	[257274] = 20,		--- Vile Coating (Environment)
	
	-- Shrine of the Storm
	[264560] = 20,		--- Choking Brine (Aqualing)
	[267899] = 20,		--- Hindering Cleave (Brother Ironhull)
	[268280] = 20,		--- Tidal Pod (Tidesage Enforcer)
	[276286] = 20,		--- Slicing Hurricane (Environment)
	[276292] = 20,		--- Whirlign Slam (Ironhull Apprentice)
	[269104] = 20,		--- Explosive Void (Lord Stormsong)
	[267385] = 20,		--- Tentacle Slam (Vol'zith the Whisperer)
	
	-- Siege of Boralus
	[256663] = 20,		--- Burning Tar (Blacktar Bomber)
	[275775] = 20,		--- Savage Tempest (Irontide Raider)
	[272426] = 20,		--- Sighted Artillery
	[272140] = 20,		--- Iron Volley
	[273681] = 20,		--- Heavy Hitter (Chopper Redhook)
	
	
	-- Tol Dagor
	[257785] = 20,		--- Flashing Daggers
	[256976] = 20,		--- Ignition (Knight Captain Valyri)
	[256955] = 20,		--- Cinderflame (Knight Captain Valyri)
	[256083] = 20,		--- Cross Ignition (Overseer Korgus)
	[263345] = 20,		--- Massive Blast (Overseer Korgus)
	[258864] = 20,		--- Suppression Fire (Ashvane Marine/Spotter)
	[258364] = 20,		--- Fuselighter (Ashvane Flamecaster)
	[259711] = 20,		--- Lockdown (Ashvane Warden)
	
	-- Waycrest Manor
	[260569] = 20,		--- Wildfire (Soulbound Goliath)
	[265407] = 20,		--- Dinner Bell (Banquet Steward)
	[264923] = 20,		--- Tenderize (Raal the Gluttonous)
	[264150] = 20,		--- Shatter (Thornguard)
	[271174] = 20,		--- Retch (Pallid Gorger)
	[268387] = 20,		--- Contagious Remnants (Lord Waycrest)
	[268308] = 20,		--- Discordant Cadenza (Lady Waycrest

	-- Atal'Dazar
	[253666] = 20,		--- Fiery Bolt (Dazar'ai Juggernaught)
	[257692] = 20,		--- Tiki Blaze (Environment)
	[255620] = 20,		--- Festering Eruption (Reanimated Honor Guard)
	[256959] = 20,		--- Rotting Decay (Renaimated Honor Guard)
	[250259] = 20,		--- Toxic Leap
	[250022] = 20,		--- Echoes of Shadra (Echoes of Shadra)
	[250585] = 20, 		--- Toxic Pool
	[250036] = 20,		--- Shadowy Remains

	-- King's Rest
	[265914] = 20,		--- Molten Gold (The Golden Serpent)
	[266191] = 20,		--- Whirling Axe (Council of Tribes)
	[270289] = 20,		--- Purification Beam
	[270503] = 20,		--- Hunting Leap (Honored Raptor)
	[271564] = 20,		--- Embalming Fluid (Embalming Fluid)
	[270485] = 20,		--- Blooded Leap (Spectral Berserker)
	[267639] = 20,		--- Burn Corruption (Mchimba the Embalmer)
	[270931] = 20,		-- Darkshot
	
	-- The MOTHERLODE!!
	[257371] = 20,		--- Gas Can (Mechanized Peace Keeper)
	[262287] = 20,		-- Concussion Charge (Mech Jockey / Venture Co. Skyscorcher)
	[268365] = 20,		--- Mining Charge (Wanton Sapper)
	[269313] = 20,		--- Final Blast (Wanton Sapper)
	[275907] = 20,		--- Tectonic Smash
	[259533] = 20,		--- Azerite Catalyst (Rixxa Fluxflame)
	[260103] = 20,		--- Propellant Blast
	[260279] = 20,		--- Gattling Gun (Mogul Razdunk)
	[276234] = 20, 		--- Micro Missiles
	[270277] = 20,		--- Big Red Rocket (Mogul Razdunk)
	[271432] = 20,		--- Test Missile (Venture Co. War Machine)
	[262348] = 20,		--- Mine Blast
	[257337] = 20,		--- Shocking Claw
	[269092] = 20,		--- Artillery Barrage (Ordnance Specialist)

	-- Temple of Sethraliss
	[273225] = 20,		--- Volley (Sandswept Marksman)
	[273995] = 20,		--- Pyrrhic Blast (Crazed Incubator)
	[264206] = 20,		--- Burrow (Merektha)
	[272657] = 20,		--- Noxious Breath
	

	-- Underrot
	[265542] = 20,		--- Rotten Bile (Fetid Maggot)
	[265019] = 20,		--- Savage Cleave (Chosen Blood Matron)
	[261498] = 20,		--- Creeping Rot (Elder Leaxa)
	[265665] = 20,		--- Foul Sludge (Living Rot)
}
local SpellsNoTank = {
	-- Freehold

	-- Shrine of the Storm
	[267899] = 20,  		--- Hindering Cleave

	-- Siege of Boralus

	-- Tol Dagor

	-- Waycrest Manor

	-- Atal'Dazar

	-- King's Rest

	-- The MOTHERLODE!!

	-- Temple of Sethraliss
	[255741] = 20,			--- Cleave (Scaled Krolusk Rider)

	-- Underrot
	[265019] = 20,			--- Savage Cleave (Chosen Blood Matron)
}
local Auras = {
	-- Freehold
	[274389] = true,		-- Rat Traps (Vermin Trapper)
	[274516] = true,		-- Slippery Suds
	
	-- Shrine of the Storm
	[268391] = true,		-- Mental Assault (Abyssal Cultist)
	[276268] = true,		-- Heaving Blow (Shrine Templar)

	-- Siege of Boralus
	[257292] = true,		-- Heavy Slash (Kul Tiran Vanguard)
	[272874] = true,		-- Trample (Ashvane Commander)

	-- Tol Dagor
	[257119] = true,		-- Sand Trap (The Sand Queen)
	[256474] = true,		-- Heartstopper Venom (Overseer Korgus)

	-- Waycrest Manor
	[265352] = true,		-- Toad Blight (Toad)
	
	-- Atal'Dazar

	-- King's Rest
	[270003] = true,		-- Suppression Slam (Animated Guardian)
	[270931] = true,		-- Darkshot
	[268796] = true,		-- (Kind Dazar)

	-- The MOTHERLODE!!
	
	-- Temple of Sethraliss
	[263914] = true,		-- Blinding Sand (Merektha)
	[269970] = true,		-- Blinding Sand (Merektha)

	-- Underrot
	[272609] = true,		-- Maddening Gaze (Faceless Corrupter)

}
local AurasNoTank = {
}

local function compareDamage(a,b)
	return a["value"] < b["value"]
end

function AD:OnInitialize()
    self.db = DB.profile.modules.AvoidableDamage
    AD:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    AD:RegisterEvent("CHAT_MSG_ADDON")
    AD:RegisterEvent("GROUP_ROSTER_UPDATE")
    AD:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    AD:RegisterEvent("CHALLENGE_MODE_START")
    AD:RegisterEvent("CHALLENGE_MODE_COMPLETED")
    -- AD:RegisterEvent("ADDON_LOADED")
    ElitismFrame:RebuildTable()
end

local function maybeSendAddonMessage(prefix, message)
	if IsInGroup() and not IsInGroup(2) and not IsInRaid() then
		C_ChatInfo.SendAddonMessage(prefix,message,"PARTY")
	elseif IsInGroup() and not IsInGroup(2) and IsInRaid() then
		C_ChatInfo.SendAddonMessage(prefix,message,"RAID")
	end
end

function generateMaybeOutput(user)
	local func = function()
			local msg = "<EH> "..user.." got hit by "
			local amount = 0
			local minPct = math.huge
			for k,v in pairs(TimerData[user]) do
				msg = msg..GetSpellLink(k).." "
				local spellMinPct = nil
				if Spells[k] then
					spellMinPct = Spells[k]
				elseif SpellsNoTank[k] then
					spellMinPct = SpellsNoTank[k]
				end
				if spellMinPct ~= nil and spellMinPct < minPct then
					minPct = spellMinPct
				end
				amount = amount + v
			end
			if minPct == math.huge then
				local spellNames = " "
				for k,v in pairs(TimerData[user]) do
					spellNames = spellNames..GetSpellLink(k).." "
				end
				print("<EH> Error: Could not find spells"..spellNames.."in Spells or SpellsNoTank but got Timer for them. wtf")
			end
			TimerData[user] = nil
			Timers[user] = nil
			local userMaxHealth = UnitHealthMax(user)
			local msgAmount = round(amount / 1000,1)
			local pct = Round(amount / userMaxHealth * 100)
			if pct >= hardMinPct and pct >= minPct and ElitismHelperDB.Loud then
				msg = msg.."for "..msgAmount.."k ("..pct.."%)."
				maybeSendChatMessage(msg)
			end
		end
	return func
end

local function maybeSendChatMessage(message)
	if activeUser ~= playerUser then
		return
	end
	if AD.db.outputmode == "self" then
		print(message)
	elseif AD.db.outputmode == "party" and IsInGroup() and not IsInGroup(2) then
		SendChatMessage(message,"PARTY")
	elseif AD.db.outputmode == "raid" and IsInGroup() and not IsInGroup(2) and IsInRaid() then
		SendChatMessage(message,"RAID")
	elseif AD.db.outputmode == "default" then
		if IsInGroup() and not IsInGroup(2) and not IsInRaid() then
			SendChatMessage(message,"PARTY")
		elseif IsInGroup() and not IsInGroup(2) and IsInRaid() then
			SendChatMessage(message,"RAID")
		end
	end
end

function AD:RebuildTable()
	Users = {}
	activeUser = nil
	print("Reset Addon Users table")
	if IsInGroup() then
		maybeSendAddonMessage(B.AddonMsgPrefix,"VREQ")
	else
		name = GetUnitName("player",true)
		activeUser = name.."-"..GetRealmName()
		print("We are alone, activeUser: "..activeUser)
	end
end

function AD:GROUP_ROSTER_UPDATE(self, event,...)
	print("GROUP_ROSTER_UPDATE")
	self:RebuildTable()
end

function AD:ZONE_CHANGED_NEW_AREA(self, event,...)
	print("ZONE_CHANGED_NEW_AREA")
	self:RebuildTable()
end

function AD:CHALLENGE_MODE_COMPLETED(self, event,...)
	local count = 0
	for _ in pairs(CombinedFails) do count = count + 1 end
	if count == 0 then
		maybeSendChatMessage("Thank you for travelling with ElitismHelper. No failure damage was taken this run.")
		return
	else
		maybeSendChatMessage("Thank you for travelling with ElitismHelper. Amount of failure damage:")
	end
	local u = { }
	for k, v in pairs(CombinedFails) do table.insert(u, { key = k, value = v }) end
	table.sort(u, compareDamage)
	for k,v in pairs(u) do
			maybeSendChatMessage(k..". "..v["key"].." "..B.Round(v["value"] / 1000,1).."k")
	end
	CombinedFails = {}
end

function AD:CHALLENGE_MODE_START(event,...)
	CombinedFails = {}
	print("Failure damage now being recorded.")
end

function AD:CHAT_MSG_ADDON(event,...)
	local prefix, message, channel, sender = select(1,...)
	if prefix ~= B.AddonMsgPrefix then
		return
	end
	if message == "VREQ" then
		maybeSendAddonMessage(B.AddonMsgPrefix,"VANS;0.1")
	elseif message:match("^VANS") then
		Users[sender] = message
		for k,v in pairs(Users) do
			if activeUser == nil then
				activeUser = k
			end
			if k < activeUser then
				activeUser = k
			end
		end
	else
		-- print("Unknown message: "..message)
	end
end


function AD:SpellDamage(self, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, aAmount)
	if (Spells[spellId] or (SpellsNoTank[spellId] and UnitGroupRolesAssigned(dstName) ~= "TANK")) and UnitIsPlayer(dstName) then
		-- Initialize TimerData and CombinedFails for Timer shot
		if TimerData[dstName] == nil then
			TimerData[dstName] = {}
		end
		if CombinedFails[dstName] == nil then
			CombinedFails[dstName] = 0
		end
		
		-- Add this event to TimerData / CombinedFails
		CombinedFails[dstName] = CombinedFails[dstName] + aAmount
		if TimerData[dstName][spellId] == nil then
			TimerData[dstName][spellId] = aAmount
		else
			TimerData[dstName][spellId] = TimerData[dstName][spellId] + aAmount
		end
		
		-- If there is no timer yet, start one with this event
		if Timers[dstName] == nil then
			Timers[dstName] = true
			C_Timer.After(4, generateMaybeOutput(dstName))
		end
	end
end

function AD:SwingDamage(self, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, aAmount)
end

function AD:AuraApply(self, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType, auraAmount)
	if (Auras[spellId] or (AurasNoTank[spellId] and UnitGroupRolesAssigned(dstName) ~= "TANK")) and UnitIsPlayer(dstName)  then
		if auraAmount and self.db.loud then
			maybeSendChatMessage("<EH> "..dstName.." got hit by "..GetSpellLink(spellId)..". "..auraAmount.." Stacks.")
		elseif self.db.loud then
			maybeSendChatMessage("<EH> "..dstName.." got hit by "..GetSpellLink(spellId)..".")
		end
	end
end

function AD:COMBAT_LOG_EVENT_UNFILTERED(event,...)
	local timestamp, eventType, hideCaster, srcGUID, srcName, srcFlags, srcFlags2, dstGUID, dstName, dstFlags, dstFlags2 = CombatLogGetCurrentEventInfo(); -- Those arguments appear for all combat event variants.
	local eventPrefix, eventSuffix = eventType:match("^(.-)_?([^_]*)$");
	if (eventPrefix:match("^SPELL") or eventPrefix:match("^RANGE")) and eventSuffix == "DAMAGE" then
		local spellId, spellName, spellSchool, sAmount, aOverkill, sSchool, sResisted, sBlocked, sAbsorbed, sCritical, sGlancing, sCrushing, sOffhand, _ = select(12,CombatLogGetCurrentEventInfo())
		AD:SpellDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, sAmount)
	elseif eventPrefix:match("^SWING") and eventSuffix == "DAMAGE" then
		local aAmount, aOverkill, aSchool, aResisted, aBlocked, aAbsorbed, aCritical, aGlancing, aCrushing, aOffhand, _ = select(12,CombatLogGetCurrentEventInfo())
		AD:SwingDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, aAmount)
	elseif eventPrefix:match("^SPELL") and eventSuffix == "MISSED" then
		local spellId, spellName, spellSchool, missType, isOffHand, mAmount  = select(12,CombatLogGetCurrentEventInfo())
		if mAmount then
			AD:SpellDamage(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, mAmount)
		end
	elseif eventType == "SPELL_AURA_APPLIED" then
		local spellId, spellName, spellSchool, auraType = select(12,CombatLogGetCurrentEventInfo())
		AD:AuraApply(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType)
	elseif eventType == "SPELL_AURA_APPLIED_DOSE" then
		local spellId, spellName, spellSchool, auraType, auraAmount = select(12,CombatLogGetCurrentEventInfo())
		AD:AuraApply(timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellId, spellName, spellSchool, auraType, auraAmount)
	end
end