local metatable_cache = setmetatable( {}, { __mode = "k" } )
local function make_getter( real_table )
	local function getter( dummy, key )
		local ret = real_table[ key ]
		if type( ret ) == "table" and not metatable_cache[ ret ] then
			ret = ULib.makeReadOnly( ret )
		end
		return ret
	end
	return getter
end
local function setter()
	ULib.error( "Attempt to modify read-only table!" )
end
local function make_pairs( real_table )
	local function pairs()
		local key, value, cur_key = nil, nil, nil
		local function nexter()
			key, value = next( real_table, cur_key )
			cur_key = key
			if type( key ) == "table" and not metatable_cache[ key ] then
				key = ULib.makeReadOnly( key )
			end
			if type( value ) == "table" and not metatable_cache[ value ] then
				value = ULib.makeReadOnly( value )
			end
			return key, value
		end
		return nexter
	end
	return pairs
end
function ULib.makeReadOnly( t )
	local new={}
	local mt={
		__metatable = "read only table",
		__index = make_getter( t ),
		__newindex = setter,
		__pairs = make_pairs( t ),
		__type = "read-only table" }
	setmetatable( new, mt )
	metatable_cache[ new ] = mt
	return new
end
function ULib.ropairs( t )
	local mt = metatable_cache[ t ]
	if mt==nil then
		ULib.error( "bad argument #1 to 'ropairs' (read-only table expected, got " .. type(t) .. ")" )
	end
	return mt.__pairs()
end
function ULib.findInTable( t, check, init, last, recursive )
	init = init or 1
	last = last or #t
	if init > last then return false end
	for i=init, last do
		if t[ i ] == check then return i end
		if type( t[ i ] ) == "table" and recursive then return ULib.findInTable( t[ i ], check, 1, nil, recursive ) end
	end
	return false
end
function ULib.matrixTable( t, columns )
	local baserows = math.floor( #t / columns )
	local remainder = math.fmod( #t, columns )
	local nt = {}
	local curn = 1
	for i=1, columns do
		local numtograb = baserows
		if i <= remainder then
			numtograb = baserows + 1
		end
		nt[ i ] = {}
		for n=0, numtograb - 1 do
			table.insert( nt[ i ], t[ curn + n ] )
		end
		curn = curn + numtograb
	end
	return nt
end