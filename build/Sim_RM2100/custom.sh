
#!/bin/bash

# 安装额外依赖软件包
# sudo -E apt-get -y install rename

# 更新feeds文件
# sed -i 's@#src-git helloworld@src-git helloworld@g' feeds.conf.default #启用helloworld
cat feeds.conf.default

# 添加第三方软件包
git clone https://github.com/gogogojason/OpenWrt-Packages.git package/jason

# 更新并安装源
./scripts/feeds clean
./scripts/feeds update -a && ./scripts/feeds install -a

# 删除部分默认包
#rm -rf package/lean/luci-theme-argon
#rm -rf feeds/packages/net/haproxy

# 自定义定制选项
utc_name='Asia\/Shanghai'                                               
date=`date +%m.%d.%Y`

echo "修改版本信息"
sed -i "s/OpenWrt /hfy166 Ver.D$(TZ=UTC-8 date "+%Y.%m.%d") \/ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

echo "修改wifi名称"
sed -i "s/OpenWrt_2G/RMWiFi/g" package/lean/mt/drivers/mt_wifi/files/mt7603.dat
sed -i "s/OpenWrt_5G/RMWiFi_5G/g" package/lean/mt/drivers/mt_wifi/files/mt7615.dat

echo "默认IP设置"
sed -i "s/192.168.1.1/192.168.2.1/g" package/base-files/files/bin/config_generate

echo "修改机器名称"
sed -i "s/OpenWrt/MiRouter/g" package/base-files/files/bin/config_generate

echo "时区设置"
sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='$utc_name'/g" package/base-files/files/bin/config_generate

echo "修改默认主题"
sed -i 's/+luci-theme-bootstrap/+luci-theme-edge/g' feeds/luci/collections/luci/Makefile
sed -i "s/bootstrap/argon/g" feeds/luci/modules/luci-base/root/etc/config/luci
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

#echo "添加软件包"
#sed -i 's/exit 0//g' package/lean/default-settings/files/zzz-default-settings
#a='$a' 
#echo "sed -i '$a src/gz jason_packages http://openwrt.ink:8666/RedMi2100/Packages' /etc/opkg/distfeeds.conf" >>package/lean/default-settings/files/zzz-default-settings
#echo 'exit 0' >>package/lean/default-settings/files/zzz-default-settings

echo "设置版本号"
sed -i "s/# REVISION:=x/REVISION:= $date/g" include/version.mk

#创建自定义配置文件 - Sim_RM2100

cd build/Sim_RM2100
touch ./.config

#
# ========================固件定制部分========================
# 

# 
# 如果不对本区块做出任何编辑, 则生成默认配置固件. 
# 

# 以下为定制化固件选项和说明:
#

#
# 有些插件/选项是默认开启的, 如果想要关闭, 请参照以下示例进行编写:
# 
#          =========================================
#         |  # 取消编译VMware镜像:                    |
#         |  cat >> .config <<EOF                   |
#         |  # CONFIG_VMDK_IMAGES is not set        |
#         |  EOF                                    |
#          =========================================
#

# 
# 以下是一些提前准备好的一些插件选项.
# 直接取消注释相应代码块即可应用. 不要取消注释代码块上的汉字说明.
# 如果不需要代码块里的某一项配置, 只需要删除相应行.
#
# 如果需要其他插件, 请按照示例自行添加.
# 注意, 只需添加依赖链顶端的包. 如果你需要插件 A, 同时 A 依赖 B, 即只需要添加 A.
# 
# 无论你想要对固件进行怎样的定制, 都需要且只需要修改 EOF 回环内的内容.
# 

# 编译Sim_RM2100固件:
cat >> .config <<EOF
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_xiaomi_redmi-router-ac2100=y
EOF

# 开启FPU支持
cat >> .config <<EOF
CONFIG_KERNEL_MIPS_FPU_EMULATOR=y
EOF

# IPv6支持:
cat >> .config <<EOF
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_ipv6helper=y
EOF

# 第三方插件选择:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_PACKAGE_luci-app-gpsysupgrade=y
CONFIG_DEFAULT_luci-app-vlmcsd=y
CONFIG_PACKAGE_luci-app-eqos=y 
CONFIG_PACKAGE_luci-app-poweroff=y 
# CONFIG_PACKAGE_luci-app-argon-config=y #argon主题设置
# CONFIG_PACKAGE_luci-theme-atmaterial=y #atmaterial 三合一主题
CONFIG_PACKAGE_luci-app-filetransfer=y #系统-文件传输
CONFIG_PACKAGE_luci-app-autoreboot=y #定时重启
CONFIG_PACKAGE_luci-app-upnp=y #通用即插即用UPnP(端口自动转发)
CONFIG_PACKAGE_luci-app-accesscontrol=y #上网时间控制
CONFIG_PACKAGE_luci-app-wol=y #网络唤醒
CONFIG_PACKAGE_luci-app-webadmin=y #Web管理页面设置
CONFIG_PACKAGE_luci-theme-edge=y #edge主题
CONFIG_PACKAGE_luci-app-socat=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-mwan3helper=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-webadmin=y
CONFIG_PACKAGE_luci-app-zerotier=y
CONFIG_PACKAGE_luci-app-sfe=y 
EOF

# 添加Passwall+:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-bypass=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Shadowsocks_Server=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_ShadowsocksR_Server=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Simple_obfs=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Simple_obfs_server=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_V2ray_plugin=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_V2ray=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Xray=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Trojan=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Trojan-Go=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_NaiveProxy=y
# CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Kcptun is not set
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Socks5_Proxy=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Socks_Server=y
EOF

# 去掉默认设置:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-flowoffload is not set 
# CONFIG_PACKAGE_adbyby is not set
# CONFIG_PACKAGE_luci-app-adbyby-plus is not set
# CONFIG_PACKAGE_luci-app-xlnetacc is not set
# CONFIG_PACKAGE_luci-app-ssr-plus is not set
# CONFIG_PACKAGE_luci-app-unblockmusic is not set
# CONFIG_PACKAGE_luci-app-vsftpd is not set
# CONFIG_PACKAGE_vsftpd-alt is not set
EOF


# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 返回工作目录
cd ../..

# 配置文件创建完成
