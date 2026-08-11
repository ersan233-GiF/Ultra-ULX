function ULib.getPicker( ply, radius )
	radius = radius or 30
	local trace = util.GetPlayerTrace( ply )
	local trace_results = util.TraceLine( trace )
	if not trace_results.Entity:IsValid() or not trace_results.Entity:IsPlayer() then
		local best_choice
		local best_choice_diff
		local pos = ply:GetPos()
		local ang = ply:GetAimVector():Angle()
		local players = player.GetAll()
		for _, player in ipairs( players ) do
			if player ~= ply then
				local vec_diff = player:GetPos() - Vector( 0, 0, 16 ) - pos
				local newang = vec_diff:Angle()
				local diff = math.abs( math.NormalizeAngle( newang.pitch - ang.pitch ) ) + math.abs( math.NormalizeAngle( newang.yaw - ang.yaw ) )
				if not best_choice_diff or diff < best_choice_diff then
					best_choice_diff = diff
					best_choice = player
				end
			end
		end
		if not best_choice or best_choice_diff > radius then
			return
		else
			return best_choice
		end
	else
		return trace_results.Entity
	end
end
local Player = FindMetaTable( "Player" )
local checkIndexes = { Player.UniqueID, function( ply ) if CLIENT then return "" end local ip = ULib.splitPort( ply:IPAddress() ) return ip end, Player.SteamID, Player.UserID }
function ULib.getPlyByID( id )
	id = id:upper()
	local players = player.GetAll()
	for _, indexFn in ipairs( checkIndexes ) do
		for _, ply in ipairs( players ) do
			if tostring( indexFn( ply ) ) == id then
				return ply
			end
		end
	end
	return nil
end
function ULib.getUniqueIDForPlayer( ply )
	if game.SinglePlayer() then
		return "1"
	end
	local players = player.GetAll()
	for _, indexFn in ipairs( checkIndexes ) do
		local id = indexFn( ply )
		if ULib.getUser( "$" .. id, true ) == ply then
			return id
		end
	end
	return nil
end
function ULib.getUsers( target, enable_keywords, ply )
	if target == "" then
		return false, "No target specified!"
	end
	local players = player.GetAll()
	for _, player in ipairs( players ) do
		if target:lower() == player:Nick():lower() then
			return { player }
		end
	end
	local targetPlys = {}
	local pieces = ULib.explode( ",", target )
	for _, piece in ipairs( pieces ) do
		piece = piece:Trim()
		if piece ~= "" then
			local keywordMatch = false
			if enable_keywords then
				local tmpTargets = {}
				local negate = false
				if piece:sub( 1, 1 ) == "!" and piece:len() > 1 then
					negate = true
					piece = piece:sub( 2 )
				end
				if piece:sub( 1, 1 ) == "$" then
					local player = ULib.getPlyByID( piece:sub( 2 ) )
					if player then
						table.insert( tmpTargets, player )
					end
				elseif piece == "*" then
					table.Add( tmpTargets, players )
				elseif piece == "^" then
					if ply then
						if ply:IsValid() then
							table.insert( tmpTargets, ply )
						elseif not negate then
							return false, "You cannot target yourself from console!"
						end
					end
				elseif piece:sub( 1, 1 ) == "@" then
					if #piece == 1 then
						if IsValid( ply ) then
							local player = ULib.getPicker( ply )
							if player then
								table.insert( tmpTargets, player )
							end
						end
					else
						local teamNameOrId = piece:sub( 2 )
						local teamId = tonumber( teamNameOrId )
						if teamId then
							for _, ply in ipairs( team.GetPlayers( teamId ) ) do
								table.insert( tmpTargets, ply )
							end
						else
							local teams = team.GetAllTeams()
							for teamId, teamData in pairs( teams ) do
								if teamData.Name == teamNameOrId then
									for _, ply in ipairs( team.GetPlayers( teamId ) ) do
										table.insert( tmpTargets, ply )
									end
									break
								end
							end
						end
					end
				elseif piece:sub( 1, 1 ) == "#" and ULib.ucl.groups[ piece:sub( 2 ) ] then
					local group = piece:sub( 2 )
					for _, player in ipairs( players ) do
						if player:GetUserGroup() == group then
							table.insert( tmpTargets, player )
						end
					end
				elseif piece:sub( 1, 1 ) == "%" and ULib.ucl.groups[ piece:sub( 2 ) ] then
					local group = piece:sub( 2 )
					for _, player in ipairs( players ) do
						if player:CheckGroup( group ) then
							table.insert( tmpTargets, player )
						end
					end
				else
					local tblForHook = hook.Run( ULib.HOOK_GETUSERS_CUSTOM_KEYWORD, piece, ply )
					if tblForHook then
						table.Add( tmpTargets, tblForHook )
					end
				end
				if negate then
					for _, player in ipairs( players ) do
						if not table.HasValue( tmpTargets, player ) then
							keywordMatch = true
							table.insert( targetPlys, player )
						end
					end
				else
					if #tmpTargets > 0 then
						keywordMatch = true
						table.Add( targetPlys, tmpTargets )
					end
				end
			end
			if not keywordMatch then
				for _, player in ipairs( players ) do
					if player:Nick():lower():find( piece:lower(), 1, true ) then
						table.insert( targetPlys, player )
					end
				end
			end
		end
	end
	local finalTable = {}
	for _, player in ipairs( targetPlys ) do
		if not table.HasValue( finalTable, player ) then
			table.insert( finalTable, player )
		end
	end
	if #finalTable < 1 then
		return false, "No target found or target has immunity!"
	end
	return finalTable
end
function ULib.getUser( target, enable_keywords, ply )
	if target == "" then
		return false, "No target specified!"
	end
	local players = player.GetAll()
	target = target:lower()
	local plyMatches = {}
	if enable_keywords and target:sub( 1, 1 ) == "$" then
		local possibleId = target:sub( 2 )
		local match = ULib.getPlyByID( possibleId )
		if match then table.insert( plyMatches, match ) end
	end
	for _, player in ipairs( players ) do
		if target == player:Nick():lower() then
			if #plyMatches == 0 then
				return player
			else
				return false, "Found multiple targets! Please choose a better string for the target. (EG, the whole name)"
			end
		end
	end
	if enable_keywords then
		if target == "^" and ply then
			if ply:IsValid() then
				return ply
			else
				return false, "You cannot target yourself from console!"
			end
		elseif IsValid( ply ) and target == "@" then
			local player = ULib.getPicker( ply )
			if not player then
				return false, "No player found in the picker"
			else
				return player
			end
		else
			local player = hook.Run( ULib.HOOK_GETUSER_CUSTOM_KEYWORD, target, ply )
			if player then return player end
		end
	end
	for _, player in ipairs( players ) do
		if player:Nick():lower():find( target, 1, true ) then
			table.insert( plyMatches, player )
		end
	end
	if #plyMatches == 0 then
		return false, "No target found or target has immunity!"
	elseif #plyMatches > 1 then
		local str = plyMatches[ 1 ]:Nick()
		for i=2, #plyMatches do
			str = str .. ", " .. plyMatches[ i ]:Nick()
		end
		return false, "Found multiple targets: " .. str .. ". Please choose a better string for the target. (EG, the whole name)"
	end
	return plyMatches[ 1 ]
end