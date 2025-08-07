local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 灑出的液體
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 346329,
	},
	{
		-- 殊離之環
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 347481,
	},
	{
		-- 武裝保全
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 348366,
	},
	{
		-- 飢餓之握
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 349663,
	},
	{
		-- 宏偉吞噬
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 349801,
	},
	{
		-- 靈魄引爆
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 349999,
	},
	{
		-- 旋風之滅
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 350090,
	},
	{
		-- 控場
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 350921,
	},
	{
		-- 散熱震盪
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 351070,
	},
	{
		-- 裂隙衝擊
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355306,
	},
	{
		-- 壓制火光
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355439,
	},
	{
		-- 震擊地雷
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355476,
	},
	{
		-- 致命武力
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355487,
	},
	{
		-- 震光屏障
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355502,
	},
	{
		-- 鎮壓猛襲
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355638,
	},
	{
		-- 干擾手榴彈
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 355903,
	},
	{
		-- 光束接合者
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 356011,
	},
	{
		-- 腐爛的食物
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 356482,
	},
	{
		-- 聖光裂片撤退
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 357019,
	},
	{
		-- 不許進入！
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 357799,
	},
}

local mapIds = { 1989, 1990, 1991, 1992 }

AD:AddData("Tazavesh: Streets of Wonder", mistakes, mapIds)
