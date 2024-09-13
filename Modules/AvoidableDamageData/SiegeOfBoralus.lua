local W, F, L, P = unpack(select(2, ...))
local AD = W:GetModule("AvoidableDamage")

local mistakes = {
	{
		-- 兇蠻風暴 (鐵潮劫掠者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 275775,
	},
	{
		-- 燃燒焦油 (黑油炸彈客)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 256663,
	},
	{
		-- 巨力重拳 (骨頭幫執行者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 256627,
	},
	{
		-- 香蕉狂怒 (污鼠會海盜)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 274941,
	},
	{
		-- 粉碎猛擊 (污鼠會毀滅者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 272713,
	},
	{
		-- 鋼鐵砲雨 (艾胥凡偵察兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 272140,
	},
	{
		-- 踐踏 (艾胥凡指揮官)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 272874,
	},
	{
		-- 標記轟炸 (艾胥凡偵察兵, 恐怖船長洛克伍德)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 272426,
	},
	{
		-- 猛擊 (艾胥凡砲手)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 268260,
	},
	{
		-- 重斬 (鐵潮斬擊者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 257292,
	},
	{
		-- 水密外殼 (鐵潮造浪者)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 257069,
	},
	-- 首領
	{
		-- 重擊手 (喬巴‧紅鉤)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 273681,
	},
	{
		-- 肉鉤 (喬巴‧紅鉤)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 257431,
	},
	{
		-- 恐怖砲轟 (恐怖船長洛克伍德)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 268443,
	},
	{
		-- 淨空甲板 (恐怖船長洛克伍德)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 269029,
	},
	{
		-- 潮汐奔騰 (哈達爾‧黑淵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 276068,
	},

	{
		-- 粉碎浪潮 (哈達爾‧黑淵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 261565,
	},
	{
		-- 破浪 (哈達爾‧黑淵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 257883,
	},
	{
		-- 鹽水池 (哈達爾‧黑淵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 257886,
	},
	{
		-- 維克高斯之怒 (維克高斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 277535,
	},
	-- testing spells from EM
	{
		-- 燃燒焦油 (黑油炸彈客)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 256660,
		testing = true,
	},
	{
		-- 火砲彈幕
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 257585,
		testing = true,
	},
	{
		-- 滅絕 (維克高斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 269484,
		testing = true,
	},
	{
		-- 深淵呼喚 (維克高斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 270187,
		testing = true,
	},
	{
		-- 深淵呼喚 (維克高斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 270484,
		testing = true,
	},
	{
		-- 香蕉狂怒 (污鼠會海盜)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 272546,
		testing = true,
	},
	{
		-- 沉重火炮 (喬巴‧紅鉤)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 273716,
		testing = true,
	},
	{
		-- 沉重火藥
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 273718,
		testing = true,
	},
	{
		-- 腐敗之水 (維克高斯)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 275051,
		testing = true,
	},
	{
		-- 潮汐奔騰 (哈達爾‧黑淵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 276042,
		testing = true,
	},
	{
		-- 鋼鐵砲雨 (艾胥凡偵察兵)
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 277432,
		testing = true,
	},
	{
		-- 碾碎之擁
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 280485,
		testing = true,
	},
	{
		-- 火砲彈幕
		type = AD.MISTAKE.SPELL_DAMAGE,
		spell = 280679,
		testing = true,
	},
}

local mapIds = { 1162 }

AD:AddData("Siege of Boralus", mistakes, mapIds)
