AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName		= "Wire Floppy"
ENT.Author      	= "Aeralius"
ENT.WireDebugName 	= "Portable and dupable floppy"

if CLIENT then return end --no client.

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	--extra properties
	local phys = self:GetPhysicsObject()
	phys:SetMass(1)
	--self:SetMaterial( "aeralius/floppy_3-5", false )
	
	--defaults
	self.properties = { --
		sectors = 1000,
		sectorsize = 512, --bytes
		tracks = 10,
	}
	self.properties.tracks = math.ceil( self.properties.sectors / 100 )
	self.properties.sectors_per_track = self.properties.sectors/self.properties.tracks
	--PrintTable(self.properties)
	
end

function ENT:Setup( label, writeprotection, colorr, colorg, colorb, hasauthor, authorname, sectors, dupes )
	--dims
	self.sectors = sectors
	self.properties.sectors = self.sectors
	self.properties.tracks = math.ceil( self.properties.sectors / 100 )
	self.properties.sectors_per_track = self.properties.sectors/self.properties.tracks	
	
	self.writeprotection = writeprotection
	self.colorr = colorr
	self.colorg = colorg 
	self.colorb = colorb
	self.hasauthor = hasauthor
	self.authorname = authorname
	self.dupes = dupes
	--perma author
	if self.permaauthor == nil then 
		self.permaauthor = self.authorname
	end

	--label
	self.label = label
	self.wptext = "??"
	if writeprotection == 1 then 
		self.wptext = "Writing disabled."
	else
		self.wptext = "Writing enabled."
	end
	
	if self.permaauthor != nil then
		self:SetOverlayText("Floppy \n".. self.label .. "\n" .. "PermaMarker: " .. self.permaauthor .. "\n" .. self.wptext  )
	end
	
	if self.colorr != nil and self.colorg != nil and self.colorb != nil then
		self:SetColor( Color( self.colorr, self.colorg, self.colorb, 255 ) )
	end
	--memory
	if not self.memory then --if memory does not exist, define memory and its sector table. + failsafe
		self.memory = { sector = { } }
		setmetatable( self.memory.sector,{
			__index = function(t,k) return {} end,
			--__newindex = print
		})
	end 
	
	self.SetupDone = true
	
end

function ENT:Think()
	--print(  self.owner ) 
	--print( self.permaauthor )
	if not self.dupes then self.dupes = 1 end
	if self.DupeDone != nil and self.SetupDone != nil and self.Overlayyed == nil then
		self.dupes = self.dupes + 1
		self:SetOverlayText("Floppy \n".. self.label .. "\n" .. "PermaMarker: " .. self.permaauthor .. "\n" .. self.wptext  )
		self.Overlayyed = true
		--print( self:GetOwner() )
	end
end

--duping stuff--
function ENT:BuildDupeInfo()
	local info = self.BaseClass.BuildDupeInfo( self ) or {}
	info.memory = self.memory
	info.permaauthor = self.permaauthor
	info.dupes = self.dupes 
	return info
end

function ENT:ApplyDupeInfo(ply, ent, info, GetEntByID)
	self.memory = info.memory
	self.permaauthor = info.permaauthor
	self.dupes = info.dupes
	self.DupeDone = true
end

duplicator.RegisterEntityClass( "gmod_wire_floppy", WireLib.MakeWireEnt, "Data", "label", "writeprotection", "colorg", "colorg", "colorb")

