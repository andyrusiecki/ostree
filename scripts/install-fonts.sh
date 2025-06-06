#!/bin/sh

fonts=(
  AdwaitaMono
  BitstreamVeraSansMono
  CascadiaCode
  CascadiaMono
  DejaVuSansMono
  FiraCode
  FiraMono
  Hack
  Iosevka
  IosevkaTerm
  JetBrainsMono
  Meslo
  Noto
  RobotoMono
  SourceCodePro
  Ubuntu
  UbuntuMono
)

tmp_dir=$(mktemp -d)
base_dir="/usr/share/fonts"

mkdir -p $base_dir

for font in ${fonts[@]}
do
  fontname="nerd-$(echo "$font" | sed 's/[A-Z]/-\l&/g' | sed 's/^-//')"
  fontdir="$base_dir/$fontname"

  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip --output $tmp_dir/$font.zip &> /dev/null

  if [ -d "$fontdir" ]; then
    rm -r $fontdir
  fi

  mkdir -p $fontdir
  unzip $tmp_dir/$font.zip -d $fontdir/
done

rm -rf $tmp_dir

fc-cache -r
