#!/usr/bin/env python

#=========================================================================================
#   Written by damo, feb 2012
#   Use as you like :)
#=========================================================================================
#
#   Python script to set per-desktop background wallpaper for Openbox WM, without the need to
#   add shell commands to key and mouse bindings.
#
#   This code uses 'xprop' to get the current desktop, then 'feh' to set the wallpaper
#
#   You need to create a background image for each desktop, named '0.jpg','1.jpg' etc,
#   (although you could change the code to read eg 'png' etc)
#
#   See 'feh' man page for options, which can be entered as fields in the subprocess.call()
#==========================================================================================
#   USAGE   python switchbg.py [options]
#
#           [option 1] : [/path/to/wallpaper/directory/]
#           [option 2] : [secs] (0.25 works OK) - time to poll xprop, 
#
#   Set the initial wallpaper background in autostart, using nitrogen, feh, fsetbg etc
#   then add this script eg...
#
#   (feh --bg-scale /path/to/wallpaper/directory/0.jpg) &
#   (sleep 2s && python /path/to/switchbg.py /path/to/wallpaper/directory/ 0.2) &
#
#=========================================================================================

import time,subprocess,sys

def xprop_pipe(wp,t):
    '''Params are path to wallpaper directory (from args, and passed to set_bg()),
        and time to wait between xprop calls;
        Run xprop subprocess in an endless loop. It gets the current desktop as a string from
        stdout. The desktop number (0,1,2,3...) is the last field (cardinal),
        which is extracted with 'tail';
        communicate() returns a tuple, so we want the first value and discard the '\n';
        If the cardinal has changed, call set_bg() to change the wallpaper'''
    
    dtop = 0 # set initial desktop number (flag)
    xp = 'xprop -root _NET_CURRENT_DESKTOP | tail -c -2'# set xprop shell command

    while True:
        proc = subprocess.Popen(xp,stdout=subprocess.PIPE,shell=True)# subprocess: pipe to stdout
        curr_dtop = proc.communicate()[0]  # output is tuple, so get first val (desktop number)
        curr_dtop = int(curr_dtop)         # current desktop cardinal = 0,1,2,3...
        if curr_dtop != dtop:              # if cardinal has changed....
            set_bg(wp,curr_dtop)           # ....call set_bg func
            dtop = curr_dtop               # set the flag to current desktop
            
        time.sleep(t)                      # wait for t secs (from args)

def set_bg(wpath,i):
    '''params are the path to wallpaper directory and current desktop number;
        Get file path for wallpaper directory (from args);
        Run 'feh' shell command to set wallpaper for current desktop'''
    #======= set image filetype here... ==========================================================
    bg = wpath + str(i) + ".jpg"
    #======= See feh man pages for options: each should be in its own comma-separated quoted field
    subprocess.call(['feh','--bg-scale',bg],)# sub.call can be passed a list of strings as 
                                             # commandline input - no need to escape spaces etc

if __name__ == '__main__':
    '''commandline arguments are filepath to wallpaper directory [1], and polling time (secs)[2]
        Pass these on'''
    wp = sys.argv[1]       # path to wallpaper directory 
    t = float(sys.argv[2]) #convert commandline string input to float(required by sleep() )
    xprop_pipe(wp,t)       #run xprop to get current desktop 