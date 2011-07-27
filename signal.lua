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

------------------------------------------------------------------------
-- callback should return a bool, if bool is false then callback will be 
-- disconnected.
------------------------------------------------------------------------
local modname = ...
local signal = {__mode='k'}
signal.__index = signal
package.loaded[modname] = signal

local select,setmetatable,pairs,ipairs,type =
			select,setmetatable,pairs,ipairs,type

function signal:new(o)
	local o = o or {}
	setmetatable(o, signal)
	return o
end

local function flistcall(flist,...)
	if not flist then return end
	local i = 1
	while flist[i] do
		if flist[i](...) == false then 
			flist[i] = flist[#flist]
			flist[#flist] = nil
		else
			i = i + 1
		end
	end
end

function signal:__call(...)
	local flist = self.flist
	flistcall(self.flist,...)

	self.flist = nil
	for k,v in pairs(self) do
		flistcall(v,k,...)
	end
	self.flist = flist
end

function signal:connect(...)
	local one, two = select(1,...), select(2,...)
	if not two then -- connect function
		local flist = self.flist or {}
		flist[#flist+1] = one
		self.flist = flist
	else -- connect member function
		local t = self[one] or {}
		if type(two) == 'function' then
			t[#t+1] = two
		else
			t[#t+1] = one[two]
		end
		self[one] = t
	end
end
function signal:disconnect(...)
	local slot, func = select(1,...), select(2,...)
	if type(slot) == 'table' then
		local t = self[slot]
		if not t then return end
		if not func then
			self[slot] = nil
		else
			if type(func) ~= 'function' then func = slot[func] end
			for i,v in ipairs(t) do
				if v == func then
					t[i] = t[#t]
					t[#t] = nil
					return
				end
			end
		end
	else --disconnect a function
		if not self.flist then return end
		for i,v in ipairs(self.flist) do
			if v == slot then
				self.flist[i] = self.flist[#self.flist]
				self.flist[#self.flist] = nil
				return
			end
		end
	end
end
