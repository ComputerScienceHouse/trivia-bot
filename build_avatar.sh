#!/bin/sh
gcc -o avatar `sdl-config --cflags --libs` -lGL -lGLU -lglut -lm -I/usr/include/SDL -I/usr/local/include/SDL avatar.c
