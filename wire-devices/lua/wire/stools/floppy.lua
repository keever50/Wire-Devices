WireToolSetup.setCategory( "Wire Devices/Memory" )
WireToolSetup.open( "Floppy", "Floppy", "gmod_wire_floppy", nil, "Floppies" )

TOOL.ClientConVar = 
{
	model = "models/jaanus/wiretool/wiretool_gate.mdl",
	label = "Unnamed",
	writeprotection = 0,
	colorr = 50,
	colorg = 50,
	colorb = 50,
	hasauthor = 0,
	authorname = "Unknown",
	sectors = 1000
}

if CLIENT then
	language.Add( "Tool.wire_floppy.name", "Floppy Tool (Wire)" )
	language.Add( "Tool.wire_floppy.desc", "Spawns a Floppy to store data using the Floppy drive." )
	language.Add( "Tool.wire_floppy.label", "Label:" )
	language.Add( "Tool.wire_floppy.writeprotection", "write protection" )
	language.Add( "Tool.wire_floppy.colour", "Floppy colour" )
	language.Add( "Tool.wire_floppy.hasauthor", "Author?" ) 
	language.Add( "Tool.wire_floppy.authorinfo", "This text stays on the floppy forever. You are unable to change this later!" )
	language.Add( "Tool.wire_floppy.authorname", "PermaMarker:" ) 
	language.Add( "Tool.wire_floppy.sectors", "Sectors: " ) 
	
	TOOL.Information = { { name = "left", text = "Create a " .. TOOL.Name } }
	
	--The panel. 
	local FloppyModels = 
	{
		["models/neatro/diskette.mdl"] = true,
		["models/hunter/plates/plate025x025.mdl"] = true --actually a placeholder
	}
	function TOOL.BuildCPanel( panel )
		WireDermaExts.ModelSelect(panel, "wire_floppy_model", FloppyModels, 1)
		panel:AddControl("Color", {
			Label = "#Tool.wire_floppy.colour",
			Red = "wire_floppy_colorr",
			Green = "wire_floppy_colorg",
			Blue = "wire_floppy_colorb",
			ShowAlpha = "0",
			ShowHSV = "1",
			ShowRGB = "1",
			Multiplier = "1"
		})			
		panel:TextEntry("#Tool.wire_floppy.label", "wire_floppy_label")
		panel:TextEntry("#Tool.wire_floppy.authorname", "wire_floppy_authorname")
		panel:Help("#Tool.wire_floppy.authorinfo")
		panel:CheckBox("#Tool.wire_floppy.writeprotection", "wire_floppy_writeprotection")
		--panel:CheckBox("#Tool.wire_floppy.hasauthor", "wire_floppy_hasauthor") --we dont really need this, so it remains unused.
		panel:NumSlider("#Tool.wire_floppy.sectors", "wire_floppy_sectors", 0, 2000, 0)
		

		
	end	

	--


	
end

WireToolSetup.setToolMenuIcon( "icon16/disk.png" )
WireToolSetup.BaseLang()
WireToolSetup.SetupMax( 20 )

if SERVER then	
	CreateConVar('sbox_maxwire_floppies', 20)
	function TOOL:GetConVars() 
		return
			self:GetClientInfo( "label" ),
			self:GetClientNumber( "writeprotection" ),
			self:GetClientNumber( "colorr" ),
			self:GetClientNumber( "colorg" ),
			self:GetClientNumber( "colorb" ),	
			self:GetClientNumber( "hasauthor" ),
			self:GetClientInfo( "authorname" ),
			self:GetClientNumber( "sectors" )
	end
end



	

