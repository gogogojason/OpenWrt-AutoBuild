#!/bin/bash

# 安装额外依赖软件包
# sudo -E apt-get -y install rename

# 更新feeds文件
# sed -i 's@#src-git helloworld@src-git helloworld@g' feeds.conf.default #启用helloworld
cat feeds.conf.default
#sed -i '$a src-git otherpackages https://github.com/kenzok8/openwrt-packages.git' feeds.conf.default
#sed -i '$a src-git small https://github.com/kenzok8/small.git' feeds.conf.default
#cat feeds.conf.default


# 添加第三方软件包
git clone https://github.com/gogogojason/OpenWrt-Packages.git package/jason
#svn co https://github.com/vernesong/OpenClash/trunk/luci-app-openclash package/luci-app-openclash
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/lean/luci-app-adguardhome
#git clone https://github.com/garypang13/luci-theme-edge -b 18.06 package/lean/luci-theme-edge
#git clone https://github.com/sirpdboy/luci-app-autopoweroff.git package/lean/luci-app-autopoweroff
#svn co https://github.com/281677160/openwrt-package/trunk/luci-app-poweroff package/lean/luci-app-poweroff
#git clone --depth=1 https://github.com/tty228/luci-app-serverchan.git package/lean/luci-app-serverchan
#git clone https://github.com/jerrykuku/lua-maxminddb.git package/lean/lua-maxminddb
#git clone https://github.com/jerrykuku/luci-app-vssr.git package/lean/luci-app-vssr
#git clone https://github.com/Lienol/openwrt-package.git package/Lienol
#git clone https://github.com/db-one/dbone-update.git -b 18.06 package/dbone-update
#git clone https://github.com/kenzok8/small.git package/small
#git clone https://github.com/kenzok8/openwrt-packages.git package/otherpackages
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/lean/luci-app-adguardhome
#git clone https://github.com/281677160/openwrt-package.git package/otherpackages2


# 更新并安装源
./scripts/feeds clean
./scripts/feeds update -a && ./scripts/feeds install -a
./scripts/feeds update -a && ./scripts/feeds install -a

# 删除部分默认包
#rm -rf package/lean/luci-theme-argon
#rm -rf feeds/packages/net/haproxy

# 自定义定制选项
# 定义部分以及需要添加对应APP必须的文件
device_name='MiRouter'                                                      # 自定义设备名
wifi_name="RMWiFi"                                                          # 自定义Wifi 名字
wifi_name5g="RMWiFi_5G"                                                     # 自定义Wifi 名字
lan_ip='192.168.2.1'                                                        # 自定义Lan Ip地址
utc_name='Asia\/Shanghai'                                                   # 自定义时区
#ver_name='D201212'                                                          # 版本号
#ver_op='R20.12.12'                                                          # 编译的版本
delete_bootstrap=false                                                      # 是否删除默认主题 true 、false
default_theme='luci-theme-edge'                                             # 默认主题 结合主题文件夹名字
openClash_url='https://github.com/vernesong/OpenClash.git'                  # OpenClash包地址
upgrade_url='https://github.com/gogogojason/upgrade.git'

echo "修改版本信息"
sed -i "s/OpenWrt /hfy166 Ver.D$(TZ=UTC-8 date "+%Y.%m.%d") \/ OpenWrt /g" package/lean/default-settings/files/zzz-default-settings

echo "修改wifi名称"
sed -i "s/OpenWrt_2G/$wifi_name/g" package/lean/mt/drivers/mt_wifi/files/mt7603.dat
sed -i "s/OpenWrt_5G/$wifi_name5g/g" package/lean/mt/drivers/mt_wifi/files/mt7615.dat

echo "默认IP设置"
sed -i "s/192.168.1.1/$lan_ip/g" package/base-files/files/bin/config_generate

echo "修改机器名称"
sed -i "s/OpenWrt/$device_name/g" package/base-files/files/bin/config_generate

echo "时区设置"
sed -i "s/'UTC'/'CST-8'\n   set system.@system[-1].zonename='$utc_name'/g" package/base-files/files/bin/config_generate

echo "修改默认主题"
sed -i 's/+luci-theme-bootstrap/+luci-theme-edge/g' feeds/luci/collections/luci/Makefile
sed -i "s/bootstrap/argon/g" feeds/luci/modules/luci-base/root/etc/config/luci
sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

#echo "修改版本信息"
#sed -i "s/$ver_op/$ver_op\/hfy166 Ver.$ver_name/g" package/lean/default-settings/files/zzz-default-settings

#echo "取消默认密码"
#sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings #取消系统默认密码

#echo "其他修改"
#sed -i 's#option commit_interval 24h#option commit_interval 10m#g' feeds/packages/net/nlbwmon/files/nlbwmon.config #修改流量统计写入为10分钟
#sed -i 's#option database_directory /var/lib/nlbwmon#option database_directory /etc/config/nlbwmon_data#g' feeds/packages/net/nlbwmon/files/nlbwmon.config #修改流量统计数据存放默认位置
#sed -i 's@interval: 5@interval: 1@g' package/lean/luci-app-wrtbwmon/htdocs/luci-static/wrtbwmon.js #wrtbwmon默认刷新时间更改为1秒
#sed -i 's@%D %V, %C@%D %V, %C Lean_x86_64@g' package/base-files/files/etc/banner #自定义banner显示
#sed -i 's@e5effd@f8fbfe@g' package/dbone-update/luci-theme-edge/htdocs/luci-static/edge/cascade.css #luci-theme-edge主题颜色微调
#sed -i 's#223, 56, 18, 0.04#223, 56, 18, 0.02#g' package/dbone-update/luci-theme-edge/htdocs/luci-static/edge/cascade.css #luci-theme-edge主题颜色微调

#创建自定义配置文件 - All_RM2100

cd build/All_RM2100
touch ./.config

# ========================固件定制部分========================


# 编译All_RM2100固件:
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
# CONFIG_PACKAGE_luci-app-oaf=y #应用过滤
CONFIG_PACKAGE_luci-app-openclash=y #OpenClash客户端
CONFIG_PACKAGE_luci-app-serverchan=y #微信推送
CONFIG_PACKAGE_luci-app-eqos=y #IP限速
# CONFIG_PACKAGE_luci-app-control-weburl=y #网址过滤
CONFIG_PACKAGE_luci-app-smartdns=y #smartdns服务器
CONFIG_PACKAGE_luci-app-adguardhome=y #ADguardhome
CONFIG_PACKAGE_luci-app-poweroff=y #关机（增加关机功能）
# CONFIG_PACKAGE_luci-app-argon-config=y #argon主题设置
# CONFIG_PACKAGE_luci-theme-atmaterial=y #atmaterial 三合一主题
CONFIG_PACKAGE_luci-theme-edge=y #edge主题
CONFIG_PACKAGE_luci-app-socat=y
CONFIG_PACKAGE_luci-app-frpc=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-mwan3helper=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-wrtbwmon-zh=y
# CONFIG_PACKAGE_luci-app-wrtbwmon is not set
CONFIG_PACKAGE_luci-app-wrtbwmon-zhcn=y
CONFIG_PACKAGE_wrtbwmon=y
CONFIG_PACKAGE_luci-app-webadmin=y
CONFIG_PACKAGE_luci-app-zerotier=y
CONFIG_PACKAGE_luci-app-sfe=y
CONFIG_PACKAGE_luci-app-ddns=y
CONFIG_DEFAULT_luci-app-vlmcsd=y
CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_UnblockNeteaseMusic=y
CONFIG_PACKAGE_UnblockNeteaseMusicGo=y
CONFIG_PACKAGE_luci-app-wol=y
CONFIG_PACKAGE_luci-app-upnp=y
CONFIG_PACKAGE_luci-app-filetransfer=y #系统-文件传输
CONFIG_PACKAGE_luci-app-autoreboot=y #定时重启
CONFIG_PACKAGE_luci-app-accesscontrol=y #上网时间控制
#CONFIG_PACKAGE_luci-app-nps=y
EOF

# VSSR插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-vssr=y
# CONFIG_PACKAGE_luci-app-vssr_INCLUDE_V2ray_plugin is not set
# CONFIG_PACKAGE_luci-app-vssr_INCLUDE_V2ray is not set
CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Xray=y
# CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Trojan is not set
# CONFIG_PACKAGE_luci-app-vssr_INCLUDE_Kcptun is not set
CONFIG_PACKAGE_luci-app-vssr_INCLUDE_ShadowsocksR_Server=y
EOF

# Passwall插件:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-passwall is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd is not set
# CONFIG_PACKAGE_https-dns-proxy is not set
# CONFIG_PACKAGE_kcptun-client is not set
# CONFIG_PACKAGE_chinadns-ng is not set
# CONFIG_PACKAGE_haproxy is not set
# CONFIG_PACKAGE_xray is not set
# CONFIG_PACKAGE_v2ray is not set
# CONFIG_PACKAGE_v2ray-plugin is not set
# CONFIG_PACKAGE_simple-obfs is not set
# CONFIG_PACKAGE_trojan-plus is not set
# CONFIG_PACKAGE_trojan-go is not set
# CONFIG_PACKAGE_brook is not set
# CONFIG_PACKAGE_ssocks is not set
# CONFIG_PACKAGE_naiveproxy is not set
# CONFIG_PACKAGE_ipt2socks is not set
# CONFIG_PACKAGE_shadowsocks-libev-config is not set
# CONFIG_PACKAGE_shadowsocks-libev-ss-local is not set
# CONFIG_PACKAGE_shadowsocks-libev-ss-redir is not set
# CONFIG_PACKAGE_shadowsocksr-libev-alt is not set
# CONFIG_PACKAGE_shadowsocksr-libev-ssr-local is not set
# CONFIG_PACKAGE_pdnsd-alt is not set
# CONFIG_PACKAGE_dns2socks is not set
EOF

# vssr-plus插件配置#
#cat >> .config <<EOF
#CONFIG_PACKAGE_luci-app-vssr-plus=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_Shadowsocks=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_V2ray=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_Trojan=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_Kcptun=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ShadowsocksR_Server=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_Shadowsocks_Server=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ShadowsocksR_Socks=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_Shadowsocks_Socks=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ipt2socks=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_microsocks=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_dns2socks=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_dnscrypt_proxy=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_dnsforwarder=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_ChinaDNS=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_haproxy=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_privoxy=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_simple-obfs=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_simple-obfs-server=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_udpspeeder=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_udp2raw-tunnel=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_GoQuiet-client=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_GoQuiet-server=y
#CONFIG_PACKAGE_luci-app-vssr-plus_INCLUDE_v2ray-plugin=y
#EOF

# 去掉默认设置:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-flowoffload is not set #开源 Linux Flow Offload 驱动
# CONFIG_PACKAGE_adbyby is not set
# CONFIG_PACKAGE_luci-app-adbyby-plus is not set
# CONFIG_PACKAGE_luci-app-ssr-plus is not set
# CONFIG_PACKAGE_luci-app-vsftpd is not set
EOF

# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 返回工作目录
cd ../..

# 配置文件创建完成
