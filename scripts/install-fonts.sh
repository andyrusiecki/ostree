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

  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.tar.xz --output $tmp_dir/$font.tar.xz &> /dev/null

  if [ -d "$fontdir" ]; then
    rm -r $fontdir
  fi

  mkdir -p $fontdir
  tar -xf $tmp_dir/$font.tar.xz  -C $fontdir/

  echo "Added Font: $font"
done

rm -rf $tmp_dir

fc-cache -r
