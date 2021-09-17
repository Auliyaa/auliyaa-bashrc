#!/bin/sh

## =======================================
## 2160p.raw
## =======================================
function _v210_gen_2160p()
{
  echo "-- Generating 2160p buffer..."
  ffmpeg -y -i "${src}" -an\
  -vf "scale=3840x2160:flags=lanczos:in_range=full:out_range=tv,drawtext=fontfile=${font}: text='%{frame_num}': start_number=0: x=${box_x}: y=${box_x}: fontcolor=${font_color}: fontsize=$((font_sz*4)): box=1: boxcolor=${box_color}: boxborderw=${box_w}"\
  -c:v v210 -pix_fmt yuv422p10le "2160p.yuv" >> ffmpeg.log 2>> ffmpeg.log

  mv "2160p.yuv" "2160p.raw"

  echo "$ vooya --width 3840 --height 2160 --color yuv --packing v210 --bits 10 \"2160p.raw\"";
}

## =======================================
## 1080p.raw
## =======================================
function _v210_gen_1080p()
{
  echo "-- Generating 1080p buffer..."
  ffmpeg -y -i "${src}" -an\
  -vf "scale=1920x1080:flags=lanczos:in_range=full:out_range=tv,drawtext=fontfile=${font}: text='%{frame_num}': start_number=0: x=${box_x}: y=${box_x}: fontcolor=${font_color}: fontsize=$((font_sz)): box=1: boxcolor=${box_color}: boxborderw=${box_w}"\
  -c:v v210 -pix_fmt yuv422p10le "1080p.yuv" >> ffmpeg.log 2>> ffmpeg.log

  mv "1080p.yuv" "1080p.raw"

  echo "$ vooya --width 1920 --height 1080 --color yuv --packing v210 --bits 10 \"1080p.raw\"";
}

## =======================================
## 720p.raw
## =======================================
function _v210_gen_720p()
{
  echo "-- Generating 720p buffer..."
  ffmpeg -y -i "${src}" -an\
  -vf "scale=1280x720:flags=lanczos:in_range=full:out_range=tv,drawtext=fontfile=${font}: text='%{frame_num}': start_number=0: x=${box_x}: y=${box_x}: fontcolor=${font_color}: fontsize=$((font_sz)): box=1: boxcolor=${box_color}: boxborderw=${box_w}"\
  -c:v v210 -pix_fmt yuv422p10le "720p.yuv" >> ffmpeg.log 2>> ffmpeg.log

  mv "720p.yuv" "720p.raw"

  echo "$ vooya --width 1280 --height 720 --color yuv --packing v210 --bits 10 \"720p.raw\"";
}

## =======================================
## 1080i.raw
## =======================================
function _v210_gen_1080i()
{
  echo "-- Generating 1080p clean buffer..."
  # create a clean 1080p source with no burn-in text
  ffmpeg -y -i "${src}" -an -vf "scale=1920x1080:flags=lanczos" -c:v v210 -pix_fmt yuv422p10le 1080p.yuv >> ffmpeg.log 2>> ffmpeg.log
  # split odd & even fields
  echo "-- Generating 1080i odd & even buffers..."
  ffmpeg -y -f image2pipe -vcodec v210 -s 1920x1080 -frame_size 5529600 -pix_fmt yuv422p10le -i "1080p.yuv" -an\
  -filter_complex "[0]il=l=d:c=d,split[o][e];[o]crop=iw:ih/2:0:0[odd];[e]crop=iw:ih/2:0:ih/2[even]"\
  -map "[odd]" -c:v v210 -pix_fmt yuv422p10le "1080i-odd.yuv"\
  -map "[even]" -c:v v210 -pix_fmt yuv422p10le "1080i-even.yuv" >> ffmpeg.log 2>> ffmpeg.log
  # insert field number texts inside odd buffer
  echo "-- inserting text (odd buffer)..."
  ffmpeg -y -f image2pipe -vcodec v210 -s 1920x540 -frame_size 2764800 -pix_fmt yuv422p10le -i "1080i-odd.yuv" -an\
  -vf "scale=in_range=full:out_range=tv,drawtext=fontfile=${font}: text='1.%{frame_num}': start_number=0: x=${box_x}: y=$((box_x/2)): fontcolor=${font_color}: fontsize=${font_sz}: box=1: boxcolor=${box_color}: boxborderw=$((box_w/2))"\
  -c:v v210 -pix_fmt yuv422p10le "1080i-odd-fn.yuv" >> ffmpeg.log 2>> ffmpeg.log
  # insert field number texts inside even buffer
  echo "-- inserting text (even buffer)..."
  ffmpeg -y -f image2pipe -vcodec v210 -s 1920x540 -frame_size 2764800 -pix_fmt yuv422p10le -i "1080i-even.yuv" -an\
  -vf "scale=in_range=full:out_range=tv,drawtext=fontfile=${font}: text='0.%{frame_num}': start_number=0: x=${box_x}: y=$((box_x/2)): fontcolor=${font_color}: fontsize=${font_sz}: box=1: boxcolor=${box_color}: boxborderw=$((box_w/2))"\
  -c:v v210 -pix_fmt yuv422p10le "1080i-even-fn.yuv" >> ffmpeg.log 2>> ffmpeg.log

  echo "-- Merging 1080i field buffers..."
  # merge both buffers in a single 1080i buffer
  field_size=2764800
  buf_size=$(stat -c%s 1080i-odd-fn.yuv)
  rm -f "1080i.yuv"
  for ((ii=0; ii < buf_size; ii+=field_size)); do
    echo ".. merging fields at offset ${ii} / ${buf_size}"
    dd if=1080i-even-fn.yuv of=1080i.yuv bs=${field_size} count=1 skip=$((ii / field_size)) oflag=append conv=notrunc >/dev/null 2>&1
    dd if=1080i-odd-fn.yuv of=1080i.yuv bs=${field_size} count=1 skip=$((ii / field_size)) oflag=append conv=notrunc >/dev/null 2>&1
  done

  rm -f "1080p.yuv"
  rm -f "1080i-odd.yuv"
  rm -f "1080i-even.yuv"
  rm -f "1080i-odd-fn.yuv"
  rm -f "1080i-even-fn.yuv"

  mv "1080i.yuv" "1080i.raw"

  echo "$ vooya --width 1920 --height 540 --color yuv --packing v210 --bits 10 \"1080i.raw\"";
}

## =======================================
## ch-XX.pcm
## =======================================
function _v210_gen_audio()
{
  local ccnt=$(ffprobe -i "${src}" -show_streams -select_streams a:0 2>&1 | grep '^channels=' | cut -f 2 -d '=');
  for ((ii=0; ii<ccnt; ++ii)); do
    echo "extracting audio ${ii}/$((ccnt-1))..";
    ffmpeg -y -i "${f}" -f s24le -vn -map_channel 0.1.0 -c:a pcm_s24le -ar 48000 "${f}-ch${ii}.pcm" >> ffmpeg.log 2>> ffmpeg.log
  done;

  echo "$ audacity \"${f}-ch*.pcm\""
}

## =======================================
## v210_gen
## =======================================

function v210_gen()
{
  # default values
  src=""

  font="/usr/share/fonts/dejavu/DejaVuSansMono.ttf"
  font_sz=40
  font_color="black"
  box_color="white"
  box_x=10
  box_w=338

  with_text=1
  positional=()

  # CLI arguments
  while [[ $# -gt 0 ]]; do
    key=${1}
    case $key in
    -i|--input)
      shift # past argument
      src="${1}"
      shift
      ;;
    -n|--no-text)
      with_text=0
      shift # past argument
      ;;
    *)    # positional arguments
    positional+=("$1") # save it in an array for later
    shift # past argument
    ;;
    esac
  done

  if [[ "${src}" == "" || "${#positional[@]}" == "0" ]]; then
    echo 'usage: v210_gen --input <input-file> [--no-text] [--checks] <raster-1> [raster-2 [raster-3 ...]]'
    echo 'generates v210 buffers from a given input file'
    echo ' -i|--input: input file path'
    echo ' -n|--no-text: disable text box overlay'
    echo ' raster1, raster2, ...: each positional argument indicates a target raster to render. supported values are 720p, 1080p, 2160p, 1080i and audio'
    return 1
  fi

  # set text to fully transparent when disabled
  if [[ "${with_text}" == "0" ]]; then
    box_color="#00000000"
    font_color="#00000000"
  fi

  for gen in ${positional[@]}; do
    _v210_gen_${gen}
  done
}
