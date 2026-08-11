ULib = ULib or {}
ULib.RELEASE = false
ULib.VERSION = 2.72
ulx = ulx or {}
ulx.VERSION = "2.98.51"
ulx.VERSION_STR = "v" .. ulx.VERSION
ulx.BUILD = "20260706"
ulx.BASE_ULX = "3.81"
ulx.BASE_ULIB = "2.72"
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
end
ulx.version = tonumber( ulx.BASE_ULX ) or 3.81
ulx.release = false
ulx.ID_ORIGINAL = 1
ulx.ID_PLAYER_HELP = 2
ulx.ID_HELP = 3
ulx.ID_MMAIN = 1
ulx.ID_MCLIENT = 2
ulx.ID_MADMIN = 3
ulx.HOOK_ULXDONELOADING = "ULXLoaded"
ulx.HOOK_VETO = "ULXVetoChanged"