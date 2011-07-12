--[[
http://www.opensource.org/licenses/mit-license.php

The MIT License

Copyright (c) 2011 Zhu Ya Dong

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
]]--
local function search(k,plist)
	for i=1,#plist do
		local v = plist[i][k]
		if v then return v end
	end
end

local class = {}
setmetatable(class, class)
function class:__call(name)
	local _,pkgname = debug.getlocal(2,1)
	local fenv = getfenv(2)
	return function (...)
		local c = {}
		local plist = {...}
		c.__index = function (t,k)
			local v
			local _get = rawget(c, '_get')
			if _get then
				v = _get(t,k)
			end
			if not v then
				v = rawget(c,k) or search(k, plist)
				rawset(t,k,v) --cache it
			end
			return v
		end
		c.__newindex = function (t,k,v)
			local _set = rawget(c, '_set')
			if _set then
				_set(t,k,v)
			else
				rawset(t,k,v)
			end
		end
		c._tostring = function ()
			return pkgname and string.format('<%s:%s>', pkgname, name)
			or string.format('<%s>', name)
		end
		fenv[name] = c
		setmetatable(c, {
			__call = function (t, ...)
				local o = {}
				local _init = rawget(t, '_init')
				setmetatable(o, t)
				if _init then o = _init(o, ...) or o end
				return o
			end,
		})
		return c
	end
end

local type, tostring = type, tostring
function class.type(o)
	local stype = type(o)
	if stype ~= 'table' then return stype end
	local mt = getmetatable(o)
	if not mt or not mt._tostring then return stype end
	return stype, mt._tostring()
end
function class.tostring(o)
	local st, smt = class.type(o)
	if not smt then return tostring(o) end
	return string.format('%s%s', smt, tostring(o))
end
_G.class = class
_G.tostring = class.tostring
_G.type = class.type
return class
