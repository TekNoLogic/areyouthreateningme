
local defaults, db = {x = 0, y = -100, anchor = "CENTER", useactualperc = false}
local obj = LibStub("LibDataBroker-1.1"):NewDataObject("AreYouThreateningMe", {text = "0%"})


local f = CreateFrame("Button", nil, UIParent)
f:SetHeight(24)

f:SetMovable(true)
f:RegisterForDrag("LeftButton")
f:SetClampedToScreen(true)

f:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16, edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 16, insets = {left = 5, right = 5, top = 5, bottom = 5}})
f:SetBackdropColor(0.09, 0.09, 0.19, 0.5)
f:SetBackdropBorderColor(0.5, 0.5, 0.5, 0.5)

f.text = f:CreateFontString(nil, nil, "GameFontNormalSmall")
f.text:SetPoint("CENTER")
f.text:SetText(obj.text or "AreYouThreateningMe")
f:SetWidth(f.text:GetStringWidth() + 8)
function f:LibDataBroker_AttributeChanged_AreYouThreateningMe_text(event, name, key, value)
	self.text:SetText(value)
	self:SetWidth(self.text:GetStringWidth() + 8)
end
LibStub("LibDataBroker-1.1").RegisterCallback(f, "LibDataBroker_AttributeChanged_AreYouThreateningMe_text")


f:SetScript("OnEvent", function(self)
	AreYouThreateningMeDB = setmetatable(AreYouThreateningMeDB or {}, {__index = defaults})
	db = AreYouThreateningMeDB

	self:SetPoint("TOP", UIParent, db.anchor, db.x, db.y)

	self:SetScript("OnDragStart", self.StartMoving)
	self:SetScript("OnDragStop", function(self)
		self:StopMovingOrSizing()
		db.anchor, db.x, db.y = "BOTTOMLEFT", self:GetCenter()
	end)

	self:UnregisterEvent("PLAYER_LOGIN")
	self:SetScript("OnEvent", function(self, event, unit)
		if event == "PLAYER_LOGOUT" then
			for i,v in pairs(defaults) do if db[i] == v then db[i] = nil end end
			return
		end

		if unit ~= "player" and unit ~= "target" then return end

		local a, status, threatPct1, threatPct2, rawthreat = UnitDetailedThreatSituation("player", "target")
		local r, g, b = 1,1,1
		if status and status > 0 then r, g, b = GetThreatStatusColor(status) end
		obj.text = string.format("|cff%02x%02x%02x%d%%|r", r*255, g*255, b*255, db.useactualperc and threatPct2 or threatPct1 or 0)
	end)
	self:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self:RegisterEvent("PLAYER_LOGOUT")
end)
f:RegisterEvent("PLAYER_LOGIN")
