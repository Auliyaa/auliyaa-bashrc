# https://wiki.multimedia.cx/index.php/YCbCr_4:2:2
# https://samples.mplayerhq.hu/V-codecs/R210/bmd_pixel_formats.pdf

# align <x> <a>
# align x over a
function align()
{
  local x=${1}
  local a=${2}

  local r=$((x%a))
  if [[ "${r}" == "0" ]]; then
	echo ${x}
  else
    echo $((x + a - r))
  fi
}

# same as align but faster
function fast_align()
{
  local x=${1}
  local a=${2}
  echo $(( ((x+a-1)/a)*a )) # this is an integer division
}

# v210_stride <width>
# prints the size (in bytes) of 1 stride for the given image width (in px)
function v210_stride()
{
  local width=${1}

  # V210 is packed UYVY with 4 components for 2 pixels
  local component_cnt=$((width * 4 / 2))

  # each v210 line is made of 32-bits words containing 3 components (with 2 bits unused)
  local word_cnt=$((component_cnt / 3))
  local stride_sz_bits=$((word_cnt * 32))

  # each line is then aligned on 128 bytes (1024 bits)
  local stride_sz_aligned_bits=$(align "${stride_sz_bits}" "1024")

  # print out the size in bytes
  echo $((stride_sz_aligned_bits / 8))
}

# v210_size <width> <height>
# prints the size (in bytes) for a v210 frame at the given resolution
function v210_size()
{
  local width=${1}
  local height=${2}
  local stride_sz=$(v210_stride ${width})
  echo $((stride_sz * height))
}

# vooya helper for v210 streams
function vooya_v210()
{
  local _w=${1}
  shift
  local _h=${1}
  shift

  if [[ "${_w}" == "" || "${_h}" == "" ]]; then
    echo 'usage: vooya_v210 <width> <height> <file>'
  fi

  vooya --width ${_w} --height ${_h} --color yuv --packing v210 --bits 10 "${@}"
}
