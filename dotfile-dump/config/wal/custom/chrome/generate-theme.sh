#!/bin/bash

# Taken from https://github.com/metafates/ChromiumPywal
# commit 9d7c584

. ~/.cache/wal/colors.sh # import colors from pywal

THEME_NAME="Pywal"


DIR=$(dirname "${BASH_SOURCE[0]}")
THEME_DIR="$DIR/$THEME_NAME"

# Converts hex colors into rgb joined with comma
# #fff -> 255, 255, 255
hexToRgb() {
    # Remove '#' character from hex color #fff -> fff
    plain=${1#*#}
    printf "%d, %d, %d" 0x${plain:0:2} 0x${plain:2:2} 0x${plain:4:2}
}

prepare() {
    if [ -d $THEME_DIR ]; then
        rm -rf $THEME_DIR
    fi
    
    mkdir $THEME_DIR
    mkdir "$THEME_DIR/images"
    
    # Copy wallpaper so it can be used in theme  
    background_image="images/theme_ntp_background_norepeat.png"
    cp "$wallpaper" "$THEME_DIR/$background_image"

}


background=$(hexToRgb $background)
foreground=$(hexToRgb $foreground)

background_light=$(hexToRgb $color4)
background_extra=$(hexToRgb $color6)

accent=$(hexToRgb $color1)

incognito="255, 0, 255"

generate() {
    # Theme template
    cat > "$THEME_DIR/manifest.json" << EOF
    {
      "manifest_version": 3,
      "version": "1.0",
      "name": "$THEME_NAME Theme",
      "theme": {
        "colors": {
          "frame": [$background],
          "frame_inactive": [$background],
	  "frame_incognito": [$incognito],
	  "frame_incognito_inactive": [$incognito],
          "background_tab": [$background],
	  "background_tab_inactive": [$background],
	  "background_tab_incognito": [$background],
	  "background_tab_incognito_inactive": [$background],
	  "bookmark_text": [$foreground],
          "tab_background_text": [$foreground],
	  "tab_background_text_inactive": [$foreground],
	  "tab_background_text_incognito": [$foreground],
	  "tab_background_text_incognito_inactive": [$foreground],
	  "tab_text": [$foreground],
	  "toolbar": [$background_light],
	  "toolbar_button_icon": [$accent],
	  "omnibox_text": [$foreground],
	  "omnibox_background": [$background_extra]
        }
      }
    }
EOF
}

#prepare
generate
echo "Pywal Chrome theme generated at $THEME_DIR"
