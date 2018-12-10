import           Control.Monad                 (liftM2)
import qualified Data.Map                      as M
import           Data.Monoid
import           System.IO

import           XMonad
import qualified XMonad.StackSet               as W

import           XMonad.Actions.CopyWindow     ()
import           XMonad.Actions.CycleWS
import qualified XMonad.Actions.FlexibleResize as Flex
import           XMonad.Actions.FloatKeys
import           XMonad.Actions.UpdatePointer  ()
import           XMonad.Actions.WindowGo

import           XMonad.Hooks.DynamicLog
import           XMonad.Hooks.EwmhDesktops
import           XMonad.Hooks.ManageDocks
import           XMonad.Hooks.ManageHelpers

import           XMonad.Layout                 ()
import           XMonad.Layout.DragPane        ()
import           XMonad.Layout.Gaps
import           XMonad.Layout.LayoutModifier
import           XMonad.Layout.NoBorders
import           XMonad.Layout.PerWorkspace    ()
import           XMonad.Layout.ResizableTile
import           XMonad.Layout.Simplest
import           XMonad.Layout.SimplestFloat   ()
import           XMonad.Layout.Spacing
import           XMonad.Layout.ToggleLayouts
import           XMonad.Layout.TwoPane

import           XMonad.Prompt
import           XMonad.Prompt.Window
import           XMonad.Util.EZConfig
import           XMonad.Util.Paste             ()
import           XMonad.Util.Run               (spawnPipe)
import           XMonad.Util.SpawnOnce

import           Graphics.X11.ExtraTypes.XF86  ()

--------------------------------------------------------------------------- }}}
-- local variables                                                          {{{
-------------------------------------------------------------------------------
myWorkspaces :: [String]
myWorkspaces = ["1", "2", "3", "4", "5", "6"]

modm :: KeyMask
modm = mod4Mask

-- Color Setting
-- colorBlue :: String
-- colorBlue      = "#868bae"

-- colorGreen :: String
-- colorGreen     = "#00d700"

colorRed :: String
colorRed       = "#ff005f"

colorGray :: String
colorGray      = "#666666"

-- colorWhite :: String
-- colorWhite     = "#bdbdbd"

colorNormalbg :: String
colorNormalbg  = "#1c1c1c"

colorfg :: String
colorfg        = "#a8b6b8"

-- Border width
borderwidth :: Dimension
borderwidth = 2

-- Border color
mynormalBorderColor :: String
mynormalBorderColor  = "#262626"

myfocusedBorderColor :: String
myfocusedBorderColor = "#ededed"

-- Float window control width
moveWD :: Dimension
moveWD = borderwidth

-- resizeWD :: Dimension
-- resizeWD = 2*borderwidth

-- gapwidth
gapwidth :: Int
gapwidth  = 4

gwU :: Int
gwU = 36

gwD :: Int
gwD = 0

gwL :: Int
gwL = 0

gwR :: Int
gwR = 0

--------------------------------------------------------------------------- }}}
-- main                                                                     {{{
-------------------------------------------------------------------------------

main :: IO ()
main = do
    wsbar <- spawnPipe $ "dzen2 -x 0 -w 1650 -ta l " ++ dzenStyle
    -- spawn $ "conky -c ~/.config/conky/conky.conf | dzen2 -y 18 -ta l " ++ dzenStyle

    xmonad $ ewmh def
       { borderWidth        = borderwidth
       , terminal           = "alacritty"
    -- , terminal           = "urxvtc"
       , focusFollowsMouse  = True
       , normalBorderColor  = mynormalBorderColor
       , focusedBorderColor = myfocusedBorderColor
       , startupHook        = myStartupHook
       , manageHook         = myManageHookShift <+>
                              myManageHookFloat <+>
                              manageDocks
       , layoutHook         = avoidStruts ( toggleLayouts (noBorders Full) myLayout )
        -- xmobar setting
       , logHook            = dynamicLogWithPP $ myDzenPP wsbar
       , handleEventHook    = fullscreenEventHook
       , workspaces         = myWorkspaces
       , modMask            = modm
       , mouseBindings      = newMouse
       }

       -------------------------------------------------------------------- }}}
       -- Define keys to remove                                             {{{
       ------------------------------------------------------------------------

       `removeKeysP`
       [
       -- Unused gmrun binding
       -- "M-S-p",
       -- Unused close window binding
       -- "M-S-c",
       -- "M-S-<Return>"
       ]

       -------------------------------------------------------------------- }}}
       -- Keymap: window operations                                         {{{
       ------------------------------------------------------------------------

       `additionalKeysP`
       [
       -- Shrink / Expand the focused window
         ("M-,"    , sendMessage Shrink)
       , ("M-."    , sendMessage Expand)
       , ("M-z"    , sendMessage MirrorShrink)
       , ("M-a"    , sendMessage MirrorExpand)
       -- Close the focused window
       -- , ("M-c"    , kill1)
       -- Toggle layout (Fullscreen mode)
       , ("M-f"    , sendMessage ToggleLayout)
       -- , ("M-S-f"  , withFocused (keysMoveWindow (-borderwidth,-borderwidth)))
       -- Move the focused window
       , ("M-C-<R>", withFocused (keysMoveWindow (moveWD, 0)))
       , ("M-C-<L>", withFocused (keysMoveWindow (-moveWD, 0)))
       , ("M-C-<U>", withFocused (keysMoveWindow (0, -moveWD)))
       , ("M-C-<D>", withFocused (keysMoveWindow (0, moveWD)))
       -- Resize the focused window
       -- , ("M-s"    , withFocused (keysResizeWindow (-resizeWD, resizeWD) (0.5, 0.5)))
       -- , ("M-i"    , withFocused (keysResizeWindow (resizeWD, resizeWD) (0.5, 0.5)))
       -- Increase / Decrese the number of master pane
       , ("M-S-;"  , sendMessage $ IncMasterN 1)
       , ("M--"    , sendMessage $ IncMasterN (-1))
       -- Go to the next / previous workspace
       , ("M-<R>"  , nextWS )
       , ("M-<L>"  , prevWS )
       , ("M-l"    , nextWS )
       , ("M-h"    , prevWS )
       -- Shift the focused window to the next / previous workspace
       , ("M-S-<R>", shiftToNext)
       , ("M-S-<L>", shiftToPrev)
       , ("M-S-l"  , shiftToNext)
       , ("M-S-h"  , shiftToPrev)
       -- CopyWindow
       -- , ("M-v"    , windows copyToAll)
       -- , ("M-S-v"  , killAllOtherCopies)
       -- Move the focus down / up
       , ("M-<D>"  , windows W.focusDown)
       , ("M-<U>"  , windows W.focusUp)
       , ("M-j"    , windows W.focusDown)
       , ("M-k"    , windows W.focusUp)
       -- Swap the focused window down / up
       , ("M-S-j"  , windows W.swapDown)
       , ("M-S-k"  , windows W.swapUp)
       -- Shift the focused window to the master window
       , ("M-S-m"  , windows W.shiftMaster)
       -- Search a window and focus into the window
       , ("M-g"    , windowPromptGoto myXPConfig)
       -- Search a window and bring to the current workspace
       , ("M-b"    , windowPromptBring myXPConfig)
       -- Move the focus to next screen (multi screen)
       , ("M-<Tab>", nextScreen)
       ]
       -------------------------------------------------------------------- }}}
       -- Keymap: Manage workspace                                          {{{
       ------------------------------------------------------------------------
       -- mod-[1..9]          Switch to workspace N
       -- mod-shift-[1..9]    Move window to workspace N
       -- mod-control-[1..9]  Copy window to workspace N

       `additionalKeys`
       [ ((modm, xK_b), runOrRaise "google-chrome-stable" (className =? "Google-chrome"))
       , ((modm, xK_a), runOrRaise "alacritty" (className =? "Alacritty"))
       , ((modm, xK_s), runOrRaise "slack" (className =? "Slack"))
       , ((modm, xK_d), runOrRaise "discord" (className =? "Discord"))
       , ((modm, xK_t), runOrRaise "atomic-teeetdeck" (className =? "Atomic TweetDeck"))
       , ((modm .|. controlMask, xK_p), spawn "maim -s | xclip -selection clipboard -t image/png")
       -- , ((modm, xK_v), runOrRaise "calibre" (className =? "calibre-ebook-viewer"))
       -- , ((modm , xK_p ), spawn "scrot screen_%Y-%m-%d-%H-%M-%S.png -d 1")
       -- , ((modm .|. controlMask, xK_p ), spawn "scrot window_%Y-%m-%d-%H-%M-%S.png -d 1 -u")
       ]
       -------------------------------------------------------------------- }}}
       -- Keymap: custom commands                                           {{{
       ------------------------------------------------------------------------

       `additionalKeysP`
       [
       -- Lock screen
         ("M-C-s", spawn "light-locker-command -l")
       , ("M-S-<Return>", spawn "alacritty") -- Launch terminal
       -- , ("M-S-<Return>", spawn "urxvtc")
       -- Launch file manager
       , ("M-e", spawn "thunar")
       -- Launch dmenu
       , ("M-p", spawn "exe=`dmenu_run -l 10 -fn 'RictyDiscord Nerd Font:size=16'` && exec $exe")
       -- Play / Pause media keys
       , ("<XF86AudioPlay>"  , spawn "mpc toggle")
       , ("<XF86HomePage>"   , spawn "mpc toggle")
       , ("S-<F6>"           , spawn "mpc toggle")
       , ("S-<XF86AudioPlay>", spawn "streamradio pause")
       , ("S-<XF86HomePage>" , spawn "streamradio pause")
       -- Volume setting media keys
       , ("<XF86AudioRaiseVolume>", spawn "amixer sset Master 5%+")
       , ("<XF86AudioLowerVolume>", spawn "amixer sset Master 5%-")
       , ("<XF86AudioMute>"       , spawn "amixer sset Master toggle")
        -- Brightness Keys
       , ("<XF86MonBrightnessUp>"  , spawn "xbacklight + 5 -time 100 -steps 1")
       , ("<XF86MonBrightnessDown>", spawn "xbacklight - 5 -time 100 -steps 1")
       -- Take a screenshot (whole window)
       , ("<Print>", spawn "screenshot.sh")
       -- Take a screenshot (selected area)
       , ("S-<Print>", spawn "screenshot_select.sh")
       ]

--------------------------------------------------------------------------- }}}
-- myLayout:          Handle Window behaveior                               {{{
-------------------------------------------------------------------------------

myLayout :: ModifiedLayout Spacing (ModifiedLayout Gaps (Choose ResizableTall (Choose TwoPane Simplest))) a
myLayout = spacing gapwidth $ gaps [(U, gwU),(D, gwD),(L, gwL),(R, gwR)]
           $ ResizableTall 1 (1 / 201) (116 / 201) []
             ||| TwoPane (1 / 201) (116 / 201)
             ||| Simplest

--------------------------------------------------------------------------- }}}
-- myStartupHook:     Start up applications                                 {{{
-------------------------------------------------------------------------------

myStartupHook :: X ()
myStartupHook = do
        spawnOnce "nm-applet"
        spawnOnce "volumeicon"
        spawnOnce "stalonetray"
        spawnOnce "alacritty"
        spawnOnce "light-locker"
        spawnOnce "$HOME/.dropbox-dist/dropboxd"
        spawnOnce "feh --bg-fill $HOME/Documents/background/Aurora.jpg"
        -- spawnOnce "cbatticon"
        -- spawnOnce "urxvtd --quiet --fork --opendisplay"
        -- spawnOnce "enpass"
        -- spawnOnce "xfce4-notifyd-config"
        -- spawnOnce "slack"

--------------------------------------------------------------------------- }}}
-- myManageHookShift: some window must created there                        {{{
-------------------------------------------------------------------------------

myManageHookShift :: Query (Endo (W.StackSet String (Layout Window) Window ScreenId ScreenDetail))
myManageHookShift = composeAll
            -- if you want to know className, type "$ xprop|grep CLASS" on shell
            [ className =? "Gimp"       --> mydoShift "3"
            , stringProperty "WM_NAME" =? "Figure 1" --> doShift "5"
            ]
             where mydoShift = doF . liftM2 (.) W.greedyView W.shift

--------------------------------------------------------------------------- }}}
-- myManageHookFloat: new window will created in Float mode                 {{{
-------------------------------------------------------------------------------

myManageHookFloat :: Query (Endo WindowSet)
myManageHookFloat = composeAll
    [ className =? "feh"              --> doCenterFloat
    , isFullscreen                    --> doFullFloat
    , isDialog                        --> doCenterFloat
    , stringProperty "WM_NAME" =? "LINE" --> doRectFloat (W.RationalRect 0.60 0.1 0.39 0.82)
    ]

--------------------------------------------------------------------------- }}}
-- myLogHook:         loghock settings                                      {{{
-------------------------------------------------------------------------------

-- myLogHook h = dynamicLogWithPP $ wsPP { ppOutput = hPutStrLn h }

--------------------------------------------------------------------------- }}}
-- myWsBar:           xmobar setting                                        {{{
-------------------------------------------------------------------------------

dzenStyle :: String
dzenStyle = "-h '36' -fg '#aaaaaa' -bg '#1c1c1c' -fn 'RictyDiscord Nerd Font:size=13'"

myDzenPP :: Handle -> PP
myDzenPP h = def
                { ppOrder           = \(ws:_l:t:_)  -> [ws,t]
                , ppCurrent         = dzenColor colorRed     colorNormalbg . const "●"
                , ppUrgent          = dzenColor colorGray    colorNormalbg . const "●"
                , ppVisible         = dzenColor colorRed     colorNormalbg . const "⦿"
                , ppHidden          = dzenColor colorGray    colorNormalbg . const "●"
                , ppHiddenNoWindows = dzenColor colorGray    colorNormalbg . const "○"
                , ppTitle           = dzenColor colorRed     colorNormalbg
                , ppOutput          = hPutStrLn h
                , ppWsSep           = " "
                , ppSep             = "  "
                }

-- myWsBar = "xmobar $HOME/.xmonad/xmobarrc"
-- wsPP = xmobarPP { ppOrder           = \(ws:l:t:_)  -> [ws,t]
--                 , ppCurrent         = xmobarColor colorRed     colorNormalbg . \s -> "●"
--                 , ppUrgent          = xmobarColor colorGray    colorNormalbg . \s -> "●"
--                 , ppVisible         = xmobarColor colorRed     colorNormalbg . \s -> "⦿"
--                 , ppHidden          = xmobarColor colorGray    colorNormalbg . \s -> "●"
--                 , ppHiddenNoWindows = xmobarColor colorGray    colorNormalbg . \s -> "○"
--                 , ppTitle           = xmobarColor colorRed     colorNormalbg
--                 , ppOutput          = putStrLn
--                 , ppWsSep           = " "
--                 , ppSep             = "  "
--                 }

--------------------------------------------------------------------------- }}}
-- myXPConfig:        XPConfig                                            {{{
myXPConfig :: XPConfig
myXPConfig = def
                { font              = "xft:RictyDiscord Nerd Font:size=20:antialias=true"
                , fgColor           = colorfg
                , bgColor           = colorNormalbg
                , borderColor       = colorNormalbg
                , height            = 35
                , promptBorderWidth = 0
                , autoComplete      = Just 100000
                , bgHLight          = colorNormalbg
                , fgHLight          = colorRed
                , position          = Bottom
                }

--------------------------------------------------------------------------- }}}
-- newMouse:          Right click is used for resizing window               {{{
-------------------------------------------------------------------------------
myMouse :: t -> [((KeyMask, Button), Window -> X ())]
myMouse x = [ ((modm, button3), \w -> focus w >> Flex.mouseResizeWindow w) ]


newMouse :: XConfig Layout              -> M.Map (ButtonMask, Button) (Window -> X ())
newMouse x = M.union (mouseBindings def x) (M.fromList (myMouse x))

--------------------------------------------------------------------------- }}}
