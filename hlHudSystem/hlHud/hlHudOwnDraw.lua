hlHudOwnDraw = {};
--simple draw Real Day and Time over 2 lines

function hlHudOwnDraw.setHud(args)
	if args == nil or type(args) ~= "table" or args.typPos == nil or args.inArea == nil then return;end;
	local hud = g_currentMission.hlHudSystem.hud[args.typPos];
	--if hud ~= nil then hud.clickAreas = {};end;
	if hud ~= nil and hud.visibleDraw then
		local x, y, w, h = hud:getScreen();			
			
		local mW = w/2;
		local mH = h/2;
		
		local txt = "99:99"			
		local difTxtW = hud.screen.pixelW*3;
		local difTxtH = hud.screen.pixelH*3;
		
		function needsUpdateOwnFunction() --bsp. own Function
			if hud.needsUpdate or hud.ownTable.optiSize == nil then 
				local optiSize = g_currentMission.hlUtils.optiHeightSize((h/2)-difTxtH, txt, 0.020, true)
				hud.ownTable.optiSize = g_currentMission.hlUtils.optiWidthSize(w-difTxtW, txt, optiSize, true);
			end;			
			if hud.needsUpdate or hud.ownTable.lineHeight == nil then hud.ownTable.lineHeight = getTextHeight(hud.ownTable.optiSize, utf8Substr(txt, 0));end;							
			hud.needsUpdate = false;
		end;
		
		function needsUpdate() --HL Hud System Function
			if hud.needsUpdate or hud.ownTable.optiSize == nil then 
				hud.ownTable.optiSize = hud:getOptiSizeText( {typ="text", text=txt, line=2, width=w-difTxtW, height=h-difTxtH, textBold=true} );
				hud.ownTable.lineHeight = g_currentMission.hlUtils.getTextHeight(utf8Substr(txt, 0), hud.ownTable.optiSize, true);
			end;										
			hud.needsUpdate = false;
		end;
		
		--needsUpdateOwnFunction();
		needsUpdate();
		
		function getRealDay(large)
			local realDay = math.fmod(g_currentMission.hlUtils.getRealDay(false,true,false,false), 7);
			if realDay == 0 then realDay = 7;end;
			local day = g_i18n:getText("ui_dayShort".. tostring(realDay));	
			if large then day = g_i18n:getText("ui_financesDay".. tostring(realDay));end;
			return tostring(day);
		end;
		
		local realTime = g_currentMission.hlUtils.getRealTime(true,true);
		local realDay = getRealDay(false);
		setTextAlignment(RenderText.ALIGN_CENTER);
		setTextBold(true);
		if hud.ownTable.viewColor == 1 then --simple switch color bsp.
			setTextColor(unpack(g_currentMission.hlUtils.getColor("green", true)));		
		elseif hud.ownTable.viewColor == 2 then
			setTextColor(unpack(g_currentMission.hlUtils.getColor("orange", true)));
		elseif hud.ownTable.viewColor == 3 then
			setTextColor(unpack(g_currentMission.hlUtils.getColor("khaki", true)));
		elseif hud.ownTable.viewColor == 4 then
			setTextColor(unpack(g_currentMission.hlUtils.getColor("ls22", true)));
		elseif hud.ownTable.viewColor == 5 then
			setTextColor(unpack(g_currentMission.hlUtils.getColor("mangenta", true)));
		elseif hud.ownTable.viewColor == 6 then
			setTextColor(unpack(g_currentMission.hlUtils.getColor("yellowGreen", true)));	
		end;			
		renderText(x+mW,y+mH+(difTxtH/2), hud.ownTable.optiSize, tostring(realDay));
		renderText(x+mW,y+mH-(hud.ownTable.lineHeight)+(difTxtH/2), hud.ownTable.optiSize, tostring(realTime));
		
		setTextAlignment(0);
		setTextBold(false);
		setTextColor(1,1,1,1);			
		
	end;	
end;