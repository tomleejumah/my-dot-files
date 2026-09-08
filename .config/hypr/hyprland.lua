-- Converted from hyprlang (0.54-) to Lua (0.55+)
-- https://wiki.hypr.land/Configuring/Start/

------------------
---- MONITORS ----
------------------
hl.monitor({
    output   = "eDP-1",
    mode     = "preferred",
    position = "auto",
    scale    = 1.0,
})
-- hl.monitor({ output = "eDP-1", mode = "preferred", position = "auto", scale = 0.83333 })

---------------------
---- MY PROGRAMS ----
---------------------
local terminal    = "kitty"
local fileManager  = "nautilus"
local menu         = "wofi --show drun"

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("swaync")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprpaper")
    -- hl.exec_cmd("hyprlock")

    -- sunrise-sunset night light
    hl.exec_cmd("wlsunset -l -1.3 -L 36.8 -t 4000 -T 6500")
    hl.exec_cmd("timedatectl set-ntp true")

    -- clipboard history
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-----------------------
----- PERMISSIONS -----
-----------------------
hl.permission("/usr/(bin|local/bin)/grim", "screencopy", "allow")
hl.permission("/usr/(lib|libexec|lib64)/xdg-desktop-portal-hyprland", "screencopy", "allow")
hl.permission("/usr/(bin|local/bin)/hyprpm", "plugin", "allow")

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 },
            inactive_border = "rgba(595959aa)",
        },
        resize_on_border = false,
        allow_tearing = false,
        layout = "dwindle",
    },
    decoration = {
        rounding = 10,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled = true,
            range = 4,
            render_power = 3,
            color = 0xee1a1a1a,
        },
        blur = {
            enabled = true,
            size = 3,
            passes = 1,
            vibrancy = 0.1696,
        },
    },
    animations = {
        enabled = true,
    },
})

-- Bezier curves
hl.curve("easeOutQuint", { type = "bezier", points = { {0.23, 1}, {0.32, 1} } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1} } })
hl.curve("linear", { type = "bezier", points = { {0, 0}, {1, 1} } })
hl.curve("almostLinear", { type = "bezier", points = { {0.5, 0.5}, {0.75, 1} } })
hl.curve("quick", { type = "bezier", points = { {0.15, 0}, {0.1, 1} } })

-- Animations
hl.animation({ leaf = "global",         enabled = true, speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",         enabled = true, speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",        enabled = true, speed = 4.79, bezier = "easeOutQuint" })
hl.animation({ leaf = "windowsIn",      enabled = true, speed = 4.1,  bezier = "easeOutQuint", style = "popin 87%" })
hl.animation({ leaf = "windowsOut",     enabled = true, speed = 1.49, bezier = "linear",        style = "popin 87%" })
hl.animation({ leaf = "fadeIn",         enabled = true, speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",        enabled = true, speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",           enabled = true, speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",         enabled = true, speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",       enabled = true, speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",      enabled = true, speed = 1.5,  bezier = "linear",        style = "fade" })
hl.animation({ leaf = "fadeLayersIn",   enabled = true, speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut",  enabled = true, speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",     enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",   enabled = true, speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut",  enabled = true, speed = 1.94, bezier = "almostLinear", style = "fade" })

-- Layouts
hl.config({
    dwindle = { preserve_split = true },
    master  = { new_status = "master" },
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = false,
    },
})

---------------
---- INPUT ----
---------------
hl.config({
    input = {
        kb_layout = "us",
        kb_variant = "",
        kb_model = "",
        kb_options = "",
        kb_rules = "",
        follow_mouse = 1,
        sensitivity = 0.5,
        touchpad = { natural_scroll = true },
    },
})

hl.device({
    name = "epic-mouse-v1",
    sensitivity = -0.5,
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

hl.bind(mainMod .. " + Q", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + C", hl.dsp.window.close())
hl.bind(mainMod .. " + M", hl.dsp.exit())
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + F", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + R", hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + P", hl.dsp.exec_cmd("power-menu"))
hl.bind(mainMod .. " + T", hl.dsp.layout("togglesplit")) -- dwindle only
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("cliphist list | wofi --dmenu | cliphist decode | wl-copy"))
hl.bind(mainMod .. " + SHIFT + H", hl.dsp.exec_cmd("systemctl hibernate"))
hl.bind("SUPER + SHIFT + L", hl.dsp.exec_cmd("hyprlock"))

-- Swap focused window with neighbor
-- NOTE: verify hl.dsp.window.swap(...) against the LSP stubs; not in the official example file.
hl.bind("SUPER + CTRL + h",    hl.dsp.window.swap({ direction = "l" }))
hl.bind("SUPER + CTRL + l",    hl.dsp.window.swap({ direction = "r" }))
hl.bind("SUPER + CTRL + up",   hl.dsp.window.swap({ direction = "u" }))
hl.bind("SUPER + CTRL + down", hl.dsp.window.swap({ direction = "d" }))
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next({}))

-- Screenshots
hl.bind("Print", hl.dsp.exec_cmd(
    "area=$(slurp) && grim -g \"$area\" - | wl-copy && grim -g \"$area\" ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png && notify-send \"Screenshot\" \"Area captured\""
))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(
    "grim - | wl-copy && grim ~/Pictures/Screenshots/$(date +'%Y%m%d_%H%M%S').png && notify-send \"Screenshot\" \"Fullscreen captured\""
))

-- Screen recording
hl.bind("F9", hl.dsp.exec_cmd(
    "area=$(slurp) && wf-recorder -a -g \"$area\" -f ~/Videos/Screencasts/recording_$(date +'%Y%m%d_%H%M%S').mp4 & disown && notify-send \"Recording Started (Audio + Video)\""
))
hl.bind("SHIFT + F9", hl.dsp.exec_cmd(
    "wf-recorder -a -f ~/Videos/Screencasts/recording_$(date +'%Y%m%d_%H%M%S').mp4 & disown && notify-send \"Recording Started (Audio + Video)\""
))
hl.bind("CTRL + F9", hl.dsp.exec_cmd("pkill -INT wf-recorder && notify-send \"Recording Stopped\""))

-- Night light toggle
hl.bind(mainMod .. " + F6", hl.dsp.exec_cmd("pkill wlsunset || wlsunset -t 4000 -T 6500"))

-- Move focus (vim keys)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "down" }))

-- Workspaces 1-10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key, hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Scratchpad
hl.bind(mainMod .. " + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind("SUPER + ALT + S", hl.dsp.window.move({ workspace = "e+0" }))

-- Scroll through workspaces
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))

-- Move/resize with mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Resize active window (vim-style)
hl.bind("SUPER + ALT + h", hl.dsp.window.resize({ x = -20, y = 0, relative = true }))
hl.bind("SUPER + ALT + l", hl.dsp.window.resize({ x = 20, y = 0, relative = true }))
hl.bind("SUPER + ALT + j", hl.dsp.window.resize({ x = 0, y = 20, relative = true }))
hl.bind("SUPER + ALT + k", hl.dsp.window.resize({ x = 0, y = -20, relative = true }))

-- Media / brightness keys
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"), { locked = true, repeating = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"), { locked = true, repeating = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

-- Firefox Picture-in-Picture
hl.window_rule({
    name = "pip-float",
    match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    float = true,
    size = "214 128",
    move = "1700 26",
})
hl.window_rule({
    name = "pip-tag",
    match = { title = "^([Pp]icture[-\\s]?[Ii]n[-\\s]?[Pp]icture)(.*)$" },
    tag = "+picture-in-picture",
})
hl.window_rule({
    name = "pip-pin",
    match = { tag = "picture-in-picture" },
    pin = true,
    animation = "slide right",
})

-- Nautilus
hl.window_rule({ name = "nautilus-float", match = { class = "org.gnome.Nautilus" }, float = true })
hl.window_rule({ name = "nautilus-size", match = { class = "^(org.gnome.Nautilus)$" }, size = "1013 579" })
hl.window_rule({ name = "nautilus-move", match = { class = "^(org.gnome.Nautilus)$" }, move = "475 181" })

-- Ignore maximize requests
hl.window_rule({
    name = "no_maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

-- Fix XWayland dragging issues
hl.window_rule({
    name = "fix_xwayland_drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

-- layer rules (unused, kept commented as in the original)
-- hl.layer_rule({ name = "blur-swaync-control", match = { namespace = "swaync-control-center" }, blur = true })
-- hl.layer_rule({ name = "blur-swaync-notif", match = { namespace = "swaync-notification-window" }, blur = true })
