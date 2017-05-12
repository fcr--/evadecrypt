#!/bin/sh
#\
exec tclsh "$0" "$@"

set colors {}
set forced_colors {}
set color_strings {}

set fd [open [lindex $argv 0] r]
foreach line [split [read $fd] "\n"] {
  if {[regexp -- {^ *(#.*)?$} $line]} continue
  set words [split $line]
  if {[lindex $words 0] eq "image"} {
    set image_file [lindex $words 1]
  } elseif {[lindex $words 0] eq "p00"} {
    set p00 [lrange $words 1 2]
  } elseif {[lindex $words 0] eq "pw0"} {
    set pw0 [lrange $words 1 2]
  } elseif {[lindex $words 0] eq "p0h"} {
    set p0h [lrange $words 1 2]
  } elseif {[lindex $words 0] eq "pwh"} {
    set pwh [lrange $words 1 2]
  } elseif {[lindex $words 0] eq "output"} {
    set output_file [lindex $words 1]
  } elseif {[lindex $words 0] eq "width"} {
    set width [lindex $words 1]
  } elseif {[lindex $words 0] eq "height"} {
    set height [lindex $words 1]
  } elseif {[lindex $words 0] eq "color"} {
    foreach {r g b} [lrange $words 1 3] {}
    dict append color_strings [lindex $words 4] "\033\[38;2;$r;$g;${b}m██"
    dict set colors [lrange $words 1 3] [lindex $words 4]
  } elseif {[lindex $words 0] eq "force"} {
    dict set forced_colors [lrange $words 1 2] [lindex $words 3]
  } else {
    error "unknown command [lindex $words 0]"
  }
}
close $fd
puts "Colors:"
foreach {name color_string} $color_strings {
  puts "  $name: \[$color_string\033\[0m\]"
}

package require Tk
ttk::style theme use clam
wm minsize . 600 400

set img [image create photo -file $image_file]
canvas .c -width [$img cget -width] -height [$img cget -height] \
    -xscrollcommand {.sbx set} -yscrollcommand {.sby set} \
    -scrollregion [list 0 0 [$img cget -width] [$img cget -height]]
.c create image 0 0 -anchor nw -image $img
ttk::scrollbar .sby -orient vertical -command {.c yview}
ttk::scrollbar .sbx -orient horizontal -command {.c xview}
label .status
grid configure .c -column 0 -row 0 -sticky nsew
grid configure .sby -column 1 -row 0 -sticky nsew
grid configure .sbx -column 0 -row 1 -sticky nsew
grid configure .status -column 0 -row 2 -columnspan 2 -sticky nsew
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

proc coords {x y} {
  set xleft [expr {[lindex $::p00 0] + ([lindex $::p0h 0]-[lindex $::p00 0])*$y/$::height}]
  set yleft [expr {[lindex $::p00 1] + ([lindex $::p0h 1]-[lindex $::p00 1])*$y/$::height}]
  set xright [expr {[lindex $::pw0 0] + ([lindex $::pwh 0]-[lindex $::pw0 0])*$y/$::height}]
  set yright [expr {[lindex $::pw0 1] + ([lindex $::pwh 1]-[lindex $::pw0 1])*$y/$::height}]
  return [list \
      [expr {$xleft + ($xright-$xleft)*$x/$::width}] \
      [expr {$yleft + ($yright-$yleft)*$x/$::width}]]
}

for {set y 0} {$y <= $height} {incr y} {
  .c create line {*}[coords 0 $y] {*}[coords $width $y] -fill white
  .c create text {*}[coords 0 $y] -text "$y  " -fill white -anchor e
}
for {set x 0} {$x <= $width} {incr x} {
  .c create line {*}[coords $x 0] {*}[coords $x $height] -fill white
}

bind .c <ButtonPress-1> {
  puts "clicked on [.c canvasx %x] [.c canvasy %y]"
  .status configure -text "clicked on [.c canvasx %x] [.c canvasy %y]"
}

.c configure -scrollregion [.c bbox all]

proc find_nearest_color {r g b} {
  set colordistmin 1000000000
  set colormin "unknown"
  foreach {color name} $::colors {
    foreach {r2 g2 b2} $color {}
    set dist [expr {($r2-$r)**2+($g2-$g)**2+($b2-$b)**2}]
    if {$dist < $colordistmin} {
      set colormin $name
      set colordistmin $dist
    }
  }
  list $colormin $colordistmin
}

set fd [open $output_file w]
set unknown_count 0
for {set y 0} {$y <= $height} {incr y} {
  for {set x 0} {$x <= $width} {incr x} {
    if {[dict exists $forced_colors [list $x $y]]} {
      puts -nonewline $fd [dict get $forced_colors [list $x $y]]
      continue
    }
    foreach {px py} [coords $x $y] {}
    foreach {r g b} [$img get [expr {int($px)}] [expr {int($py)}]] {}
    foreach {colormin colordistmin} [find_nearest_color $r $g $b] {}
    if {$colordistmin > 100 || $colormin eq "error"} {
      set mindist 1000
      for {set dy -5} {$dy <= 5} {incr dy} {
	for {set dx -5} {$dx <= 5} {incr dx} {
	  foreach {r2 g2 b2} [$img get [expr {int($px+$dx)}] [expr {int($py+$dy)}]] {}
	  foreach {colormin2 colordistmin2} [find_nearest_color $r2 $g2 $b2] {}
	  if {$colordistmin2 <= 100 && $colormin2 ne "error" && $dx*$dx+$dy*$dy<$mindist} {
	    set colormin $colormin2
	    set colordistmin $colordistmin2
	    set mindist [expr {$dx*$dx+$dy*$dy}]
	    set mindx $dx
	    set mindy $dy
	    foreach {minr ming minb} [list $r2 $g2 $b2] {}
	  }
	}
      }
      if {$mindist < 1000} {
	puts "correction $x $y $mindx $mindy -> \[\033\[38;2;$r;$g;${b}m██\033\[0m->\033\[38;2;$minr;$ming;${minb}m██\033\[0m\] $colormin"
	.c create oval [expr {$px+$mindx-3}] [expr {$py+$mindy-3}] [expr {$px+$mindx+3}] [expr {$py+$mindy+3}] -outline white
      }
    }
    if {$colordistmin <= 100} {
      if {$colormin eq "error"} {
	.c create oval [expr {$px-10}] [expr {$py-10}] [expr {$px+10}] [expr {$py+10}] -outline white
	puts "color not detected, use force command: $x $y (at ${px}x$py) -> $r $g $b \[\033\[38;2;$r;$g;${b}m██\033\[0m\] ($colormin, sqdist $colordistmin)"
	puts -nonewline $fd "#"
      } else {
	puts -nonewline $fd $colormin
      }
    } else {
      .c create oval [expr {$px-10}] [expr {$py-10}] [expr {$px+10}] [expr {$py+10}] -outline white
      puts "unknown color: $x $y (at ${px}x$py) -> $r $g $b \[\033\[38;2;$r;$g;${b}m██\033\[0m\] ($colormin, sqdist $colordistmin)"
      incr unknown_count
    }
  }
  puts $fd ""
}
close $fd
puts "$unknown_count out of [expr {($width+1)*($height+1)}] colors unknown ([format "%.4g" [expr {$unknown_count*100.0/($width+1)/($height+1)}]]%)"
