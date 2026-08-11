xgui.theme = xgui.theme or {}
xgui.theme.tokens = {
	canvas         = nil,
	surface1       = nil,
	surface2       = nil,
	surface3       = nil,
	hairline       = nil,
	hairlineStrong = nil,
	ink            = nil,
	muted          = nil,
	faint          = nil,
	accent         = nil,
	success        = nil,
	warning        = nil,
	danger         = nil,
}
function xgui.theme.register( name, painter )
	xgui.theme._registry = xgui.theme._registry or {}
	xgui.theme._registry[ name ] = painter
end
function xgui.theme.get( token, fallback )
	local v = xgui.theme.tokens and xgui.theme.tokens[ token ]
	if v ~= nil then
		return v
	end
	return fallback
end
function xgui.theme.getPainter( name )
	local reg = xgui.theme._registry
	if reg and reg[ name ] then
		return reg[ name ]
	end
	return nil
end
Msg( "[XGUI] theme 接入点已就绪（骨架，未启用）\n" )