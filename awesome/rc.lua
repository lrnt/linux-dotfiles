-- Standard awesome library
local awful = require("awful")
awful.autofocus = require("awful.autofocus")
awful.rules = require("awful.rules")

local math = require("math")
local vicious = require("vicious")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
local scratch = require("scratch")
local gears = require("gears")

local exec = awful.util.spawn

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
beautiful.init(os.getenv("HOME") .. "/.config/awesome/zenburn.lua")

terminal = "urxvt"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

modkey = "Mod4"

layouts =
{
    awful.layout.suit.tile,             -- 1
    awful.layout.suit.tile.bottom,      -- 2
    awful.layout.suit.fair,             -- 3
    awful.layout.suit.max,              -- 4
    awful.layout.suit.magnifier,        -- 5
    awful.layout.suit.floating          -- 6
}
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
tags = {
    names  = { "gvim", "term", "web", "mail", "im", 6, 7, 8, 9, 10 },
    layout = { layouts[2], layouts[1], layouts[5], layouts[5], layouts[6],
               layouts[6], layouts[6], layouts[6], layouts[6], layouts[6] }
}

for s = 1, screen.count() do
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Wibox

-- {{{ Wifi
wifiicon = wibox.widget.imagebox(awful.util.getdir("config") .. "/icons/wifi.png")

wifiwidget = wibox.widget.textbox()
vicious.register(wifiwidget, vicious.widgets.wifi,
    function(widget, args)
        -- TODO: combine netwidget and wifiwidget
        -- if not connected to a wifi network hide the wifi icon and show the
        -- connected ethernet adapter, ie the adapter that is used to calculate
        -- the up and download speed
        return math.floor(args['{link}']/70*100) .. '% '.. args['{ssid}']
    end, 90, "wlan0")
-- }}}

-- {{{ Network
dnicon = wibox.widget.imagebox(awful.util.getdir("config") .. "/icons/down.png")
upicon = wibox.widget.imagebox(awful.util.getdir("config") .. "/icons/up.png")

netwidget = wibox.widget.textbox()
vicious.register(netwidget, vicious.widgets.net,
    function (widget, args)
        local adapters = {"eth0", "eno1", "wlan0"}
        local down, up

        for k, adapter in pairs(adapters) do
            down = args[string.format("{%s down_kb}", adapter)]
            up = args[string.format("{%s up_kb}", adapter)]

            if (down and down ~= "0.0") or (up and up ~= "0.0") then
                break
            end
        end

        return string.format('<span color="#CC9393">%s</span> ' ..
                             '<span color="#7F9F7F">%s</span>', down, up)

    end, 3)
--}}}

-- {{{ Battery
baticon = wibox.widget.imagebox(awful.util.getdir("config") .. "/icons/bat.png")
batwidget = wibox.widget.textbox()
vicious.register(batwidget, vicious.widgets.bat,
    function (widget, args)
        if args[2] ~= 0 then
            return string.format("%s%s%% (%s)", args[1], args[2], args[3])
        else
            -- TODO: hide baticon
            return ""
        end
    end, 61, "BAT0")
-- }}}

-- {{{ Volume
volicon = wibox.widget.imagebox(awful.util.getdir("config") .. "/icons/vol.png")

volbar = awful.widget.progressbar()
volbar:set_vertical(true):set_ticks(true)
volbar:set_height(18):set_width(8):set_ticks_size(2)
volbar:set_background_color(beautiful.fg_off_widget)

volbar:set_background_color("#3F3F3F")
volbar:set_border_color("#3F3F3F")
volbar:set_color("#AECF96")

vicious.register(volbar, vicious.widgets.volume, "$1", 2, "Master")
volbar:buttons(awful.util.table.join(
   awful.button({ }, 4, function () exec("amixer set Master playback 10+", false) end),
   awful.button({ }, 5, function () exec("amixer set Master playback 10-", false) end)
))
-- }}}

-- {{{ Textclock
mytextclock = awful.widget.textclock()
-- }}}

-- {{{ Generate wibox
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  -- Without this, the following
                                                  -- :isvisible() makes no sense
                                                  c.minimized = false
                                                  if not c:isvisible() then
                                                      awful.tag.viewonly(c:tags()[1])
                                                  end
                                                  -- This will also un-minimize
                                                  -- the client, if needed
                                                  client.focus = c
                                                  c:raise()
                                              end
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))

for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
    mywibox[s] = awful.wibox({ position = "top", screen = s })

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    
    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(wifiicon)
    right_layout:add(wifiwidget)
    right_layout:add(dnicon)
    right_layout:add(netwidget)
    right_layout:add(upicon)
    right_layout:add(baticon)
    right_layout:add(batwidget)
    right_layout:add(volicon)
    right_layout:add(volbar)
    right_layout:add(mytextclock)
    right_layout:add(mylayoutbox[s])
    
    -- Bring it all together
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_middle(mytasklist[s])
    layout:set_right(right_layout)

    mywibox[s]:set_widget(layout)
end
-- }}}


-- }}}

-- {{{ Screen cycle
-- Get active outputs
local function outputs()
    local outputs = {}
    local xrandr = io.popen("xrandr -q")
    if xrandr then
        for line in xrandr:lines() do
     output = line:match("^([%w-]+) connected ")
     if output then
         outputs[#outputs + 1] = output
     end
        end
        xrandr:close()
    end

    return outputs
end

local function arrange(out)
    -- We need to enumerate all the way to combinate output. We assume
    -- we want only an horizontal layout.
    local choices  = {}
    local previous = { {} }
    for i = 1, #out do
        -- Find all permutation of length `i`: we take the permutation
        -- of length `i-1` and for each of them, we create new
        -- permutations by adding each output at the end of it if it is
        -- not already present.
        local new = {}
        for _, p in pairs(previous) do
     for _, o in pairs(out) do
         if not awful.util.table.hasitem(p, o) then
             new[#new + 1] = awful.util.table.join(p, {o})
         end
     end
        end
        choices = awful.util.table.join(choices, new)
        previous = new
    end

    return choices
end

-- Build available choices
local function menu()
    local menu = {}
    local out = outputs()
    local choices = arrange(out)

    for _, choice in pairs(choices) do
        local cmd = "xrandr"
        -- Enabled outputs
        for i, o in pairs(choice) do
     cmd = cmd .. " --output " .. o .. " --auto"
     if i > 1 then
         cmd = cmd .. " --right-of " .. choice[i-1]
     end
        end
        -- Disabled outputs
        for _, o in pairs(out) do
     if not awful.util.table.hasitem(choice, o) then
         cmd = cmd .. " --output " .. o .. " --off"
     end
        end

        local label = ""
        if #choice == 1 then
     label = 'Only <span weight="bold">' .. choice[1] .. '</span>'
        else
     for i, o in pairs(choice) do
         if i > 1 then label = label .. " + " end
         label = label .. '<span weight="bold">' .. o .. '</span>'
     end
        end

        menu[#menu + 1] = { label, cmd,
                            "/usr/share/icons/Tango/32x32/devices/display.png"}
    end

    return menu
end

-- Display xrandr notifications from choices
local state = { iterator = nil,
        timer = nil,
        cid = nil }
local function xrandr()
    -- Stop any previous timer
    if state.timer then
        state.timer:stop()
        state.timer = nil
    end

    -- Build the list of choices
    if not state.iterator then
        state.iterator = awful.util.table.iterate(menu(),
                    function() return true end)
    end

    -- Select one and display the appropriate notification
    local next  = state.iterator()
    local label, action, icon
    if not next then
        label, icon = "Keep the current configuration", "/usr/share/icons/Tango/32x32/devices/display.png"
        state.iterator = nil
    else
        label, action, icon = unpack(next)
    end
    state.cid = naughty.notify({ text = label,
                icon = icon,
                timeout = 4,
                screen = mouse.screen, -- Important, not all screens may be visible
                font = "Free Sans 18",
                replaces_id = state.cid }).id

    -- Setup the timer
    state.timer = timer { timeout = 4 }
    state.timer:connect_signal("timeout",
              function()
                  state.timer:stop()
                  state.timer = nil
                  state.iterator = nil
                  if action then
                awful.util.spawn(action, false)
                  end
              end)
    state.timer:start()
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
            if client.focus then client.focus:raise() end
        end),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
            if client.focus then client.focus:raise() end
        end),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.util.spawn(terminal) end),
    awful.key({ modkey,           }, "#49", function () scratch.drop(terminal, "bottom", nil, nil, 0.30) end),
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),

    awful.key({ modkey, "Control" }, "n", awful.client.restore),

    -- Cycle screen
    awful.key({}, "XF86Display", xrandr),

    -- Prompt
    awful.key({ modkey },            "r",     function () mypromptbox[mouse.screen]:run() end)
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey, "Shift"   }, "r",      function (c) c:redraw()                       end),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber));
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = true,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "gvim" },
      properties = { tag = tags[1][1] } },
    { rule = { class = "Skype" },
      properties = { tag = tags[1][5] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Add a titlebar
    -- awful.titlebar.add(c, { modkey = modkey })

    -- Enable sloppy focus
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
        end
    end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
