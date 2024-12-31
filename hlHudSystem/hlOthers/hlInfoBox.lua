hlInfoBox = {};

function hlInfoBox:update(dt)
	local infoBox = g_currentMission.hlHudSystem.infoBox;
	if infoBox ~= nil then
		for i = #infoBox.warnings, 1, -1 do
			local info = infoBox.warnings[i];
			info.duration = info.duration - dt;
			if info.duration < 0 then
				table.remove(infoBox.warnings, i);
			end;
		end;
	end;
end;

function hlInfoBox:draw()
    local infoBox = g_currentMission.hlHudSystem.infoBox;	
	if infoBox ~= nil then
		local numWarnings = #infoBox.warnings;
		if numWarnings == 0 then
			return;
		end;

		setTextWrapWidth(infoBox.maxTextWidth);

		local posX, posY = infoBox:getPosition();
		local textSize = infoBox.textSize;
		local textOffsetY = infoBox.textOffsetY;

		local totalHeight = 0;
		for _, warning in ipairs(infoBox.warnings) do
			local text = warning.text;
			local textHeight = getTextHeight(textSize, text);

			totalHeight = totalHeight + textHeight + 2*infoBox.boxPaddingY + infoBox.boxOffsetY;
		end;

		totalHeight = totalHeight - infoBox.boxOffsetY;
		posY = posY + totalHeight*0.5;

		setTextBold(true);
		setTextAlignment(RenderText.ALIGN_LEFT);
		setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_MIDDLE);
		local alpha = 0.4 + 0.6 * IngameMap.alpha;
		
		for _, warning in ipairs(infoBox.warnings) do
			local color = warning.color or {1, 1, 0, alpha};
			setTextColor(unpack(color));
			local text = warning.text;
			local textWidth = getTextWidth(textSize, text);
			local textHeight = getTextHeight(textSize, text);

			local boxWidth = textWidth + infoBox.iconTextOffsetX + infoBox.icon.width + 2*infoBox.boxPaddingX;
			local boxHeight = math.max(textHeight + 2*infoBox.boxPaddingY, infoBox.icon.height+2*infoBox.boxPaddingY);
			local boxX = posX-boxWidth*0.5;
			local boxY = posY-boxHeight*0.5;

			drawFilledRectRound(boxX, boxY, boxWidth, boxHeight, 0.35, 0, 0, 0, 0.8); --uiScale,rgb a
			posY = posY - boxHeight;

			infoBox.icon:setPosition(boxX + infoBox.boxPaddingX, boxY + boxHeight*0.5 - infoBox.icon.height*0.5);
			infoBox.icon:render();

			renderText(infoBox.icon.x + infoBox.icon.width + infoBox.iconTextOffsetX, boxY + boxHeight*0.5 + textOffsetY, infoBox.textSize, text);

			posY = posY - infoBox.boxOffsetY;
		end;

		setTextAlignment(RenderText.ALIGN_LEFT);
		setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE);
		setTextColor(1, 1, 1, 1);
		setTextBold(false);
	end;
end;

function hlInfoBox:storeScaledValues(self)
    local offsetX, offsetY = self:scalePixelValuesToScreenVector(0, 0);
    local posX = 0.5 + offsetX;
    local posY = 0.6 + offsetY;
    self:setPosition(posX, posY);

    self.maxTextWidth = self:scalePixelToScreenWidth(600);
    self.textSize = self:scalePixelToScreenHeight(16);
    self.boxPaddingX, self.boxPaddingY = self:scalePixelValuesToScreenVector(20, 10);
    self.textOffsetY = self:scalePixelToScreenHeight(2);
    self.boxOffsetY = self:scalePixelToScreenHeight(6);
    self.iconTextOffsetX = self:scalePixelToScreenHeight(10);

    local iconWidth, iconHeight = self:scalePixelValuesToScreenVector(36, 36);
    self.icon:setDimension(iconWidth, iconHeight);
end;

function hlInfoBox:addInfo(text, duration, color, priority)
	local infoBox = g_currentMission.hlHudSystem.infoBox;	
	if infoBox ~= nil then
		local duration = duration or 200;
		local notSet = false
		for _, info in ipairs(infoBox.warnings) do
			if info.text == text or priority ~= nil and info.customIdentifier == priority then
				info.text = text;
				info.color = color;
				info.duration = duration;
				notSet = true;
			end
		end
		if not notSet then			
			table.insert(infoBox.warnings, {
				["text"] = text,
				["color"] = color,
				["duration"] = duration,
				["customIdentifier"] = priority
			});
		end;
	end;
end;
