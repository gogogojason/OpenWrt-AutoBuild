
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

#echo "取消默认密码"
#sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings #取消系统默认密码


#创建自定义配置文件 - Ap_RM2100

cd build/Ap_RM2100
touch ./.config

# ========================固件定制部分========================


# 编译Ap_RM2100固件:
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
CONFIG_PACKAGE_luci-app-poweroff=y
CONFIG_PACKAGE_luci-app-gpsysupgrade=y
CONFIG_PACKAGE_luci-theme-edge=y 
CONFIG_PACKAGE_luci-theme-bootstrap=y
EOF


# 去除默认添加软件包:
cat >> .config <<EOF
# CONFIG_PACKAGE_adbyby is not set
# CONFIG_PACKAGE_coreutils is not set
# CONFIG_PACKAGE_dns2socks is not set
# CONFIG_PACKAGE_etherwake is not set
# CONFIG_PACKAGE_ip-full is not set
# CONFIG_PACKAGE_ipset is not set
# CONFIG_PACKAGE_iptables-mod-tproxy is not set
# CONFIG_PACKAGE_kmod-ipt-tproxy is not set
# CONFIG_PACKAGE_libelf is not set
# CONFIG_PACKAGE_libev is not set
# CONFIG_PACKAGE_libipset is not set
# CONFIG_PACKAGE_libmbedtls is not set
# CONFIG_PACKAGE_libmnl is not set
# CONFIG_PACKAGE_libnet-1.2.x is not set
# CONFIG_PACKAGE_libpcap is not set
# CONFIG_PACKAGE_libsodium is not set
# CONFIG_PACKAGE_libuuid is not set
# CONFIG_PACKAGE_luci-app-accesscontrol is not set
# CONFIG_PACKAGE_luci-app-adbyby-plus is not set
# CONFIG_PACKAGE_luci-app-arpbind is not set
# CONFIG_PACKAGE_luci-app-autoreboot is not set
# CONFIG_PACKAGE_luci-app-ddns is not set
# CONFIG_PACKAGE_luci-app-filetransfer is not set
# CONFIG_PACKAGE_luci-app-ssr-plus is not set
# CONFIG_PACKAGE_luci-app-unblockmusic is not set
# CONFIG_PACKAGE_luci-app-upnp is not set
# CONFIG_PACKAGE_luci-app-vlmcsd is not set
# CONFIG_PACKAGE_luci-app-vsftpd is not set
# CONFIG_PACKAGE_luci-app-wol is not set
# CONFIG_PACKAGE_luci-lib-fs is not set
# CONFIG_PACKAGE_microsocks is not set
# CONFIG_PACKAGE_miniupnpd is not set
# CONFIG_PACKAGE_shadowsocks-libev-ss-local is not set
# CONFIG_PACKAGE_shadowsocks-libev-ss-redir is not set
# CONFIG_PACKAGE_shadowsocksr-libev-alt is not set
# CONFIG_PACKAGE_shadowsocksr-libev-ssr-local is not set
# CONFIG_PACKAGE_simple-obfs is not set
# CONFIG_PACKAGE_tcpping is not set
# CONFIG_PACKAGE_vlmcsd is not set
# CONFIG_PACKAGE_vsftpd-alt is not set
# CONFIG_PACKAGE_luci-app-flowoffload is not set
EOF


# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 返回工作目录
cd ../..

# 配置文件创建完成
