--[[
	Take an InstanceMap and a dictionary mapping instances to sets of property
	names. Populate a patch with the encoded values of all the given properties
	on all the given instances (or, if any changes set Parent to nil, removals
	of instances) and return the patch.
]]

local Packages = script.Parent.Parent.Parent.Packages
local Log = require(Packages.Log)

local PatchSet = require(script.Parent.Parent.PatchSet)

local encodePatchUpdate = require(script.Parent.encodePatchUpdate)

return function(instanceMap, propertyChanges)
	local patch = PatchSet.newEmpty()

	for instance, properties in propertyChanges do
		local instanceId = instanceMap.fromInstances[instance]

		if instanceId == nil then
			Log.warn("Ignoring change for instance {:?} as it is unknown to Rojo", instance)
			continue
		end

		-- Instances that aren't going to be saved anyway, such as the Rojo
		-- session lock value, should never be encoded into a live-sync patch.
		-- Some of their properties (e.g. an ObjectValue's Value) may be Refs
		-- that cannot be encoded on their own, which would error every batch.
		local success, isUnarchivable = pcall(function()
			return instance.Archivable == false
		end)
		if success and isUnarchivable then
			propertyChanges[instance] = nil
			continue
		end

		if properties.Parent then
			if instance.Parent == nil then
				table.insert(patch.removed, instanceId)
			else
				Log.warn("Cannot sync non-nil Parent property changes yet")
			end
		else
			local update = encodePatchUpdate(instance, instanceId, properties)
			table.insert(patch.updated, update)
		end

		propertyChanges[instance] = nil
	end

	return patch
end
