local CATEGORY_NAME = "用户管理"

local function checkForValidId( calling_ply, id )
	if id == "BOT" or id == "NULL" then -- Bot check
		return true
	elseif id:find( "%." ) then -- Assume IP and check
	 	if not ULib.isValidIP( id ) then
			ULib.tsayError( calling_ply, "无效的 IP 地址。", true )
			return false
		end
	elseif id:find( ":" ) then
	 	if not ULib.isValidSteamID( id ) then -- Assume steamid and check
			ULib.tsayError( calling_ply, "无效的 SteamID。", true )
			return false
		end
	elseif not tonumber( id ) then -- Assume uniqueid and check
		ULib.tsayError( calling_ply, "无效的唯一标识 ID", true )
		return false
	end

	return true
end

ulx.group_names = {}
ulx.group_names_no_user = {}
local function updateNames()
	table.Empty( ulx.group_names ) -- Don't reassign so we don't lose our refs
	table.Empty( ulx.group_names_no_user )

	for group_name, _ in pairs( ULib.ucl.groups ) do
		table.insert( ulx.group_names, group_name )
		if group_name ~= ULib.ACCESS_ALL then
			table.insert( ulx.group_names_no_user, group_name )
		end
	end
end
hook.Add( ULib.HOOK_UCLCHANGED, "ULXGroupNamesUpdate", updateNames )
updateNames() -- Init

function ulx.usermanagementhelp( calling_ply )
	if calling_ply:IsValid() then
		ULib.clientRPC( calling_ply, "ulx.showUserHelp" )
	else
		ulx.showUserHelp()
	end
end
local usermanagementhelp = ulx.command( CATEGORY_NAME, "ulx usermanagementhelp", ulx.usermanagementhelp )
usermanagementhelp:defaultAccess( ULib.ACCESS_ALL )
usermanagementhelp:help( "查看用户管理帮助信息." )

function ulx.adduser( calling_ply, target_ply, group_name )
	local userInfo = ULib.ucl.authed[ target_ply:UniqueID() ]

	local id = ULib.ucl.getUserRegisteredID( target_ply )
	if not id then id = target_ply:SteamID() end

	ULib.ucl.addUser( id, userInfo.allow, userInfo.deny, group_name )

	ulx.fancyLogAdmin( calling_ply, "#A added #T to group #s", target_ply, group_name )
end
local adduser = ulx.command( CATEGORY_NAME, "ulx adduser", ulx.adduser, nil, false, false, true )
adduser:addParam{ type=ULib.cmds.PlayerArg }
adduser:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="用户组", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
adduser:defaultAccess( ULib.ACCESS_SUPERADMIN )
adduser:help( "将指定玩家添加到指定用户组." )

function ulx.adduserid( calling_ply, id, group_name )
	id = id:upper() -- Steam id needs to be upper

	-- Check for valid and properly formatted ID
	if not checkForValidId( calling_ply, id ) then return false end

	-- Now add the fool!
	local userInfo = ULib.ucl.users[ id ] or ULib.DEFAULT_GRANT_ACCESS
	ULib.ucl.addUser( id, userInfo.allow, userInfo.deny, group_name )

	if ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name then
		ulx.fancyLogAdmin( calling_ply, "#A added #s to group #s", ULib.ucl.users[ id ].name, group_name )
	else
		ulx.fancyLogAdmin( calling_ply, "#A added userid #s to group #s", id, group_name )
	end
end
local adduserid = ulx.command( CATEGORY_NAME, "ulx adduserid", ulx.adduserid, nil, false, false, true )
adduserid:addParam{ type=ULib.cmds.StringArg, hint="SteamID、IP 或唯一ID" }
adduserid:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="用户组", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
adduserid:defaultAccess( ULib.ACCESS_SUPERADMIN )
adduserid:help( "通过ID将用户添加到指定用户组." )

function ulx.removeuser( calling_ply, target_ply )
	ULib.ucl.removeUser( target_ply:UniqueID() )

	ulx.fancyLogAdmin( calling_ply, "#A removed all access rights from #T", target_ply )
end
local removeuser = ulx.command( CATEGORY_NAME, "ulx removeuser", ulx.removeuser, nil, false, false, true )
removeuser:addParam{ type=ULib.cmds.PlayerArg }
removeuser:defaultAccess( ULib.ACCESS_SUPERADMIN )
removeuser:help( "永久移除用户的所有权限." )

function ulx.removeuserid( calling_ply, id )
	id = id:upper() -- Steam id needs to be upper

	-- Check for valid and properly formatted ID
	if not checkForValidId( calling_ply, id ) then return false end

	if not ULib.ucl.authed[ id ] and not ULib.ucl.users[ id ] then
		ULib.tsayError( calling_ply, "ULib 用户列表中不存在 ID 为 \"" .. id .. "\" 的玩家", true )
		return false
	end

	local name = (ULib.ucl.authed[ id ] and ULib.ucl.authed[ id ].name) or (ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name)

	ULib.ucl.removeUser( id )

	if name then
		ulx.fancyLogAdmin( calling_ply, "#A removed all access rights from #s", name )
	else
		ulx.fancyLogAdmin( calling_ply, "#A removed all access rights from #s", id )
	end
end
local removeuserid = ulx.command( CATEGORY_NAME, "ulx removeuserid", ulx.removeuserid, nil, false, false, true )
removeuserid:addParam{ type=ULib.cmds.StringArg, hint="SteamID、IP 或唯一ID" }
removeuserid:defaultAccess( ULib.ACCESS_SUPERADMIN )
removeuserid:help( "通过ID永久移除用户的所有权限." )

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
		ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 已拥有 \"%s\" 的权限", target_ply:Nick(), access_string ), true )
	else
		if not access_tag or access_tag == "" then
			ulx.fancyLogAdmin( calling_ply, "#A granted access #q to #T", access_string, target_ply )
		else
			ulx.fancyLogAdmin( calling_ply, "#A granted access #q with tag #q to #T", access_string, access_tag, target_ply )
		end
	end
end
local userallow = ulx.command( CATEGORY_NAME, "ulx userallow", ulx.userallow, nil, false, false, true )
userallow:addParam{ type=ULib.cmds.PlayerArg }
userallow:addParam{ type=ULib.cmds.StringArg, hint="命令" } -- TODO, add completes for this
userallow:addParam{ type=ULib.cmds.StringArg, hint="权限标签", ULib.cmds.optional }
userallow:defaultAccess( ULib.ACCESS_SUPERADMIN )
userallow:help( "为用户添加权限." )

function ulx.userallowid( calling_ply, id, access_string, access_tag )
	id = id:upper() -- Steam id needs to be upper

	-- Check for valid and properly formatted ID
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
			ulx.fancyLogAdmin( calling_ply, "#A granted access #q to #s", access_string, name )
		else
			ulx.fancyLogAdmin( calling_ply, "#A granted access #q with tag #q to #s", access_string, access_tag, name )
		end
	end
end
local userallowid = ulx.command( CATEGORY_NAME, "ulx userallowid", ulx.userallowid, nil, false, false, true )
userallowid:addParam{ type=ULib.cmds.StringArg, hint="SteamID、IP 或唯一ID" }
userallowid:addParam{ type=ULib.cmds.StringArg, hint="命令" } -- TODO, add completes for this
userallowid:addParam{ type=ULib.cmds.StringArg, hint="权限标签", ULib.cmds.optional }
userallowid:defaultAccess( ULib.ACCESS_SUPERADMIN )
userallowid:help( "通过ID为用户添加权限." )

function ulx.userdeny( calling_ply, target_ply, access_string, should_use_neutral )
	local success = ULib.ucl.userAllow( target_ply:UniqueID(), access_string, should_use_neutral, true )
	if should_use_neutral then
		success = success or ULib.ucl.userAllow( target_ply:UniqueID(), access_string, should_use_neutral, false ) -- Remove from both lists
	end

	if should_use_neutral then
		if success then
			ulx.fancyLogAdmin( calling_ply, "#A made access #q neutral to #T", access_string, target_ply )
		else
			ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 未被拒绝或允许 \"%s\" 的权限", target_ply:Nick(), access_string ), true )
		end
	else
		if not success then
			ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 已被拒绝 \"%s\" 的权限", target_ply:Nick(), access_string ), true )
		else
			ulx.fancyLogAdmin( calling_ply, "#A denied access #q to #T", access_string, target_ply )
		end
	end
end
local userdeny = ulx.command( CATEGORY_NAME, "ulx userdeny", ulx.userdeny, nil, false, false, true )
userdeny:addParam{ type=ULib.cmds.PlayerArg }
userdeny:addParam{ type=ULib.cmds.StringArg, hint="命令" } -- TODO, add completes for this
userdeny:addParam{ type=ULib.cmds.BoolArg, hint="仅移除显式允许/拒绝而非直接拒绝", ULib.cmds.optional }
userdeny:defaultAccess( ULib.ACCESS_SUPERADMIN )
userdeny:help( "移除用户的一项权限." )

function ulx.userdenyid( calling_ply, id, access_string, should_use_neutral )
	id = id:upper() -- Steam id needs to be upper

	-- Check for valid and properly formatted ID
	if not checkForValidId( calling_ply, id ) then return false end

	if not ULib.ucl.authed[ id ] and not ULib.ucl.users[ id ] then
		ULib.tsayError( calling_ply, "ULib 用户列表中不存在 ID 为 \"" .. id .. "\" 的玩家", true )
		return false
	end

	local success = ULib.ucl.userAllow( id, access_string, should_use_neutral, true )
	if should_use_neutral then
		success = success or ULib.ucl.userAllow( id, access_string, should_use_neutral, false ) -- Remove from both lists
	end

	local name = (ULib.ucl.authed[ id ] and ULib.ucl.authed[ id ].name) or (ULib.ucl.users[ id ] and ULib.ucl.users[ id ].name) or id
	if should_use_neutral then
		if success then
			ulx.fancyLogAdmin( calling_ply, "#A made access #q neutral to #s", access_string, name )
		else
			ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 未被拒绝或允许 \"%s\" 的权限", name, access_string ), true )
		end
	else
		if not success then
			ULib.tsayError( calling_ply, string.format( "用户 \"%s\" 已被拒绝 \"%s\" 的权限", name, access_string ), true )
		else
			ulx.fancyLogAdmin( calling_ply, "#A denied access #q to #s", access_string, name )
		end
	end
end
local userdenyid = ulx.command( CATEGORY_NAME, "ulx userdenyid", ulx.userdenyid, nil, false, false, true )
userdenyid:addParam{ type=ULib.cmds.StringArg, hint="SteamID、IP 或唯一ID" }
userdenyid:addParam{ type=ULib.cmds.StringArg, hint="命令" } -- TODO, add completes for this
userdenyid:addParam{ type=ULib.cmds.BoolArg, hint="仅移除显式允许/拒绝而非直接拒绝", ULib.cmds.optional }
userdenyid:defaultAccess( ULib.ACCESS_SUPERADMIN )
userdenyid:help( "通过ID移除用户的一项权限." )

function ulx.addgroup( calling_ply, group_name, inherit_from )
	if ULib.ucl.groups[ group_name ] ~= nil then
		ULib.tsayError( calling_ply, "该用户组已存在！", true )
		return
	end

	if not ULib.ucl.groups[ inherit_from ] then
		ULib.tsayError( calling_ply, "指定的继承用户组不存在！", true )
		return
	end

	ULib.ucl.addGroup( group_name, _, inherit_from )
	ulx.fancyLogAdmin( calling_ply, "#A created group #s which inherits rights from group #s", group_name, inherit_from )
end
local addgroup = ulx.command( CATEGORY_NAME, "ulx addgroup", ulx.addgroup, nil, false, false, true )
addgroup:addParam{ type=ULib.cmds.StringArg, hint="用户组" }
addgroup:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="继承自", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes, default="user", ULib.cmds.optional }
addgroup:defaultAccess( ULib.ACCESS_SUPERADMIN )
addgroup:help( "创建一个新用户组，可选择性继承其他组." )

function ulx.renamegroup( calling_ply, current_group, new_group )
	if ULib.ucl.groups[ new_group ] then
		ULib.tsayError( calling_ply, "目标用户组已存在！", true )
		return
	end

	ULib.ucl.renameGroup( current_group, new_group )
	ulx.fancyLogAdmin( calling_ply, "#A renamed group #s to #s", current_group, new_group )
end
local renamegroup = ulx.command( CATEGORY_NAME, "ulx renamegroup", ulx.renamegroup, nil, false, false, true )
renamegroup:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="当前用户组", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
renamegroup:addParam{ type=ULib.cmds.StringArg, hint="新用户组" }
renamegroup:defaultAccess( ULib.ACCESS_SUPERADMIN )
renamegroup:help( "重命名一个用户组." )

function ulx.setGroupCanTarget( calling_ply, group, can_target )
	if can_target and can_target ~= "" and can_target ~= "*" then
		ULib.ucl.setGroupCanTarget( group, can_target )
		ulx.fancyLogAdmin( calling_ply, "#A changed group #s to only be able to target #s", group, can_target )
	else
		ULib.ucl.setGroupCanTarget( group, nil )
		ulx.fancyLogAdmin( calling_ply, "#A changed group #s to be able to target anyone", group )
	end
end
local setgroupcantarget = ulx.command( CATEGORY_NAME, "ulx setgroupcantarget", ulx.setGroupCanTarget, nil, false, false, true )
setgroupcantarget:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="用户组", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
setgroupcantarget:addParam{ type=ULib.cmds.StringArg, hint="目标字符串", ULib.cmds.optional }
setgroupcantarget:defaultAccess( ULib.ACCESS_SUPERADMIN )
setgroupcantarget:help( "设置用户组允许瞄准的目标范围" )

function ulx.removegroup( calling_ply, group_name )
	ULib.ucl.removeGroup( group_name )
	ulx.fancyLogAdmin( calling_ply, "#A removed group #s", group_name )
end
local removegroup = ulx.command( CATEGORY_NAME, "ulx removegroup", ulx.removegroup, nil, false, false, true )
removegroup:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names_no_user, hint="用户组", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
removegroup:defaultAccess( ULib.ACCESS_SUPERADMIN )
removegroup:help( "移除一个用户组。请谨慎使用！" )

function ulx.groupallow( calling_ply, group_name, access_string, access_tag )
	local accessTable
	if access_tag and access_tag ~= "" then
		accessTable = { [access_string]=access_tag }
	else
		accessTable = { access_string }
	end

	local success = ULib.ucl.groupAllow( group_name, accessTable )
	if not success then
		ULib.tsayError( calling_ply, string.format( "用户组 \"%s\" 已拥有 \"%s\" 的权限", group_name, access_string ), true )
	else
		if not access_tag or access_tag == "" then
			ulx.fancyLogAdmin( calling_ply, "#A granted access #q to group #s", access_string, group_name )
		else
			ulx.fancyLogAdmin( calling_ply, "#A granted access #q with tag #q to group #s", access_string, access_tag, group_name )
		end
	end
end
local groupallow = ulx.command( CATEGORY_NAME, "ulx groupallow", ulx.groupallow, nil, false, false, true )
groupallow:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="用户组", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
groupallow:addParam{ type=ULib.cmds.StringArg, hint="命令" } -- TODO, add completes for this
groupallow:addParam{ type=ULib.cmds.StringArg, hint="权限标签", ULib.cmds.optional }
groupallow:defaultAccess( ULib.ACCESS_SUPERADMIN )
groupallow:help( "为用户组添加权限." )

function ulx.groupdeny( calling_ply, group_name, access_string )
	local success = ULib.ucl.groupAllow( group_name, access_string, true )
	if success then
		ulx.fancyLogAdmin( calling_ply, "#A 撤销了用户组 #s 的权限 #q", group_name, access_string )
	else
		ULib.tsayError( calling_ply, string.format( "用户组 \"%s\" 没有 \"%s\" 的权限", group_name, access_string ), true )
	end
end
local groupdeny = ulx.command( CATEGORY_NAME, "ulx groupdeny", ulx.groupdeny, nil, false, false, true )
groupdeny:addParam{ type=ULib.cmds.StringArg, completes=ulx.group_names, hint="用户组", error="invalid group \"%s\" specified", ULib.cmds.restrictToCompletes }
groupdeny:addParam{ type=ULib.cmds.StringArg, hint="命令" } -- TODO, add completes for this
groupdeny:defaultAccess( ULib.ACCESS_SUPERADMIN )
groupdeny:help( "移除用户组的一项权限." )
