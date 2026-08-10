ULib = ULib or {}
ULib.RELEASE = false
ULib.VERSION = 2.72
ULib.AUTOMATIC_UPDATE_CHECKS = true
ULib.ACCESS_ALL = "user"
ULib.ACCESS_OPERATOR = "operator"
ULib.ACCESS_ADMIN = "admin"
ULib.ACCESS_SUPERADMIN = "superadmin"
ULib.DEFAULT_ACCESS = ULib.ACCESS_ALL
ULib.COLOR_ACCENT   = Color( 60,  160, 240 )
ULib.COLOR_SUCCESS  = Color( 40,  200, 80  )
ULib.COLOR_WARN     = Color( 220, 140, 0   )
ULib.COLOR_ERROR    = Color( 220, 80,  30  )
ULib.COLOR_INFO     = Color( 0,   170, 220 )
ULib.COLOR_MUTED    = Color( 160, 160, 170 )
ULib.COLOR_HIGHLIGHT = Color( 255, 180, 0  )
ULib.DEFAULT_TSAY_COLOR = ULib.COLOR_ACCENT
ULib.HOOK_UCLAUTH = "UCLAuthed"
ULib.HOOK_UCLCHANGED = "UCLChanged"
ULib.HOOK_ACCESS_REGISTERED = "UCLAccessRegistered"
ULib.HOOK_REPCVARCHANGED = "ULibReplicatedCvarChanged"
ULib.HOOK_LOCALPLAYERREADY = "ULibLocalPlayerReady"
ULib.HOOK_COMMAND_CALLED = "ULibCommandCalled"
ULib.HOOK_PLAYER_TARGET = "ULibPlayerTarget"
ULib.HOOK_PLAYER_TARGETS = "ULibPlayerTargets"
ULib.HOOK_POST_TRANSLATED_COMMAND = "ULibPostTranslatedCommand"
ULib.HOOK_PLAYER_NAME_CHANGED = "ULibPlayerNameChanged"
ULib.HOOK_GETUSERS_CUSTOM_KEYWORD = "ULibGetUsersCustomKeyword"
ULib.HOOK_GETUSER_CUSTOM_KEYWORD = "ULibGetUserCustomKeyword"
ULib.HOOK_USER_KICKED = "ULibPlayerKicked"
ULib.HOOK_USER_BANNED = "ULibPlayerBanned"
ULib.HOOK_USER_UNBANNED = "ULibPlayerUnBanned"
ULib.HOOK_GROUP_CREATED = "ULibGroupCreated"
ULib.HOOK_GROUP_REMOVED = "ULibGroupRemoved"
ULib.HOOK_GROUP_ACCESS_CHANGE = "ULibGroupAccessChanged"
ULib.HOOK_GROUP_RENAMED = "ULibGroupRenamed"
ULib.HOOK_GROUP_INHERIT_CHANGE = "ULibGroupInheritanceChanged"
ULib.HOOK_GROUP_CANTARGET_CHANGE = "ULibGroupCanTargetChanged"
ULib.HOOK_USER_GROUP_CHANGE = "ULibUserGroupChange"
ULib.HOOK_USER_ACCESS_CHANGE = "ULibUserAccessChange"
ULib.HOOK_USER_REMOVED = "ULibUserRemoved"
if SERVER then
ULib.UCL_LOAD_DEFAULT = true
ULib.UCL_USERS = "data/ulib/users.txt"
ULib.UCL_GROUPS = "data/ulib/groups.txt"
ULib.UCL_REGISTERED = "data/ulib/misc_registered.txt"
ULib.DEFAULT_GRANT_ACCESS = { allow={}, deny={}, guest=true }
end
if SERVER then
	util.AddNetworkString( "URPC" )
	util.AddNetworkString( "tsayc" )
	util.AddNetworkString( "ulib_repWriteCvar" )
	util.AddNetworkString( "ulib_repWriteCvarBatch_Part" )
	util.AddNetworkString( "ulib_repWriteCvarBatch_Complete" )
	util.AddNetworkString( "ulib_repChangeCvar" )
	util.AddNetworkString( "ulx_version_check" )
	util.AddNetworkString( "ulx_file_sync_manifest" )
end
ulx.VERSION = "2.72.0"
ulx.VERSION_STR = "v2.72.0"
if SERVER then
	ulx.SYNC_FILES = ulx.SYNC_FILES or {
		"ulx/shared/defines.lua", "ulx/shared/misc.lua", "ulx/shared/util.lua",
		"ulx/shared/hook.lua", "ulx/shared/tables.lua", "ulx/shared/player.lua",
		"ulx/shared/messages.lua", "ulx/shared/commands.lua", "ulx/shared/sh_ucl.lua",
		"ulx/shared/plugin.lua", "ulx/shared/cami_global.lua", "ulx/shared/cami_ulib.lua",
		"ulx/shared/ulx_defines.lua", "ulx/shared/ulx_base.lua",
		"ulx/shared/language.lua",
		"ulx/cl_init.lua",
		"ulx/client/cl_commands.lua", "ulx/client/cl_util.lua",
		"ulx/client/draw.lua", "ulx/client/ulx_cl_lib.lua",
		"ulx/modules/cl/motdmenu.lua", "ulx/modules/cl/uteam.lua",
		"ulx/modules/cl/xgui_client.lua", "ulx/modules/cl/xgui_helpers.lua",
		"ulx/modules/cl/xlib.lua",
		"ulx/modules/sh/chat.lua", "ulx/modules/sh/community.lua",
		"ulx/modules/sh/extras.lua", "ulx/modules/sh/fun.lua",
		"ulx/modules/sh/menus.lua", "ulx/modules/sh/rcon.lua",
		"ulx/modules/sh/teleport.lua", "ulx/modules/sh/user.lua",
		"ulx/modules/sh/userhelp.lua", "ulx/modules/sh/util.lua",
		"ulx/modules/sh/vote.lua", "ulx/modules/sh/bhop.lua",
		"ulx/modules/sh/crouchjump.lua", "ulx/modules/sh/coord.lua",
		"ulx/items/init.lua", "ulx/items/weapons_hl2.lua", "ulx/items/weapons_css.lua",
		"ulx/items/weapons_admin.lua", "ulx/items/tools.lua", "ulx/items/ammo.lua",
		"ulx/items/props.lua", "ulx/items/seats.lua", "ulx/items/vehicles.lua",
		"ulx/xgui/bans.lua", "ulx/xgui/commands.lua", "ulx/xgui/groups.lua",
		"ulx/xgui/items.lua", "ulx/xgui/maps.lua", "ulx/xgui/settings.lua",
		"ulx/xgui/xgui_core.lua", "ulx/xgui/framework/init.lua", "ulx/xgui/framework/layout.lua",
		"ulx/xgui/gamemodes/sandbox.lua",
		"ulx/xgui/settings/client.lua", "ulx/xgui/settings/server.lua",
	}
	ulx._sync_cache = ulx._sync_cache or {}
end