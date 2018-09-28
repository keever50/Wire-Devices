WireToolSetup.setCategory( "Wire Devices/Memory" )
WireToolSetup.open( "floppydrive", "Floppy Drive", "gmod_wire_floppydrive", nil, "Floppydrives" )

if CLIENT then
	language.Add( "Tool.wire_floppydrive.name", "Floppy Drive Tool (Wire)" )
	language.Add( "Tool.wire_floppydrive.desc", "Spawns a Floppy Drive to store or read data from floppies." )
	language.Add( "Tool.wire_floppydrive.note", "Press E on the drive to take nearby floppies." )
	TOOL.Information = { { name = "left", text = "Create a " .. TOOL.Name } }

	--The panel. 
	local FloppyDriveModels =  --PLACEHOLDERS .-.
	{
		["models/props_c17/consolebox01a.mdl"] = true,
		["models/props_c17/consolebox03a.mdl"] = true,
		["models/props_lab/reciever01a.mdl"] = true,
		["models/hunter/plates/plate025x025.mdl"] = true,
		["models/hunter/plates/plate05x05.mdl"] = true,
		["models/props_c17/consolebox05a.mdl"] = true
	}
	function TOOL.BuildCPanel( panel )
		WireDermaExts.ModelSelect(panel, "wire_floppydrive_model", FloppyDriveModels, 2)
		panel:Help("#Tool.wire_floppydrive.note")
	end	
	--

	WireToolSetup.setToolMenuIcon( "icon16/drive_disk.png" )
end
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

TOOL.ClientConVar = 
{
	model = "models/jaanus/wiretool/wiretool_gate.mdl"
}

if SERVER then

end



	

