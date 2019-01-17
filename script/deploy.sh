#!/usr/bin/env bash
cd ..
hexo clean
hexo g
rsync -avz ./public/ k71yygchvb8o@166.62.10.141:/home/k71yygchvb8o/www
