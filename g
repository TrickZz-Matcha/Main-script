--[[
    matcha library
]]

UILib = {
    _font_face   = Drawing.Fonts.System,
    _font_size   = 13,
    _drawings    = {},
    _tree        = {},
    _tab_order   = {},
    _menu_open   = true,
    _menu_toggled_at = 0,
    _open_tab    = nil,
    _tab_change_at = 0,
    _notifications = {},
    _notifications_spawned = 0,
    _inputs      = {['m1']={id=0x01,held=false,click=false},['m2']={id=0x02,held=false,click=false},['f1']={id=0x70,held=false,click=false},['lshift']={id=0xA0,held=false,click=false},['rshift']={id=0xA1,held=false,click=false},['unbound']={id=0x08,held=false,click=false},['enter']={id=0x0D,held=false,click=false},['space']={id=0x20,held=false,click=false},['a']={id=0x41,held=false,click=false},['b']={id=0x42,held=false,click=false},['c']={id=0x43,held=false,click=false},['d']={id=0x44,held=false,click=false},['e']={id=0x45,held=false,click=false},['f']={id=0x46,held=false,click=false},['g']={id=0x47,held=false,click=false},['h']={id=0x48,held=false,click=false},['i']={id=0x49,held=false,click=false},['j']={id=0x4A,held=false,click=false},['k']={id=0x4B,held=false,click=false},['l']={id=0x4C,held=false,click=false},['m']={id=0x4D,held=false,click=false},['n']={id=0x4E,held=false,click=false},['o']={id=0x4F,held=false,click=false},['p']={id=0x50,held=false,click=false},['q']={id=0x51,held=false,click=false},['r']={id=0x52,held=false,click=false},['s']={id=0x53,held=false,click=false},['t']={id=0x54,held=false,click=false},['u']={id=0x55,held=false,click=false},['v']={id=0x56,held=false,click=false},['w']={id=0x57,held=false,click=false},['x']={id=0x58,held=false,click=false},['y']={id=0x59,held=false,click=false},['z']={id=0x5A,held=false,click=false},['0']={id=0x30,held=false,click=false},['1']={id=0x31,held=false,click=false},['2']={id=0x32,held=false,click=false},['3']={id=0x33,held=false,click=false},['4']={id=0x34,held=false,click=false},['5']={id=0x35,held=false,click=false},['6']={id=0x36,held=false,click=false},['7']={id=0x37,held=false,click=false},['8']={id=0x38,held=false,click=false},['9']={id=0x39,held=false,click=false},['minus']={id=0xBD,held=false,click=false},['period']={id=0xBE,held=false,click=false},['comma']={id=0xBC,held=false,click=false}},
    _slider_drag = nil,
    _sb_drag     = false,
    _menu_drag   = nil,
    _input_ctx   = nil,
    _menu_key    = 'f1',
    _active_dropdown    = nil,
    _active_colorpicker = nil,
    _scroll      = 0,
    _scrollT     = 0,
    _scroll_delta = 0,

    title    = 'matcha',
    subtitle = 'beta',
    username = 'Player',
    usertext = '',
    w = 580, h = 420,
    x = 160, y = 100,
    _padding = 10,
    _sw      = 145,

    C = {
        accent  = Color3.fromRGB(80,200,120),
        accdim  = Color3.fromRGB(30,80,50),
        bg      = Color3.fromRGB(18,18,20),
        side    = Color3.fromRGB(22,22,25),
        content = Color3.fromRGB(26,26,30),
        card    = Color3.fromRGB(32,32,38),
        cardhov = Color3.fromRGB(40,40,48),
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

local function clamp(x,a,b) return x<a and a or x>b and b or x end
local function lerp(a,b,t)  return a+(b-a)*t end

local function rgbToHsv(r,g,b)
    local max=math.max(r,g,b); local min=math.min(r,g,b); local d=max-min
    local h,s,v=0, max>0 and d/max or 0, max
    if d~=0 then
        if max==r then h=(g-b)/d+(g<b and 6 or 0)
        elseif max==g then h=(b-r)/d+2 else h=(r-g)/d+4 end
        h=h/6
    end
    return h,s,v
end

-- ─── DRAWING ─────────────────────────────────────────────────────────────────

local D = UILib._drawings

local function draw(id, dtype, col, zi, ...)
    local o = D[id]
    if dtype == 'rect' then
        if not o then D[id]=Drawing.new('Square'); o=D[id] end
        local pos,sz,filled = ...
        o.Position=pos; o.Size=sz; o.Filled=filled
    elseif dtype == 'text' then
        if not o then D[id]=Drawing.new('Text'); o=D[id] end
        local pos,text,outline,center,sz,font = ...
        o.Position=pos; o.Text=tostring(text or '')
        o.Outline=outline or false; o.Center=center or false
        o.Size=sz or UILib._font_size; o.Font=font or UILib._font_face
    elseif dtype == 'line' then
        if not o then D[id]=Drawing.new('Line'); o=D[id] end
        local from,to,thickness = ...
        o.From=from; o.To=to; o.Thickness=thickness or 1
    end
    if o then o.Color=col; o.ZIndex=zi; o.Transparency=0; o.Visible=true end
end

local function undraw(id)
    local o=D[id]; if o then o.Visible=false end
end

local function undrawPrefix(p)
    for k,o in pairs(D) do
        if k:sub(1,#p)==p then o.Visible=false end
    end
end

local function removePrefix(p)
    for k,o in pairs(D) do
        if k:sub(1,#p)==p then o:Remove(); D[k]=nil end
    end
end

local function setAlpha(id, a)
    local o=D[id]; if o then o.Transparency=a end
end

local function roundedCorners(id, x, y, w, h, r, bg, zi)
    if not r or r <= 0 then return end
    for dy = 0, r-1 do
        local inner = math.floor(math.sqrt(math.max(0, r*r - (r-dy-1)*(r-dy-1) )))
        local maskW = r - inner
        if maskW >= 1 then
            draw(id..'_tl'..dy,'rect',bg,zi,Vector2.new(x,         y+dy),      Vector2.new(maskW,1),true)
            draw(id..'_tr'..dy,'rect',bg,zi,Vector2.new(x+w-maskW, y+dy),      Vector2.new(maskW,1),true)
            draw(id..'_bl'..dy,'rect',bg,zi,Vector2.new(x,         y+h-1-dy),  Vector2.new(maskW,1),true)
            draw(id..'_br'..dy,'rect',bg,zi,Vector2.new(x+w-maskW, y+h-1-dy),  Vector2.new(maskW,1),true)
        end
    end
end

-- ─── HELPERS ─────────────────────────────────────────────────────────────────

local function getScreenSize()
    local c=workspace.CurrentCamera
    return (c and c.ViewportSize) or Vector2.new(1920,1080)
end

local function getMouse()
    local p=game:GetService('Players').LocalPlayer
    if p then local m=p:GetMouse(); if m then return Vector2.new(m.X,m.Y) end end
    return Vector2.new(0,0)
end

local function inBounds(origin,size)
    local m=getMouse()
    return m.X>=origin.X and m.X<=origin.X+size.X and m.Y>=origin.Y and m.Y<=origin.Y+size.Y
end

local function textW(text, size)
    return #tostring(text or '')*(size or UILib._font_size)*0.53
end

-- ─── INPUT ───────────────────────────────────────────────────────────────────

local function pollInput()
    for key,data in pairs(UILib._inputs) do
        local pressed
        if key == 'm1' then
            pressed = ismouse1pressed()
        elseif key == 'm2' then
            pressed = ismouse2pressed()
        else
            local ok,v = pcall(iskeypressed, data.id)
            pressed = ok and v or false
        end
        if pressed then
            data.click = not data.held
            data.held  = true
        else
            data.click = false
            data.held  = false
        end
    end
end

local function isPressed(key) return UILib._inputs[key] and UILib._inputs[key].click end
local function isHeld(key)   return UILib._inputs[key] and UILib._inputs[key].held end

-- ─── PUBLIC API ──────────────────────────────────────────────────────────────

function UILib:SetMenuTitle(t,s) self.title=t; self.subtitle=s or '' end
function UILib:SetMenuSize(s)   self.w=s.X or s.x or self.w; self.h=s.Y or s.y or self.h end
function UILib:GetMenuSize()    return Vector2.new(self.w,self.h) end
function UILib:SetProfile(u,s)  self.username=u; self.usertext=s or '' end
function UILib:UpdateFont(f)    self._font_face=f end

function UILib:CenterMenu()
    local ss=getScreenSize()
    if ss.X<100 or ss.Y<100 then self.x=160; self.y=100; return end
    self.x=math.floor(ss.X/2-self.w/2)
    self.y=math.floor(ss.Y/2-self.h/2)
end

function UILib:Notification(text,time)
    table.insert(self._notifications,{text=text,time=time,_id=self._notifications_spawned,_spawned_at=os.clock()})
    self._notifications_spawned=self._notifications_spawned+1
end

function UILib:Unload()
    removePrefix('')
    pcall(setrobloxinput,true)
end

-- ─── TREE BUILDER ────────────────────────────────────────────────────────────

function UILib:Tab(name)
    self._tree[name]={_sec_order={},_items={}}
    table.insert(self._tab_order,name)
    if not self._open_tab then self._open_tab=name end
    return { Section=function(_,sname) return UILib:_Section(name,sname) end }
end

function UILib:_Section(tab,sname)
    if not self._tree[tab]._items[sname] then
        self._tree[tab]._items[sname]={_widgets={}}
        table.insert(self._tree[tab]._sec_order,sname)
    end
    local sec=self._tree[tab]._items[sname]
    local function add(w) table.insert(sec._widgets,w); return #sec._widgets end
    return {
        Toggle=function(_,label,sub,val,cb,unsafe)
            local id=add({type='toggle',label=label,sub=sub or '',value=val,cb=cb,unsafe=unsafe})
            return {
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
        end,
        Slider=function(_,label,val,step,min,max,suffix,cb)
            local id=add({type='slider',label=label,value=val,step=step,min=min,max=max,suffix=suffix or '',cb=cb})
            return {Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end}
        end,
        Dropdown=function(_,label,val,choices,multi,cb)
            if type(val)=='string' then val={val} end
            local id=add({type='dropdown',label=label,value=val,choices=choices,multi=multi,cb=cb})
            return {
                Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end,
                UpdateChoices=function(_,c) sec._widgets[id].choices=c end,
            }
        end,
        Button=function(_,label,sub,cb)
            add({type='button',label=label,sub=sub or '',cb=cb}); return {}
        end,
        Textbox=function(_,label,val,cb)
            local id=add({type='textbox',label=label,value=val or '',cb=cb})
            return {Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end}
        end,
        Colorpicker=function(_,label,val,cb)
            local id=add({type='colorpicker',label=label,value=val or Color3.new(1,1,1),cb=cb})
            return {Set=function(_,v) sec._widgets[id].value=v; if cb then cb(v) end end}
        end,
    }
end

-- ─── STEP ────────────────────────────────────────────────────────────────────

function UILib:Step()
    local C=self.C
    if not C then return end

    pollInput()
    setrobloxinput(not self._menu_open)

    local clickFrame = isPressed('m1')
    local mouseHeld  = isHeld('m1')

    if isPressed(self._menu_key) then
        self._menu_open = not self._menu_open
        self._menu_toggled_at = os.clock()
    end

    -- NOTIFICATIONS
    for ni=#self._notifications,1,-1 do
        local n=self._notifications[ni]
        local el=os.clock()-n._spawned_at
        local fade=clamp(el<0.3 and el/0.3 or (el>n.time and 1-(el-n.time)/0.4 or 1),0,1)
        if fade>0.01 then
            local nW=math.max(textW(n.text,12)+20,160); local nH=26
            local nx=20; local ny=20+(ni-1)*(nH+4)
            draw('notif_'..n._id..'_bg','rect',C.card,50,Vector2.new(nx,ny),Vector2.new(nW,nH),true)
            draw('notif_'..n._id..'_t', 'text',C.text,51,Vector2.new(nx+8,ny+6),n.text,false,false,12)
            draw('notif_'..n._id..'_p', 'rect',C.accent,52,Vector2.new(nx+2,ny+nH-3),Vector2.new((nW-4)*clamp(el/n.time,0,1),2),true)
            setAlpha('notif_'..n._id..'_bg',1-fade)
            setAlpha('notif_'..n._id..'_t', 1-fade)
            setAlpha('notif_'..n._id..'_p', 1-fade)
        end
        if el>n.time+0.5 then removePrefix('notif_'..n._id..'_'); table.remove(self._notifications,ni) end
    end

    if not self._menu_open then
        undrawPrefix('m_'); undrawPrefix('nav_'); undrawPrefix('s_')
        return
    end

    -- DRAG
    if mouseHeld and self._menu_drag then
        local mp=getMouse(); self.x=mp.X-self._menu_drag.X; self.y=mp.Y-self._menu_drag.Y
    elseif not mouseHeld then
        self._menu_drag=nil
    end

    local x,y,w,h=self.x,self.y,self.w,self.h
    local sw,pad=self._sw,self._padding
    local tbH=32

    -- BACKGROUND + TITLE
    local _wr = 10
    for _row = 0, _wr-1 do
        local _inner = math.floor(math.sqrt(math.max(0, _wr*_wr - (_wr-_row-1)*(_wr-_row-1))))
        local _lx = x + _wr - _inner
        local _rw = w - (_wr-_inner)*2
        draw('m_tr'..(_row), 'rect', C.side, 2, Vector2.new(_lx, y+_row), Vector2.new(_rw, 1), true)
        draw('m_br'..(_row), 'rect', C.bg,   2, Vector2.new(_lx, y+h-1-_row), Vector2.new(_rw, 1), true)
    end
    draw('m_bg', 'rect', C.bg,   1, Vector2.new(x, y+_wr), Vector2.new(w, h-_wr*2),    true)
    draw('m_tb', 'rect', C.side, 2, Vector2.new(x, y+_wr), Vector2.new(w, tbH-_wr),    true)
    draw('m_ttl', 'text', C.text, 3, Vector2.new(x+pad+4,y+8), self.title,         false,false,14)
    local tW=textW(self.title,14)
    draw('m_sub', 'text', C.sub,  3, Vector2.new(x+pad+4+tW+6,y+10), self.subtitle, false,false,11)
    draw('m_dr','rect',Color3.fromRGB(255,95,86), 3,Vector2.new(x+w-14,y+11),Vector2.new(10,10),true)
    draw('m_dy','rect',Color3.fromRGB(255,189,46),3,Vector2.new(x+w-28,y+11),Vector2.new(10,10),true)
    draw('m_dg','rect',Color3.fromRGB(39,201,63), 3,Vector2.new(x+w-42,y+11),Vector2.new(10,10),true)

    if clickFrame and inBounds(Vector2.new(x,y),Vector2.new(w-50,tbH)) and not self._menu_drag then
        local mp=getMouse(); self._menu_drag=Vector2.new(mp.X-x,mp.Y-y); clickFrame=false
    end

    -- SIDEBAR
    local sbX,sbY,sbH=x,y+tbH,h-tbH
    draw('m_sb',  'rect',C.side,2,Vector2.new(sbX,sbY),    Vector2.new(sw,sbH),true)
    draw('m_sdiv','line',C.div, 3,Vector2.new(sbX+sw,sbY), Vector2.new(sbX+sw,sbY+sbH),1)

    -- NAV
    local navY=sbY+pad
    for _,tname in ipairs(self._tab_order) do
        local isOpen=self._open_tab==tname
        local navCol = isOpen and C.navhi or C.side
        draw('nav_'..tname..'_bg','rect',navCol,4,Vector2.new(sbX+pad,navY),Vector2.new(sw-pad*2,28),true)
        if isOpen then
            draw('nav_'..tname..'_bdr','rect',C.div,4,Vector2.new(sbX+pad,navY),Vector2.new(sw-pad*2,28),false)
        else undraw('nav_'..tname..'_bdr') end
        roundedCorners('nav_'..tname..'_bg', sbX+pad, navY, sw-pad*2, 28, 8, C.side, 6)
        if isOpen then draw('nav_'..tname..'_bar','rect',C.accent,5,Vector2.new(sbX+pad,navY+4),Vector2.new(3,20),true)
        else undraw('nav_'..tname..'_bar') end
        draw('nav_'..tname..'_t','text',isOpen and C.text or C.sub,5,Vector2.new(sbX+pad+10,navY+8),tname,false,false,12)
        if clickFrame and inBounds(Vector2.new(sbX+pad,navY),Vector2.new(sw-pad*2,28)) and not isOpen then
            self._open_tab=tname; self._tab_change_at=os.clock()
            self._scroll=0; self._scrollT=0
            clickFrame=false
        end
        navY=navY+28+3
    end

    -- PROFILE
    local pfY=sbY+sbH-38
    draw('m_pfbg', 'rect',C.side,  2,Vector2.new(sbX,pfY),       Vector2.new(sw,38),true)
    draw('m_pfav', 'rect',C.accdim,4,Vector2.new(sbX+pad,pfY+7), Vector2.new(24,24),true)
    roundedCorners('m_pfav', sbX+pad, pfY+7, 24, 24, 5, C.side, 5)
    draw('m_pfn',  'text',C.accent,5,Vector2.new(sbX+pad+12,pfY+13),(self.username or 'P'):sub(1,1):upper(),false,true,11)
    draw('m_pfname','text',C.text, 5,Vector2.new(sbX+pad+28,pfY+8), self.username or '',false,false,11)
    draw('m_pfsub', 'text',C.sub,  5,Vector2.new(sbX+pad+28,pfY+20),self.usertext or '',false,false,10)

    -- CONTENT AREA
    local cX=x+sw+1; local cY=y+tbH; local cW=w-sw-1; local cH=h-tbH
    draw('m_ct',   'rect',C.content,2,Vector2.new(cX,cY),Vector2.new(cW,cH),  true)
    local chH=34
    draw('m_chbg', 'rect',C.content,3,Vector2.new(cX,cY),Vector2.new(cW,chH), true)
    draw('m_chtxt','text',C.text,   4,Vector2.new(cX+pad+4,cY+10),self._open_tab or '',false,false,14)
    draw('m_chdiv','line',C.div,    4,Vector2.new(cX+6,cY+chH),Vector2.new(cX+cW-6,cY+chH),1)

    -- SCROLL
    if self._scroll_delta ~= 0 then
        self._scrollT = math.max(0, self._scrollT - self._scroll_delta * 40)
        self._scroll_delta = 0
    end
    self._scroll = lerp(self._scroll, self._scrollT, 0.25)

    -- SCROLLBAR
    local sbW2=8; local sbX2=cX+cW-sbW2-4; local sbY2=cY+chH+6; local sbH2=cH-chH-14

    -- WIDGETS
    local tabData=self._open_tab and self._tree[self._open_tab]
    for _,tname in ipairs(self._tab_order) do
        if tname~=self._open_tab then
            local td=self._tree[tname]
            if td then for _,sn in ipairs(td._sec_order or {}) do undrawPrefix('s_'..tname..'_'..sn) end end
        end
    end

    local maxScroll = 0

    if tabData then
        local wY = cY+chH+pad - math.floor(self._scroll)
        local wX=cX+pad; local wW=cW-pad*2-sbW2-12  -- leave room for scrollbar
        local clipTop=cY+chH; local clipBot=cY+cH
        local totalH=0

        for _,sname in ipairs(tabData._sec_order or {}) do
            local sec=tabData._items[sname]
            if not sec then continue end
            local slid='s_'..self._open_tab..'_'..sname

            if wY>=clipTop-20 and wY<=clipBot then
                draw(slid..'_hdr','text',C.sub,10,Vector2.new(wX+2,wY+3),sname:upper(),false,false,10)
            else undraw(slid..'_hdr') end
            wY=wY+18; totalH=totalH+18

            for wi,w2 in ipairs(sec._widgets) do
                local wid=slid..'_'..wi
                local wType=w2.type
                local hasSub=(w2.sub or '')~=''
                local iH=(wType=='toggle' or wType=='button') and (hasSub and 52 or 34)
                       or wType=='slider' and 46
                       or wType=='dropdown' and 46
                       or wType=='textbox' and 38
                       or 34

                totalH=totalH+iH+4

                if wY+iH<=clipTop or wY>=clipBot then
                    undrawPrefix(wid); wY=wY+iH+4; continue
                end

                local isHov=inBounds(Vector2.new(wX,wY),Vector2.new(wW,iH))
                local cardCol = isHov and C.cardhov or C.card
                draw(wid..'_bg', 'rect',cardCol,10,Vector2.new(wX,wY),Vector2.new(wW,iH),true)
                draw(wid..'_bdr','rect',C.div,  11,Vector2.new(wX,wY),Vector2.new(wW,iH),false)
                roundedCorners(wid..'_bg',  wX, wY, wW, iH, 8, C.content, 12)
                roundedCorners(wid..'_bdr', wX, wY, wW, iH, 8, C.content, 13)

                if wType=='toggle' then
                    local hasCP=w2.cp~=nil
                    if hasCP then
                        local csz=18; local cx2=wX+wW-csz-6; local cy2=wY+(iH-csz)/2
                        draw(wid..'_cp',   'rect',w2.cp.value,12,Vector2.new(cx2,cy2),Vector2.new(csz,csz),true)
                        draw(wid..'_cpbdr','rect',C.div,       13,Vector2.new(cx2,cy2),Vector2.new(csz,csz),false)
                        roundedCorners(wid..'_cp',   cx2, cy2, csz, csz, 4, cardCol, 14)
                        roundedCorners(wid..'_cpbdr',cx2, cy2, csz, csz, 4, cardCol, 15)
                        if clickFrame and inBounds(Vector2.new(cx2,cy2),Vector2.new(csz,csz)) then
                            local col=w2.cp.value; local h2,s2,v2=rgbToHsv(col.R,col.G,col.B)
                            local ss2=getScreenSize(); local ppx=cX+cW+4
                            if ppx+200>ss2.X then ppx=cX-204 end
                            self._active_colorpicker={x=ppx,y=cY,label=w2.cp.label,h=h2,s=s2,v=v2,
                                cb=function(c) w2.cp.value=c; if w2.cp.cb then w2.cp.cb(c) end end,_spawned_at=os.clock()}
                            clickFrame=false
                        end
                    end
                    local tOff=hasCP and (wW-80) or (wW-50)
                    local tX=wX+tOff; local tY2=wY+(iH-18)/2
                    local onC=w2.unsafe and Color3.fromRGB(255,180,0) or C.accent
                    local trkCol=w2.value and onC or C.trkoff
                    draw(wid..'_trk','rect',trkCol,11,Vector2.new(tX,tY2),Vector2.new(34,18),true)
                    roundedCorners(wid..'_trk', tX, tY2, 34, 18, 9, cardCol, 13)
                    local thmPX=w2.value and tX+16 or tX+2
                    draw(wid..'_thm','rect',C.white,12,Vector2.new(thmPX,tY2+2),Vector2.new(14,14),true)
                    roundedCorners(wid..'_thm', thmPX, tY2+2, 14, 14, 7, trkCol, 14)
                    if clickFrame and inBounds(Vector2.new(tX,tY2),Vector2.new(34,18)) then
                        w2.value=not w2.value; if w2.cb then w2.cb(w2.value) end; clickFrame=false
                    end
                    draw(wid..'_lbl','text',C.text,11,Vector2.new(wX+10,wY+8),w2.label,false,false,13)
                    if hasSub then draw(wid..'_sub','text',C.sub,11,Vector2.new(wX+10,wY+22),w2.sub,false,false,11)
                    else undraw(wid..'_sub') end

                elseif wType=='slider' then
                    draw(wid..'_lbl','text',C.text,11,Vector2.new(wX+10,wY+6),w2.label,false,false,12)
                    local vt=tostring(w2.value)..w2.suffix
                    draw(wid..'_val','text',C.accent,11,Vector2.new(wX+wW-textW(vt,11)-8,wY+6),vt,false,false,11)
                    local slX=wX+10; local slY2=wY+26; local slW=wW-20
                    draw(wid..'_trk','rect',C.trkoff,11,Vector2.new(slX,slY2),Vector2.new(slW,4),true)
                    draw(wid..'_trkl','rect',C.content,12,Vector2.new(slX,slY2),Vector2.new(2,4),true)
                    draw(wid..'_trkr','rect',C.content,12,Vector2.new(slX+slW-2,slY2),Vector2.new(2,4),true)
                    local pct=clamp((w2.value-w2.min)/(w2.max-w2.min),0,1)
                    if pct>0 then draw(wid..'_fill','rect',C.accent,12,Vector2.new(slX,slY2),Vector2.new(math.max(2,slW*pct),4),true) end
                    local thmX=slX+slW*pct-5; local thmY=slY2-3
                    draw(wid..'_thm','rect',C.white,13,Vector2.new(thmX,thmY),Vector2.new(10,10),true)
                    roundedCorners(wid..'_thm', thmX, thmY, 10, 10, 5, C.content, 14)
                    if mouseHeld then
                        if inBounds(Vector2.new(slX-4,slY2-6),Vector2.new(slW+8,16)) and clickFrame then
                            self._slider_drag=wid; clickFrame=false
                        end
                        if self._slider_drag==wid then
                            local mp=getMouse()
                            local np=clamp((mp.X-slX)/slW,0,1)
                            local nv=math.floor(((w2.min+(w2.max-w2.min)*np)/w2.step)+0.5)*w2.step
                            nv=clamp(nv,w2.min,w2.max)
                            if nv~=w2.value then w2.value=nv; if w2.cb then w2.cb(nv) end end
                        end
                    else self._slider_drag=nil end

                elseif wType=='dropdown' then
                    draw(wid..'_lbl','text',C.text,11,Vector2.new(wX+10,wY+6),w2.label,false,false,12)
                    local dBX=wX+10; local dBY=wY+22; local dBW=wW-20; local dBH=18
                    draw(wid..'_box','rect',C.srch,11,Vector2.new(dBX,dBY),Vector2.new(dBW,dBH),true)
                    draw(wid..'_bdr','rect',C.div, 12,Vector2.new(dBX,dBY),Vector2.new(dBW,dBH),false)
                    local disp=table.concat(w2.value,', '); if #disp==0 then disp='None' end
                    draw(wid..'_val','text',C.text,12,Vector2.new(dBX+6,dBY+3),disp,false,false,11)
                    draw(wid..'_arr','text',C.sub, 12,Vector2.new(dBX+dBW-12,dBY+4),'v',false,false,9)
                    if clickFrame and inBounds(Vector2.new(dBX,dBY),Vector2.new(dBW,dBH)) then
                        self._active_dropdown={x=dBX,y=dBY+dBH,w=dBW,value=w2.value,choices=w2.choices,multi=w2.multi,
                            cb=function(v) w2.value=v; if w2.cb then w2.cb(v) end end,_spawned_at=os.clock()}
                        clickFrame=false
                    end

                elseif wType=='button' then
                    draw(wid..'_lbl','text',C.text,11,Vector2.new(wX+10,wY+8),w2.label,false,false,13)
                    if hasSub then draw(wid..'_sub','text',C.sub,11,Vector2.new(wX+10,wY+22),w2.sub,false,false,11)
                    else undraw(wid..'_sub') end
                    draw(wid..'_arr','text',C.sub,11,Vector2.new(wX+wW-16,wY+iH/2-7),'>',false,false,12)
                    if clickFrame and isHov then if w2.cb then w2.cb() end; clickFrame=false end

                elseif wType=='textbox' then
                    local isTyp=self._input_ctx==wid
                    draw(wid..'_lbl','text',C.sub,11,Vector2.new(wX+10,wY+4),w2.label,false,false,10)
                    local tBX=wX+10; local tBY=wY+16; local tBW=wW-20; local tBH=16
                    draw(wid..'_box','rect',C.srch,11,Vector2.new(tBX,tBY),Vector2.new(tBW,tBH),true)
                    draw(wid..'_bdr','rect',isTyp and C.accent or C.div,12,Vector2.new(tBX,tBY),Vector2.new(tBW,tBH),false)
                    local disp=(w2.value~='' and w2.value or (isTyp and '' or w2.label))..(isTyp and (math.floor(os.clock()*2)%2==0 and '|' or ' ') or '')
                    draw(wid..'_val','text',w2.value~='' and C.text or C.sub,12,Vector2.new(tBX+4,tBY+3),disp,false,false,11)
                    if clickFrame then
                        if inBounds(Vector2.new(tBX,tBY),Vector2.new(tBW,tBH)) then self._input_ctx=wid; clickFrame=false
                        elseif isTyp then self._input_ctx=nil end
                    end
                    if isTyp then
                        local cm={space=' ',dash='-',period='.',comma=','}
                        local sh=isHeld('lshift') or isHeld('rshift')
                        local sm={['1']='!',['2']='@',['3']='#',['4']='$',['5']='%',['0']=')'}
                        for ch in pairs(self._inputs) do
                            if isPressed(ch) then
                                local m=cm[ch] or ch
                                if m=='enter' then self._input_ctx=nil
                                elseif m=='unbound' then w2.value=w2.value:sub(1,-2); if w2.cb then w2.cb(w2.value) end
                                elseif #m==1 then
                                    if sh and sm[m] then m=sm[m] elseif sh then m=m:upper() end
                                    w2.value=w2.value..m; if w2.cb then w2.cb(w2.value) end
                                end
                            end
                        end
                    end

                elseif wType=='colorpicker' then
                    draw(wid..'_lbl','text',C.text,11,Vector2.new(wX+10,wY+8),w2.label,false,false,12)
                    local csz=20; local cx2=wX+wW-csz-8; local cy2=wY+7
                    draw(wid..'_sw', 'rect',w2.value,12,Vector2.new(cx2,cy2),Vector2.new(csz,csz),true)
                    draw(wid..'_bdr','rect',C.div,   13,Vector2.new(cx2,cy2),Vector2.new(csz,csz),false)
                    roundedCorners(wid..'_sw',  cx2, cy2, csz, csz, 4, cardCol, 14)
                    roundedCorners(wid..'_bdr', cx2, cy2, csz, csz, 4, cardCol, 15)
                    if clickFrame and inBounds(Vector2.new(cx2,cy2),Vector2.new(csz,csz)) then
                        local h2,s2,v2=rgbToHsv(w2.value.R,w2.value.G,w2.value.B)
                        self._active_colorpicker={x=cX+cW+4,y=cY,label=w2.label,h=h2,s=s2,v=v2,
                            cb=function(c) w2.value=c; if w2.cb then w2.cb(c) end end,_spawned_at=os.clock()}
                        clickFrame=false
                    end
                end

                wY=wY+iH+4
            end
            wY=wY+8; totalH=totalH+8
        end

        maxScroll=math.max(0, totalH-(cH-chH-pad*2))
        self._scrollT=clamp(self._scrollT,0,maxScroll)
    end

    -- SCROLLBAR
    if maxScroll > 0 then
        -- track
        draw('sb_trk','rect',C.trkoff,20,Vector2.new(sbX2,sbY2),Vector2.new(sbW2,sbH2),true)
        -- thumb: height proportional to how much content is visible
        local visRatio = (cH-chH-pad*2) / ((cH-chH-pad*2) + maxScroll)
        local thumbH = math.max(20, math.floor(sbH2 * visRatio))
        local thumbPct = maxScroll > 0 and clamp(math.floor(self._scroll)/maxScroll, 0, 1) or 0
        local travelH = math.max(0, sbH2 - thumbH)
        local thumbY = sbY2 + math.floor(travelH * thumbPct)
        thumbY = clamp(thumbY, sbY2, sbY2 + travelH)
        local isHovSB = inBounds(Vector2.new(sbX2-4,sbY2),Vector2.new(sbW2+8,sbH2))
        local thumbCol = (isHovSB or self._sb_drag) and C.accent or C.sub
        draw('sb_thm','rect',thumbCol,21,Vector2.new(sbX2,thumbY),Vector2.new(sbW2,thumbH),true)
        -- drag
        if mouseHeld then
            if clickFrame and isHovSB then self._sb_drag=true; clickFrame=false end
            if self._sb_drag then
                local mp=getMouse()
                local rel=clamp((mp.Y - sbY2 - thumbH/2) / math.max(1, travelH), 0, 1)
                self._scrollT = rel * maxScroll
            end
        else
            self._sb_drag=false
        end
    else
        undraw('sb_trk'); undraw('sb_thm'); undrawPrefix('sb_thm_')
        self._sb_drag=false
    end

    -- DROPDOWN
    local dd=self._active_dropdown
    if dd then
        local iH=20; local total=#dd.choices*iH+8
        draw('dd_bg', 'rect',C.card,30,Vector2.new(dd.x,dd.y),Vector2.new(dd.w,total),true)
        draw('dd_bdr','rect',C.div, 31,Vector2.new(dd.x,dd.y),Vector2.new(dd.w,total),false)
        local cancel=true
        for i,ch in ipairs(dd.choices) do
            local cy=dd.y+4+(i-1)*iH
            local found=table.find(dd.value,ch)
            if inBounds(Vector2.new(dd.x+2,cy),Vector2.new(dd.w-4,iH)) then
                draw('dd_hov','rect',C.navhi,31,Vector2.new(dd.x+2,cy),Vector2.new(dd.w-4,iH),true)
                if clickFrame then
                    cancel=not dd.multi
                    if dd.multi then if found then table.remove(dd.value,found) else table.insert(dd.value,ch) end
                    else dd.value={ch} end
                    if dd.cb then dd.cb(dd.value) end
                    clickFrame=cancel and false or clickFrame
                end
            else undraw('dd_hov') end
            draw('dd_ch_'..i,'text',found and C.accent or C.text,32,Vector2.new(dd.x+8,cy+4),ch,false,false,12)
        end
        if clickFrame and cancel then self._active_dropdown=nil; undrawPrefix('dd_'); clickFrame=false end
    else undrawPrefix('dd_') end

    -- COLORPICKER
    local cp=self._active_colorpicker
    if cp then
        local cW2,cH2=200,195
        local cpX,cpY=cp.x,cp.y
        local ss=getScreenSize(); if cpX+cW2>ss.X then cpX=ss.X-cW2-4 end
        draw('cp_bg', 'rect',C.card,30,Vector2.new(cpX,cpY),Vector2.new(cW2,cH2),true)
        draw('cp_bdr','rect',C.div, 31,Vector2.new(cpX,cpY),Vector2.new(cW2,cH2),false)
        draw('cp_lbl','text',C.text,31,Vector2.new(cpX+8,cpY+6),cp.label,false,false,12)
        local pX=cpX+8; local pY=cpY+22; local pW=cW2-16; local pH=cH2-50
        local hH=12; local palH=pH-hH-6
        local cols,rows=12,8
        local cellW=pW/cols; local cellH=palH/rows
        for col=0,cols-1 do
            local s=col/(cols-1)
            for row=0,rows-1 do
                local v=1-(row/(rows-1))
                draw('cp_cell_'..col..'_'..row,'rect',Color3.fromHSV(cp.h,s,v),31,
                    Vector2.new(pX+col*cellW,pY+row*cellH),Vector2.new(cellW+1,cellH+1),true)
            end
        end
        local hY=pY+palH+6
        local hues={Color3.fromRGB(255,0,0),Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),Color3.fromRGB(0,255,255),Color3.fromRGB(0,0,255),Color3.fromRGB(255,0,255),Color3.fromRGB(255,0,0)}
        for i=1,6 do
            local c1,c2=hues[i],hues[i+1]; local sw2=pW/6
            for j=1,4 do
                local t=(j-1)/3
                draw('cp_h'..i..'_'..j,'rect',Color3.new(lerp(c1.R,c2.R,t),lerp(c1.G,c2.G,t),lerp(c1.B,c2.B,t)),34,
                    Vector2.new(pX+(i-1)*sw2+(j-1)*(sw2/4),hY),Vector2.new(sw2/4+1,hH),true)
            end
        end
        local dotX=pX+cp.s*pW-5; local dotY=pY+(1-cp.v)*palH-5
        draw('cp_dot_bg','rect',C.black,36,Vector2.new(dotX,  dotY),  Vector2.new(10,10),true)
        draw('cp_dot',   'rect',C.white,37,Vector2.new(dotX+2,dotY+2),Vector2.new(6,  6),true)
        draw('cp_hdot',  'rect',C.white,36,Vector2.new(pX+cp.h*pW-3,hY),Vector2.new(6,hH),true)
        local nc=Color3.fromHSV(cp.h,cp.s,cp.v)
        draw('cp_sw','rect',nc,36,Vector2.new(cpX+8,cpY+cH2-14),Vector2.new(cW2-16,10),true)
        local mp=getMouse()
        if mouseHeld then
            if inBounds(Vector2.new(pX,pY),Vector2.new(pW,palH)) then
                cp.s=clamp((mp.X-pX)/pW,0,1); cp.v=1-clamp((mp.Y-pY)/palH,0,1)
                if cp.cb then cp.cb(Color3.fromHSV(cp.h,cp.s,cp.v)) end
            elseif inBounds(Vector2.new(pX,hY),Vector2.new(pW,hH)) then
                cp.h=clamp((mp.X-pX)/pW,0,1)
                if cp.cb then cp.cb(Color3.fromHSV(cp.h,cp.s,cp.v)) end
            end
        end
        if clickFrame and not inBounds(Vector2.new(cpX,cpY),Vector2.new(cW2,cH2)) then
            self._active_colorpicker=nil; undrawPrefix('cp_'); clickFrame=false
        end
    else undrawPrefix('cp_') end

    -- menu fade
    local menuFade=1-(self._menu_toggled_at-(os.clock()-0.25))/0.25
    if menuFade<1.1 then
        local a=math.abs((self._menu_open and 0 or 1)-clamp(menuFade,0,1))
        for k,o in pairs(D) do
            if k:sub(1,2)=='m_' or k:sub(1,4)=='nav_' or k:sub(1,2)=='s_' then
                if o then o.Transparency=a end
            end
        end
    end
end

_G.UILib = UILib
return UILib
