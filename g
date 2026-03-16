--[[
    library.lua — matcha edition
    Minimal, direct Drawing API usage. No abstractions that can silently fail.
]]

UILib = {
    _drawings = {},
    _tree     = {},
    _tab_order= {},
    _open_tab = nil,
    _menu_open= false,  -- START CLOSED, F1 opens it
    _menu_key = 'f1',
    _inputs   = {['m1']={id=0x01,h=false,c=false},['m2']={id=0x02,h=false,c=false},['f1']={id=0x70,h=false,c=false},['f2']={id=0x71,h=false,c=false},['f3']={id=0x72,h=false,c=false},['f4']={id=0x73,h=false,c=false},['f5']={id=0x74,h=false,c=false},['f6']={id=0x75,h=false,c=false},['esc']={id=0x1B,h=false,c=false},['lshift']={id=0xA0,h=false,c=false},['rshift']={id=0xA1,h=false,c=false},['up']={id=0x26,h=false,c=false},['down']={id=0x28,h=false,c=false},['left']={id=0x25,h=false,c=false},['right']={id=0x27,h=false,c=false},['unbound']={id=0x08,h=false,c=false},['enter']={id=0x0D,h=false,c=false},['space']={id=0x20,h=false,c=false},['a']={id=0x41,h=false,c=false},['b']={id=0x42,h=false,c=false},['c']={id=0x43,h=false,c=false},['d']={id=0x44,h=false,c=false},['e']={id=0x45,h=false,c=false},['f']={id=0x46,h=false,c=false},['g']={id=0x47,h=false,c=false},['h']={id=0x48,h=false,c=false},['i']={id=0x49,h=false,c=false},['j']={id=0x4A,h=false,c=false},['k']={id=0x4B,h=false,c=false},['l']={id=0x4C,h=false,c=false},['m']={id=0x4D,h=false,c=false},['n']={id=0x4E,h=false,c=false},['o']={id=0x4F,h=false,c=false},['p']={id=0x50,h=false,c=false},['q']={id=0x51,h=false,c=false},['r']={id=0x52,h=false,c=false},['s']={id=0x53,h=false,c=false},['t']={id=0x54,h=false,c=false},['u']={id=0x55,h=false,c=false},['v']={id=0x56,h=false,c=false},['w']={id=0x57,h=false,c=false},['x']={id=0x58,h=false,c=false},['y']={id=0x59,h=false,c=false},['z']={id=0x5A,h=false,c=false},['0']={id=0x30,h=false,c=false},['1']={id=0x31,h=false,c=false},['2']={id=0x32,h=false,c=false},['3']={id=0x33,h=false,c=false},['4']={id=0x34,h=false,c=false},['5']={id=0x35,h=false,c=false},['6']={id=0x36,h=false,c=false},['7']={id=0x37,h=false,c=false},['8']={id=0x38,h=false,c=false},['9']={id=0x39,h=false,c=false},['minus']={id=0xBD,h=false,c=false},['period']={id=0xBE,h=false,c=false},['comma']={id=0xBC,h=false,c=false},['slash']={id=0xBF,h=false,c=false},['semicolon']={id=0xBA,h=false,c=false},['quote']={id=0xDE,h=false,c=false},['lbracket']={id=0xDB,h=false,c=false},['rbracket']={id=0xDD,h=false,c=false},['backslash']={id=0xDC,h=false,c=false}},
    _drag        = nil,
    _ctx         = nil,     -- focused input id
    _search      = '',
    _scroll      = 0,
    _scrollT     = 0,
    _wheelConn   = nil,     -- mouse wheel connection
    _slider_drag = nil,
    _dd          = nil,     -- active dropdown
    _cp          = nil,     -- active colorpicker
    _copied_color= nil,
    _notifs      = {},
    _notif_id    = 0,
    -- layout
    title    = 'matcha',
    subtitle = '',
    username = 'Player',
    usertext = '',
    x = 100, y = 80, w = 580, h = 420,
    _sw = 145,   -- sidebar width
    _pad = 10,
    _corner = 6,
    _font = Drawing.Fonts.System,
    _fsize = 13,
    -- theme
    C = {
        bg      = Color3.fromRGB(18,18,20),
        side    = Color3.fromRGB(22,22,25),
        content = Color3.fromRGB(26,26,30),
        card    = Color3.fromRGB(32,32,38),
        cardhov = Color3.fromRGB(40,40,48),
        accent  = Color3.fromRGB(80,200,120),
        accdim  = Color3.fromRGB(30,80,50),
        text    = Color3.fromRGB(240,240,245),
        sub     = Color3.fromRGB(110,110,120),
        div     = Color3.fromRGB(40,40,48),
        navhi   = Color3.fromRGB(36,36,44),
        trkoff  = Color3.fromRGB(55,55,65),
        srch    = Color3.fromRGB(28,28,34),
        white   = Color3.fromRGB(255,255,255),
        black   = Color3.fromRGB(0,0,0),
    },
}

-- ─── UTILS ───────────────────────────────────────────────────────────────────

local function clamp(v,a,b) return v<a and a or v>b and b or v end
local function lerp(a,b,t) return a+(b-a)*t end
local PI = math.pi

local function hsvToRgb(h,s,v)
    local r,g,b
    local i=math.floor(h*6); local f=h*6-i; local p=v*(1-s); local q=v*(1-f*s); local t2=v*(1-(1-f)*s)
    i=i%6
    if i==0 then r,g,b=v,t2,p elseif i==1 then r,g,b=q,v,p elseif i==2 then r,g,b=p,v,t2
    elseif i==3 then r,g,b=p,q,v elseif i==4 then r,g,b=t2,p,v else r,g,b=v,p,q end
    return Color3.new(r,g,b)
end

local function rgbToHsv(r,g,b)
    local max=math.max(r,g,b); local min=math.min(r,g,b); local d=max-min
    local h,s,v=0,max>0 and d/max or 0,max
    if d~=0 then
        if max==r then h=(g-b)/d+(g<b and 6 or 0)
        elseif max==g then h=(b-r)/d+2 else h=(r-g)/d+4 end
        h=h/6
    end
    return h,s,v
end

-- ─── RAW DRAWING ─────────────────────────────────────────────────────────────

local D = {}  -- drawing object cache

local function sq(id, x, y, w, h, col, tr)
    if w<=0 or h<=0 then return end
    if not D[id] then D[id]=Drawing.new('Square') end
    local o=D[id]
    o.Position=Vector2.new(x,y); o.Size=Vector2.new(w,h)
    o.Color=col; o.Filled=true; o.Transparency=tr or 0; o.Visible=true
end

local function txt(id, x, y, text, col, size, center, outline, tr)
    if not D[id] then D[id]=Drawing.new('Text') end
    local o=D[id]
    o.Position=Vector2.new(x,y); o.Text=tostring(text or '')
    o.Color=col; o.Size=size or UILib._fsize; o.Font=UILib._font
    o.Center=center or false; o.Outline=outline or false
    o.Transparency=tr or 0; o.Visible=true
end

local function ln(id, x1, y1, x2, y2, col, tr)
    if not D[id] then D[id]=Drawing.new('Line') end
    local o=D[id]
    o.From=Vector2.new(x1,y1); o.To=Vector2.new(x2,y2)
    o.Color=col; o.Thickness=1; o.Transparency=tr or 0; o.Visible=true
end

local function hide(id)
    if D[id] then D[id].Visible=false end
end

local function hidePrefix(p)
    for k,o in pairs(D) do
        if k:sub(1,#p)==p then o.Visible=false end
    end
end

local function setTr(id, tr)
    if D[id] then D[id].Transparency=tr end
end

local function trPrefix(p, tr)
    for k,o in pairs(D) do
        if k:sub(1,#p)==p then o.Transparency=tr end
    end
end

local function removePfx(p)
    for k,o in pairs(D) do
        if k:sub(1,#p)==p then o:Remove(); D[k]=nil end
    end
end

local function rect(id, x, y, w, h, col, tr)
    sq(id, x, y, w, h, col, tr)
end

-- Text bounds estimate
local function tbounds(text, size)
    size = size or UILib._fsize
    return Vector2.new(#tostring(text or '') * size * 0.52, size)
end

-- Mouse position
local function mouse()
    local p=game:GetService('Players').LocalPlayer
    if p then local m=p:GetMouse(); if m then return Vector2.new(m.X,m.Y) end end
    return Vector2.new(0,0)
end

-- Screen size
local function screen()
    local c=workspace.CurrentCamera
    if c and c.ViewportSize then return c.ViewportSize end
    return Vector2.new(1920,1080)
end

-- Hit test
local function hit(x,y,w,h)
    local mp=mouse(); return mp.X>=x and mp.X<=x+w and mp.Y>=y and mp.Y<=y+h
end

-- ─── INPUT ───────────────────────────────────────────────────────────────────

local function pollInput()
    for key,data in pairs(UILib._inputs) do
        local ok,pressed=pcall(iskeypressed,data.id)
        if not ok then pressed=false end
        if pressed then
            data.c = not data.h
            data.h = true
        else
            data.c = false
            data.h = false
        end
    end
end

local function pressed(key) return UILib._inputs[key] and UILib._inputs[key].c end
local function held(key)    return UILib._inputs[key] and UILib._inputs[key].h end

-- ─── MOUSE WHEEL SETUP ───────────────────────────────────────────────────────

local function setupWheelScroll()
    if UILib._wheelConn then return end
    local ok, UIS = pcall(function() return game:GetService('UserInputService') end)
    if not ok or not UIS then return end
    UILib._wheelConn = UIS.InputChanged:Connect(function(input)
        if input.UserInputType ~= Enum.UserInputType.MouseWheel then return end
        if not UILib._menu_open then return end
        -- content area bounds (title bar = 32, content header = 34)
        local tbH = 32
        local chH = 34
        local cX = UILib.x + UILib._sw + 1
        local cY = UILib.y + tbH + chH
        local cW = UILib.w - UILib._sw - 1
        local cH = UILib.h - tbH - chH
        local mp = mouse()
        if mp.X >= cX and mp.X <= cX + cW and mp.Y >= cY and mp.Y <= cY + cH then
            -- input.Position.Z: +1 = scroll up, -1 = scroll down
            UILib._scrollT = math.max(0, UILib._scrollT - input.Position.Z * 40)
        end
    end)
end

-- ─── PUBLIC API ──────────────────────────────────────────────────────────────

function UILib:SetMenuSize(s)   self.w=s.x or self.w; self.h=s.y or self.h end
function UILib:GetMenuSize()    return Vector2.new(self.w,self.h) end
function UILib:SetMenuTitle(t,s) self.title=t; self.subtitle=s or '' end
function UILib:SetProfile(u,s)  self.username=u; self.usertext=s or '' end

function UILib:CenterMenu()
    local ss=screen()
    self.x=math.floor(ss.X/2-self.w/2)
    self.y=math.floor(ss.Y/2-self.h/2)
end

function UILib:Notification(text,time)
    table.insert(self._notifs,{text=text,time=time,id=self._notif_id,at=os.clock()})
    self._notif_id=self._notif_id+1
end

function UILib:UpdateFont(f)
    self._font=f
    for _,o in pairs(D) do
        if o.Font~=nil then pcall(function() o.Font=f end) end
    end
end

function UILib:Unload()
    -- Disconnect mouse wheel listener
    if self._wheelConn then
        self._wheelConn:Disconnect()
        self._wheelConn = nil
    end
    removePfx('')
    pcall(setrobloxinput,true)
end

-- ─── TAB / SECTION / WIDGET BUILDER ─────────────────────────────────────────

function UILib:Tab(name)
    self._tree[name]={_sec_order={},_items={}}
    table.insert(self._tab_order,name)
    if not self._open_tab then self._open_tab=name end
    return {
        Section=function(_,sname) return UILib:_Section(name,sname) end
    }
end

function UILib:_Section(tab,sname)
    if not self._tree[tab]._items[sname] then
        self._tree[tab]._items[sname]={_widgets={}}
        table.insert(self._tree[tab]._sec_order,sname)
    end
    local sec=self._tree[tab]._items[sname]
    local function addWidget(w) table.insert(sec._widgets,w); return #sec._widgets end
    return {
        Toggle=function(_,label,sub,val,cb,unsafe)
            local id=addWidget({type='toggle',label=label,sub=sub or '',value=val,cb=cb,unsafe=unsafe})
            local r={
                Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end,
                AddColorpicker=function(_,lbl,val2,ow,cb2)
                    sec._widgets[id].cp={label=lbl,value=val2 or Color3.new(1,1,1),ow=ow,cb=cb2}
                    return {Set=function(_,v) sec._widgets[id].cp.value=v; if cb2 then cb2(v) end end}
                end,
                AddKeybind=function(_,kval,mode,canChange,kcb)
                    sec._widgets[id].kb={value=kval,mode=mode or 'Toggle',canChange=canChange~=false,cb=kcb,listening=false,at=0}
                    return {Set=function(_,v,m) local kb=sec._widgets[id].kb; kb.value=v; kb.mode=m or kb.mode; if kcb then kcb(v,kb.mode) end end}
                end,
            }
            return r
        end,
        Slider=function(_,label,val,step,min,max,suffix,cb)
            local id=addWidget({type='slider',label=label,value=val,step=step,min=min,max=max,suffix=suffix or '',cb=cb})
            return {Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end}
        end,
        Dropdown=function(_,label,val,choices,multi,cb)
            if type(val)=='string' then val={val} end
            local id=addWidget({type='dropdown',label=label,value=val,choices=choices,multi=multi,cb=cb})
            return {
                Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end,
                UpdateChoices=function(_,c) sec._widgets[id].choices=c end
            }
        end,
        Button=function(_,label,sub,cb)
            addWidget({type='button',label=label,sub=sub or '',cb=cb})
            return {}
        end,
        Textbox=function(_,label,val,cb)
            local id=addWidget({type='textbox',label=label,value=val or '',cb=cb})
            return {Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end}
        end,
        Colorpicker=function(_,label,val,cb)
            local id=addWidget({type='colorpicker',label=label,value=val or Color3.new(1,1,1),cb=cb})
            return {Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end}
        end,
    }
end

-- ─── DROPDOWN POPUP ──────────────────────────────────────────────────────────

local function drawDropdown(click)
    local dd=UILib._dd
    if not dd then return click end
    local iH=20; local total=#dd.choices*iH+8
    rect('dd_bg', dd.x, dd.y, dd.w, total, UILib.C.card)
    ln('dd_bor_t', dd.x, dd.y, dd.x+dd.w, dd.y, UILib.C.div)
    ln('dd_bor_b', dd.x, dd.y+total, dd.x+dd.w, dd.y+total, UILib.C.div)
    ln('dd_bor_l', dd.x, dd.y, dd.x, dd.y+total, UILib.C.div)
    ln('dd_bor_r', dd.x+dd.w, dd.y, dd.x+dd.w, dd.y+total, UILib.C.div)
    local cancel=true
    for i,ch in ipairs(dd.choices) do
        local cy=dd.y+4+(i-1)*iH
        local found=table.find(dd.value,ch)
        if hit(dd.x+2,cy,dd.w-4,iH) then
            rect('dd_hov', dd.x+2, cy, dd.w-4, iH, UILib.C.navhi)
            if click then
                cancel=not dd.multi
                if dd.multi then if found then table.remove(dd.value,found) else table.insert(dd.value,ch) end
                else dd.value={ch} end
                if dd.cb then dd.cb(dd.value) end
                click=cancel and false or click
            end
        else hide('dd_hov') end
        txt('dd_ch_'..i, dd.x+8, cy+4, ch, found and UILib.C.accent or UILib.C.text, 12)
    end
    if click then UILib._dd=nil; hidePrefix('dd_'); click=false end
    return click
end

-- ─── COLORPICKER POPUP ───────────────────────────────────────────────────────

local function drawColorpicker(held2, click)
    local cp=UILib._cp
    if not cp then return click end
    local cW,cH=200,195
    local cx,cy=cp.x,cp.y
    rect('cp_bg', cx, cy, cW, cH, UILib.C.card)
    txt('cp_lbl', cx+8, cy+6, cp.label, UILib.C.text, 12)
    local pX,pY,pW,pH=cx+8,cy+22,cW-16,cH-50
    local hH=12
    local palH=pH-hH-6
    -- palette base (hue color)
    rect('cp_pal', pX, pY, pW, palH, Color3.fromHSV(cp.h,1,1))
    -- white overlay fade (horizontal segments)
    for i=1,16 do
        local sx=pX+(i-1)*(pW/16); local sw=pW/16+1
        sq('cp_wh_'..i, sx, pY, sw, palH, Color3.fromRGB(255,255,255), (i-1)/15)
    end
    -- black overlay fade (vertical segments)
    for i=1,16 do
        local sy=pY+(i-1)*(palH/16); local sh=palH/16+1
        sq('cp_bk_'..i, pX, sy, pW, sh, Color3.fromRGB(0,0,0), 1-(i-1)/15)
    end
    -- hue bar
    local hY=pY+palH+6
    local hueColors={Color3.fromRGB(255,0,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,255,255),Color3.fromRGB(0,0,255),Color3.fromRGB(255,0,255),Color3.fromRGB(255,0,0)}
    for i=1,6 do
        local c1,c2=hueColors[i],hueColors[i+1]
        local segW=pW/6
        for j=1,8 do
            local t2=(j-1)/7
            local lc=Color3.new(lerp(c1.R,c2.R,t2),lerp(c1.G,c2.G,t2),lerp(c1.B,c2.B,t2))
            sq('cp_h_'..i..'_'..j, pX+(i-1)*segW+(j-1)*(segW/8), hY, segW/8+1, hH, lc)
        end
    end
    -- cursor
    local dotX=pX+cp.s*pW-4; local dotY=pY+(1-cp.v)*palH-4
    sq('cp_dot', dotX, dotY, 8, 8, UILib.C.white)
    -- hue cursor
    sq('cp_hdot', pX+cp.h*pW-3, hY, 6, hH, UILib.C.white)
    -- current color swatch
    local nc=Color3.fromHSV(cp.h,cp.s,cp.v)
    sq('cp_sw', cx+8, cy+cH-14, cW-16, 10, nc)
    if cp.cb then cp.cb(nc) end
    -- interaction
    local mp=mouse()
    if held2 then
        if hit(pX,pY,pW,palH) then
            cp.s=clamp((mp.X-pX)/pW,0,1); cp.v=1-clamp((mp.Y-pY)/palH,0,1)
        end
        if hit(pX,hY,pW,hH) then
            cp.h=clamp((mp.X-pX)/pW,0,1)
        end
    end
    if click and not hit(cx,cy,cW,cH) then
        UILib._cp=nil; hidePrefix('cp_'); click=false
    end
    return click
end

-- ─── MAIN STEP ───────────────────────────────────────────────────────────────

function UILib:Step()
    local C=self.C

    -- Setup mouse wheel scroll connection once
    setupWheelScroll()

    -- INPUT (all keys read before setrobloxinput)
    pollInput()
    local click=pressed('m1'); local heldM=held('m1'); local rclick=pressed('m2')

    -- menu toggle
    if pressed(self._menu_key) then
        self._menu_open=not self._menu_open
    end

    -- lock roblox input when menu open
    pcall(setrobloxinput, not self._menu_open)

    -- NOTIFICATIONS
    local nx0,ny0=self.x+self.w+8,self.y; local ntH=0
    for ni=#self._notifs,1,-1 do
        local n=self._notifs[ni]
        local el=os.clock()-n.at
        local fade=clamp(el<0.3 and el/0.3 or (el>n.time and 1-(el-n.time)/0.3 or 1),0,1)
        if fade>0.01 then
            local nW=math.max(tbounds(n.text,12).X+20,160); local nH=24
            local nnx=nx0+(nW+8)*(1-fade); local nny=ny0+ntH
            rect('n_'..n.id..'_bg', nnx,nny,nW,nH, C.card, 1-fade)
            txt('n_'..n.id..'_t', nnx+8,nny+6, n.text, C.text, 12, false, false, 1-fade)
            local p=clamp(el/n.time,0,1)
            sq('n_'..n.id..'_p', nnx+2,nny+nH-3, (nW-4)*p, 2, C.accent, 1-fade)
            ntH=ntH+nH+4
        end
        if el>n.time+0.4 then removePfx('n_'..n.id..'_'); table.remove(self._notifs,ni) end
    end

    -- CLOSED: hide menu and return
    if not self._menu_open then
        hidePrefix('m_')
        hidePrefix('nav_')
        hidePrefix('s_')
        return
    end

    -- DRAG
    if heldM and self._drag then
        local mp=mouse()
        self.x=mp.X-self._drag.X; self.y=mp.Y-self._drag.Y
    elseif not heldM then
        self._drag=nil
    end

    local x,y,w,h=self.x,self.y,self.w,self.h
    local sw,pad=self._sw,self._pad
    local tbH=32  -- title bar height

    -- OUTER BG
    rect('m_bg', x, y, w, h, C.bg)

    -- TITLE BAR
    rect('m_tb', x, y, w, tbH, C.side)
    txt('m_title', x+pad+4, y+8, self.title, C.text, 14)
    local tW=tbounds(self.title,14).X
    txt('m_sub', x+pad+4+tW+6, y+10, self.subtitle, C.sub, 11)
    -- window dots
    sq('m_dr', x+w-14, y+11, 10, 10, Color3.fromRGB(255,95,86))
    sq('m_dy', x+w-28, y+11, 10, 10, Color3.fromRGB(255,189,46))
    sq('m_dg', x+w-42, y+11, 10, 10, Color3.fromRGB(39,201,63))
    -- title bar drag
    if click and hit(x,y,w-50,tbH) and not self._drag then
        local mp=mouse(); self._drag=Vector2.new(mp.X-x,mp.Y-y); click=false
    end

    -- SIDEBAR
    local sbX,sbY,sbH=x,y+tbH,h-tbH
    rect('m_sb', sbX, sbY, sw, sbH, C.side)
    ln('m_sdiv', sbX+sw, sbY, sbX+sw, sbY+sbH, C.div)

    -- Search bar
    local srX,srY,srW,srH=sbX+pad,sbY+pad,sw-pad*2,26
    rect('m_sr', srX, srY, srW, srH, C.srch)
    ln('m_sr_t', srX, srY, srX+srW, srY, C.div)
    ln('m_sr_b', srX, srY+srH, srX+srW, srY+srH, C.div)
    ln('m_sr_l', srX, srY, srX, srY+srH, C.div)
    ln('m_sr_r', srX+srW, srY, srX+srW, srY+srH, C.div)
    local isSrch=self._ctx=='search'
    if isSrch then
        ln('m_sr_hl', srX, srY, srX+srW, srY, C.accent)
    end
    local srDisp=self._search=='' and (isSrch and '' or 'Search...') or self._search
    if isSrch then srDisp=self._search..(math.floor(os.clock()*2)%2==0 and '|' or ' ') end
    txt('m_sr_t2', srX+6, srY+7, srDisp, self._search=='' and C.sub or C.text, 12)
    if click then
        if hit(srX,srY,srW,srH) then self._ctx='search'; click=false
        elseif isSrch then self._ctx=nil end
    end
    if isSrch then
        local cm={space=' ',dash='-',period='.',comma=',',slash='/'}
        local sh=held('lshift') or held('rshift')
        local sm={['1']='!',['2']='@',['3']='#',['4']='$',['5']='%',['6']='^',['7']='&',['8']='*',['9']='(',['0']=')'}
        for ch in pairs(self._inputs) do
            if pressed(ch) then
                local m=cm[ch] or ch
                if m=='enter' or m=='esc' then self._ctx=nil
                elseif m=='unbound' then self._search=self._search:sub(1,-2)
                elseif #m==1 then
                    if sh and sm[m] then m=sm[m] elseif sh then m=m:upper() end
                    self._search=self._search..m
                end
            end
        end
    end

    -- Nav items
    local navY=srY+srH+6
    for _,tname in ipairs(self._tab_order) do
        local isOpen=self._open_tab==tname
        local bg=isOpen and C.navhi or C.side
        local tc=isOpen and C.text or C.sub
        rect('nav_'..tname..'_bg', sbX+pad, navY, sw-pad*2, 28, bg)
        if isOpen then
            sq('nav_'..tname..'_bar', sbX+pad, navY+4, 3, 20, C.accent)
        else hide('nav_'..tname..'_bar') end
        txt('nav_'..tname..'_t', sbX+pad+10, navY+8, tname, tc, 12)
        if click and hit(sbX+pad,navY,sw-pad*2,28) and not isOpen then
            -- hide old tab widgets
            local old=self._tree[self._open_tab]
            if old then
                for _,sn in ipairs(old._sec_order or {}) do
                    hidePrefix('s_'..self._open_tab..'_'..sn)
                end
            end
            self._open_tab=tname; self._scroll=0; self._scrollT=0; click=false
        end
        navY=navY+28+3
    end

    -- Profile footer
    local pfY=sbY+sbH-38
    ln('m_pfl', sbX+6, pfY, sbX+sw-6, pfY, C.div)
    rect('m_pfbg', sbX, pfY, sw, 38, C.side)
    sq('m_pfav', sbX+pad, pfY+7, 24, 24, C.accdim)
    txt('m_pfav_l', sbX+pad+12, pfY+13, (self.username or 'P'):sub(1,1):upper(), C.accent, 11, true)
    txt('m_pfname', sbX+pad+28, pfY+8, self.username or '', C.text, 11)
    txt('m_pfsub', sbX+pad+28, pfY+20, self.usertext or '', C.sub, 10)

    -- CONTENT AREA
    local cX=x+sw+1; local cY=y+tbH; local cW=w-sw-1; local cH=h-tbH
    rect('m_ct', cX, cY, cW, cH, C.content)
    -- header
    local chH=34
    rect('m_chbg', cX, cY, cW, chH, C.content)
    txt('m_chtxt', cX+pad+4, cY+10, self._open_tab or '', C.text, 14)
    ln('m_chdiv', cX+6, cY+chH, cX+cW-6, cY+chH, C.div)

    -- ─── SCROLL ──────────────────────────────────────────────────────────────
    -- Arrow key scrolling (mouse wheel is handled by setupWheelScroll connection)
    if pressed('up')   then self._scrollT=math.max(0,self._scrollT-35) end
    if pressed('down') then self._scrollT=self._scrollT+35 end
    self._scroll=lerp(self._scroll, self._scrollT, 0.2)

    -- WIDGETS
    local sq2=self._search:lower()
    local tabData=self._open_tab and self._tree[self._open_tab]

    -- hide all inactive tab widgets
    for _,tname in ipairs(self._tab_order) do
        if tname~=self._open_tab then
            local td=self._tree[tname]
            if td then
                for _,sn in ipairs(td._sec_order or {}) do
                    hidePrefix('s_'..tname..'_'..sn)
                end
            end
        end
    end

    if tabData then
        local wY=cY+chH+pad-math.floor(self._scroll)
        local wX=cX+pad; local wW=cW-pad*2
        local clipTop=cY+chH; local clipBot=cY+cH

        for _,sname in ipairs(tabData._sec_order or {}) do
            local sec=tabData._items[sname]
            if not sec then continue end
            local slid='s_'..self._open_tab..'_'..sname

            if wY>=clipTop-20 and wY<=clipBot then
                txt(slid..'_hdr', wX+2, wY+3, sname:upper(), C.sub, 10)
            else hide(slid..'_hdr') end
            wY=wY+18

            for wi,w2 in ipairs(sec._widgets) do
                local wid=slid..'_'..wi
                local wType=w2.type
                local hasSub=(w2.sub or '')~=''
                local iH= (wType=='toggle' or wType=='button') and (hasSub and 52 or 34)
                       or wType=='slider' and 46
                       or wType=='dropdown' and 46
                       or wType=='textbox' and 38
                       or 34

                -- search filter
                if sq2~='' and not w2.label:lower():find(sq2,1,true) then
                    hidePrefix(wid); wY=wY+iH+4; continue
                end

                -- clip
                if wY+iH<=clipTop or wY>=clipBot then
                    hidePrefix(wid); wY=wY+iH+4; continue
                end

                -- card
                local isHov=hit(wX,wY,wW,iH)
                rect(wid..'_bg', wX, wY, wW, iH, isHov and C.cardhov or C.card)

                if wType=='toggle' then
                    local hasCP=w2.cp~=nil; local hasKB=w2.kb~=nil
                    -- colorpicker swatch
                    if hasCP then
                        local csz=18; local cx2=wX+wW-csz-8; local cy2=wY+(iH-csz)/2
                        sq(wid..'_cp', cx2, cy2, csz, csz, w2.cp.value)
                        ln(wid..'_cpb_t', cx2,cy2, cx2+csz,cy2, C.div)
                        ln(wid..'_cpb_b', cx2,cy2+csz, cx2+csz,cy2+csz, C.div)
                        ln(wid..'_cpb_l', cx2,cy2, cx2,cy2+csz, C.div)
                        ln(wid..'_cpb_r', cx2+csz,cy2, cx2+csz,cy2+csz, C.div)
                        if click and hit(cx2,cy2,csz,csz) then
                            local h2,s2,v2=rgbToHsv(w2.cp.value.R,w2.cp.value.G,w2.cp.value.B)
                            local ppx=cX+cW+4; if ppx+200>screen().X then ppx=cX-204 end
                            UILib._cp={x=ppx,y=cY,label=w2.cp.label,cb=function(c) w2.cp.value=c; if w2.cp.cb then w2.cp.cb(c) end end,h=h2,s=s2,v=v2}
                            click=false
                        end
                    end
                    -- toggle pill
                    local tr=hasCP and (wW-56) or (wW-50)
                    local tX=wX+tr; local tY=wY+(iH-18)/2
                    local onC=w2.unsafe and Color3.fromRGB(255,180,0) or C.accent
                    sq(wid..'_trk', tX, tY, 34, 18, w2.value and onC or C.trkoff)
                    sq(wid..'_thm', w2.value and tX+16 or tX+2, tY+2, 14, 14, C.white)
                    if click and hit(tX,tY,34,18) then
                        w2.value=not w2.value; if w2.cb then w2.cb(w2.value) end; click=false
                    end
                    txt(wid..'_lbl', wX+10, wY+8, w2.label, C.text, 13)
                    if hasSub then txt(wid..'_sub', wX+10, wY+22, w2.sub, C.sub, 11)
                    else hide(wid..'_sub') end

                elseif wType=='slider' then
                    txt(wid..'_lbl', wX+10, wY+6, w2.label, C.text, 12)
                    local vt=tostring(w2.value)..w2.suffix
                    txt(wid..'_val', wX+wW-tbounds(vt,11).X-8, wY+6, vt, C.accent, 11)
                    local slX=wX+10; local slY2=wY+26; local slW=wW-20
                    sq(wid..'_trk', slX, slY2, slW, 4, C.trkoff)
                    local pct=clamp((w2.value-w2.min)/(w2.max-w2.min),0,1)
                    if pct>0 then sq(wid..'_fill', slX, slY2, math.max(2,slW*pct), 4, C.accent) end
                    sq(wid..'_thm', slX+slW*pct-5, slY2-3, 10, 10, C.white)
                    if heldM then
                        if hit(slX-4,slY2-6,slW+8,16) and click then self._slider_drag=wid; click=false end
                        if self._slider_drag==wid then
                            local mp=mouse()
                            local np=clamp((mp.X-slX)/slW,0,1)
                            local nv=math.floor(((w2.min+(w2.max-w2.min)*np)/w2.step)+0.5)*w2.step
                            nv=clamp(nv,w2.min,w2.max)
                            if nv~=w2.value then w2.value=nv; if w2.cb then w2.cb(nv) end end
                        end
                    else self._slider_drag=nil end

                elseif wType=='dropdown' then
                    txt(wid..'_lbl', wX+10, wY+6, w2.label, C.text, 12)
                    local dBX=wX+10; local dBY=wY+22; local dBW=wW-20; local dBH=18
                    rect(wid..'_box', dBX, dBY, dBW, dBH, C.srch)
                    ln(wid..'_bt', dBX,dBY, dBX+dBW,dBY, C.div)
                    ln(wid..'_bb', dBX,dBY+dBH, dBX+dBW,dBY+dBH, C.div)
                    ln(wid..'_bl', dBX,dBY, dBX,dBY+dBH, C.div)
                    ln(wid..'_br', dBX+dBW,dBY, dBX+dBW,dBY+dBH, C.div)
                    local disp=table.concat(w2.value,', ')
                    if #disp==0 then disp='None' end
                    txt(wid..'_val', dBX+6, dBY+3, disp, C.text, 11)
                    txt(wid..'_arr', dBX+dBW-12, dBY+4, 'v', C.sub, 9)
                    if click and hit(dBX,dBY,dBW,dBH) then
                        UILib._dd={x=dBX,y=dBY+dBH,w=dBW,value=w2.value,choices=w2.choices,multi=w2.multi,cb=function(v) w2.value=v; if w2.cb then w2.cb(v) end end}
                        click=false
                    end

                elseif wType=='button' then
                    txt(wid..'_lbl', wX+10, wY+8, w2.label, C.text, 13)
                    if hasSub then txt(wid..'_sub', wX+10, wY+22, w2.sub, C.sub, 11)
                    else hide(wid..'_sub') end
                    txt(wid..'_arr', wX+wW-16, wY+(iH/2)-7, '>', C.sub, 12)
                    if click and isHov then if w2.cb then w2.cb() end; click=false end

                elseif wType=='textbox' then
                    local isTyp=self._ctx==wid
                    txt(wid..'_lbl', wX+10, wY+4, w2.label, C.sub, 10)
                    local tBX=wX+10; local tBY=wY+16; local tBW=wW-20; local tBH=16
                    rect(wid..'_box', tBX, tBY, tBW, tBH, C.srch)
                    ln(wid..'_bt', tBX,tBY, tBX+tBW,tBY, isTyp and C.accent or C.div)
                    ln(wid..'_bb', tBX,tBY+tBH, tBX+tBW,tBY+tBH, isTyp and C.accent or C.div)
                    ln(wid..'_bl', tBX,tBY, tBX,tBY+tBH, isTyp and C.accent or C.div)
                    ln(wid..'_br', tBX+tBW,tBY, tBX+tBW,tBY+tBH, isTyp and C.accent or C.div)
                    local disp=(w2.value~='' and w2.value or (isTyp and '' or w2.label))..(isTyp and (math.floor(os.clock()*2)%2==0 and '|' or ' ') or '')
                    txt(wid..'_val', tBX+4, tBY+3, disp, w2.value~='' and C.text or C.sub, 11)
                    if click then
                        if hit(tBX,tBY,tBW,tBH) then self._ctx=wid; click=false
                        elseif isTyp then self._ctx=nil end
                    end
                    if isTyp then
                        local cm={space=' ',dash='-',period='.',comma=',',slash='/'}
                        local sh=held('lshift') or held('rshift')
                        local sm={['1']='!',['2']='@',['3']='#',['4']='$',['5']='%',['0']=')'}
                        for ch in pairs(self._inputs) do
                            if pressed(ch) then
                                local m=cm[ch] or ch
                                if m=='enter' or m=='esc' then self._ctx=nil
                                elseif m=='unbound' then w2.value=w2.value:sub(1,-2); if w2.cb then w2.cb(w2.value) end
                                elseif #m==1 then
                                    if sh and sm[m] then m=sm[m] elseif sh then m=m:upper() end
                                    w2.value=w2.value..m; if w2.cb then w2.cb(w2.value) end
                                end
                            end
                        end
                    end

                elseif wType=='colorpicker' then
                    txt(wid..'_lbl', wX+10, wY+8, w2.label, C.text, 12)
                    local csz=20; local cx2=wX+wW-csz-8; local cy2=wY+7
                    sq(wid..'_sw', cx2, cy2, csz, csz, w2.value)
                    ln(wid..'_sb_t', cx2,cy2, cx2+csz,cy2, C.div)
                    ln(wid..'_sb_b', cx2,cy2+csz, cx2+csz,cy2+csz, C.div)
                    ln(wid..'_sb_l', cx2,cy2, cx2,cy2+csz, C.div)
                    ln(wid..'_sb_r', cx2+csz,cy2, cx2+csz,cy2+csz, C.div)
                    if click and hit(cx2,cy2,csz,csz) then
                        local h2,s2,v2=rgbToHsv(w2.value.R,w2.value.G,w2.value.B)
                        local ppx=cX+cW+4; if ppx+200>screen().X then ppx=cX-204 end
                        UILib._cp={x=ppx,y=cY,label=w2.label,cb=function(c) w2.value=c; if w2.cb then w2.cb(c) end end,h=h2,s=s2,v=v2}
                        click=false
                    end
                end

                wY=wY+iH+4
            end
            wY=wY+8
        end

        -- clamp scroll
        local maxScroll=math.max(0, wY+math.floor(self._scroll)-(cY+cH)+20)
        self._scrollT=clamp(self._scrollT,0,maxScroll)
    end

    -- Draw popups on top
    click=drawDropdown(click)
    click=drawColorpicker(heldM, click)

    -- Repaint sidebar ON TOP of content (high z isn't available, so redraw last)
    rect('m_sb2', sbX, sbY, sw, sbH, C.side)
    ln('m_sdiv2', sbX+sw, sbY, sbX+sw, sbY+sbH, C.div)
    -- repaint search
    rect('m_sr2', srX, srY, srW, srH, C.srch)
    txt('m_sr_t3', srX+6, srY+7, srDisp, self._search=='' and C.sub or C.text, 12)
    -- repaint nav
    local navY2=srY+srH+6
    for _,tname in ipairs(self._tab_order) do
        local isOpen=self._open_tab==tname
        rect('nav2_'..tname..'_bg', sbX+pad, navY2, sw-pad*2, 28, isOpen and C.navhi or C.side)
        if isOpen then sq('nav2_'..tname..'_bar', sbX+pad, navY2+4, 3, 20, C.accent)
        else hide('nav2_'..tname..'_bar') end
        txt('nav2_'..tname..'_t', sbX+pad+10, navY2+8, tname, isOpen and C.text or C.sub, 12)
        navY2=navY2+28+3
    end
    -- repaint profile footer
    rect('m_pfbg2', sbX, pfY, sw, 38, C.side)
    sq('m_pfav2', sbX+pad, pfY+7, 24, 24, C.accdim)
    txt('m_pfav_l2', sbX+pad+12, pfY+13, (self.username or 'P'):sub(1,1):upper(), C.accent, 11, true)
    txt('m_pfname2', sbX+pad+28, pfY+8, self.username or '', C.text, 11)
    txt('m_pfsub2', sbX+pad+28, pfY+20, self.usertext or '', C.sub, 10)
    -- repaint header
    rect('m_chbg2', cX, cY, cW, chH, C.content)
    txt('m_chtxt2', cX+pad+4, cY+10, self._open_tab or '', C.text, 14)
    ln('m_chdiv2', cX+6, cY+chH, cX+cW-6, cY+chH, C.div)
    -- bottom edge cover
    rect('m_bot', cX, cY+cH-2, cW, 4, C.bg)
end

return UILib
