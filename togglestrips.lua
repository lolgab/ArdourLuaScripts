ardour {
	["type"]    = "EditorAction",
	name        = "Toggle All Plugins and Sends",
	license     = "MIT",
	author      = "Lorenzo Gabriele",
	description = [[Toggle all Plugins and sends on all tracks]]
}
	function factory () return function ()
		if deactivating_lolgab == nil then deactivating_lolgab = 1 end
		if already_deactivated_lolgab == nil then already_deactivated_lolgab = {} end
		local tracks = Session:get_routes ()
		local trackNumber = 1
		for track in tracks:iter () do
			local i = 0;
			while 1 do -- iterate over all plugins/processors
				local proc = track:nth_plugin (i)
				if proc:isnil () then
					break
				end
				if proc:active() and deactivating_lolgab == 1 then
					proc:deactivate()
					if already_deactivated_lolgab[trackNumber] ~= nil then
						already_deactivated_lolgab[trackNumber][i] = nil
					end
				elseif deactivating_lolgab == 1 and not proc:active() then
					if already_deactivated_lolgab[trackNumber] == nil then
						already_deactivated_lolgab[trackNumber] = {}
					end
					already_deactivated_lolgab[trackNumber][i] = true
				elseif deactivating_lolgab == 0 and (already_deactivated_lolgab[trackNumber] == nil or already_deactivated_lolgab[trackNumber][i] == nil) then
					proc:activate()
				end
				i = i + 1
			end

			i = 0
			while 1 do -- iterate over all sends
				local send = track:nth_send (i)
				if send:isnil () then
					break
				end
				if send:active() and deactivating_lolgab == 1 then
					send:deactivate()
					already_deactivated_lolgab[send] = nil
				elseif deactivating_lolgab == 1 and not send:active() then
					already_deactivated_lolgab[send] = true
				elseif deactivating_lolgab == 0 and already_deactivated_lolgab[send] == nil then
					send:activate()
				end
				i = i + 1
			end
		trackNumber = trackNumber + 1
		end

		local i = 0
			while 1 do -- iterate over all plugins/processors
				local proc = Session:master_out():nth_plugin (i)
				if proc:isnil () then
					break
				end
				local proc = proc:to_insert()
				if proc:active() and deactivating_lolgab == 1 then
					proc:deactivate()
					already_deactivated_lolgab[proc] = nil
				elseif deactivating_lolgab == 1 and not proc:active() then
					already_deactivated_lolgab[proc] = true
				elseif deactivating_lolgab == 0 and not proc:active() and already_deactivated_lolgab[proc] == nil then
					proc:activate()
				end
				i = i + 1
			end
		
		deactivating_lolgab = 1 - deactivating_lolgab
	end 
end
