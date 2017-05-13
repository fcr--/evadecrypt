#!/usr/bin/awk -f
{
  gsub(/k/, ";16")
  gsub(/m/, ";13")
  gsub(/y/, ";11")
  gsub(/g/, ";34")
  gsub(/c/, ";33")
  gsub(/n/, ";52")
  gsub(/o/, ";166")
  gsub(/r/, ";196")
  gsub(/;[0-9]*/, "[48;5&m  ")
  gsub(/$|_/, "[0m&&")
  print
}
