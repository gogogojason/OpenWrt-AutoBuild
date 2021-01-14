#!/bin/bash

# 添加第三方软件包
git clone https://github.com/gogogojason/OpenWrt-Packages.git package/jason
git clone https://github.com/gogogojason/logos.git package/logos


# 更新并安装源
#./scripts/feeds clean
./scripts/feeds update -a && ./scripts/feeds install -a

# 删除部分默认包
#rm -rf package/lean/luci-theme-argon
#rm -rf feeds/packages/net/haproxy

echo "修改版本信息"
date=`date +%m.%d.%Y`
sed -i "s/OpenWrt /hfy166 Ver.D$(TZ=UTC-8 date "+%Y.%m.%d") \/ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

echo "默认IP设置"
sed -i "s/192.168.1.1/192.168.2.1/g" package/base-files/files/bin/config_generate

echo "修改机器名称"
sed -i "s/OpenWrt/$MyRouter/g" package/base-files/files/bin/config_generate

echo "修改ADG默认更新地址"
sed -i 's/${Arch}_softfloat/${Arch}/g' package/jason/luci-app-adguardhome/root/usr/share/AdGuardHome/links.txt

echo "更换主题LOGO"
rm -f package/jason/luci-theme-edge/htdocs/luci-static/edge/logo.png
cp package/logos/oplogo.png package/jason/luci-theme-edge/htdocs/luci-static/edge/logo.png
rm package/logos -r

echo "防掉线"
INTERFACE='$INTERFACE'
INTERFACE...='$INTERFACE...'
LOG='$LOG'
sed -i "88a\		ifdown $INTERFACE" feeds/packages/net/mwan3/files/etc/hotplug.d/iface/15-mwan3
sed -i "89a\		sleep 3" feeds/packages/net/mwan3/files/etc/hotplug.d/iface/15-mwan3
sed -i "90a\		ifup $INTERFACE" feeds/packages/net/mwan3/files/etc/hotplug.d/iface/15-mwan3
sed -i "91a\		$LOG notice \"Recycled $INTERFACE...\"" feeds/packages/net/mwan3/files/etc/hotplug.d/iface/15-mwan3

echo "设置版本号"
sed -i "s/# REVISION:=x/REVISION:= $date/g" include/version.mk

echo "修改默认主题"
sed -i 's/+luci-theme-bootstrap/+luci-theme-edge/g' feeds/luci/collections/luci/Makefile
sed -i "s/bootstrap/argon/g" feeds/luci/modules/luci-base/root/etc/config/luci
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

#echo "取消默认密码"
#sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings #取消系统默认密码

#创建自定义配置文件 - Lean_x86_64

cd build/Lean_x86_64
touch ./.config

# 编译Lean_x86_64固件:
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_DEVICE_generic=y
CONFIG_TARGET_KERNEL_PARTSIZE=64
CONFIG_TARGET_ROOTFS_PARTSIZE=1000
EOF

# 压缩固件:
cat >> .config <<EOF
CONFIG_TARGET_IMAGES_GZIP=y
EOF

# IPv6支持:
cat >> .config <<EOF
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_ipv6helper=y
EOF

# Passwall插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-passwall=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd=y
CONFIG_PACKAGE_https-dns-proxy=y
CONFIG_PACKAGE_kcptun-client=y
CONFIG_PACKAGE_chinadns-ng=y
CONFIG_PACKAGE_haproxy=y
CONFIG_PACKAGE_xray=y
CONFIG_PACKAGE_v2ray=y
CONFIG_PACKAGE_v2ray-plugin=y
CONFIG_PACKAGE_simple-obfs=y
CONFIG_PACKAGE_trojan-plus=y
CONFIG_PACKAGE_trojan-go=y
CONFIG_PACKAGE_brook=y
CONFIG_PACKAGE_ssocks=y
CONFIG_PACKAGE_naiveproxy=y
CONFIG_PACKAGE_ipt2socks=y
CONFIG_PACKAGE_shadowsocks-libev-config=y
CONFIG_PACKAGE_shadowsocks-libev-ss-local=y
CONFIG_PACKAGE_shadowsocks-libev-ss-redir=y
CONFIG_PACKAGE_shadowsocksr-libev-alt=y
CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=y
CONFIG_PACKAGE_pdnsd-alt=y
CONFIG_PACKAGE_dns2socks=y
EOF

# 磁盘管理插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_kmod_md_linear=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_kmod_md_raid456=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_mdadm=y
EOF

# 其他插件设置选择:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-adguardhome=y
CONFIG_PACKAGE_luci-app-gpsysupgrade=y
CONFIG_PACKAGE_luci-app-frpc=y
CONFIG_PACKAGE_luci-app-jd-dailybonus=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-mwan3helper=y
CONFIG_PACKAGE_luci-app-nps=y
CONFIG_PACKAGE_luci-app-poweroff=y
CONFIG_PACKAGE_luci-app-serverchan=y
CONFIG_PACKAGE_luci-app-smartdns=y
CONFIG_PACKAGE_luci-app-socat=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-eqos=y
#CONFIG_PACKAGE_luci-app-wrtbwmon-zh=y
CONFIG_PACKAGE_smartdns=y
EOF

# 添加Hello World+:
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
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Kcptun=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Socks5_Proxy=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Socks_Server=y
EOF

# 不安装插件:
cat >> .config <<EOF
# CONFIG_PACKAGE_dns2socks is not set
# CONFIG_PACKAGE_luci-app-ipsec-server is not set
# CONFIG_PACKAGE_luci-app-ipsec is not set
# CONFIG_PACKAGE_adbyby is not set
# CONFIG_PACKAGE_libevent2 is not set
# CONFIG_PACKAGE_vsftpd-alt is not set
# CONFIG_PACKAGE_redsocks2 is not set
# CONFIG_PACKAGE_luci-app-xlnetacc is not set
# CONFIG_PACKAGE_luci-app-vsftpd is not set
# CONFIG_PACKAGE_luci-app-ssr-plus is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Redsocks2 is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_plugin is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Xray is not set
# CONFIG_PACKAGE_luci-app-rclone_INCLUDE_fuse-utils is not set
# CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-ng is not set
# CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-webui is not set
# CONFIG_PACKAGE_luci-app-dockerman_INCLUDE_ttyd is not set
# CONFIG_PACKAGE_luci-app-adbyby-plus is not set
# CONFIG_PACKAGE_luci-app-dockerman_INCLUDE_ttyd is not set
# CONFIG_PACKAGE_luci-app-ipsec-vpnd is not set
# CONFIG_PACKAGE_luci-app-unblockmusic is not set
# CONFIG_PACKAGE_luci-app-vsftpd is not set
# CONFIG_UnblockNeteaseMusic_Go is not set
# CONFIG_UnblockNeteaseMusic_NodeJS is not set
EOF


# VSSR专用插件:
#cat >> .config <<EOF
#CONFIG_PACKAGE_luci-app-vssr=y
#CONFIG_PACKAGE_luci-app-vssr_INCLUDE_V2ray_plugin=y
#CONFIG_PACKAGE_luci-app-vssr_INCLUDE_V2ray=y
#CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray=y
#CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Trojan=y
#CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Kcptun=y
#CONFIG_PACKAGE_luci-app-vssr_INCLUDE_ShadowsocksR_Server=y
#CONFIG_PACKAGE_lua-maxminddb=y
#EOF

# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 返回工作目录
cd ../..

# 配置文件创建完成
