AddCSLuaFile()
DEFINE_BASECLASS( "base_wire_entity" )
ENT.PrintName		= "Wire Floppy Drive"
ENT.Author      	= "Aeralius"
ENT.WireDebugName 	= "Floppy drive"

--[[ Hispeed addresses
	0: Contains floppy? (R) 
	1: Write Protection? (R)
	2: Lock(R/W) Locks the floppy in place. You dont have to set value but it prevents people from stealing your floppy. Usefull to prevent corruption.
	3: Force Eject(W*) Ejects the floppy, so you dont have to do it yourself. Lazy, but cool.
	4: Motor(R/W) This should be turned on when operating a floppy. Turn it off when you dont want constant floppy noise.
	5: Sector(R/W) This will move the head and target to the inserted value. When bieng read, it will return it's current target.
	6: Read(W*) Reads specific sector to buffer.
	7: Write(W*) Writes buffer to specific sector.
	8: Status(R/W) Listed below.
	9: Error(R/W) Listed below. You can write this for custom errors and to set it back to 0. It wont reset itself.
	10: Reset(W*) Sets every value to default.
	11: Sectors(R) Returns how many sectors the floppy has.
	512-1024: Buffer(R/W) All values between are bieng written or are the result of a read operation. NOTE: This will be automatically erased on R/W operations.
	512-512512: Memory (R/W) TEMPORARY
	
	*does not have to be a value. Simply writing to it will run the operation.
--]]

if CLIENT then return end --no client.

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.timecreated = SysTime()
	
	--wires
	self.Outputs = Wire_CreateOutputs(self, { "Memory" })
	
	--vars
	--self.memorysize = 1000 --sectors
	self.catchdistance = self:OBBMaxs()[1]+10 --its own size + a bit margin.
	self.headspeed = 1.5 --Seconds to travel across whole floppy.
	self.latancy = 0.03 --delay on each write and read.
	--defaults
	self.gotfloppy = false
	self.thefloppy = nil
	self.memory = {}
	self.lock = 0
	self.status = 1
	self.csector = 0
	self.ctrack = 0
	self.buffer = {}
	self.motor = 0
	--sounds 
	self.motorsound = CreateSound( self, "ambient/machines/machine2.wav" )
	self.headsound = CreateSound( self, "ambient/machines/fluorescent_hum_1.wav" )
	self.headsoundstop = CreateSound( self, "physics/metal/metal_computer_impact_soft3.wav" )
	
end

function ENT:Setup( ) --Is here just in case. 
	--label
	self:SetOverlayText("Floppy Drive \nFree")

end

function ENT:Use(ply)
	if self.lastuser != ply then --User only activates this once.
		self.lastuser = ply
		
		--Insert
		if self.gotfloppy == false then 
		
			--Search for floppies specific and checks distance.
			local search = ents.FindByClass( "gmod_wire_floppy" )
			local neardrives = ents.FindByClass( "gmod_wire_floppydrive" )
			for i, v in ipairs( search ) do 
				local ent = v 
				local Dist = ent:GetPos():Distance(self:GetCenterPos( ))
				if Dist <= self.catchdistance then 
				
					--check if any drive is closer. So it doesnt steal the wrong floppy.
					for i, v in ipairs( neardrives ) do 
						if v != self then
							local dDist = ent:GetPos():Distance( v:GetCenterPos() )
							if dDist < Dist then 
								self.ignorefloppy = true
								break
							end
						end
					end
					
					--If floppy is not ignored(nil) then catch it
					if self.ignorefloppy == nil then
						sound.Play( "buttons/weapon_confirm.wav", self:GetPos(), 75, 100 )
						self.gotfloppy = true
						self.thefloppy = ent
						self:TakeFloppy( )
						self:SetOverlayText("Floppy Drive \nContains floppy")
						--TEST. REMOVE--
						--self.thefloppy.memory[1]=58292
						local data = self.thefloppy.memory 
						--PrintTable( data )
						
						break
					end
					self.ignorefloppy = nil	
				end 
			end
		else 
			--Eject	
			if self.lock == 0 then
				sound.Play( "buttons/weapon_confirm.wav", self:GetPos(), 75, 70 )
				self:EjectFloppy()
				self.gotfloppy = false
				self:SetOverlayText("Floppy Drive \nFree")
			else 
				sound.Play( "buttons/button18.wav", self:GetPos(), 75, 100 )
			end
		end
	end
end

function ENT:Think()
	--checks if the player is still holding E on the drive. If not, the player can press it again.
	if self.lastuser != nil then 
		if not self.lastuser:KeyDown(IN_USE) then 
			self.lastuser = nil
		end
	end

	if self.gotfloppy == true then 
		if not self.thefloppy:IsValid() then
			sound.Play( "buttons/button11.wav", self:GetPos(), 75, 70 )
			self.gotfloppy = false
			self:SetOverlayText("Floppy Drive \nFloppy deleted")
		end
	end
end

function ENT:TakeFloppy( )
	self.status = 2
	--when grabbed by a gravity gun, this un-grabs it.
	local phys = self.thefloppy:GetPhysicsObject()
	phys:EnableMotion(false)

	--automatically plugs in the floppy. No more hardcoded offsets 
	self.thefloppy:SetAngles( self:GetAngles() )
	local floppyoffset = LocalToWorld( self.thefloppy:OBBCenter(), Angle(), Vector(), self.thefloppy:GetAngles() )
	local driveoffset = LocalToWorld( self:OBBCenter(), Angle(), Vector(), self:GetAngles() ) + (self:GetForward()*GetSize(self))
	local offset = self:GetPos() + driveoffset - (self:GetForward()*GetSize( self.thefloppy )/1.05 )
	self.thefloppy:SetPos( offset-floppyoffset)

	--parents the floppy. Making sure its staying on its place.
	self.thefloppy:SetParent( self )
end

function ENT:EjectFloppy( )
	self.status = 1
	--deparents
	self.thefloppy:SetParent( nil )

	--Same as TakeFloppy, but it looks like its ejected.
	local floppyoffset = LocalToWorld( self.thefloppy:OBBCenter(), Angle(), Vector(), self.thefloppy:GetAngles() )
	local driveoffset = LocalToWorld( self:OBBCenter(), Angle(), Vector(), self:GetAngles() ) + (self:GetForward()*GetSize(self))
	local offset = self:GetPos() + driveoffset - (self:GetForward()*GetSize( self.thefloppy )/5)
	self.thefloppy:SetPos( offset-floppyoffset)
	
	--holds the floppy so it doesnt fall when ejecting.
	local phys = self.thefloppy:GetPhysicsObject()
	phys:EnableMotion(true)
	constraint.Weld( self, self.thefloppy, 0, 0, 1000, true, false )
end

function GetSize( Ent )
	return Ent:OBBMaxs()[1]
end

function ENT:GetCenterPos( )
	return self:GetPos() + self:OBBCenter()
end

function ENT:GotoSector( Sect )
	
	local floppy = self.thefloppy
	if Sect <= floppy.properties.sectors then
		local targettrack = math.ceil( Sect / floppy.properties.sectors_per_track )
		local trackstomove = math.abs( self.ctrack - targettrack )
		local delay = (self.headspeed/floppy.properties.tracks)*trackstomove
		if trackstomove >= 0 then
			self.status = 3
			if trackstomove > 0 then
				self.headsound:Play()
			end
			self.headsound:ChangePitch(200,0)
			self.headsound:ChangeVolume(0.1,0)
			self.headsoundstop:Stop()
			timer.Create("wire.floppydrive.headmovement".. self.timecreated, delay, 1, function( )
	
				self.ctrack = targettrack
				self.csector = Sect
				self.headsound:Stop()
				self.headsoundstop:Play()
				self.headsoundstop:ChangeVolume(0.4,0)
				self.headsoundstop:ChangePitch(200,0)
				
				self.motorsound:ChangePitch(155+((self.ctrack/floppy.properties.tracks)*50),0.2) --Spins faster when closer to center
				
				self.status = 2
			end)
		end
	end
end

function ENT:CheckHasFloppy()
	if self.thefloppy == nil or self.gotfloppy == false then 
		return false
	else
		return true
	end
end

function ENT:Read( )
	local floppy = self.thefloppy
	self.status = 3
	timer.Create("wire.floppydrive.latency.read" .. self.timecreated, self.latancy, 1, function( )
		self.buffer = floppy.memory.sector[self.csector]
		if self.status == 3 then self.status = 2 end 
	end)
end

function ENT:Write( )
	local floppy = self.thefloppy
	self.status = 3
	timer.Create("wire.floppydrive.latency.write" .. self.timecreated, self.latancy, 1, function( )
		local data = {}
		for i=1,512,1 do  --Limitter
			data[i] = self.buffer[i]
		end
		floppy.memory.sector[self.csector] = data
		if self.status == 3 then self.status = 2 end 
	end)
end

--hi speed communication

function ENT:ReadCell( Address )
	if Address >= 512 and self:CheckHasFloppy() then
		return self.buffer[Address-511]
	else
		--Contains floppy?
		if Address == 0 then 
			local Ans = 0
			if self:CheckHasFloppy() then 
				Ans = 1
			else 
				Ans = 0
			end
			return Ans
			
		elseif Address == 1 then
			return self.thefloppy.writeprotection
			
		elseif Address == 2 then 		
			return self.lock
			
		elseif Address == 5 then 
			return self.csector
		elseif Address == 8 then
			return self.status
		elseif Address == 11 and self:CheckHasFloppy() then
			return self.thefloppy.properties.sectors
		elseif Address == 510 then 
			return 100
		end
	end
end

function ENT:WriteCell( Address, value )
	if Address >= 512 and self:CheckHasFloppy() then 
		self.buffer[Address-511] = value
	end
		--Lock
	if Address == 2 then
		self.lock = value
		if value > 0 then
			self:SetOverlayText("Floppy Drive \nContains floppy and is locked")
		else 
			self:SetOverlayText("Floppy Drive \nContains floppy")
		end
		
	elseif Address == 3 and self.status != 3 then 
		if self.lock == 0 and self:CheckHasFloppy() then--Eject			
			sound.Play( "buttons/button6.wav", self:GetPos(), 75, 200 )
			self:EjectFloppy()
			self.gotfloppy = false
			self:SetOverlayText("Floppy Drive \nFree")
		end	
		
	elseif Address == 4 and self.status != 3 then 
		if value > 0 and self:CheckHasFloppy() then
			self.motor = 1
			if not self.motorsound:IsPlaying() then
				self.motorsound:ChangePitch(0,0)
				self.motorsound:Play()
				--self.motorsound:ChangePitch(100,0.2)
				self.motorsound:ChangeVolume(0.2,0)
			end
		else 
			self.motor = 0
			if self.motorsound:IsPlaying() then
				self.motorsound:ChangePitch(0,0.5)
				timer.Create("floppydrive.motorsoundstop" .. self.timecreated, 0.7, 1, function( )
					self.motorsound:Stop()
				end)
			end
		end
	
	elseif Address == 5 and self.status != 3 and self:CheckHasFloppy() then 
		self:GotoSector( math.Round( value ) )
	elseif Address == 6 and self.status != 3 and self.motor > 0 and self:CheckHasFloppy() then 
		self:Read( )
	elseif Address == 7 and self.status != 3 and self.motor > 0 and self:CheckHasFloppy() then 
		self:Write( )		
	end

end

function ENT:BuildDupeInfo()

end


duplicator.RegisterEntityClass( "gmod_wire_floppydrive", WireLib.MakeWireEnt, "Data")
