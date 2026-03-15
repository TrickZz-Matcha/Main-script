--[[
    library.lua — matcha edition
    Modern sidebar navigation UI for Roblox Drawing API
    Design inspired by Argon Hub X aesthetic
]]

UILib = {
    -- state
    _drawings          = {},
    _tree              = {},        -- { [tabName] = { _label=str, _items={...} } }
    _tab_order         = {},        -- ordered list of tab names
    _open_tab          = nil,
    _menu_open         = true,
    _menu_toggled_at   = 0,
    _tab_change_at     = 0,

    -- input
    _inputs = {['m1']={id=0x01,held=false,click=false},['m2']={id=0x02,held=false,click=false},['unbound']={id=0x08,held=false,click=false},['tab']={id=0x09,held=false,click=false},['enter']={id=0x0D,held=false,click=false},['shift']={id=0x10,held=false,click=false},['lshift']={id=0xA0,held=false,click=false},['rshift']={id=0xA1,held=false,click=false},['lctrl']={id=0xA2,held=false,click=false},['rctrl']={id=0xA3,held=false,click=false},['ctrl']={id=0x11,held=false,click=false},['esc']={id=0x1B,held=false,click=false},['space']={id=0x20,held=false,click=false},['left']={id=0x25,held=false,click=false},['up']={id=0x26,held=false,click=false},['right']={id=0x27,held=false,click=false},['down']={id=0x28,held=false,click=false},['delete']={id=0x2E,held=false,click=false},['0']={id=0x30,held=false,click=false},['1']={id=0x31,held=false,click=false},['2']={id=0x32,held=false,click=false},['3']={id=0x33,held=false,click=false},['4']={id=0x34,held=false,click=false},['5']={id=0x35,held=false,click=false},['6']={id=0x36,held=false,click=false},['7']={id=0x37,held=false,click=false},['8']={id=0x38,held=false,click=false},['9']={id=0x39,held=false,click=false},['a']={id=0x41,held=false,click=false},['b']={id=0x42,held=false,click=false},['c']={id=0x43,held=false,click=false},['d']={id=0x44,held=false,click=false},['e']={id=0x45,held=false,click=false},['f']={id=0x46,held=false,click=false},['g']={id=0x47,held=false,click=false},['h']={id=0x48,held=false,click=false},['i']={id=0x49,held=false,click=false},['j']={id=0x4A,held=false,click=false},['k']={id=0x4B,held=false,click=false},['l']={id=0x4C,held=false,click=false},['m']={id=0x4D,held=false,click=false},['n']={id=0x4E,held=false,click=false},['o']={id=0x4F,held=false,click=false},['p']={id=0x50,held=false,click=false},['q']={id=0x51,held=false,click=false},['r']={id=0x52,held=false,click=false},['s']={id=0x53,held=false,click=false},['t']={id=0x54,held=false,click=false},['u']={id=0x55,held=false,click=false},['v']={id=0x56,held=false,click=false},['w']={id=0x57,held=false,click=false},['x']={id=0x58,held=false,click=false},['y']={id=0x59,held=false,click=false},['z']={id=0x5A,held=false,click=false},['f1']={id=0x70,held=false,click=false},['f2']={id=0x71,held=false,click=false},['f3']={id=0x72,held=false,click=false},['f4']={id=0x73,held=false,click=false},['f5']={id=0x74,held=false,click=false},['f6']={id=0x75,held=false,click=false},['f7']={id=0x76,held=false,click=false},['f8']={id=0x77,held=false,click=false},['f9']={id=0x78,held=false,click=false},['f10']={id=0x79,held=false,click=false},['f11']={id=0x7A,held=false,click=false},['f12']={id=0x7B,held=false,click=false},['semicolon']={id=0xBA,held=false,click=false},['plus']={id=0xBB,held=false,click=false},['comma']={id=0xBC,held=false,click=false},['minus']={id=0xBD,held=false,click=false},['period']={id=0xBE,held=false,click=false},['slash']={id=0xBF,held=false,click=false},['tilde']={id=0xC0,held=false,click=false},['lbracket']={id=0xDB,held=false,click=false},['backslash']={id=0xDC,held=false,click=false},['rbracket']={id=0xDD,held=false,click=false},['quote']={id=0xDE,held=false,click=false}},
    _slider_drag       = nil,
    _menu_drag         = nil,
    _input_ctx         = nil,
    _search_query      = '',
    _active_dropdown   = nil,
    _active_colorpicker= nil,
    _copied_color      = nil,
    _notifications     = {},
    _notifications_spawned = 0,
    _scroll_offset     = 0,   -- content scroll
    _scroll_target     = 0,
    _scroll_delta      = 0,   -- accumulated wheel ticks
    _wheel_conn        = nil, -- wheel event connections

    -- profile shown in sidebar footer
    username  = 'Player',
    subtext   = '',

    -- menu title shown top-left of sidebar
    title     = 'matcha',
    subtitle  = 'v1.0',

    -- layout
    w           = 580,
    h           = 420,
    x           = 100,
    y           = 100,
    _sidebar_w  = 145,
    _padding    = 10,
    _item_h     = 54,   -- height of a toggle row with subtitle
    _corner_r   = 8,    -- global corner radius
    _menu_key   = 'f1',

    -- font
    _font       = Drawing.Fonts.System,
    _font_size  = 13,

    -- theming
    _t = {
        bg          = Color3.fromRGB(18,  18,  20),   -- outer window
        sidebar     = Color3.fromRGB(22,  22,  25),   -- sidebar panel
        content     = Color3.fromRGB(26,  26,  30),   -- content area
        card        = Color3.fromRGB(32,  32,  38),   -- item card bg
        card_hover  = Color3.fromRGB(38,  38,  46),   -- hovered card
        accent      = Color3.fromRGB(80,  200, 120),  -- green
        accent_dim  = Color3.fromRGB(40,  100, 60),   -- dim accent
        text        = Color3.fromRGB(240, 240, 245),
        subtext     = Color3.fromRGB(120, 120, 130),
        divider     = Color3.fromRGB(40,  40,  48),
        nav_active  = Color3.fromRGB(36,  36,  44),
        nav_text    = Color3.fromRGB(150, 150, 160),
        nav_active_text = Color3.fromRGB(240,240,245),
        toggle_off  = Color3.fromRGB(55,  55,  65),
        toggle_on   = Color3.fromRGB(80,  200, 120),
        search_bg   = Color3.fromRGB(30,  30,  36),
        title_text  = Color3.fromRGB(255, 255, 255),
    },
}

-- ─────────────────────────────────────────────
-- UTILS
-- ─────────────────────────────────────────────

local function clamp(x,a,b) return x<a and a or (x>b and b or x) end
local function lerp(a,b,t)  return a+(b-a)*t end

local function rgbToHsv(r,g,b)
    local max=math.max(r,g,b); local min=math.min(r,g,b)
    local h,s,v=0,0,max; local d=max-min
    if max~=0 then s=d/max end
    if d~=0 then
        if max==r then h=(g-b)/d; if g<b then h=h+6 end
        elseif max==g then h=(b-r)/d+2
        else h=(r-g)/d+4 end
        h=h/6
    end
    return h,s,v
end

-- ─────────────────────────────────────────────
-- DRAWING PRIMITIVES
-- ─────────────────────────────────────────────

local PI   = math.pi
local FANS = 7   -- triangles per corner quarter

local function _getOrCreate(drawings, id, dType)
    if not drawings[id] then
        local ok, d = pcall(Drawing.new, dType)
        if ok and d then
            d.Visible = false
            drawings[id] = d
        else
            return nil
        end
    end
    return drawings[id]
end

-- Safe property setter: silently ignores unsupported properties
local function _set(obj, prop, val)
    if obj == nil then return end
    pcall(function() obj[prop] = val end)
end

-- filled rounded rect using strip + 4 corner fans
function UILib:_RRect(id, x, y, w, h, col, z, r, alpha)
    if not x or not y or not col or not z then return end
    if not w or not h or w <= 0 or h <= 0 then return end
    if r and r < 0 then r = 0 end
    r = math.min(r or self._corner_r, math.floor(math.min(w,h)/2))
    alpha = alpha or 1
    local function setRect(sid, rx, ry, rw, rh)
        if not rw or rw<=0 or not rh or rh<=0 then return end
        local o = _getOrCreate(self._drawings, sid, 'Square')
        if not o then return end
        _set(o,'Position',Vector2.new(rx,ry)); _set(o,'Size',Vector2.new(rw,rh))
        _set(o,'Filled',true); _set(o,'Color',col); _set(o,'ZIndex',z)
        _set(o,'Transparency', 1 - alpha)  -- Drawing: 0=opaque, 1=transparent
        _set(o,'Visible',true)
    end
    local function setTri(sid, a, b, c)
        local o = _getOrCreate(self._drawings, sid, 'Triangle')
        if not o then return end
        _set(o,'PointA',a); _set(o,'PointB',b); _set(o,'PointC',c)
        _set(o,'Filled',true); _set(o,'Color',col); _set(o,'ZIndex',z)
        _set(o,'Transparency', 1 - alpha)  -- Drawing: 0=opaque, 1=transparent
        _set(o,'Visible',true)
    end
    -- strips
    setRect(id..'_s0', x,   y+r, w,   h-2*r)
    setRect(id..'_s1', x+r, y,   w-2*r, r)
    setRect(id..'_s2', x+r, y+h-r, w-2*r, r)
    -- corners: TL, TR, BR, BL
    local corners = {
        {cx=x+r,   cy=y+r,   a0=PI},
        {cx=x+w-r, cy=y+r,   a0=PI*3/2},
        {cx=x+w-r, cy=y+h-r, a0=0},
        {cx=x+r,   cy=y+h-r, a0=PI/2},
    }
    for ci, cn in ipairs(corners) do
        for i=1,FANS do
            local a0 = cn.a0+(i-1)*(PI/2)/FANS
            local a1 = cn.a0+i*(PI/2)/FANS
            setTri(id..'_c'..ci..'_'..i,
                Vector2.new(cn.cx, cn.cy),
                Vector2.new(cn.cx+math.cos(a0)*r, cn.cy+math.sin(a0)*r),
                Vector2.new(cn.cx+math.cos(a1)*r, cn.cy+math.sin(a1)*r))
        end
    end
end

-- hide all sub-draws for a rounded rect
function UILib:_HideRRect(id)
    for _, s in ipairs({'_s0','_s1','_s2'}) do
        local o=self._drawings[id..s]; if o then pcall(function() o.Visible=false end) end
    end
    for ci=1,4 do for i=1,FANS do
        local o=self._drawings[id..'_c'..ci..'_'..i]; if o then pcall(function() o.Visible=false end) end
    end end
end

-- set opacity for all sub-draws
function UILib:_RRectOpacity(id, alpha)
    -- alpha: 1=opaque  →  Drawing.Transparency = 1-alpha
    for _, s in ipairs({'_s0','_s1','_s2'}) do
        local o=self._drawings[id..s]; if o then pcall(function() o.Transparency=1-alpha end) end
    end
    for ci=1,4 do for i=1,FANS do
        local o=self._drawings[id..'_c'..ci..'_'..i]; if o then pcall(function() o.Transparency=1-alpha end) end
    end end
end

-- unfilled rounded rect outline (4 lines)
function UILib:_RRectOutline(id, x, y, w, h, col, z, r, alpha)
    if not x or not y or not col or not z then return end
    if not w or not h or w <= 0 or h <= 0 then return end
    r = math.min(r or self._corner_r, math.floor(math.min(w,h)/2))
    if r < 0 then r = 0 end
    alpha = alpha or 1
    local segs = {
        {Vector2.new(x+r,y),       Vector2.new(x+w-r,y)},
        {Vector2.new(x+w,y+r),     Vector2.new(x+w,y+h-r)},
        {Vector2.new(x+r,y+h),     Vector2.new(x+w-r,y+h)},
        {Vector2.new(x,y+r),       Vector2.new(x,y+h-r)},
    }
    for i,seg in ipairs(segs) do
        local o = _getOrCreate(self._drawings, id..'_ol'..i, 'Line')
        if not o then continue end
        _set(o,'From',seg[1]); _set(o,'To',seg[2]); _set(o,'Color',col); _set(o,'ZIndex',z)
        _set(o,'Thickness',1); _set(o,'Filled',1)
        _set(o,'Transparency', 1-alpha); _set(o,'Visible',true)
    end
end

-- plain text
function UILib:_Text(id, x, y, text, col, z, size, center, outline, alpha)
    if not x or not y or not col or not z then return end
    local o = _getOrCreate(self._drawings, id, 'Text')
    if not o then return end
    _set(o,'Position',Vector2.new(x,y)); _set(o,'Text',tostring(text or ''))
    _set(o,'Color',col); _set(o,'ZIndex',z)
    _set(o,'Size',size or self._font_size or 13); _set(o,'Font',self._font or Drawing.Fonts.Plex)
    _set(o,'Center',center or false); _set(o,'Outline',outline or false)
    _set(o,'Transparency', 1-(alpha or 1)); _set(o,'Visible',true)
end

-- pill toggle (rounded rect track + circle thumb)
function UILib:_Toggle(id, x, y, value, col_on, col_off, z, alpha)
    if not x or not y or not col_on or not col_off or not z then return end
    local tw, th = 34, 18
    local trackCol = value and col_on or col_off
    self:_RRect(id..'_track', x, y, tw, th, trackCol, z, th/2, alpha or 1)
    local thumbX = value and (x+tw-th+2) or (x+2)
    self:_RRect(id..'_thumb', thumbX, y+2, th-4, th-4, Color3.fromRGB(255,255,255), z+1, (th-4)/2, alpha or 1)
end

-- line
function UILib:_Line(id, x1, y1, x2, y2, col, z, alpha)
    if not x1 or not y1 or not x2 or not y2 or not col or not z then return end
    local o = _getOrCreate(self._drawings, id, 'Line')
    if not o then return end
    _set(o,'From',Vector2.new(x1,y1)); _set(o,'To',Vector2.new(x2,y2))
    _set(o,'Color',col); _set(o,'ZIndex',z)
    _set(o,'Thickness',1); _set(o,'Filled',1)
    _set(o,'Transparency', 1-(alpha or 1)); _set(o,'Visible',true)
end

-- hide a single drawing
function UILib:_Hide(id)
    local o=self._drawings[id]; if o then pcall(function() o.Visible=false end) end
end

-- hide all drawings whose key starts with prefix
function UILib:_HidePrefix(prefix)
    for k,o in pairs(self._drawings) do
        if k:sub(1,#prefix)==prefix then pcall(function() o.Visible=false end) end
    end
end

-- set opacity for all drawings with prefix
function UILib:_OpacityPrefix(prefix, alpha)
    -- alpha: 1=opaque, 0=transparent  →  Drawing.Transparency = 1-alpha
    for k,o in pairs(self._drawings) do
        if k:sub(1,#prefix)==prefix then pcall(function() o.Transparency=1-alpha end) end
    end
end

-- remove (destroy) all drawings with prefix
function UILib:_RemovePrefix(prefix)
    for k,o in pairs(self._drawings) do
        if k:sub(1,#prefix)==prefix then o:Remove(); self._drawings[k]=nil end
    end
end

-- text bounds estimate
function UILib:_TBounds(text, size)
    size = size or self._font_size or 13
    text = tostring(text or '')
    return Vector2.new(#text * size * 0.55, size)
end

-- ─────────────────────────────────────────────
-- INPUT
-- ─────────────────────────────────────────────

function UILib:_KeyIDToName(id)
    for n,k in pairs(self._inputs) do if k.id==id then return n end end
end

function UILib:_Pressed(key)  return self._inputs[key] and self._inputs[key].click end
function UILib:_Held(key)     return self._inputs[key] and self._inputs[key].held  end

function UILib:_Mouse()
    local p=game:GetService('Players').LocalPlayer
    if p then local m=p:GetMouse(); if m then return Vector2.new(m.X,m.Y) end end
    return Vector2.new()
end

function UILib:_Screen()
    local c=workspace.CurrentCamera
    return (c and c.ViewportSize) or Vector2.new(1920,1080)
end

function UILib:_InBounds(ox,oy,ow,oh)
    local mp=self:_Mouse()
    return mp.X>=ox and mp.X<=ox+ow and mp.Y>=oy and mp.Y<=oy+oh
end

-- ─────────────────────────────────────────────
-- COLORPICKER & DROPDOWN  (floating popups)
-- ─────────────────────────────────────────────

function UILib:_SpawnColorpicker(px, py, label, value, callback)
    self:_HidePrefix('cp_')
    local h,s,v=0,0,0
    if value then h,s,v=rgbToHsv(value.R,value.G,value.B) end
    self._active_colorpicker={ x=px, y=py, label=label, callback=callback, _h=h, _s=s, _v=v, _at=os.clock() }
end

function UILib:_KillColorpicker()
    self._active_colorpicker=nil; self:_HidePrefix('cp_')
end

function UILib:_SpawnDropdown(px, py, w, value, choices, multi, callback)
    self:_HidePrefix('dd_')
    self._active_dropdown={ x=px, y=py, w=w, value=value, choices=choices, multi=multi, callback=callback, _at=os.clock() }
end

function UILib:_KillDropdown()
    self._active_dropdown=nil; self:_HidePrefix('dd_')
end

-- ─────────────────────────────────────────────
-- PUBLIC: TAB & SECTION BUILDER
-- ─────────────────────────────────────────────

function UILib:Tab(name)
    self._tree[name] = { _items={} }
    table.insert(self._tab_order, name)
    if not self._open_tab then self._open_tab=name end
    return {
        Section = function(_, sname)
            return self:_MakeSection(name, sname)
        end
    }
end

function UILib:_MakeSection(tabName, sname)
    if not self._tree[tabName]._items[sname] then
        self._tree[tabName]._items[sname] = { _order={}, _widgets={} }
        table.insert(self._tree[tabName]._items[sname]._order or {}, sname)
        -- keep a flat section order list on the tab
        if not self._tree[tabName]._sec_order then self._tree[tabName]._sec_order={} end
        table.insert(self._tree[tabName]._sec_order, sname)
    end
    local sec = self._tree[tabName]._items[sname]
    return {
        Toggle = function(_, label, subtitle, value, callback, unsafe)
            local id = #sec._widgets+1
            table.insert(sec._widgets, { type='toggle', label=label, subtitle=subtitle or '', value=value, callback=callback, unsafe=unsafe })
            return {
                Set = function(_, v) sec._widgets[id].value=v; if sec._widgets[id].callback then sec._widgets[id].callback(v) end end,
                AddColorpicker = function(_, cplabel, cpval, overwrite, cpcb)
                    sec._widgets[id].colorpicker={ label=cplabel, value=cpval or Color3.new(1,1,1), overwrite=overwrite, callback=cpcb }
                    return { Set=function(_,v) sec._widgets[id].colorpicker.value=v; if cpcb then cpcb(v) end end }
                end,
                AddKeybind = function(_, kval, mode, canChange, kcb)
                    sec._widgets[id].keybind={ value=kval, mode=mode or 'Toggle', canChange=canChange~=false, callback=kcb, _listening=false, _at=0 }
                    return { Set=function(_,v,m) local kb=sec._widgets[id].keybind; kb.value=v; kb.mode=m or kb.mode; if kcb then kcb(v,kb.mode) end end }
                end,
            }
        end,
        Slider = function(_, label, value, step, min, max, suffix, callback)
            local id=#sec._widgets+1
            table.insert(sec._widgets,{ type='slider', label=label, value=value, step=step, min=min, max=max, suffix=suffix or '', callback=callback })
            return { Set=function(_,v) sec._widgets[id].value=v; if sec._widgets[id].callback then sec._widgets[id].callback(v) end end }
        end,
        Dropdown = function(_, label, value, choices, multi, callback)
            local id=#sec._widgets+1
            if type(value)=='string' then value={value} end
            table.insert(sec._widgets,{ type='dropdown', label=label, value=value, choices=choices, multi=multi, callback=callback })
            return {
                Set=function(_,v) sec._widgets[id].value=v; if sec._widgets[id].callback then sec._widgets[id].callback(v) end end,
                UpdateChoices=function(_,c) sec._widgets[id].choices=c end
            }
        end,
        Button = function(_, label, subtitle, callback)
            table.insert(sec._widgets,{ type='button', label=label, subtitle=subtitle or '', callback=callback })
            return {}
        end,
        Textbox = function(_, label, value, callback)
            local id=#sec._widgets+1
            table.insert(sec._widgets,{ type='textbox', label=label, value=value or '', callback=callback })
            return { Set=function(_,v) sec._widgets[id].value=v; if sec._widgets[id].callback then sec._widgets[id].callback(v) end end }
        end,
        Colorpicker = function(_, label, value, callback)
            local id=#sec._widgets+1
            table.insert(sec._widgets,{ type='colorpicker', label=label, value=value or Color3.new(1,1,1), callback=callback })
            return { Set=function(_,v) sec._widgets[id].value=v; if sec._widgets[id].callback then sec._widgets[id].callback(v) end end }
        end,
    }
end

-- ─────────────────────────────────────────────
-- PUBLIC API
-- ─────────────────────────────────────────────

function UILib:SetMenuSize(s)    self.w=s.x or self.w; self.h=s.y or self.h end
function UILib:GetMenuSize()     return Vector2.new(self.w, self.h) end
function UILib:SetMenuTitle(t,s) self.title=t; self.subtitle=s or self.subtitle end
function UILib:SetProfile(user,sub) self.username=user; self.subtext=sub or '' end

function UILib:CenterMenu()
    local ss=self:_Screen()
    self.x=math.floor(ss.X/2-self.w/2)
    self.y=math.floor(ss.Y/2-self.h/2)
end

function UILib:Notification(text, time)
    table.insert(self._notifications,{ text=text, time=time, _id=self._notifications_spawned, _at=os.clock() })
    self._notifications_spawned=self._notifications_spawned+1
end

function UILib:UpdateFont(fontFace)
    self._font = fontFace
    for _, obj in pairs(self._drawings) do
        pcall(function()
            if obj.Font ~= nil then obj.Font = fontFace end
        end)
    end
end

function UILib:Unload()
    self:_RemovePrefix('')
    if self._wheel_conn then
        for _, c in ipairs(self._wheel_conn) do pcall(function() c:Disconnect() end) end
        self._wheel_conn = nil
    end
    pcall(setrobloxinput, true)
end

-- ─────────────────────────────────────────────
-- STEP — main render + input loop
-- ─────────────────────────────────────────────

function UILib:Step()
    local t = self._t   -- theme shorthand

    -- ── MOUSE WHEEL HOOK (connect once via UserInputService) ──
    if not self._wheel_conn then
        local UIS = game:GetService('UserInputService')
        self._wheel_conn = {}
        local ok, conn = pcall(function()
            return UIS.InputChanged:Connect(function(input, gameProcessed)
                if not self._menu_open then return end
                if input.UserInputType == Enum.UserInputType.MouseWheel then
                    self._scroll_delta = self._scroll_delta - input.Position.Z
                end
            end)
        end)
        if ok and conn then
            table.insert(self._wheel_conn, conn)
        else
            -- fallback: Mouse events
            local p = game:GetService('Players').LocalPlayer
            if p then
                local m = p:GetMouse()
                if m then
                    table.insert(self._wheel_conn, m.WheelForward:Connect(function()
                        if self._menu_open then self._scroll_delta = self._scroll_delta - 1 end
                    end))
                    table.insert(self._wheel_conn, m.WheelBackward:Connect(function()
                        if self._menu_open then self._scroll_delta = self._scroll_delta + 1 end
                    end))
                end
            end
        end
    end

    -- ── INPUT ──
    pcall(setrobloxinput, not self._menu_open)
    for key, data in pairs(self._inputs) do
        local ok2, pressed = pcall(iskeypressed, data.id)
        if not ok2 then pressed = false end
        local rbxok, rbxActive = pcall(isrbxactive); rbxActive = rbxok and rbxActive
        if rbxActive and pressed then
            self._inputs[key].click = not data.held
            self._inputs[key].held  = true
        else
            self._inputs[key].click = false
            self._inputs[key].held  = false
        end
    end

    local click     = self:_Pressed('m1')
    local held      = self:_Held('m1')
    local rclick    = self:_Pressed('m2')
    local menuKey   = self:_Pressed(self._menu_key)
    if menuKey then self._menu_open=not self._menu_open; self._menu_toggled_at=os.clock() end

    -- ── NOTIFICATIONS ──
    local nOrigin = Vector2.new(self.x+self.w+8, self.y)
    local nTotalH = 0
    for ni=#self._notifications,1,-1 do
        local n=self._notifications[ni]
        local elapsed=os.clock()-n._at
        local shouldFade=elapsed>n.time
        local t2=math.max(0,math.min(n._at-os.clock()+(shouldFade and n.time+0.5 or 0.5),0.5))/0.5
        local fade=math.abs((shouldFade and 0 or 1)-(t2*t2*(3-2*t2)))
        local nid='notif_'..n._id
        local ntsz=self:_TBounds(n.text)
        local nsz=Vector2.new(math.max(ntsz.X+24,180),ntsz.Y+20)
        local nx=nOrigin.X+(nsz.X+10)*(1-fade)
        local ny=nOrigin.Y+nTotalH
        if fade>0.01 then
            self:_RRect(nid..'_bg', nx, ny, nsz.X, nsz.Y, t.card, 200, 6, fade)
            self:_RRectOutline(nid..'_bo', nx, ny, nsz.X, nsz.Y, t.divider, 201, 6, fade)
            local prog=math.min(elapsed/n.time,1)
            self:_RRect(nid..'_prog', nx+2, ny+nsz.Y-4, (nsz.X-4)*prog, 2, t.accent, 202, 1, fade)
            self:_Text(nid..'_txt', nx+12, ny+4, n.text, t.text, 203, 12, false, false, fade)
        end
        nTotalH=nTotalH+nsz.Y+6
        if elapsed-0.5>n.time then
            self:_RemovePrefix(nid); table.remove(self._notifications,ni)
        end
    end

    if not self._menu_open then
        self:_HidePrefix('menu_')
        return
    end

    -- ── DRAG ──
    if held and self._menu_drag then
        local mp=self:_Mouse()
        self.x=mp.X-self._menu_drag.X
        self.y=mp.Y-self._menu_drag.Y
    elseif not held then
        self._menu_drag=nil
    end

    local mx,my,mw,mh = self.x, self.y, self.w, self.h
    local sw = self._sidebar_w
    local pad = self._padding

    -- ── OUTER WINDOW ──
    self:_RRect('menu_bg', mx, my, mw, mh, t.bg, 1, self._corner_r)
    self:_RRectOutline('menu_bg_bor', mx, my, mw, mh, t.divider, 20, self._corner_r)

    -- ── TITLE BAR (top strip, draggable) ──
    local tbH = 36
    self:_RRect('menu_titlebar', mx, my, mw, tbH, t.sidebar, 3, self._corner_r)
    -- flatten bottom corners of titlebar
    self:_RRect('menu_titlebar_bot', mx, my+tbH-self._corner_r, mw, self._corner_r, t.sidebar, 3, 0)
    self:_Text('menu_title_txt',  mx+pad+6,  my+10, self.title,    t.title_text, 4, 14, false, false)
    local _stW=(self.title and self:_TBounds(self.title,14).X or 0); self:_Text('menu_sub_txt', mx+pad+6+_stW+6, my+12, self.subtitle or '', t.subtext, 4, 11, false, false)
    -- close / min dots
    self:_RRect('menu_dot_r', mx+mw-14, my+13, 10, 10, Color3.fromRGB(255,95,86),  4, 5)
    self:_RRect('menu_dot_y', mx+mw-28, my+13, 10, 10, Color3.fromRGB(255,189,46), 4, 5)
    self:_RRect('menu_dot_g', mx+mw-42, my+13, 10, 10, Color3.fromRGB(39,201,63),  4, 5)

    -- titlebar drag
    if click and self:_InBounds(mx, my, mw-50, tbH) and not self._menu_drag then
        local mp=self:_Mouse(); self._menu_drag=Vector2.new(mp.X-mx, mp.Y-my); click=false
    end
    -- close button
    if click and self:_InBounds(mx+mw-20, my+8, 18, 20) then self._menu_open=false; click=false end

    -- ── SIDEBAR PANEL ──
    local sbX, sbY = mx, my+tbH
    local sbH = mh-tbH
    self:_RRect('menu_sidebar', sbX, sbY, sw, sbH, t.sidebar, 16, 0)
    -- right edge divider
    self:_Line('menu_sdiv', sbX+sw, sbY, sbX+sw, sbY+sbH, t.divider, 17)

    -- search bar
    local srchX, srchY = sbX+pad, sbY+pad
    local srchW, srchH = sw-pad*2, 28
    local isSearchFocused = self._input_ctx == 'search'
    self:_RRect('menu_search_bg', srchX, srchY, srchW, srchH, t.search_bg, 17, 6)
    if isSearchFocused then
        self:_RRectOutline('menu_search_bor_o', srchX, srchY, srchW, srchH, t.accent, 18, 6)
    else
        self:_RRectOutline('menu_search_bor_o', srchX, srchY, srchW, srchH, t.divider, 18, 6)
    end
    local srchDisplay = self._search_query=='' and (isSearchFocused and '' or 'Search...') or self._search_query
    local srchCol = self._search_query=='' and t.subtext or t.text
    if isSearchFocused then srchDisplay=self._search_query..(math.floor(os.clock()*2)%2==0 and '|' or ' ') end
    self:_Text('menu_search_tx', srchX+8, srchY+8, srchDisplay, srchCol, 7, 19, false, false)
    -- search interaction
    if click then
        if self:_InBounds(srchX,srchY,srchW,srchH) then self._input_ctx='search'; click=false
        elseif isSearchFocused then self._input_ctx=nil end
    end
    if isSearchFocused then
        local charMap={space=' ',dash='-',period='.',comma=',',slash='/',semicolon=';'}
        local shiftMap={['1']='!',['2']='@',['3']='#',['4']='$',['5']='%',['6']='^',['7']='&',['8']='*',['9']='(',['0']=')',['=']='+'}
        local sh=self:_Held('lshift') or self:_Held('rshift')
        for ch in pairs(self._inputs) do
            if self:_Pressed(ch) then
                local m=charMap[ch] or ch
                if m=='enter' or m=='esc' then self._input_ctx=nil
                elseif m=='unbound' then self._search_query=self._search_query:sub(1,-2)
                elseif m and #m==1 then
                    if sh and shiftMap[m] then m=shiftMap[m] elseif sh then m=m:upper() end
                    self._search_query=self._search_query..m
                end
            end
        end
    end

    -- nav items
    local navY = srchY+srchH+pad
    local navItemH = 30
    local sq = self._search_query:lower()

    for _, tabName in ipairs(self._tab_order) do
        local isOpen = self._open_tab==tabName
        local navBg  = isOpen and t.nav_active or t.sidebar
        local navTxt = isOpen and t.nav_active_text or t.nav_text
        local niX,niY = sbX+pad, navY
        local niW,niH = sw-pad*2, navItemH

        -- highlight bar on active
        if isOpen then
            self:_RRect('nav_'..tabName..'_bg', niX, niY, niW, niH, navBg, 17, 5)
            self:_RRect('nav_'..tabName..'_bar', niX, niY+4, 3, niH-8, t.accent, 18, 1)
        else
            self:_RRect('nav_'..tabName..'_bg', niX, niY, niW, niH, navBg, 17, 5)
            self:_Hide('nav_'..tabName..'_bar')
        end
        self:_Text('nav_'..tabName..'_txt', niX+12, niY+8, tabName, navTxt, 19, 12, false, false)

        if click and self:_InBounds(niX,niY,niW,niH) and self._open_tab ~= tabName then
            -- immediately hide the old tab widgets before switching
            local oldTD = self._open_tab and self._tree[self._open_tab]
            if oldTD then
                for _, sn in ipairs(oldTD._sec_order or {}) do
                    self:_HidePrefix('sec_'..self._open_tab..'_'..sn)
                end
            end
            self._open_tab=tabName; self._tab_change_at=os.clock()
            self._scroll_offset=0; self._scroll_target=0; click=false
        end
        navY=navY+navItemH+3
    end

    -- profile footer
    local pfH = 40
    local pfY = sbY+sbH-pfH
    self:_Line('menu_pfdiv2', sbX+6, pfY, sbX+sw-6, pfY, t.divider, 17)
    -- avatar circle
    -- profile
    self:_RRect('menu_pf_cover', sbX, pfY, sw, pfH+4, t.sidebar, 16, 0)
    self:_RRect('menu_pf_av2', sbX+pad, pfY+8, 24, 24, t.accent_dim, 17, 12)
    self:_Text('menu_pf_avt', sbX+pad+12, pfY+14, self.username:sub(1,1):upper(), t.accent, 6, 11, true, false)
    self:_Text('menu_pfnm',   sbX+pad+28, pfY+9,  self.username, t.text, 19, 19, false, false)
    self:_Text('menu_pfsb',    sbX+pad+28, pfY+22, self.subtext,  t.subtext, 19, 19, false, false)

    -- ── CONTENT AREA ──
    local cX = mx+sw+1
    local cY = my+tbH
    local cW = mw-sw-1
    local cH = mh-tbH
    self:_RRect('menu_content', cX, cY, cW, cH, t.content, 3, 0)
    -- bottom edge cover
    self:_RRect('menu_bedge', cX, cY+cH-2, cW, 4, t.bg, 15, 0)

    -- content header
    local chH = 36
    -- header cover (prevents content bleeding over header)
    self:_RRect('menu_hcover', cX, cY, cW, chH, t.content, 15, 0)
    self:_Text('menu_chead', cX+pad+4, cY+10, self._open_tab or '', t.text, 16, 14, false, false)
    self:_Line('menu_chdiv', cX+6, cY+chH, cX+cW-6, cY+chH, t.divider, 16)

    -- scroll via accumulated wheel delta (no bounds check needed, always consume)
    if self._scroll_delta ~= 0 then
        self._scroll_target = self._scroll_target + self._scroll_delta * 35
        self._scroll_target = math.max(0, self._scroll_target)
        self._scroll_delta = 0
    end
    self._scroll_offset = lerp(self._scroll_offset, self._scroll_target, 0.3)

    -- Hide all widgets for every tab that is NOT currently open
    for _, tname in ipairs(self._tab_order) do
        if tname ~= self._open_tab then
            local td = self._tree[tname]
            if td then
                for _, sname in ipairs(td._sec_order or {}) do
                    local sec = td._items[sname]
                    if sec then
                        local slid = 'sec_'..tname..'_'..sname
                        self:_HidePrefix(slid)
                    end
                end
            end
        end
    end

    -- render widgets for open tab
    local tabData = self._open_tab and self._tree[self._open_tab]
    local cYmin = cY+chH      -- top clip boundary
    local cYmax = cY+cH       -- bottom clip boundary
    if tabData then
        local wY = cY+chH+pad - math.floor(self._scroll_offset)
        local wX = cX+pad
        local wW = cW-pad*2-2

        for _, sname in ipairs(tabData._sec_order or {}) do
            local sec = tabData._items[sname]
            if not sec then continue end

            -- section label
            local slid = 'sec_'..self._open_tab..'_'..sname
            -- section label (clipped)
            if wY >= cYmin-18 and wY <= cYmax then
                self:_Text(slid..'_lbl', wX+4, wY+4, sname:upper(), t.subtext, 6, 10, false, false)
            end
            wY = wY+20

            for wi, widget in ipairs(sec._widgets) do
                local wid = slid..'_w'..wi

                -- search filter
                local matchSearch = sq=='' or widget.label:lower():find(sq,1,true)
                if not matchSearch then
                    self:_HidePrefix(wid); continue
                end

                local wType = widget.type
                local itemH = (wType=='toggle' or wType=='button') and ((widget.subtitle or '')~='' and 54 or 36)
                           or wType=='slider' and 48
                           or wType=='dropdown' and 48
                           or wType=='textbox' and 40
                           or wType=='colorpicker' and 36
                           or 36

                -- Y clip: hide widget if outside content bounds
                local inView = (wY + itemH > cYmin) and (wY < cYmax)
                if not inView then
                    self:_HidePrefix(wid)
                    wY = wY + itemH + 4
                    continue
                end

                -- card background
                local isHover = self:_InBounds(wX, wY, wW, itemH) and self:_InBounds(cX, cYmin, cW, cH-chH)
                local cardCol = isHover and t.card_hover or t.card
                self:_RRect(wid..'_card', wX, wY, wW, itemH, cardCol, 5, 6)

                -- ── TOGGLE ──
                if wType=='toggle' then
                    local hasCP = widget.colorpicker~=nil
                    local hasKB = widget.keybind~=nil

                    -- colorpicker swatch on the right
                    if hasCP then
                        local cpSw=18; local cpX=wX+wW-cpSw-8; local cpY2=wY+(itemH-cpSw)/2
                        self:_RRect(wid..'_cp_sw', cpX, cpY2, cpSw, cpSw, widget.colorpicker.value, 7, 4)
                        self:_RRectOutline(wid..'_cp_swb', cpX, cpY2, cpSw, cpSw, t.divider, 8, 4)
                        if click and self:_InBounds(cpX,cpY2,cpSw,cpSw) then
                            self:_SpawnColorpicker(cX+cW+4, cY, widget.colorpicker.label, widget.colorpicker.value, function(v)
                                widget.colorpicker.value=v; if widget.colorpicker.callback then widget.colorpicker.callback(v) end
                            end)
                            click=false
                        end
                    end

                    -- keybind text
                    if hasKB then
                        local kb=widget.keybind
                        local kbTxt='['.. (kb._listening and '...' or ((kb.value or '-'):upper()))..']'
                        local kbW=self:_TBounds(kbTxt,10).X+4
                        local kbX=wX+wW-kbW-(hasCP and 30 or 8); local kbY2=wY+(itemH-10)/2
                        self:_Text(wid..'_kb', kbX, kbY2, kbTxt, t.subtext, 7, 10)
                        if click and self:_InBounds(kbX,kbY2,kbW,12) then
                            kb._listening=true; kb._at=os.clock(); click=false
                        elseif rclick and self:_InBounds(kbX,kbY2,kbW,12) then
                            self:_SpawnDropdown(self:_Mouse().X, self:_Mouse().Y, 70, {kb.mode}, {'Hold','Toggle','Always'}, false, function(v)
                                kb.mode=v[1]; if kb.callback then kb.callback(self._inputs[kb.value] and self._inputs[kb.value].id,kb.mode) end
                            end)
                            rclick=false
                        end
                        if kb._listening then
                            for kn,kd in pairs(self._inputs) do
                                if self:_Pressed(kn) then
                                    if kn~='m1' or os.clock()-kb._at>0.2 then
                                        local nv=kn~='unbound' and kn or nil
                                        if kb.callback and self._inputs[nv] then kb.callback(kd.id, kb.mode) end
                                        kb.value=nv; kb._listening=false
                                    end
                                end
                            end
                        end
                    end

                    -- toggle pill
                    local tglR = hasCP and (wW-56) or hasKB and (wW-60) or (wW-50)
                    local tglX = wX+tglR
                    local tglY2 = wY+(itemH-18)/2
                    local onCol  = widget.unsafe and Color3.fromRGB(255,180,0) or t.toggle_on
                    self:_Toggle(wid..'_tgl', tglX, tglY2, widget.value, onCol, t.toggle_off, 7)

                    if click and self:_InBounds(tglX, tglY2, 34, 18) then
                        widget.value = not widget.value
                        if widget.callback then widget.callback(widget.value) end
                        click=false
                    end

                    -- labels
                    self:_Text(wid..'_lbl', wX+10, wY+8, widget.label, t.text, 7, 13)
                    if (widget.subtitle or '')~='' then
                        self:_Text(wid..'_sub', wX+10, wY+24, widget.subtitle, t.subtext, 7, 11)
                    else
                        self:_HidePrefix(wid..'_sub')
                    end

                -- ── SLIDER ──
                elseif wType=='slider' then
                    self:_Text(wid..'_lbl', wX+10, wY+8, widget.label, t.text, 7, 12)
                    local valTxt=tostring(widget.value)..widget.suffix
                    local vtW=self:_TBounds(valTxt,11).X
                    self:_Text(wid..'_val', wX+wW-vtW-10, wY+8, valTxt, t.accent, 7, 11)
                    -- track
                    local slX=wX+10; local slY2=wY+28; local slW=wW-20; local slH=4
                    self:_RRect(wid..'_trk', slX, slY2, slW, slH, t.toggle_off, 6, 2)
                    local pct=(widget.value-widget.min)/(widget.max-widget.min)
                    if pct>0.001 then self:_RRect(wid..'_fill', slX, slY2, math.max(2,slW*pct), slH, t.accent, 7, 2) end
                    -- thumb
                    local thX=slX+slW*pct-5
                    self:_RRect(wid..'_thumb', thX, slY2-3, 10, 10, Color3.fromRGB(255,255,255), 8, 5)
                    -- drag
                    local hovSlider=self:_InBounds(slX-4,slY2-6,slW+8,16)
                    if held then
                        if (hovSlider and click) then self._slider_drag=wid; click=false end
                        if self._slider_drag==wid then
                            local mp=self:_Mouse()
                            local np=clamp((mp.X-slX)/slW,0,1)
                            local nv=math.floor(((widget.min+(widget.max-widget.min)*np)/widget.step)+0.5)*widget.step
                            nv=clamp(nv,widget.min,widget.max)
                            if nv~=widget.value then widget.value=nv; if widget.callback then widget.callback(nv) end end
                        end
                    else self._slider_drag=nil end

                -- ── DROPDOWN ──
                elseif wType=='dropdown' then
                    self:_Text(wid..'_lbl', wX+10, wY+8, widget.label, t.text, 7, 12)
                    local disp=table.concat(widget.value,', ')
                    if #disp==0 then disp='None' end
                    -- dropdown box
                    local ddBX=wX+10; local ddBY=wY+24; local ddBW=wW-20; local ddBH=18
                    self:_RRect(wid..'_box', ddBX, ddBY, ddBW, ddBH, t.search_bg, 6, 4)
                    self:_RRectOutline(wid..'_boxb', ddBX, ddBY, ddBW, ddBH, t.divider, 7, 4)
                    self:_Text(wid..'_val', ddBX+6, ddBY+3, disp, t.text, 8, 11)
                    -- arrow
                    local arX=ddBX+ddBW-14; local arY=ddBY+7
                    self:_Text(wid..'_arr', arX, arY, 'v', t.subtext, 8, 9)
                    if click and self:_InBounds(ddBX,ddBY,ddBW,ddBH) then
                        self:_SpawnDropdown(ddBX, ddBY+ddBH, ddBW, widget.value, widget.choices, widget.multi, function(v)
                            widget.value=v; if widget.callback then widget.callback(v) end
                        end)
                        click=false
                    end

                -- ── BUTTON ──
                elseif wType=='button' then
                    self:_Text(wid..'_lbl', wX+10, wY+8, widget.label, t.text, 7, 13)
                    if (widget.subtitle or '')~='' then self:_Text(wid..'_sub', wX+10, wY+24, widget.subtitle, t.subtext, 7, 11) end
                    -- click arrow indicator
                    self:_Text(wid..'_arr', wX+wW-18, wY+(itemH/2)-6, '>', t.subtext, 7, 12)
                    if click and isHover then
                        if widget.callback then widget.callback() end; click=false
                    end
                    -- pressed highlight
                    if held and self:_InBounds(wX,wY,wW,itemH) then
                        self:_RRect(wid..'_press', wX, wY, wW, itemH, t.accent_dim, 9, 6)
                    else
                        self:_Hide(wid..'_press')
                    end

                -- ── TEXTBOX ──
                elseif wType=='textbox' then
                    self:_Text(wid..'_lbl', wX+10, wY+4, widget.label, t.subtext, 7, 10)
                    local isTyping=self._input_ctx==wid
                    local tbBX=wX+10; local tbBY=wY+16; local tbBW=wW-20; local tbBH=18
                    self:_RRect(wid..'_box', tbBX, tbBY, tbBW, tbBH, t.search_bg, 6, 4)
                    self:_RRectOutline(wid..'_boxb', tbBX, tbBY, tbBW, tbBH, isTyping and t.accent or t.divider, 7, 4)
                    local disp=(widget.value~='' and widget.value or (isTyping and '' or widget.label))..(isTyping and (math.floor(os.clock()*2)%2==0 and '|' or ' ') or '')
                    self:_Text(wid..'_val', tbBX+6, tbBY+3, disp, widget.value~='' and t.text or t.subtext, 8, 11)
                    if click then
                        if self:_InBounds(tbBX,tbBY,tbBW,tbBH) then self._input_ctx=wid; click=false
                        elseif isTyping then self._input_ctx=nil end
                    end
                    if isTyping then
                        local cm={space=' ',dash='-',period='.',comma=',',slash='/',semicolon=';'}
                        local sm={['1']='!',['2']='@',['3']='#',['4']='$',['5']='%',['6']='^',['7']='&',['8']='*',['9']='(',['0']=')',['=']='+'}
                        local sh=self:_Held('lshift') or self:_Held('rshift')
                        for ch in pairs(self._inputs) do
                            if self:_Pressed(ch) then
                                local m=cm[ch] or ch
                                if m=='enter' or m=='esc' then self._input_ctx=nil
                                elseif m=='unbound' then widget.value=widget.value:sub(1,-2); if widget.callback then widget.callback(widget.value) end
                                elseif m and #m==1 then
                                    if sh and sm[m] then m=sm[m] elseif sh then m=m:upper() end
                                    widget.value=widget.value..m; if widget.callback then widget.callback(widget.value) end
                                end
                            end
                        end
                    end

                -- ── COLORPICKER (inline) ──
                elseif wType=='colorpicker' then
                    self:_Text(wid..'_lbl', wX+10, wY+8, widget.label, t.text, 7, 12)
                    local cpSw=20; local cpX2=wX+wW-cpSw-10; local cpY2=wY+8
                    self:_RRect(wid..'_sw', cpX2, cpY2, cpSw, cpSw, widget.value, 7, 4)
                    self:_RRectOutline(wid..'_swb', cpX2, cpY2, cpSw, cpSw, t.divider, 8, 4)
                    if click and self:_InBounds(cpX2,cpY2,cpSw,cpSw) then
                        self:_SpawnColorpicker(cX+cW+4, cY, widget.label, widget.value, function(v)
                            widget.value=v; if widget.callback then widget.callback(v) end
                        end)
                        click=false
                    end
                end

                wY = wY+itemH+4
            end

            wY=wY+8  -- gap after section
        end

        -- update max scroll
        local contentEnd = wY+math.floor(self._scroll_offset)-(cY+chH+pad)
        self._scroll_target = clamp(self._scroll_target, 0, math.max(0, contentEnd-cH+20))
    end

    -- ── DROPDOWN POPUP ──
    local dd=self._active_dropdown
    if dd then
        local fade=clamp((os.clock()-dd._at)/0.15,0,1)
        local ddTotalH=#dd.choices*22+8
        self:_RRect('dd_bg',  dd.x, dd.y, dd.w, ddTotalH, t.card, 50, 6, fade)
        self:_RRectOutline('dd_bor', dd.x, dd.y, dd.w, ddTotalH, t.divider, 51, 6, fade)
        local cancel=true
        for i,ch in ipairs(dd.choices) do
            local cy2=dd.y+4+(i-1)*22
            local found=table.find(dd.value,ch)
            local hovC=self:_InBounds(dd.x+4,cy2,dd.w-8,20)
            if hovC then self:_RRect('dd_ch_hov_'..i, dd.x+4,cy2,dd.w-8,20, t.nav_active, 52, 4, fade) end
            self:_Text('dd_ch_'..i, dd.x+10, cy2+4, ch, found and t.accent or t.text, 53, 12, false, false, fade)
            if click and hovC then
                cancel=not dd.multi
                if dd.multi then if found then table.remove(dd.value,found) else table.insert(dd.value,ch) end
                else dd.value={ch} end
                if dd.callback then dd.callback(dd.value) end
            end
        end
        if click and cancel then self:_KillDropdown() end
        click=false
    end

    -- ── COLORPICKER POPUP ──
    local cp=self._active_colorpicker
    if cp then
        local fade=clamp((os.clock()-cp._at)/0.15,0,1)
        local cpW,cpH=200,210
        local cpX2,cpY2=cp.x, cp.y
        self:_RRect('cp_bg', cpX2,cpY2,cpW,cpH, t.card, 50, 8, fade)
        self:_RRectOutline('cp_bor', cpX2,cpY2,cpW,cpH, t.divider, 51, 8, fade)
        self:_Text('cp_lbl', cpX2+pad,cpY2+pad, cp.label, t.text, 52, 12, false, false, fade)

        local palX=cpX2+pad; local palY=cpY2+pad+18
        local palW=cpW-pad*2; local palH=cpH-pad*3-28
        local hueH=12

        -- palette
        self:_RRect('cp_pal', palX,palY,palW,palH-hueH-pad, Color3.fromHSV(cp._h,1,1), 52, 3, fade)
        -- white→transparent horizontal gradient (fake via segments)
        local segs=20
        for i=1,segs do
            local sx=palX+(i-1)*(palW/segs)
            local sw2=palW/segs+1
            local alpha2=1-(i-1)/(segs-1)
            self:_RRect('cp_pw_'..i, sx,palY,sw2,palH-hueH-pad, Color3.fromRGB(255,255,255), 53, 0, alpha2*fade)
        end
        -- black→transparent vertical gradient
        for i=1,segs do
            local sy=palY+(i-1)*((palH-hueH-pad)/segs)
            local sh2=(palH-hueH-pad)/segs+1
            local alpha2=(i-1)/(segs-1)
            self:_RRect('cp_pb_'..i, palX,sy,palW,sh2, Color3.fromRGB(0,0,0), 54, 0, alpha2*fade)
        end

        -- hue bar
        local hueY=palY+palH-hueH-pad+pad
        local hueColors={Color3.fromRGB(255,0,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,255,255),Color3.fromRGB(0,0,255),Color3.fromRGB(255,0,255),Color3.fromRGB(255,0,0)}
        local hsegs=palW/6
        for i=1,6 do
            local c1=hueColors[i]; local c2=hueColors[i+1]
            for j=1,8 do
                local t2=(j-1)/7
                local lc=Color3.new(lerp(c1.R,c2.R,t2),lerp(c1.G,c2.G,t2),lerp(c1.B,c2.B,t2))
                self:_RRect('cp_hue_'..i..'_'..j, palX+(i-1)*hsegs+(j-1)*(hsegs/8), hueY, hsegs/8+1, hueH, lc, 55, 0, fade)
            end
        end

        -- interaction
        local mp=self:_Mouse()
        local palH2=palH-hueH-pad
        if held and self:_InBounds(palX,palY,palW,palH2) then
            cp._s=clamp((mp.X-palX)/palW,0,1); cp._v=1-clamp((mp.Y-palY)/palH2,0,1)
        end
        if held and self:_InBounds(palX,hueY,palW,hueH) then
            cp._h=clamp((mp.X-palX)/palW,0,1)
        end

        -- cursor dot on palette
        local dotX=palX+cp._s*palW-4; local dotY=palY+(1-cp._v)*(palH2)-4
        self:_RRect('cp_dot', dotX,dotY,8,8, Color3.fromRGB(255,255,255), 56, 4, fade)

        -- current colour swatch
        local newCol=Color3.fromHSV(cp._h,cp._s,cp._v)
        self:_RRect('cp_swatch', cpX2+pad,cpY2+cpH-pad-14, 20,14, newCol, 56, 3, fade)
        if cp.callback then cp.callback(newCol) end

        -- cancel on click outside
        if click and not self:_InBounds(cpX2,cpY2,cpW,cpH) then self:_KillColorpicker(); click=false end
    end

    -- ── MENU FADE ──
    local mFade=clamp(1-(self._menu_toggled_at-(os.clock()-0.3))/0.3,0,1)
    if mFade<1.05 then
        local opacity=math.abs((self._menu_open and 0 or 1)-(mFade*mFade*(3-2*mFade)))
        self:_OpacityPrefix('menu_', opacity)
        self:_OpacityPrefix('nav_',  opacity)
        self:_OpacityPrefix('sec_',  opacity)
    end
    -- when fully closed, hide everything completely
    if not self._menu_open and mFade >= 1.0 then
        self:_HidePrefix('menu_')
        self:_HidePrefix('nav_')
        self:_HidePrefix('sec_')
    end
end

return UILib
