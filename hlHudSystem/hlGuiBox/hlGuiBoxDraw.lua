hlGuiBoxDraw = {};

function hlGuiBoxDraw:show()
	local ingameMapLarge = g_currentMission.hlUtils.getIngameMap();
	if #g_currentMission.hlHudSystem.guiBox > 0 and not ingameMapLarge then
		local guiBoxDragDrop = g_currentMission.hlUtils.isMouseCursor and g_currentMission.hlUtils.dragDrop.on and g_currentMission.hlUtils.dragDrop.what == "_hlGuiBox_" and g_currentMission.hlUtils.dragDrop.system == "hlHudSystem";
		local showGui = false;
		for pos=1, #g_currentMission.hlHudSystem.guiBox do
			if showGui then break;end; --not multiple view
			local guiBox = g_currentMission.hlHudSystem.guiBox[pos];
			if guiBox ~= nil then guiBox.clickAreas = {};end;
			if guiBox ~= nil and guiBox.show then				
				hlGuiBoxDraw:checkBounds(guiBox);
				guiBox.screen.bounds[4] = #guiBox.lines+1; --+#guiBox.modLines;
				local x, y, w, h = guiBox:getScreen();
				local setGuiBoxClickArea = false; --total Gui Box
				--if guiBox.needsUpdate then guiBox:resetDimension();guiBox.needsUpdate = false;end;
				showGui = true;
				local size = guiBox.screen.size.zoomOutIn.text[1];
				local textColor = "";
				local iconColor = "";
				local overlayGroup = guiBox.overlays["defaultIcons"]["guiBox"];
				local overlayByName = guiBox.overlays.byName["defaultIcons"]["guiBox"];
				local bgFrame = overlayGroup[overlayByName["bgFrame"]];
				local bgLine = overlayGroup[overlayByName["bgLine"]]; --area click lines			
				local frame = overlayGroup[overlayByName["frame"]];				
				local upDown = overlayGroup[overlayByName["upDown"]];
				local stateOn = overlayGroup[overlayByName["on"]];
				local stateOff = overlayGroup[overlayByName["off"]];
				--local closeGui = overlayGroup[overlayByName["close"]];
				local overlay = overlayGroup[overlayByName["bg"]];
				g_currentMission.hlUtils.setOverlay(overlay, x, y, w, h);
				overlay:render();
				local thisDragDrop = guiBoxDragDrop and g_currentMission.hlUtils.dragDrop.where == "dragDrop_" and g_currentMission.hlUtils.dragDrop.typPos == pos;				
				local thisDragDropWH = guiBoxDragDrop and g_currentMission.hlUtils.dragDrop.where == "dragDropWH_" and g_currentMission.hlUtils.dragDrop.typPos == pos;
				if thisDragDrop or thisDragDropWH then
					if thisDragDrop then
						g_currentMission.hlHudSystem.screen:setDragDropPosition( {difHeight=-h} );
					elseif thisDragDropWH then
						g_currentMission.hlHudSystem.screen:setDragDropWidthHeight( {} );						
					end;
				end;
				if not thisDragDrop then						
					local distance = guiBox:getSize( {"distance"} );
					local inArea = overlay.mouseInArea();
					function setGuiBoxArea()
						if not g_currentMission.hlUtils:disableInArea() then hlGuiBoxDraw:clickAreas( {overlay.x, overlay.x+overlay.width, overlay.y, overlay.y+overlay.height, whatClick="_hlGuiBox_", whereClick="guiBox_", typPos=pos} );end;
					end;
					if g_currentMission.hlUtils.isMouseCursor then
						setGuiBoxClickArea = hlHudSystemDraw:showGuiBoxIcons( {typ=guiBox, typName="guiBox", typPos=pos, inArea=inArea} );
					end;
					if inArea and setGuiBoxClickArea then setGuiBoxArea();end;				
					local posX = x;
					local posY = y+h-guiBox.titleHeight;
					local width = w-(distance.textWidth*2);
					local width1 = width/1.6;
					local width2 = width-width1;
					function setTitle()
						if type(guiBox.color.title) == "string" then textColor = g_currentMission.hlUtils.getColor(guiBox.color.title, true);else textColor = guiBox.color.title;end;
						local optiSize = g_currentMission.hlUtils.optiWidthSize(width-(guiBox.iconWidth*2), guiBox.title, size+0.002, true);
						setTextAlignment(1);
						setTextBold(true);					
						setTextColor(unpack(textColor));
						renderText(posX+width/2, posY, optiSize, guiBox.title);
						setTextColor(1, 1, 1, 1);					
						setTextBold(false);
						setTextAlignment(0);
					end;
					function setLines()
						local bounds1 = guiBox.screen.bounds[1];
						local bounds2 = guiBox.screen.bounds[2];
						for t=bounds1, bounds2 do
							local orgLine = guiBox.lines[t];
							local line = nil;
							if orgLine ~= nil then line = {};end;
							if line ~= nil and orgLine.getLine ~= nil then
								if type(orgLine.getLine) == "function" then
									line = orgLine.getLine( {lineCallSequence=orgLine.lineCallSequence,line=t,guiBox=guiBox} ); 
								else
									line = guiBox.getLine( {lineCallSequence=orgLine.lineCallSequence,line=t,guiBox=guiBox} );
								end;
							elseif line ~= nil and guiBox.getLine ~= nil then 								
								line = guiBox.getLine( {lineCallSequence=orgLine.lineCallSequence,line=t,guiBox=guiBox} );								
							end;
							
													
							if line == nil and guiBox.lines[t] ~= nil then line = guiBox:getErrorLine(t, guiBox.lines[t].modLine ~= nil);end; --default error line
							if line == nil or posY < y then break;end;
							if posY-(guiBox.iconHeight/1.3) < y then break;end; --check overlap sizeWidthHeight Icon
							line = guiBox:formatLine(guiBox, line);
							----
							local nextPosX = posX+distance.textWidth;								
							local text1 = line.text[1];
							local text2 = line.text[2];
							if line.oneClick ~= nil and line.oneClick then
								g_currentMission.hlUtils.setOverlay(bgLine, nextPosX, posY-(distance.textHeight/2), width, guiBox.iconHeight);
							else
								g_currentMission.hlUtils.setOverlay(bgLine, nextPosX, posY-(distance.textHeight/2), width1, guiBox.iconHeight);
							end;
							inIconArea = inArea and bgLine.mouseInArea();							
							local isHeadLine = line.typ == "headline";						
							if inIconArea then
								textColor = g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.inArea, true);
							else								
								if type(text1.color) == "string" then textColor = g_currentMission.hlUtils.getColor(text1.color, true);else textColor = text1.color;end;								
							end;
							if isHeadLine then setTextAlignment(1);nextPosX = posX+(width/2);end;
							setTextColor(unpack(textColor));
							local dropText = false;
							if text1.blinking then
								if g_currentMission.hlUtils.runsTimer("1sec", true) then
									dropText = true;
								end;
							else
								dropText = true;
							end;
							if not isHeadLine then
								local lineIcon = overlayGroup[overlayByName["lineIcon"]];
								if line.icon ~= nil then local tempLineIcon = line.icon;if tempLineIcon ~= nil then lineIcon = tempLineIcon;end;end;								
								g_currentMission.hlUtils.setOverlay(lineIcon, nextPosX, posY-(distance.textHeight/2), guiBox.iconWidth, guiBox.iconHeight, guiBox.iconHeight+(distance.textHeight/2));
								if line.iconColor ~= nil then 
									if type(line.iconColor) == "string" then iconColor = g_currentMission.hlUtils.getColor(line.iconColor, true);else iconColor = line.iconColor;end;
									g_currentMission.hlUtils.setBackgroundColor(lineIcon, iconColor);
								else
									g_currentMission.hlUtils.setBackgroundColor(lineIcon, g_currentMission.hlUtils.getColor("white", true));
								end;
								local dropIcon = false;
								if line.iconBlinking ~= nil then
									if (line.iconBlinking and g_currentMission.hlUtils.runsTimer("1sec", true)) or not line.iconBlinking then dropIcon = true;end;
								else
									dropIcon = true;
								end;	
								if dropIcon then lineIcon:render();end;
								nextPosX = nextPosX+guiBox.iconWidth+distance.textWidth;
							end;
							if dropText then
								local trim = "."
								if text1.text:len() < 2 then trim = "";end;
								local maxWidth = width1-guiBox.iconWidth;
								if isHeadLine then maxWidth = width-(guiBox.iconWidth*2);end;
								if text2 == nil and not isHeadLine then maxWidth = maxWidth+width2;end;
								local text = g_currentMission.hlUtils.getTxtToWidth(text1.text, text1.size, maxWidth, false, trim, text1.bold);
								if text1.bold then setTextBold(true);end;
								renderText(nextPosX, posY, text1.size, text);								
							end;
							setTextColor(1, 1, 1, 1);
							setTextAlignment(0);							
							setTextBold(false);
							if inIconArea then 
								local helpText = "";								
								if text1.helpText ~= nil and text1.helpText:len() > 0 then helpText = text1.helpText;elseif line.helpText ~= nil and line.helpText:len() > 0 then helpText = line.helpText;end;
								if helpText ~= nil and helpText:len() > 0 then g_currentMission.hlHudSystem:addTextDisplay( {txt=helpText, maxLine=0} );end;								
								if text1.acceptsMouse ~= nil then g_currentMission.hlHudSystem:addMouseAcceptsInfo( {acceptsMouse=text1.acceptsMouse}, true );elseif line.acceptsMouse ~= nil then g_currentMission.hlHudSystem:addMouseAcceptsInfo( {acceptsMouse=line.acceptsMouse}, true );end;
							end;
							local areaClick = "text1_";
							if line.oneClick ~= nil and line.oneClick then areaClick = "line_";end;
							if not g_currentMission.hlUtils:disableInArea() and inArea then guiBox:setClickArea( {bgLine.x, bgLine.x+bgLine.width, bgLine.y, bgLine.y+bgLine.height, onClick=line.onClick, whatClick="guiBox_", typPos=pos, whereClick="guiLine_", areaClick=areaClick, lineCallSequence=orgLine.lineCallSequence, line=t, ownTable=line.ownTable or {}} );end;		
							----
							if not isHeadLine and text2 ~= nil then
								nextPosX = nextPosX+width1-guiBox.iconWidth;
								if line.oneClick == nil or not line.oneClick then
									g_currentMission.hlUtils.setOverlay(bgLine, nextPosX, posY-(distance.textHeight/2), width2, guiBox.iconHeight);
									inIconArea = inArea and bgLine.mouseInArea();								
								end;
								g_currentMission.hlUtils.setOverlay(bgFrame, nextPosX-distance.textWidth, posY-(distance.textHeight/2), w-(width1)-distance.textWidth, guiBox.iconHeight+(distance.textHeight/2));
								bgFrame:render();								
								local setFrame = line.setFrame ~= nil and line.setFrame;								
								if line.typ ~= "string" or setFrame then
									g_currentMission.hlUtils.setOverlay(frame, nextPosX-distance.textWidth, bgFrame.y, guiBox.iconWidth+distance.textWidth, guiBox.iconHeight+(distance.textHeight/2));
									frame:render();
									if line.typ == "booleanNumber" or line.typ == "booleanFrame" then
										g_currentMission.hlUtils.setOverlay(frame, frame.x+frame.width, bgFrame.y, frame.width, frame.height);
										frame:render();
									end;
								end;
								if line.frameIcon ~= nil then
									g_currentMission.hlUtils.setOverlay(line.frameIcon, frame.x+(frame.width/2)-(guiBox.iconWidth/2), frame.y+(frame.height/2)-(guiBox.iconHeight/2), guiBox.iconWidth, guiBox.iconHeight);									
									if line.frameIconColor ~= nil then 
										if type(line.frameIconColor) == "string" then iconColor = g_currentMission.hlUtils.getColor(line.frameIconColor, true);else iconColor = line.frameIconColor;end;
										g_currentMission.hlUtils.setBackgroundColor(line.frameIcon, iconColor);
									else
										g_currentMission.hlUtils.setBackgroundColor(line.frameIcon, g_currentMission.hlUtils.getColor("white", true));
									end;									
									line.frameIcon:render();
								end;
								if line.typ == "booleanNumber" or line.typ == "booleanFrame" then
									if text2.state then
										g_currentMission.hlUtils.setOverlay(stateOn, frame.x-(frame.width)+(frame.width/2)-(guiBox.iconWidth/2), frame.y+(frame.height/2)-(guiBox.iconHeight/2), guiBox.iconWidth, guiBox.iconHeight);
										stateOn:render();
									else
										g_currentMission.hlUtils.setOverlay(stateOff, frame.x-(frame.width)+(frame.width/2)-(guiBox.iconWidth/2), frame.y+(frame.height/2)-(guiBox.iconHeight/2), guiBox.iconWidth, guiBox.iconHeight);
										stateOff:render();
									end;
									if line.typ == "booleanNumber" then
										g_currentMission.hlUtils.setOverlay(upDown, frame.x+(frame.width/2)-(guiBox.iconWidth/2), frame.y+(frame.height/2)-(guiBox.iconHeight/2), guiBox.iconWidth, guiBox.iconHeight);
										upDown:render();
									end;
								elseif line.typ == "number" then									
									g_currentMission.hlUtils.setOverlay(upDown, frame.x+(frame.width/2)-(guiBox.iconWidth/2), frame.y+(frame.height/2)-(guiBox.iconHeight/2), guiBox.iconWidth, guiBox.iconHeight);
									upDown:render();
								elseif line.typ == "boolean" then
									if text2.state then
										g_currentMission.hlUtils.setOverlay(stateOn, frame.x+(frame.width/2)-(guiBox.iconWidth/2), frame.y+(frame.height/2)-(guiBox.iconHeight/2), guiBox.iconWidth, guiBox.iconHeight);
										stateOn:render();
									else
										g_currentMission.hlUtils.setOverlay(stateOff, frame.x+(frame.width/2)-(guiBox.iconWidth/2), frame.y+(frame.height/2)-(guiBox.iconHeight/2), guiBox.iconWidth, guiBox.iconHeight);
										stateOff:render();
									end;									
								end;
								if line.typ == "booleanNumber" or line.typ == "booleanFrame" then
									nextPosX = nextPosX+(frame.width*2)+distance.textWidth;
								else
									nextPosX = nextPosX+frame.width+distance.textWidth;
								end;
								if inIconArea then
									textColor = g_currentMission.hlUtils.getColor(g_currentMission.hlHudSystem.overlays.color.inArea, true);
								else
									if type(text2.color) == "string" then textColor = g_currentMission.hlUtils.getColor(text2.color, true);else textColor = text2.color;end;
								end;
								setTextColor(unpack(textColor));
								dropText = false;
								if text2.blinking then
									if g_currentMission.hlUtils.runsTimer("1sec", true) then
										dropText = true;
									end;
								else
									dropText = true;
								end;
								if dropText then
									local trim = "."
									local text = text2.text;									
									if text:len() == 0 and line.typ == "boolean" then
										if text2.state then text = g_i18n:getText("ui_on");else text = g_i18n:getText("ui_off");end;
									end;
									if text:len() < 2 then trim = "";end;
									local maxWidth = width2;
									if line.typ ~= "string" or setFrame then 
										if line.typ == "booleanNumber" then
											maxWidth = maxWidth-(guiBox.iconWidth*2);
										else
											maxWidth = maxWidth-guiBox.iconWidth;
										end;
									end;
									text = g_currentMission.hlUtils.getTxtToWidth(text, text2.size, maxWidth, false, trim, text2.bold);
									if text2.bold then setTextBold(true);end;
									renderText(nextPosX, posY, text2.size, text);									
								end;
								setTextColor(1, 1, 1, 1);
								setTextAlignment(0);
								setTextBold(false);
								if inIconArea then 
									local helpText = "";
									if text2.helpText ~= nil and text2.helpText:len() > 0 then helpText = text2.helpText;elseif line.helpText ~= nil and line.helpText:len() > 0 then helpText = line.helpText;end;
									if helpText ~= nil and helpText:len() > 0 then g_currentMission.hlHudSystem:addTextDisplay( {txt=helpText, maxLine=0} );end;
									if text2.acceptsMouse ~= nil then g_currentMission.hlHudSystem:addMouseAcceptsInfo( {acceptsMouse=text2.acceptsMouse}, true );elseif line.acceptsMouse ~= nil then g_currentMission.hlHudSystem:addMouseAcceptsInfo( {acceptsMouse=line.acceptsMouse}, true );end;
								end;
								if line.oneClick == nil or not line.oneClick then
									if not g_currentMission.hlUtils:disableInArea() and inArea then guiBox:setClickArea( {bgLine.x, bgLine.x+bgLine.width, bgLine.y, bgLine.y+bgLine.height, onClick=line.onClick, whatClick="guiBox_", typPos=pos, whereClick="guiLine_", areaClick="text2_", lineCallSequence=orgLine.lineCallSequence, line=t, ownTable=line.ownTable or {}} );end;
								end;
							end;
							----
							posY = posY-guiBox.lineHeight+distance.textHeight;							
						end;
					end;
					setTitle();
					posY = posY-guiBox.lineHeight+distance.textHeight;
					if guiBox.screen.bounds[1] > 0 then setLines();hlHudSystemDraw:showBoundsInfo( {typ=guiBox, typName="guiBox"} );end;
				end;
				hlGuiBoxDraw:checkCorrectBounds(guiBox);
			end;
		end;
	end;
end;

function hlGuiBoxDraw:checkBounds(guiBox)
	if not guiBox.screen.canBounds.on then return;end;
	if guiBox.screen.bounds[1] == -1 then
		guiBox.screen:generateBounds();
	else
		guiBox.screen:checkCorrectBounds();
	end;
end;

function hlGuiBoxDraw:checkCorrectBounds(guiBox)
	guiBox.screen:checkCorrectBounds();
end;

function hlGuiBoxDraw:clickAreas(args)		
	if g_currentMission.hlHudSystem.areas[args.whatClick] == nil then g_currentMission.hlHudSystem.areas[args.whatClick] = {};end;
	g_currentMission.hlHudSystem.areas[args.whatClick][#g_currentMission.hlHudSystem.areas[args.whatClick]+1] = {
		args[1]; --posX
		args[2]; --posX1
		args[3]; --posY
		args[4]; --posY1		
		whatClick = args.whatClick;			
		whereClick = args.whereClick or "";
		areaClick = args.areaClick or "";		
		overlay = args.overlay;
		typ = args.typ or "guiBox";
		typPos = args.typPos or 0;
		ownTable = args.ownTable;
	};	
end;