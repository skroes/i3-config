#
# https://faq.i3wm.org/question/478/how-do-i-simulate-keypresses/index.html
#
#Xmodmap is very readable:
#
#$ cat ~/.Xmodmap
#remove Lock = Caps_Lock
#keysym Caps_Lock = Escape
#
#And it is activated like this in ~/.xinitrc:
#
#xmodmap ~/.Xmodmap
