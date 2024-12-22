hlHudOwnXml = {};

function hlHudOwnXml:defaultValues(hud)
	hud.ownTable.viewColor = {1,1,6}; --is,min,max -own value for text color 1-6
end;

function hlHudOwnXml:onLoadXml(hud, Xml, xmlNameTag)
	if hud.ownTable.viewColor == nil then hlHudOwnXml:defaultValues(hud);end;	
	if Xml ~= nil and xmlNameTag ~= nil then	
		if getXMLInt(Xml, xmlNameTag.."#viewColor") ~= nil then 
			hud.ownTable.viewColor[1] = getXMLInt(Xml, xmlNameTag.. "#viewColor");
			if hud.ownTable.viewColor[1] > hud.ownTable.viewColor[3] or hud.ownTable.viewColor[1] < hud.ownTable.viewColor[2] then hud.ownTable.viewColor[1] = 1;end;
		else
			return; --first config not found
		end;
	end;	
end;

function hlHudOwnXml.onSaveXml(hud, Xml, xmlNameTag)
	setXMLInt(Xml, xmlNameTag.."#viewColor", hud.ownTable.viewColor[1]);
end;

