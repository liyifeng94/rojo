--[[
	Decide which side of a two-way sync is newer.

	fileMtime and lastSyncedMtime are unix milliseconds for the file on disk.
	studioChangedAt is unix milliseconds for the latest Studio edit of that file.
	fromFileEvent is true when this patch was produced by a filesystem change
	while already connected.
]]

return function(fileMtime, lastSyncedMtime, studioChangedAt, fromFileEvent)
	if type(fileMtime) == "number" and type(studioChangedAt) == "number" then
		if studioChangedAt > fileMtime then
			return "studio"
		end
		return "disk"
	end

	if type(studioChangedAt) == "number" then
		return "studio"
	end

	if fromFileEvent then
		return "disk"
	end

	if type(fileMtime) == "number" and type(lastSyncedMtime) == "number" and fileMtime > lastSyncedMtime then
		return "disk"
	end

	if type(lastSyncedMtime) == "number" then
		return "studio"
	end

	return nil
end
