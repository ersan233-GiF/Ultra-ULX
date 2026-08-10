xgui.prepareDataType( "bans" )
local xbans = xlib.makepanel{ parent=xgui.null }
local function createBanlist()
	local banlist = xlib.makelistview{ x=5, y=30, w=572, h=310, multiselect=false, parent=xbans }
	banlist:AddColumn( xgui.T("bans_col_name") )
	banlist:AddColumn( xgui.T("bans_col_banner") )
	banlist:AddColumn( xgui.T("bans_col_unban") )
	banlist:AddColumn( xgui.T("bans_col_reason") )
	banlist.DoDoubleClick = function( self, LineID, line )
		xbans.ShowBanDetailsWindow( xgui.data.bans.cache[LineID] )
	end
	banlist.OnRowRightClick = function( self, LineID, line )
		local menu = DermaMenu()
		menu:SetSkin( xgui.settings.skin )
		menu:AddOption( xgui.T("bans_details"), function()
			if not line:IsValid() then return end
			xbans.ShowBanDetailsWindow( xgui.data.bans.cache[LineID] )
		end )
		menu:AddOption( xgui.T("bans_edit"), function()
			if not line:IsValid() then return end
			xgui.ShowBanWindow( nil, line:GetValue( 5 ), nil, true, xgui.data.bans.cache[LineID] )
		end )
		menu:AddOption( xgui.T("bans_remove"), function()
			if not line:IsValid() then return end
			xbans.RemoveBan( line:GetValue( 5 ), xgui.data.bans.cache[LineID] )
		end )
		menu:Open()
	end
	banlist.SortByColumn = function( self, ColumnID, Desc )
		local index = ColumnID == 1 and 2 or ColumnID == 2 and 4 or ColumnID == 3 and 6 or ColumnID == 4 and 5 or 1
		xbans.sortbox:ChooseOptionID( index )
	end
	return banlist
end
xbans.banlist = createBanlist()
local searchFilter = ""
xbans.searchbox = xlib.maketextbox{ x=5, y=6, w=175, text=xgui.T("bans_search"), selectall=true, parent=xbans }
local txtCol = xbans.searchbox:GetTextColor() or Color( 0, 0, 0, 255 )
xbans.searchbox:SetTextColor( Color( txtCol.r, txtCol.g, txtCol.b, 196 ) )
xbans.searchbox.OnChange = function( pnl )
	if pnl:GetText() == "" then
		pnl:SetText( xgui.T("bans_search") )
		pnl:SelectAll()
		pnl:SetTextColor( Color( txtCol.r, txtCol.g, txtCol.b, 196 ) )
	else
		pnl:SetTextColor( Color( txtCol.r, txtCol.g, txtCol.b, 255 ) )
	end
end
xbans.searchbox.OnLoseFocus = function( pnl )
	searchFilter = ( pnl:GetText() == xgui.T("bans_search") ) and "" or pnl:GetText()
	xbans.setPage( 1 )
	xbans.retrieveBans()
	hook.Call( "OnTextEntryLoseFocus", nil, pnl )
end
local sortMode = 0
local sortAsc = false
local sortOptions = { xgui.T("bans_sort_date"), xgui.T("bans_sort_name"), xgui.T("bans_sort_steamid"),
	xgui.T("bans_sort_admin"), xgui.T("bans_sort_reason"), xgui.T("bans_sort_unbandate"), xgui.T("bans_sort_length") }
xbans.sortbox = xlib.makecombobox{ x=185, y=6, w=150, text=xgui.T("bans_sort_label") .. sortOptions[1] .. xgui.T("bans_sort_desc"), choices=sortOptions, parent=xbans }
function xbans.sortbox:OnSelect( i, v )
	if i - 1 == sortMode then sortAsc = not sortAsc
	else sortMode = i - 1; sortAsc = false end
	self:SetValue( xgui.T("bans_sort_label") .. v .. ( sortAsc and xgui.T("bans_sort_asc") or xgui.T("bans_sort_desc") ) )
	xbans.setPage( 1 )
	xbans.retrieveBans()
end
local hidePerma = 0
local btnPermaFilter = xlib.makebutton{ x=355, y=6, w=95, label=xgui.T("bans_perma_show"), parent=xbans }
btnPermaFilter.DoClick = function( self )
	hidePerma = ( hidePerma + 1 ) % 3
	local texts = { xgui.T("bans_perma_show"), xgui.T("bans_perma_hide"), xgui.T("bans_perma_only") }
	self:SetText( texts[hidePerma + 1] )
	xbans.setPage( 1 )
	xbans.retrieveBans()
end
local hideIncomplete = 0
local btnIncompleteFilter = xlib.makebutton{ x=455, y=6, w=95, label=xgui.T("bans_incomplete_show"), parent=xbans, tooltip="Filter ban records without metadata." }
btnIncompleteFilter.DoClick = function( self )
	hideIncomplete = ( hideIncomplete + 1 ) % 3
	local texts = { xgui.T("bans_incomplete_show"), xgui.T("bans_incomplete_hide"), xgui.T("bans_incomplete_only") }
	self:SetText( texts[hideIncomplete + 1] )
	xbans.setPage( 1 )
	xbans.retrieveBans()
end
local function banUserList( doFreeze )
	local menu = DermaMenu()
	menu:SetSkin( xgui.settings.skin )
	for k, v in ipairs( player.GetAll() ) do
		menu:AddOption( v:Nick(), function()
			if not v:IsValid() then return end
			xgui.ShowBanWindow( v, v:SteamID(), doFreeze )
		end )
	end
	menu:AddSpacer()
	if LocalPlayer():query( "ulx banid" ) then
		menu:AddOption( xgui.T("bans_btn_banid"), function() xgui.ShowBanWindow() end )
	end
	menu:Open()
end
xbans.btnBan = xlib.makebutton{ x=5, y=340, w=70, label=xgui.T("bans_btn_ban"), parent=xbans }
xbans.btnBan.DoClick = function() banUserList( false ) end
xbans.btnFreezeBan = xlib.makebutton{ x=80, y=340, w=95, label=xgui.T("bans_btn_freeze_ban"), parent=xbans }
xbans.btnFreezeBan.DoClick = function() banUserList( true ) end
xbans.infoLabel = xlib.makelabel{ x=204, y=344, label=xgui.T("bans_right_click"), parent=xbans }
xbans.resultCount = xlib.makelabel{ y=344, parent=xbans }
function xbans.setResultCount( count )
	xbans.resultCount:SetText( count .. xgui.T("bans_result_count") )
	xbans.resultCount:SizeToContents()
	local width = xbans.resultCount:GetWide()
	xbans.resultCount:SetPos( 475 - width, xbans.resultCount:GetPos() )
	xbans.infoLabel:SetPos( ( 130 - width ) / 2 + 175, xbans.infoLabel:GetPos() )
end
local numPages = 1
local pageNumber = 1
xbans.pgleft = xlib.makebutton{ x=480, y=340, w=20, icon="icon16/arrow_left.png", centericon=true, disabled=true, parent=xbans }
xbans.pgleft.DoClick = function() xbans.setPage( pageNumber - 1 ); xbans.retrieveBans() end
xbans.pageSelector = xlib.makecombobox{ x=500, y=340, w=57, text="1", enableinput=true, parent=xbans }
function xbans.pageSelector:OnSelect( index ) xbans.setPage( index ); xbans.retrieveBans() end
function xbans.pageSelector.TextEntry:OnEnter()
	local pg = math.Clamp( tonumber( self:GetValue() ) or 1, 1, numPages )
	xbans.setPage( pg ); xbans.retrieveBans()
end
xbans.pgright = xlib.makebutton{ x=557, y=340, w=20, icon="icon16/arrow_right.png", centericon=true, disabled=true, parent=xbans }
xbans.pgright.DoClick = function() xbans.setPage( pageNumber + 1 ); xbans.retrieveBans() end
xbans.setPage = function( newPage )
	pageNumber = newPage
	xbans.pgleft:SetDisabled( pageNumber <= 1 )
	xbans.pgright:SetDisabled( pageNumber >= numPages )
	xbans.pageSelector.TextEntry:SetText( pageNumber )
end
function xbans.RemoveBan( ID, bandata )
	local tempstr = bandata and bandata.name or xgui.T("bans_unknown")
	Derma_Query( xgui.T("bans_confirm_unban") .. tempstr .. " - " .. ID .. "?",
		xgui.T("maps_warning_title"),
		xgui.T("bans_remove"), function() RunConsoleCommand( "ulx", "unban", ID ); xbans.RemoveBanDetailsWindow( ID ) end,
		xgui.T("maps_btn_cancel"), function() end )
end
xbans.openWindows = {}
function xbans.RemoveBanDetailsWindow( ID )
	if xbans.openWindows[ID] then xbans.openWindows[ID]:Remove(); xbans.openWindows[ID] = nil end
end
function xbans.ShowBanDetailsWindow( bandata )
	if not bandata then return end
	local wx, wy
	if xbans.openWindows[bandata.steamID] then
		wx, wy = xbans.openWindows[bandata.steamID]:GetPos()
		xbans.openWindows[bandata.steamID]:Remove()
	end
	xbans.openWindows[bandata.steamID] = xlib.makeframe{ label=xgui.T("bans_details"), x=wx, y=wy, w=285, h=295, skin=xgui.settings.skin }
	local panel = xbans.openWindows[bandata.steamID]
	local TL = xgui.T
	xlib.makelabel{ x=50, y=30, label=TL("bans_col_name") .. ":", parent=panel }
	xlib.makelabel{ x=90, y=30, w=190, label=( bandata.name or TL("bans_unknown") ), parent=panel, tooltip=bandata.name }
	xlib.makelabel{ x=36, y=50, label=TL("bans_steamid"), parent=panel }
	xlib.makelabel{ x=90, y=50, label=bandata.steamID, parent=panel }
	xlib.makelabel{ x=33, y=70, label=TL("bans_sort_date") .. ":", parent=panel }
	xlib.makelabel{ x=90, y=70, label=bandata.time and os.date( "%b %d, %Y - %I:%M:%S %p", tonumber( bandata.time ) ) or TL("bans_no_metadata"), parent=panel }
	xlib.makelabel{ x=20, y=90, label=TL("bans_col_unban") .. ":", parent=panel }
	xlib.makelabel{ x=90, y=90, label=( tonumber( bandata.unban ) == 0 and TL("bans_never") or os.date( "%b %d, %Y - %I:%M:%S %p", math.min( tonumber( bandata.unban ), 4294967295 ) ) ), parent=panel }
	xlib.makelabel{ x=10, y=110, label=TL("bans_sort_length") .. ":", parent=panel }
	xlib.makelabel{ x=90, y=110, label=( tonumber( bandata.unban ) == 0 and TL("bans_permanent") or xgui.ConvertTime( tonumber( bandata.unban ) - bandata.time ) ), parent=panel }
	xlib.makelabel{ x=33, y=130, label=TL("bans_remaining"), parent=panel }
	local timeleft = xlib.makelabel{ x=90, y=130, label=( tonumber( bandata.unban ) == 0 and TL("bans_na") or xgui.ConvertTime( tonumber( bandata.unban ) - os.time() ) ), parent=panel }
	xlib.makelabel{ x=26, y=150, label=TL("bans_col_banner") .. ":", parent=panel }
	if bandata.admin then xlib.makelabel{ x=90, y=150, label=string.gsub( bandata.admin, "%(STEAM_%w:%w:%w*%)", "" ), parent=panel } end
	if bandata.admin then xlib.makelabel{ x=90, y=165, label=string.match( bandata.admin, "%(STEAM_%w:%w:%w*%)" ), parent=panel } end
	xlib.makelabel{ x=41, y=185, label=TL("bans_col_reason") .. ":", parent=panel }
	xlib.makelabel{ x=90, y=185, w=190, label=bandata.reason, parent=panel, tooltip=bandata.reason ~= "" and bandata.reason or nil }
	xlib.makelabel{ x=13, y=205, label=TL("bans_last_modified"), parent=panel }
	xlib.makelabel{ x=90, y=205, label=( bandata.modified_time == nil and TL("bans_never") or os.date( "%b %d, %Y - %I:%M:%S %p", tonumber( bandata.modified_time ) ) ), parent=panel }
	xlib.makelabel{ x=21, y=225, label=TL("bans_modified_by"), parent=panel }
	if bandata.modified_admin then xlib.makelabel{ x=90, y=225, label=string.gsub( bandata.modified_admin, "%(STEAM_%w:%w:%w*%)", "" ), parent=panel } end
	if bandata.modified_admin then xlib.makelabel{ x=90, y=240, label=string.match( bandata.modified_admin, "%(STEAM_%w:%w:%w*%)" ), parent=panel } end
	panel.data = bandata
	xlib.makebutton{ x=5, y=265, w=89, label=TL("bans_edit"), parent=panel }.DoClick = function()
		xgui.ShowBanWindow( nil, panel.data.steamID, nil, true, panel.data )
	end
	xlib.makebutton{ x=99, y=265, w=89, label=TL("bans_unban_btn"), parent=panel }.DoClick = function()
		xbans.RemoveBan( panel.data.steamID, panel.data )
	end
	xlib.makebutton{ x=192, y=265, w=88, label=TL("ui_close"), parent=panel }.DoClick = function()
		xbans.RemoveBanDetailsWindow( panel.data.steamID )
	end
	panel.btnClose.DoClick = function() xbans.RemoveBanDetailsWindow( panel.data.steamID ) end
	if timeleft:GetValue() ~= TL("bans_na") then
		function panel.OnTimer()
			if panel:IsVisible() then
				local bantime = tonumber( panel.data.unban ) - os.time()
				if bantime <= 0 then xbans.RemoveBanDetailsWindow( panel.data.steamID ); return
				else timeleft:SetText( xgui.ConvertTime( bantime ) ) end
				timeleft:SizeToContents()
				timer.Simple( 1, panel.OnTimer )
			end
		end
		panel.OnTimer()
	end
end
function xbans.retrieveBans()
	RunConsoleCommand( "_xgui", "getBans", pageNumber, searchFilter, sortMode, sortAsc and "1" or "0", hidePerma, hideIncomplete )
end
xgui.registerRefresh( "bans", function()
	for i = 1, 4 do
		local col = xbans.banlist.Columns[i]
		if col and col.Header then
			local keys = { "bans_col_name", "bans_col_banner", "bans_col_unban", "bans_col_reason" }
			col.Header:SetText( xgui.T(keys[i]) )
		end
	end
	xbans.searchbox:SetText( xgui.T("bans_search") )
	xbans.searchbox:SelectAll()
	local newSortOpts = { xgui.T("bans_sort_date"), xgui.T("bans_sort_name"), xgui.T("bans_sort_steamid"),
		xgui.T("bans_sort_admin"), xgui.T("bans_sort_reason"), xgui.T("bans_sort_unbandate"), xgui.T("bans_sort_length") }
	xbans.sortbox:Clear()
	for _, v in ipairs( newSortOpts ) do xbans.sortbox:AddChoice( v ) end
	xbans.sortbox:SetText( xgui.T("bans_sort_label") .. newSortOpts[sortMode + 1] .. ( sortAsc and xgui.T("bans_sort_asc") or xgui.T("bans_sort_desc") ) )
	xbans.btnBan:SetText( xgui.T("bans_btn_ban") )
	xbans.infoLabel:SetText( xgui.T("bans_right_click") )
	xbans.btnFreezeBan:SetText( xgui.T("bans_btn_freeze_ban") )
	local permaTexts = { xgui.T("bans_perma_show"), xgui.T("bans_perma_hide"), xgui.T("bans_perma_only") }
	btnPermaFilter:SetText( permaTexts[hidePerma + 1] or xgui.T("bans_perma_show") )
	local incTexts = { xgui.T("bans_incomplete_show"), xgui.T("bans_incomplete_hide"), xgui.T("bans_incomplete_only") }
	btnIncompleteFilter:SetText( incTexts[hideIncomplete + 1] or xgui.T("bans_incomplete_show") )
end )
xgui.addModule( "bans", xbans, "icon16/delete.png" )
function xgui.ShowBanWindow( ply, ID, doFreeze, isUpdate, bandata )
	if not LocalPlayer():query( "ulx ban" ) and not LocalPlayer():query( "ulx banid" ) then return end
	local xgui_banwindow = xlib.makeframe{ label=( isUpdate and "编辑封禁" or "封禁玩家" ), w=285, h=180, skin=xgui.settings.skin }
	xlib.makelabel{ x=37, y=33, label="玩家名称:", parent=xgui_banwindow }
	xlib.makelabel{ x=23, y=58, label="SteamID:", parent=xgui_banwindow }
	xlib.makelabel{ x=28, y=83, label="封禁原因:", parent=xgui_banwindow }
	xlib.makelabel{ x=10, y=108, label="封禁时长:", parent=xgui_banwindow }
	local reason = xlib.makecombobox{ x=75, y=80, w=200, parent=xgui_banwindow, enableinput=true, selectall=true, choices=ULib.cmds.translatedCmds["ulx ban"].args[4].completes }
	local banpanel = ULib.cmds.NumArg.x_getcontrol( ULib.cmds.translatedCmds["ulx ban"].args[3], 2, xgui_banwindow )
	banpanel.interval:SetParent( xgui_banwindow )
	banpanel.interval:SetPos( 200, 105 )
	banpanel.val:SetParent( xgui_banwindow )
	banpanel.val:SetPos( 75, 125 )
	banpanel.val:SetWidth( 200 )
	local name
	if not isUpdate then
		name = xlib.makecombobox{ x=75, y=30, w=200, parent=xgui_banwindow, enableinput=true, selectall=true }
		for k,v in pairs( player.GetAll() ) do
			name:AddChoice( v:Nick(), v:SteamID() )
		end
		name.OnSelect = function( self, index, value, data )
			self.steamIDbox:SetText( data )
		end
	else
		name = xlib.maketextbox{ x=75, y=30, w=200, parent=xgui_banwindow, selectall=true }
		if bandata then
			name:SetText( bandata.name or "" )
			reason:SetText( bandata.reason or "" )
			if tonumber( bandata.unban ) ~= 0 then
				local btime = ( tonumber( bandata.unban ) - tonumber( bandata.time ) )
				if btime % 31536000 == 0 then
					if #banpanel.interval.Choices >= 6 then banpanel.interval:ChooseOptionID(6) else banpanel.interval:SetText( "年" ) end
					btime = btime / 31536000
				elseif btime % 604800 == 0 then
					if #banpanel.interval.Choices >= 5 then banpanel.interval:ChooseOptionID(5) else banpanel.interval:SetText( "周" ) end
					btime = btime / 604800
				elseif btime % 86400 == 0 then
					if #banpanel.interval.Choices >= 4 then banpanel.interval:ChooseOptionID(4) else banpanel.interval:SetText( "天" ) end
					btime = btime / 86400
				elseif btime % 3600 == 0 then
					if #banpanel.interval.Choices >= 3 then banpanel.interval:ChooseOptionID(3) else banpanel.interval:SetText( "小时" ) end
					btime = btime / 3600
				else
					btime = btime / 60
					if #banpanel.interval.Choices >= 2 then banpanel.interval:ChooseOptionID(2) else banpanel.interval:SetText( "分钟" ) end
				end
				banpanel.val:SetValue( btime )
			end
		end
	end
	local steamID = xlib.maketextbox{ x=75, y=55, w=200, selectall=true, disabled=( isUpdate or not LocalPlayer():query( "ulx banid" ) ), parent=xgui_banwindow }
	name.steamIDbox = steamID
	if doFreeze and ply then
		if LocalPlayer():query( "ulx freeze" ) then
			RunConsoleCommand( "ulx", "freeze", "$" .. ULib.getUniqueIDForPlayer( ply ) )
			steamID:SetDisabled( true )
			name:SetDisabled( true )
			xgui_banwindow:ShowCloseButton( false )
		else
			doFreeze = false
		end
	end
	xlib.makebutton{ x=165, y=150, w=75, label="取消", parent=xgui_banwindow }.DoClick = function()
		if doFreeze and ply and ply:IsValid() then
			RunConsoleCommand( "ulx", "unfreeze", "$" .. ULib.getUniqueIDForPlayer( ply ) )
		end
		xgui_banwindow:Remove()
	end
	xlib.makebutton{ x=45, y=150, w=75, label=( isUpdate and "更新" or "封禁!" ), parent=xgui_banwindow }.DoClick = function()
		if isUpdate then
			local function performUpdate(btime)
				RunConsoleCommand( "_xgui", "updateBan", steamID:GetValue(), btime, reason:GetValue(), name:GetValue() )
				xgui_banwindow:Remove()
			end
			local btime = banpanel:GetMinutes()
			if btime ~= 0 and bandata and btime * 60 + bandata.time < os.time() then
				Derma_Query( "警告！您指定的新封禁时间将导致此封禁到期。\n确定要继续吗？", "XGUI 警告",
					"到期封禁", function() performUpdate(btime); xbans.RemoveBanDetailsWindow( bandata.steamID ) end,
					"取消", function() end )
			else
				performUpdate(btime)
			end
			return
		end
		if ULib.isValidSteamID( steamID:GetValue() ) then
			local isOnline = false
			for k, v in ipairs( player.GetAll() ) do
				if v:SteamID() == steamID:GetValue() then isOnline = v; break end
			end
			if not isOnline then
				RunConsoleCommand( "ulx", "banid", steamID:GetValue(), banpanel:GetValue(), reason:GetValue() )
			else
				RunConsoleCommand( "ulx", "ban", "$" .. ULib.getUniqueIDForPlayer( isOnline ), banpanel:GetValue(), reason:GetValue() )
			end
			xgui_banwindow:Remove()
		else
			local tply, message = ULib.getUser( name:GetValue() )
			if tply then
				RunConsoleCommand( "ulx", "ban", "$" .. ULib.getUniqueIDForPlayer( tply ), banpanel:GetValue(), reason:GetValue() )
				xgui_banwindow:Remove()
				return
			end
			Derma_Message( message )
		end
	end
	if ply then name:SetText( ply:Nick() ) end
	if ID then steamID:SetText( ID ) else steamID:SetText( "STEAM_0:" ) end
end
function xgui.ConvertTime( seconds )
	local years = math.floor( seconds / 31536000 )
	seconds = seconds - ( years * 31536000 )
	local weeks = math.floor( seconds / 604800 )
	seconds = seconds - ( weeks * 604800 )
	local days = math.floor( seconds / 86400 )
	seconds = seconds - ( days * 86400 )
	local hours = math.floor( seconds/3600 )
	seconds = seconds - ( hours * 3600 )
	local minutes = math.floor( seconds/60 )
	seconds = seconds - ( minutes * 60 )
	local curtime = ""
	if years ~= 0 then curtime = curtime .. years .. " year" .. ( ( years > 1 ) and "s, " or ", " ) end
	if weeks ~= 0 then curtime = curtime .. weeks .. " week" .. ( ( weeks > 1 ) and "s, " or ", " ) end
	if days ~= 0 then curtime = curtime .. days .. " day" .. ( ( days > 1 ) and "s, " or ", " ) end
	curtime = curtime .. ( ( hours < 10 ) and "0" or "" ) .. hours .. ":"
	curtime = curtime .. ( ( minutes < 10 ) and "0" or "" ) .. minutes .. ":"
	return curtime .. ( ( seconds < 10 and "0" or "" ) .. seconds )
end