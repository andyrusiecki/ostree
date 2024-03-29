#!/bin/sh

#google_fonts=()
nerd_fonts=(
  FireCode
  FireMono
  JetBrainsMono
  Meslo
  Noto
  RobotoMono
  SourceCodePro
  Ubuntu
  UbuntuMono
)

# google_tmp=$(mktemp -d)
# for font in ${google_fonts[@]}
# do
#   curl -L https://fonts.google.com/download?family=${font// /%20}.zip --output $google_tmp/$font.zip
#   unzip $google_tmp/$font.zip -d /usr/share/fonts/google/$font/
# done

# rm -rf $google_tmp

nerd_tmp=$(mktemp -d)
for font in ${nerd_fonts[@]}
do
  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip --output $nerd_tmp/$font.zip
  font_dir=$(echo $font | sed 's/\([A-Z]\)/-\L\1/g;s/^-//')
  unzip $nerd_tmp/$font.zip -d /usr/share/fonts/nerd-$font/
done

rm -rf $nerd_tmp

fc-cache -f /usr/share/fonts
