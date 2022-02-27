# UDE-Maker
## General info
A postinstalation script for configuring freshly installed Arch Linux.

Disclaimer: this is an early version of this script – lack of crucial features, was tested only on virtual machine.

## Preview
![result preview](https://i.imgur.com/y7es3wF.jpg)

## Usage
```bash
git clone https://github.com/tangens90/ude-maker
bash ude-maker/src/ude-maker.sh
```

## List of features
Below you can see a list of features your system will be able to do if you decide to use this script. I also included a list of packages a particular feature depends on to make testing and troubleshooting easier.

| Feature | Used packages |
| --- | ----------- |
| ```startx``` startx dwm | xorg-server, xorg-xinit, dwm, libxft, libxinerama, *fonts-packages* |
| ```startx b``` startx dwm and brave browser | dwm, brave-bin |
| terminal can be opened by <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>Enter</kbd> | st, sxhkd |
| terminal is opaque | st, xcompmgr |
| random wallpaper is set at dwm startup | feh, python-pywal |
| dwm's, st's and dmenu's colorscheme matches wallpaper's colorscheme | feh, python-pywal, xdotool |
| touchpad is off | xorg-xinput |
| top status bar shows date and battery level | xorg-xsetroot |
| screenshot can be taken by <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>W</kbd> | sxhkd, flameshot |
| notifications can be received | dunst |
| notifications can be clicked by <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>;</kbd> | dunst, sxhkd |
| notifications can be send by ```notify-send``` | dunst, notify-send |
| <kbd>Super</kbd>+<kbd>Shift</kbd>+<kbd>l</kbd> turns off the screen | xorg-xset |
| screen is turned off after 10 minutes of inactivity | xautolock |
| slock is run when waking screen | slock, xautolock |
| sound can be muted, raised and lowered with respective keys | sxhkd, pulseaudio |
| <kbd>CapsLock</kbd> is swapped with <kbd>Esc</kbd> | xorg-xmodmap, xorg-setxkbmap |
| data is copyable from Vim using <kbd>"</kbd><kbd>+</kbd><kbd>y</kbd> | vim, gvim |
| in Zathura data is copyable and links are open in browser | zathura |
| Haskell files can be compiled | ghc, ghc-static |
