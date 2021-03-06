
#!/bin/bash

# 安装额外依赖软件包
# sudo -E apt-get -y install rename

# 更新feeds文件
# sed -i 's@#src-git helloworld@src-git helloworld@g' feeds.conf.default #启用helloworld
cat feeds.conf.default


# 添加第三方软件包
git clone https://github.com/gogogojason/OpenWrt-Packages.git package/jason 
#git clone https://github.com/gogogojason/luci-theme-edge -b 18.06 package/lean/luci-theme-edge
#git clone https://github.com/db-one/dbone-update.git -b 18.06 package/dbone-update
#git clone https://github.com/kenzok8/small.git package/small
#git clone https://github.com/kenzok8/openwrt-packages.git package/otherpackages
#git clone https://github.com/281677160/openwrt-package.git package/otherpackages2
#git clone --depth=1 https://github.com/tty228/luci-app-serverchan.git package/lean/luci-app-serverchan
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/lean/luci-app-adguardhome
#git clone https://github.com/jerrykuku/lua-maxminddb.git package/lean/lua-maxminddb
#git clone https://github.com/jerrykuku/luci-app-vssr.git package/lean/luci-app-vssr
#git clone https://github.com/Lienol/openwrt-package.git package/Lienol

# 更新并安装源
#./scripts/feeds clean
./scripts/feeds update -a && ./scripts/feeds install -a

# 删除部分默认包
#rm -rf package/lean/luci-theme-argon
#rm -rf feeds/packages/net/haproxy

# 自定义定制选项
# 定义部分以及需要添加对应APP必须的文件
device_name='K2PRouter'                                                      # 自定义设备名
wifi_name="K2PWiFi"                                                          # 自定义Wifi 名字
wifi_name5g="K2PWiFi_5G"                                                     # 自定义Wifi 名字
lan_ip='192.168.2.1'                                                        # 自定义Lan Ip地址
utc_name='Asia\/Shanghai'                                                   # 自定义时区
#ver_name='D201212'                                                          # 版本号
#ver_op='R20.12.12'                                                          # 编译的版本
delete_bootstrap=false                                                      # 是否删除默认主题 true 、false
default_theme='luci-theme-edge'                                             # 默认主题 结合主题文件夹名字
openClash_url='https://github.com/vernesong/OpenClash.git'                  # OpenClash包地址
date=`date +%m.%d.%Y`
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

#echo "修改默认主题"
#sed -i 's/+luci-theme-bootstrap/+luci-theme-edge/g' feeds/luci/collections/luci/Makefile
#sed -i "s/bootstrap/argon/g" feeds/luci/modules/luci-base/root/etc/config/luci
#sed -i '/set luci.main.mediaurlbase=\/luci-static\/bootstrap/d' feeds/luci/themes/luci-theme-bootstrap/root/etc/uci-defaults/30_luci-theme-bootstrap

echo "设置版本号"
sed -i "s/# REVISION:=x/REVISION:= $date/g" include/version.mk

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

#创建自定义配置文件 - Sim_K2P

cd build/Sim_K2P
touch ./.config


# ========================固件定制部分========================


# 编译Sim_RM2100固件:
cat >> .config <<EOF
CONFIG_TARGET_ramips=y
CONFIG_TARGET_ramips_mt7621=y
CONFIG_TARGET_ramips_mt7621_DEVICE_phicomm_k2p=y
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
# CONFIG_PACKAGE_luci-app-openclash=y #OpenClash客户端
#CONFIG_PACKAGE_luci-app-serverchan=y #微信推送
CONFIG_PACKAGE_luci-app-ddns=y #DDNS服务
CONFIG_DEFAULT_luci-app-vlmcsd=y #KMS激活服务器
CONFIG_PACKAGE_luci-app-gpsysupgrade=y
#CONFIG_PACKAGE_luci-app-eqos=y #IP限速
# CONFIG_PACKAGE_luci-app-control-weburl=y #网址过滤
#CONFIG_PACKAGE_luci-app-smartdns=y #smartdns服务器
#CONFIG_PACKAGE_luci-app-adguardhome=y #ADguardhome
CONFIG_PACKAGE_luci-app-poweroff=y #关机（增加关机功能）
# CONFIG_PACKAGE_luci-app-argon-config=y #argon主题设置
# CONFIG_PACKAGE_luci-theme-atmaterial=y #atmaterial 三合一主题
CONFIG_PACKAGE_luci-app-filetransfer=y #系统-文件传输
CONFIG_PACKAGE_luci-app-autoreboot=y #定时重启
CONFIG_PACKAGE_luci-app-upnp=y #通用即插即用UPnP(端口自动转发)
CONFIG_PACKAGE_luci-app-accesscontrol=y #上网时间控制
#CONFIG_PACKAGE_luci-app-wol=y #网络唤醒
CONFIG_PACKAGE_luci-app-webadmin=y #Web管理页面设置
CONFIG_PACKAGE_luci-theme-edge=y #edge主题
CONFIG_PACKAGE_luci-app-socat=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-mwan3helper=y
#CONFIG_PACKAGE_luci-app-smartdns=y
#CONFIG_PACKAGE_luci-theme-bootstrap=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-ttyd=y
#CONFIG_PACKAGE_luci-app-wrtbwmon=y
CONFIG_PACKAGE_luci-app-zerotier=y
CONFIG_PACKAGE_luci-app-sfe=y #高通开源的 Shortcut FE 转发加速引擎
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
# CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Trojan-Go is not set
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_NaiveProxy=y
# CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Kcptun is not set
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Socks5_Proxy=y
CONFIG_PACKAGE_luci-app-bypass_INCLUDE_Socks_Server=y
EOF

# Passwall插件:
#cat >> .config <<EOF
#CONFIG_PACKAGE_luci-app-passwall=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks is not set
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR=y
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus
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
#CONFIG_PACKAGE_xray=y
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
#EOF

# 去掉默认设置:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-flowoffload is not set #开源 Linux Flow Offload 驱动
# CONFIG_PACKAGE_adbyby is not set
# CONFIG_PACKAGE_luci-app-adbyby-plus is not set
# CONFIG_PACKAGE_luci-app-xlnetacc is not set
# CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun is not set
#CONFIG_PACKAGE_v2ray is not set
# CONFIG_PACKAGE_luci-app-ssr-plus is not set
# CONFIG_PACKAGE_luci-app-unblockmusic is not set
# CONFIG_PACKAGE_luci-app-vsftpd is not set
EOF


# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 返回工作目录
cd ../..

# 配置文件创建完成
