# 一、记录一些备忘tips
### 不用执行hexo命令,提交md文件到source目录下会自动部署的
### 测试命令
- hexo clean: 清除缓存
- hexo g:　生成文件
- hexo s:　测试
### 目前采用next主题
### gitment注册app
https://github.com/settings/applications/779445
Client ID
18c91685c1c2a411e85b
Client Secret
c8acedee8fb831839c324954f60072588cfb593d

# 二、博文title样例
---
layout: layout
title: 标签1
date: 2017-08-18 15:41:18
tags: 标签1 #此文章在`标签1 `标签下
#tags: [标签1,标签2] #此文章在`标签1,标签2`下
---
# 三、hexo命令
- 生成博文: hexo new post '{post_name}'