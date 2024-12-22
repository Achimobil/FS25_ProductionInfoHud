hlCamBoxXml = {};

function hlCamBoxXml:loadBox(name)
	if name == "hlHudSystem_CameraBox" then
		local box = g_currentMission.hlHudSystem.hlBox.generate( {name=name, width=100, height=100, info="hlHudSystem\nHudSystem CameraBox", displayName="HudSystem Show CameraBox", autoZoomOutIn="icon"} );
		box.onDraw = hlCamBoxDraw.setBox;
		box.canDraw = hlCamBoxDraw.canDrawBox;		
		box.resetBoundsByDragDrop = false;
		box.overlays.settingIcons.save.visible = false; --save over global icon
		box.overlays.settingIcons.help.visible = false; 
		box.overlays.settingIcons.setting.visible = false;
		box.overlays.settingIcons.up.visible = false; --for viewExtraLine
		box.overlays.settingIcons.down.visible = false; --for viewExtraLine
		box.isHelp = false;		
		box.autoZoomOutIn = "icon"; --replace save xml value
		box.canAutoClose = false; --replace save xml value
		box.show = false;
		hlCamBox:generate(box);
	end;
end;