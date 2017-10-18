#!/usr/bin/perl

# obmenu-generator - schema file

=for comment

    item:      add an item inside the menu               {item => ["command", "label", "icon"]},
    cat:       add a category inside the menu             {cat => ["name", "label", "icon"]},
    sep:       horizontal line separator                  {sep => undef}, {sep => "label"},
    pipe:      a pipe menu entry                         {pipe => ["command", "label", "icon"]},
    file:      include the content of an XML file        {file => "/path/to/file.xml"},
    raw:       any XML data supported by Openbox          {raw => q(...)},
    beg:       begin of a category                        {beg => ["name", "icon"]},
    end:       end of a category                          {end => undef},
    obgenmenu: generic menu settings                {obgenmenu => ["label", "icon"]},
    exit:      default "Exit" action                     {exit => ["label", "icon"]},

=cut

# NOTE:
#    * Keys and values are case sensitive. Keep all keys lowercase.
#    * ICON can be a either a direct path to an icon or a valid icon name
#    * Category names are case insensitive. (X-XFCE and x_xfce are equivalent)

require "$ENV{HOME}/.config/obmenu-generator/config.pl";

## Text editor
my $editor = $CONFIG->{editor};

our $SCHEMA = [

    #          COMMAND                 LABEL              ICON
    {item => ['thunar .',       'File Manager', 'system-file-manager']},
    {item => ['termite',        'Terminal',     'utilities-terminal']},
    {item => ['chromium', 'Web Browser',  'web-browser']},

    {sep => undef},
    {beg => ['All', 'applications-engineering']},
        #          NAME            LABEL                ICON
        {cat => ['utility',     'Accessories', 'applications-utilities']},
        {cat => ['development', 'Development', 'applications-development']},
        {cat => ['education',   'Education',   'applications-science']},
        {cat => ['game',        'Games',       'applications-games']},
        {cat => ['graphics',    'Graphics',    'applications-graphics']},
        {cat => ['audiovideo',  'Multimedia',  'applications-multimedia']},
        {cat => ['network',     'Network',     'applications-internet']},
        {cat => ['office',      'Office',      'applications-office']},
        {cat => ['other',       'Other',       'applications-other']},
        {cat => ['settings',    'Settings',    'applications-accessories']},
        {cat => ['system',      'System',      'applications-system']},
    {end => undef},

    ## Custom advanced settings
    {sep => undef},
    {beg => ['Settings', 'applications-engineering']},

      # Configuration files
      
        # Preferences
        {beg => ['Preferences', 'theme']},
            {item => ['lxappearance',              'Appearance',         'preferences-desktop-theme']},        
            {item => ['gksudo lightdm-gtk-greeter-settings',    'LightDM Appearance',       'theme']},
            {item => ['subl3 ~/.config/termite/config',         'Termite Appearance',       'theme']},
            {item => ["gksudo subl3 /etc/oblogout.conf",            'Exit Appearance',          'theme']},   
            {sep => undef},
            {item => ['exo-preferred-applications',             'Preferred Applications',   'preferred-applications']},
            {item => ['xfce4-power-manager-settings',           'Power Management',         'power']},
            {item => ['xfce4-settings-manager',                 'Xfce4 Settings Manager',   'preferences-desktop']},
            {item => ['arandr',                                 'Screen Layout Editor',     'display']},
            {item => ["$editor ~/.config/tint2/tint2rc", 'Tint2 Panel', 'text-x-generic']},
        {end => undef},

         # System Settings
        {beg => ['System Settings', 'settings']},
            {item => ['pamac-manager',  'Pamac Package Manager',    'pamac']},
            {item => ['pamac-updater',  'Pamac Package Updater',    'pamac']},
            {sep => undef},
            {item => ["gksudo thunar",  'File Manager As Root',     'thunar']},
            {item => ["gksudo subl3",   'Text Editor As Root',      'geany']},
            {sep => undef},
            {item => ["gksudo subl3 /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm.conf",  'Login Settings','login']},
            {item => ["gksudo gparted", 'GParted',                  'gparted']},
            {sep => undef},   
            {item => ["gnome-disks",      'Disks',                          'gnome-disks']},
            {item => ["hardinfo",         'System Profiler and Benchmark',        'hardinfo']},
            {item => ["gnome-system-monitor",    'Taskmanager',                      'gnome-system-monitor']},                            
        {end => undef},

      # obmenu-generator category
      {beg => ['Obmenu-Generator', 'accessories-text-editor']},
        {item => ["$editor ~/.config/obmenu-generator/schema.pl", 'Menu Schema', 'text-x-generic']},
        {item => ["$editor ~/.config/obmenu-generator/config.pl", 'Menu Config', 'text-x-generic']},

        {sep  => undef},
        {item => ['obmenu-generator -s -c',    'Generate a static menu',             'accessories-text-editor']},
        {item => ['obmenu-generator -s -i -c', 'Generate a static menu with icons',  'accessories-text-editor']},
        {sep  => undef},
        {item => ['obmenu-generator -p',       'Generate a dynamic menu',            'accessories-text-editor']},
        {item => ['obmenu-generator -p -i',    'Generate a dynamic menu with icons', 'accessories-text-editor']},
        {sep  => undef},

        {item => ['obmenu-generator -d', 'Refresh cache', 'view-refresh']},
      {end => undef},

      # Openbox category
      {beg => ['Openbox', 'openbox']},
        {item => ["$editor ~/.config/openbox/autostart", 'Openbox Autostart',   'text-x-generic']},
        {item => ["$editor ~/.config/openbox/rc.xml",    'Openbox RC',          'text-x-generic']},
        {item => ['obkey',  'Openbox Key Shortcut',        'text-x-generic']},
        {item => ["$editor ~/.config/openbox/menu.xml",  'Openbox Menu',        'text-x-generic']},
        {item => ['openbox --reconfigure',               'Reconfigure Openbox', 'openbox']},
      {end => undef},
    {end => undef},

    {sep => undef},

    {item => ['oblogout',                      'Exit Openbox',                      'exit']},
    ## This option uses the default Openbox's "Exit" action
    #{exit => ['Exit', 'application-exit']},

]
