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
local modname=...
class'object'()
package.loaded[modname] = object

local signal = require'lak.signal'

function object:_init()
end
------------------------------------------------------------------------
--  signal functions
--  object._sigs is a table contained all signals supported by object.
------------------------------------------------------------------------
function object:connect(name,...)
	self._sigs = self._sigs or {}
	local sigs = self._sigs
	sigs[name] = sigs[name] or signal:new()
	sigs[name]:connect(...)
end

function object:disconnect(name,...)
	if not self._sigs then return end
	if not self._sigs[name] then return end
	self._sigs[name]:disconnect(...)
end

function object:emit(name,...)
	if not self._sigs then return end
	if not self._sigs[name] then return end
	self._sigs[name](self,...)
end

function object:connectx(ctx, name,...)
	assert(type(ctx) ~= 'string')
	self._sigs    = self._sigs or {}
	local sigs    = self._sigs
	local ctxsigs = sigs[ctx] or {}
	sigs[ctx]     = ctxsigs
	ctxsigs[name] = ctxsigs[name] or signal:new()
	ctxsigs[name]:connect(...)
end

function object:disconnectx(ctx, name,...)
	assert(type(ctx) ~= 'string')
	if not self._sigs then return end
	local ctxsigs = self._sigs[ctx]
	if not ctxsigs then return end
	if not ctxsigs[name] then return end
	ctxsigs[name]:disconnect(...)
end

function object:emitx(ctx, name,...)
	if not self._sigs then return end
	local ctxsigs = self._sigs[ctx]
	if not ctxsigs then return end
	if not ctxsigs[name] then return end
	ctxsigs[name](self,...)
end
