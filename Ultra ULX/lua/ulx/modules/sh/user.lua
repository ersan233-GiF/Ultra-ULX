local L = ULib.ulx_lang
local CATEGORY_NAME = "cat_user"
local function getUserInfo( id_or_ply )
	if type(id_or_ply) == "Player" or type(id_or_ply) == "Entity" then
		local ply = id_or_ply
		if not ply:IsValid() then return nil end
		local uid = ply:UniqueID()
		return ULib.ucl.authed[uid], ply:SteamID(), uid, ply:Nick()
	end
	local id = id_or_ply:upper()
	return ULib.ucl.users[id] or ULib.ucl.authed[id], id, id, nil
end
local function checkForValidId( calling_ply, id )
	if id == "BOT" or id == "NULL" then
		return true
	elseif id:find( "%." ) then
	 	if not ULib.isValidIP( id ) then
			ULib.tsayError( calling_ply, L.T("user_invalid_ip"), true )
			return false
		end
	elseif id:find( ":" ) then
	 	if not ULib.isValidSteamID( id ) then
			ULib.tsayError( calling_ply, L.T("user_invalid_steamid"), true )
			return false
		end
	elseif not tonumber( id ) then
		ULib.tsayError( calling_ply, L.T("user_invalid_uid"), true )
		return false
	end
	return true
end
ulx.group_names = {}
ulx.group_names_no_user = {}
local function updateNames()
	table.Empty( ulx.group_names )
	table.Empty( ulx.group_names_no_user )
	for group_name, _ in pairs( ULib.ucl.groups ) do
		table.insert( ulx.group_names, group_name )
		if group_name ~= ULib.ACCESS_ALL then
			table.insert( ulx.group_names_no_user, group_name )
		end
	end
end
hook.Add( ULib.HOOK_UCLCHANGED, "ULXGroupNamesUpdate", updateNames )
updateNames()
function ulx.usermanagementhelp( calling_ply )
	if calling_ply:IsValid() then
		ULib.clientRPC( calling_ply, "ulx.showUserHelp" )
	else
		ulx.showUserHelp()
	end
end
local usermanagementhelp = ulx.command( CATEGORY_NAME, "ulx usermanagementhelp", ulx.usermanagementhelp )
usermanagementhelp:defaultAccess( ULib.ACCESS_ALL )
usermanagementhelp:help( L.T("help_usermanagementhelp") )
function ulx.adduser( calling_ply, target_ply, group_name )
	local userInfo = ULib.ucl.authed[ target_ply:UniqueID() ]
	local id = ULib.ucl.getUserRegisteredID( target_ply )
	if not id then id = target_ply:SteamID() end
	ULib.ucl.addUser( id, userInfo.allow, userInfo.deny, group_name )
	ulx.fancyLogKeyed(calling_ply, "user_adduser_log", target_ply, group_name )
end
local adduser = ulx.command( CATEGORY_NAME, "ulx adduser", ulx.adduser, nil, false, false, true )
adduser:addParam{ type=ULib.cmds.PlayerArg }
adduser:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="group", error=L.T("user_invalid_group"), ULib.cmds.restrictToCompletes }
adduser:defaultAccess( ULib.ACCESS_SUPERADMIN )
adduser:help( L.T("help_adduser") )
function ulx.adduserid( calling_ply, id, group_name )
	id = id:upper()
	if not checkForValidId( calling_ply, id ) then return false end
	local userInfo = ULib.ucl.users[ id ] or ULib.DEFAULT_GRANT_ACCESS
	ULib.ucl.addUser( id, userInfo.allow, userInfo.deny, group_name )
	if ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name then
		ulx.fancyLogKeyed(calling_ply, "user_adduserid_log", ULib.ucl.users[ id ].name, group_name )
	else
		ulx.fancyLogKeyed(calling_ply, "user_adduserid_log", id, group_name )
	end
end
local adduserid = ulx.command( CATEGORY_NAME, "ulx adduserid", ulx.adduserid, nil, false, false, true )
adduserid:addParam{ type=ULib.cmds.StringArg, hint="userid" }
adduserid:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="group", error=L.T("user_invalid_group"), ULib.cmds.restrictToCompletes }
adduserid:defaultAccess( ULib.ACCESS_SUPERADMIN )
adduserid:help( L.T("help_adduserid") )
function ulx.removeuser( calling_ply, target_ply )
	ULib.ucl.removeUser( target_ply:UniqueID() )
	ulx.fancyLogKeyed(calling_ply, "user_removeuser_log", target_ply )
end
local removeuser = ulx.command( CATEGORY_NAME, "ulx removeuser", ulx.removeuser, nil, false, false, true )
removeuser:addParam{ type=ULib.cmds.PlayerArg }
removeuser:defaultAccess( ULib.ACCESS_SUPERADMIN )
removeuser:help( L.T("help_removeuser") )
function ulx.removeuserid( calling_ply, id )
	id = id:upper()
	if not checkForValidId( calling_ply, id ) then return false end
	if not ULib.ucl.authed[ id ] and not ULib.ucl.users[ id ] then
		ULib.tsayError( calling_ply, L.T("user_not_found_id", id), true )
		return false
	end
	local name = (ULib.ucl.authed[ id ] and ULib.ucl.authed[ id ].name) or (ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name)
	ULib.ucl.removeUser( id )
	if name then
		ulx.fancyLogKeyed(calling_ply, "user_removeuserid_log", name )
	else
		ulx.fancyLogKeyed(calling_ply, "user_removeuserid_log", id )
	end
end
local removeuserid = ulx.command( CATEGORY_NAME, "ulx removeuserid", ulx.removeuserid, nil, false, false, true )
removeuserid:addParam{ type=ULib.cmds.StringArg, hint="SteamID、IP 或唯一ID" }
removeuserid:defaultAccess( ULib.ACCESS_SUPERADMIN )
removeuserid:help( L.T("help_removeuserid") )
function ulx.userallow( calling_ply, target_ply, access_string, access_tag )
	local accessTable
	if access_tag and access_tag ~= "" then
		accessTable = { [access_string]=access_tag }
	else
		accessTable = { access_string }
	end
	local id = ULib.ucl.getUserRegisteredID( target_ply )
	if not id then id = target_ply:SteamID() end
	local success = ULib.ucl.userAllow( id, accessTable )
	if not success then
		ULib.tsayError( calling_ply, L.T("user_already_has_access", target_ply:Nick(), access_string), true )
	else
		if not access_tag or access_tag == "" then
			ulx.fancyLogKeyed(calling_ply, "user_userallow_log", access_string, target_ply )
		else
			ulx.fancyLogKeyed(calling_ply, "user_userallow_tag_log", access_string, access_tag, target_ply )
		end
	end
end
local userallow = ulx.command( CATEGORY_NAME, "ulx userallow", ulx.userallow, nil, false, false, true )
userallow:addParam{ type=ULib.cmds.PlayerArg }
userallow:addParam{ type=ULib.cmds.StringArg, hint="command" }
userallow:addParam{ type=ULib.cmds.StringArg, hint="access", ULib.cmds.optional }
userallow:defaultAccess( ULib.ACCESS_SUPERADMIN )
userallow:help( L.T("help_userallow") )
function ulx.userallowid( calling_ply, id, access_string, access_tag )
	id = id:upper()
	if not checkForValidId( calling_ply, id ) then return false end
	if not ULib.ucl.authed[ id ] and not ULib.ucl.users[ id ] then
		ULib.tsayError( calling_ply, "ULib 用户列表中不存在 ID 为 \"" .. id .. "\" 的玩家", true )
		return false
	end
	local accessTable
	if access_tag and access_tag ~= "" then
		accessTable = { [access_string]=access_tag }
	else
		accessTable = { access_string }
	end
	local success = ULib.ucl.userAllow( id, accessTable )
	local name = (ULib.ucl.authed[ id ] and ULib.ucl.authed[ id ].name) or (ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name) or id
	if not success then
		ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 已拥有 \"%s\" 的权限", name, access_string ), true )
	else
		if not access_tag or access_tag == "" then
			ulx.fancyLogKeyed(calling_ply, "user_userallowid_log", access_string, name )
		else
			ulx.fancyLogKeyed(calling_ply, "user_userallowid_tag_log", access_string, access_tag, name )
		end
	end
end
local userallowid = ulx.command( CATEGORY_NAME, "ulx userallowid", ulx.userallowid, nil, false, false, true )
userallowid:addParam{ type=ULib.cmds.StringArg, hint="SteamID、IP 或唯一ID" }
userallowid:addParam{ type=ULib.cmds.StringArg, hint="command" }
userallowid:addParam{ type=ULib.cmds.StringArg, hint="access", ULib.cmds.optional }
userallowid:defaultAccess( ULib.ACCESS_SUPERADMIN )
userallowid:help( L.T("help_userallowid") )
function ulx.userdeny( calling_ply, target_ply, access_string, should_use_neutral )
	local success = ULib.ucl.userAllow( target_ply:UniqueID(), access_string, should_use_neutral, true )
	if should_use_neutral then
		success = success or ULib.ucl.userAllow( target_ply:UniqueID(), access_string, should_use_neutral, false )
	end
	if should_use_neutral then
		if success then
			ulx.fancyLogKeyed(calling_ply, "user_userneutral_log", access_string, target_ply )
		else
			ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 未被拒绝或允许 \"%s\" 的权限", target_ply:Nick(), access_string ), true )
		end
	else
		if not success then
			ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 已被拒绝 \"%s\" 的权限", target_ply:Nick(), access_string ), true )
		else
			ulx.fancyLogKeyed(calling_ply, "user_userdeny_log", access_string, target_ply )
		end
	end
end
local userdeny = ulx.command( CATEGORY_NAME, "ulx userdeny", ulx.userdeny, nil, false, false, true )
userdeny:addParam{ type=ULib.cmds.PlayerArg }
userdeny:addParam{ type=ULib.cmds.StringArg, hint="command" }
userdeny:addParam{ type=ULib.cmds.BoolArg, hint="deny_explicit_only", ULib.cmds.optional }
userdeny:defaultAccess( ULib.ACCESS_SUPERADMIN )
userdeny:help( L.T("help_userdeny") )
function ulx.userdenyid( calling_ply, id, access_string, should_use_neutral )
	id = id:upper()
	if not checkForValidId( calling_ply, id ) then return false end
	if not ULib.ucl.authed[ id ] and not ULib.ucl.users[ id ] then
		ULib.tsayError( calling_ply, "ULib 用户列表中不存在 ID 为 \"" .. id .. "\" 的玩家", true )
		return false
	end
	local success = ULib.ucl.userAllow( id, access_string, should_use_neutral, true )
	if should_use_neutral then
		success = success or ULib.ucl.userAllow( id, access_string, should_use_neutral, false )
	end
	local name = (ULib.ucl.authed[ id ] and ULib.ucl.authed[ id ].name) or (ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name) or id
	if should_use_neutral then
		if success then
			ulx.fancyLogKeyed(calling_ply, "user_useridneutral_log", access_string, name )
		else
			ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 未被拒绝或允许 \"%s\" 的权限", name, access_string ), true )
		end
	else
		if not success then
			ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 已被拒绝 \"%s\" 的权限", name, access_string ), true )
		else
			ulx.fancyLogKeyed(calling_ply, "user_useriddeny_log", access_string, name )
		end
	end
end
local userdenyid = ulx.command( CATEGORY_NAME, "ulx userdenyid", ulx.userdenyid, nil, false, false, true )
userdenyid:addParam{ type=ULib.cmds.StringArg, hint="SteamID、IP 或唯一ID" }
userdenyid:addParam{ type=ULib.cmds.StringArg, hint="command" }
userdenyid:addParam{ type=ULib.cmds.BoolArg, hint="deny_explicit_only", ULib.cmds.optional }
userdenyid:defaultAccess( ULib.ACCESS_SUPERADMIN )
userdenyid:help( L.T("help_userdenyid") )
function ulx.addgroup( calling_ply, group_name, inherit_from )
	if ULib.ucl.groups[ group_name ] ~= nil then
		ULib.tsayError( calling_ply, L.T("user_group_exists"), true )
		return
	end
	if not ULib.ucl.groups[ inherit_from ] then
		ULib.tsayError( calling_ply, L.T("user_inherit_missing"), true )
		return
	end
	ULib.ucl.addGroup( group_name, _, inherit_from )
	ulx.fancyLogKeyed(calling_ply, "user_addgroup_log", group_name, inherit_from )
end
local addgroup = ulx.command( CATEGORY_NAME, "ulx addgroup", ulx.addgroup, nil, false, false, true )
addgroup:addParam{ type=ULib.cmds.StringArg, hint="group" }
addgroup:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="inherit_from", error=L.T("user_invalid_group"), ULib.cmds.restrictToCompletes, default="user", ULib.cmds.optional }
addgroup:defaultAccess( ULib.ACCESS_SUPERADMIN )
addgroup:help( L.T("help_addgroup") )
function ulx.renamegroup( calling_ply, current_group, new_group )
	if ULib.ucl.groups[ new_group ] then
		ULib.tsayError( calling_ply, L.T("user_rename_exists"), true )
		return
	end
	ULib.ucl.renameGroup( current_group, new_group )
	ulx.fancyLogKeyed(calling_ply, "user_renamegroup_log", current_group, new_group )
end
local renamegroup = ulx.command( CATEGORY_NAME, "ulx renamegroup", ulx.renamegroup, nil, false, false, true )
renamegroup:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="group_current", error=L.T("user_invalid_group"), ULib.cmds.restrictToCompletes }
renamegroup:addParam{ type=ULib.cmds.StringArg, hint="group_new" }
renamegroup:defaultAccess( ULib.ACCESS_SUPERADMIN )
renamegroup:help( L.T("help_renamegroup") )
function ulx.setGroupCanTarget( calling_ply, group, can_target )
	if can_target and can_target ~= "" and can_target ~= "*" then
		ULib.ucl.setGroupCanTarget( group, can_target )
		ulx.fancyLogKeyed(calling_ply, "user_cantarget_set_log", group, can_target )
	else
		ULib.ucl.setGroupCanTarget( group, nil )
		ulx.fancyLogKeyed(calling_ply, "user_cantarget_clear_log", group )
	end
end
local setgroupcantarget = ulx.command( CATEGORY_NAME, "ulx setgroupcantarget", ulx.setGroupCanTarget, nil, false, false, true )
setgroupcantarget:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error=L.T("user_invalid_group"), ULib.cmds.restrictToCompletes }
setgroupcantarget:addParam{ type=ULib.cmds.StringArg, hint="target_string", ULib.cmds.optional }
setgroupcantarget:defaultAccess( ULib.ACCESS_SUPERADMIN )
setgroupcantarget:help( L.T("help_setgroupcantarget") )
function ulx.removegroup( calling_ply, group_name )
	ULib.ucl.removeGroup( group_name )
	ulx.fancyLogKeyed(calling_ply, "user_removegroup_log", group_name )
end
local removegroup = ulx.command( CATEGORY_NAME, "ulx removegroup", ulx.removegroup, nil, false, false, true )
removegroup:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="group", error=L.T("user_invalid_group"), ULib.cmds.restrictToCompletes }
removegroup:defaultAccess( ULib.ACCESS_SUPERADMIN )
removegroup:help( L.T("help_removegroup") )
function ulx.groupallow( calling_ply, group_name, access_string, access_tag )
	local accessTable
	if access_tag and access_tag ~= "" then
		accessTable = { [access_string]=access_tag }
	else
		accessTable = { access_string }
	end
	local success = ULib.ucl.groupAllow( group_name, accessTable )
	if not success then
		ULib.tsayError( calling_ply, L.T("group_already_has_access", group_name, access_string), true )
	else
		if not access_tag or access_tag == "" then
			ulx.fancyLogKeyed(calling_ply, "user_groupallow_log", access_string, group_name )
		else
			ulx.fancyLogKeyed(calling_ply, "user_groupallow_tag_log", access_string, access_tag, group_name )
		end
	end
end
local groupallow = ulx.command( CATEGORY_NAME, "ulx groupallow", ulx.groupallow, nil, false, false, true )
groupallow:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error=L.T("user_invalid_group"), ULib.cmds.restrictToCompletes }
groupallow:addParam{ type=ULib.cmds.StringArg, hint="command" }
groupallow:addParam{ type=ULib.cmds.StringArg, hint="access", ULib.cmds.optional }
groupallow:defaultAccess( ULib.ACCESS_SUPERADMIN )
groupallow:help( L.T("help_groupallow") )
function ulx.groupdeny( calling_ply, group_name, access_string )
	local success = ULib.ucl.groupAllow( group_name, access_string, true )
	if success then
		ulx.fancyLogKeyed(calling_ply, "user_groupdeny_log", group_name, access_string )
	else
		ULib.tsayError( calling_ply, L.T("group_not_have_access", group_name, access_string), true )
	end
end
local groupdeny = ulx.command( CATEGORY_NAME, "ulx groupdeny", ulx.groupdeny, nil, false, false, true )
groupdeny:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="group", error=L.T("user_invalid_group"), ULib.cmds.restrictToCompletes }
groupdeny:addParam{ type=ULib.cmds.StringArg, hint="command" }
groupdeny:defaultAccess( ULib.ACCESS_SUPERADMIN )
groupdeny:help( L.T("help_groupdeny") )