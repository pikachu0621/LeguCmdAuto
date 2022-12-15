使用腾讯乐固，自动加固apk
===



用法
---
---

### 1. 把打好的apk包放入  `put` 文件夹里
```
支持多个多级apk
```
### 2. 在 `info.ini` 配置你的信息
```
需要你去申请的腾讯API的
sid
skey
```

### 3. 把签名文件放到 `jks` 文件夹里
```
可以放多个不同的签名文件，会根据待加固apk文件名自动选择签名文件
ps: xxx_huawei_1.0.0.apk 对应 xxx.jks
```

### 4. 点击 `同时加固.bat` 或 `逐个加固.bat` 开始加固
```
加固完的apk在out里
```


文件目录
---
---

- LeguCmdAuto/
  - jks/ (签名文件存放目录)
  - lib/ (工具)
    - temp/ (同时加固产生的临时脚本)
    - apksigner.jar  (签名工具)
    - ms-shield.jar  (加固工具)
    - zipalign.exe   (zip对齐工具)
  - info.ini (配置文件)
  - out/ (输出路径)
  - put/ (输入路径)
  - 同时加固.bat (开始加固)
  - 逐个加固.bat (开始加固)