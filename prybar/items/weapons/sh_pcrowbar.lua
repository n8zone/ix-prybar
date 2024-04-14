ITEM.name = "Crowbar"
ITEM.description = "A slightly rusty looking crowbar."
ITEM.model = "models/weapons/w_crowbar.mdl"
ITEM.class = "weapon_crowbar"
ITEM.weaponCategory = "melee"
ITEM.category = "Prying"
ITEM.width = 2
ITEM.height = 1
ITEM.durability = 100
ITEM.iconCam = {
	ang	= Angle(-0.23955784738064, 270.44906616211, 0),
	fov	= 10.780103254469,
	pos	= Vector(0, 200, 0)
}

function ITEM:GetDescription()
	local description = self.description

	if (self:GetData("durability", self.durability) < self.durability) then
		description = description .. "\nDurability: " .. self:GetData("durability", self.durability)
	end

	return description
end

ITEM.functions.PryDoor = {
	name = "Pry Door",
	tip = "useTip",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local durability = item:GetData("durability", item.durability)
		local damage = 10

		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		local door = entity
		local doorProperties = entity:GetSaveTable()
		local doorLock = doorProperties.m_bLocked
		local class = entity:GetClass()

		local chance = ix.config.Get("pryChance", 50)
		local time = ix.config.Get("pryTime", 5)
		local roll = math.random(1, 100)

		if (door.ixLock) then
			damage = math.floor(damage * 2)
			chance = chance / 2
			time = time * 2
		end

		if (!doorLock) then
			client:Notify("The door was already unlocked.")
			entity:EmitSound("physics/wood/wood_box_impact_hard3.wav", 75, 100, 1)
			entity:Fire("open", "", 0)
			return false
		end

		client:SetAction("Prying Door", time, function()
			if (roll <= chance) then
				damage = math.floor(damage * 0.75)
				durability = durability - damage
				item:SetData("durability", durability)

				entity:Fire("unlock", "", 0)
				entity:Fire("open", "", 0)
				entity:EmitSound("doors/door_latch3.wav", 75, 100, 1)
				client:Notify("You have pried open the door.")
				if (door.ixLock) then
					-- explosion effect
					local effectdata = EffectData()
					effectdata:SetOrigin( door.ixLock:GetPos() or door:GetPos() )
					effectdata:SetMagnitude( 1 )
					effectdata:SetScale( 1.5 )
					effectdata:SetRadius( 3 )
					util.Effect( "Sparks", effectdata )

					
					timer.Create("lockBreakSound", 0.1, 3, function()
						door:EmitSound("ambient/energy/spark"..math.random(1,6)..".wav", 75, 100, 1)
					end)

					door.ixLock:Remove()
				end
			else
				client:Notify("You failed to pry open the door.")
				entity:EmitSound("physics/wood/wood_box_impact_hard3.wav", 75, 100, 1)
				durability = durability - damage
				item:SetData("durability", durability)
			end

			if (item:GetData("durability") <= 0) then
				client:Notify("The crowbar has broken.")
				item:Remove()
			end

		end)

		return false
	end,
	OnCanRun = function(item)

		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		local canPryDoor = IsValid(entity) and entity:IsDoor() and entity:GetClass() == "prop_door_rotating"

		return (!IsValid(item.entity) and canPryDoor)
	end
}

ITEM.functions.PryContainer = {
	name = "Pry Container",
	tip = "useTip",
	icon = "icon16/wrench.png",
	OnRun = function(item)
		local durability = item:GetData("durability", item.durability)
		local damage = 10

		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		local container = entity
		local containerLock = container:GetLocked()
		local class = entity:GetClass()

		local chance = ix.config.Get("pryChance", 50)
		local time = ix.config.Get("pryTime", 5)
		local roll = math.random(1, 100)

		if (!containerLock) then
			client:Notify("The container was already unlocked.")
			entity:EmitSound("physics/wood/wood_box_impact_hard3.wav", 75, 100, 1)
			return false
		end

		client:SetAction("Prying Container", time, function()
			if (roll <= chance) then
				damage = math.floor(damage * 0.75)
				durability = durability - damage
				item:SetData("durability", durability)

				container:OpenInventory(client)
				container:SetLocked(false)
				container:EmitSound("physics/wood/wood_box_impact_hard1.wav", 75, 100, 1)
				client:Notify("You have pried open the container.")
			else
				client:Notify("You failed to pry open the container.")
				container:EmitSound("physics/wood/wood_box_impact_hard3.wav", 75, 100, 1)
				durability = durability - damage
				item:SetData("durability", durability)
			end

			if (item:GetData("durability") <= 0) then
				client:Notify("The crowbar has broken.")
				item:Remove()
			end

		end)

		return false
	end,
	OnCanRun = function(item)

		local client = item.player
		local data = {}
			data.start = client:GetShootPos()
			data.endpos = data.start + client:GetAimVector() * 96
			data.filter = client
		local trace = util.TraceLine(data)
		local entity = trace.Entity

		local canPryContainer = IsValid(entity) and entity:GetClass() == "ix_container"

		return (!IsValid(item.entity) and canPryContainer)
	end
}


