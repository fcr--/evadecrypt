#!/usr/bin/awk -f
BEGIN {
  fill = " "
  maxwidth = 0
}
{
  line[NR] = $0
  if (length > maxwidth) maxwidth = length
}
END {
  for (y = 1; y <= maxwidth; y++) {
    lastx = 0
    for (x = 1; x <= NR; x++) if (length(line[x]) >= y) {
      while (lastx < x - 1) {
	printf(" ")
	lastx++
      }
      printf("%s", substr(line[x], y, 1))
      lastx = x
    }
    print ""
  }
}
