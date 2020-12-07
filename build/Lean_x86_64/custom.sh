
#!/bin/bash

# 安装额外依赖软件包
# sudo -E apt-get -y install rename

# 更新feeds文件
# sed -i 's@#src-git helloworld@src-git helloworld@g' feeds.conf.default #启用helloworld
cat feeds.conf.default
sed -i '$a src-git otherpackages https://github.com/kenzok8/openwrt-packages.git' feeds.conf.default
sed -i '$a src-git small https://github.com/kenzok8/small.git' feeds.conf.default
cat feeds.conf.default


# 添加第三方软件包
git clone https://github.com/gogogojason/luci-theme-edge -b 18.06 package/lean/luci-theme-edge
git clone https://github.com/db-one/dbone-update.git -b 18.06 package/dbone-update
#git clone https://github.com/kenzok8/small.git package/small
#git clone https://github.com/kenzok8/openwrt-packages.git package/otherpackages
git clone https://github.com/281677160/openwrt-package.git package/otherpackages2
git clone --depth=1 https://github.com/tty228/luci-app-serverchan.git package/lean/luci-app-serverchan
#git clone https://github.com/rufengsuixing/luci-app-adguardhome.git package/lean/luci-app-adguardhome
#git clone https://github.com/jerrykuku/lua-maxminddb.git package/lean/lua-maxminddb
#git clone https://github.com/jerrykuku/luci-app-vssr.git package/lean/luci-app-vssr
git clone https://github.com/Lienol/openwrt-package.git package/Lienol

# 更新并安装源
#./scripts/feeds clean
./scripts/feeds update -a && ./scripts/feeds install -a

# 删除部分默认包
#rm -rf package/lean/luci-theme-argon
#rm -rf feeds/packages/net/haproxy

# 自定义定制选项
# 定义部分以及需要添加对应APP必须的文件
device_name='MyRouter'                                                      # 自定义设备名
wifi_name="RMWiFi"                                                          # 自定义Wifi 名字
wifi_name5g="RMWiFi_5G"                                                     # 自定义Wifi 名字
lan_ip='192.168.2.1'                                                        # 自定义Lan Ip地址
utc_name='Asia\/Shanghai'                                                   # 自定义时区
ver_name='D201208'                                                          # 版本号
delete_bootstrap=false                                                      # 是否删除默认主题 true 、false
default_theme='luci-theme-edge'                                             # 默认主题 结合主题文件夹名字
openClash_url='https://github.com/vernesong/OpenClash.git'                  # OpenClash包地址
upgrade_url='https://github.com/gogogojason/upgrade.git'


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

echo "修改版本信息"
sed -i "s/R20.10.20/R20.10.20\/hfy166 Ver.$ver_name/g" package/lean/default-settings/files/zzz-default-settings

#echo "取消默认密码"
#sed -i 's@.*CYXluq4wUazHjmCDBCqXF*@#&@g' package/lean/default-settings/files/zzz-default-settings #取消系统默认密码

#echo "其他修改"
#sed -i 's#option commit_interval 24h#option commit_interval 10m#g' feeds/packages/net/nlbwmon/files/nlbwmon.config #修改流量统计写入为10分钟
#sed -i 's#option database_directory /var/lib/nlbwmon#option database_directory /etc/config/nlbwmon_data#g' feeds/packages/net/nlbwmon/files/nlbwmon.config #修改流量统计数据存放默认位置
#sed -i 's@interval: 5@interval: 1@g' package/lean/luci-app-wrtbwmon/htdocs/luci-static/wrtbwmon.js #wrtbwmon默认刷新时间更改为1秒
#sed -i 's@%D %V, %C@%D %V, %C Lean_x86_64@g' package/base-files/files/etc/banner #自定义banner显示
#sed -i 's@e5effd@f8fbfe@g' package/dbone-update/luci-theme-edge/htdocs/luci-static/edge/cascade.css #luci-theme-edge主题颜色微调
#sed -i 's#223, 56, 18, 0.04#223, 56, 18, 0.02#g' package/dbone-update/luci-theme-edge/htdocs/luci-static/edge/cascade.css #luci-theme-edge主题颜色微调

#创建自定义配置文件 - Lean_x86_64

cd build/Lean_x86_64
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

# 编译x64固件:
cat >> .config <<EOF
CONFIG_TARGET_x86=y
CONFIG_TARGET_x86_64=y
CONFIG_TARGET_x86_64_Generic=y
EOF

# 设置固件大小:
cat >> .config <<EOF
CONFIG_TARGET_KERNEL_PARTSIZE=64
CONFIG_TARGET_ROOTFS_PARTSIZE=960
EOF

# 固件压缩:
cat >> .config <<EOF
CONFIG_TARGET_IMAGES_GZIP=y
EOF

# 编译UEFI固件:
cat >> .config <<EOF
CONFIG_EFI_IMAGES=y
EOF

# IPv6支持:
cat >> .config <<EOF
CONFIG_PACKAGE_dnsmasq_full_dhcpv6=y
CONFIG_PACKAGE_ipv6helper=y
EOF

# 编译VMware镜像以及镜像填充
cat >> .config <<EOF
CONFIG_VMDK_IMAGES=y
CONFIG_TARGET_IMAGES_PAD=y
EOF

# 多文件系统支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-fs-nfs=y
# CONFIG_PACKAGE_kmod-fs-nfs-common=y
# CONFIG_PACKAGE_kmod-fs-nfs-v3=y
# CONFIG_PACKAGE_kmod-fs-nfs-v4=y
# CONFIG_PACKAGE_kmod-fs-ntfs=y
# CONFIG_PACKAGE_kmod-fs-squashfs=y
# EOF

# USB3.0支持:
# cat >> .config <<EOF
# CONFIG_PACKAGE_kmod-usb-ohci=y
# CONFIG_PACKAGE_kmod-usb-ohci-pci=y
# CONFIG_PACKAGE_kmod-usb2=y
# CONFIG_PACKAGE_kmod-usb2-pci=y
# CONFIG_PACKAGE_kmod-usb3=y
# EOF

#SmartDNS安装
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-smartdns=y
CONFIG_PACKAGE_smartdns=y
CONFIG_PACKAGE_luci-i18n-smartdns-zh-cn=y
EOF

# 第三方插件选择:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-oaf=y #应用过滤
# CONFIG_PACKAGE_luci-app-openclash=y #OpenClash客户端
CONFIG_PACKAGE_luci-app-serverchan=y #微信推送
CONFIG_PACKAGE_luci-app-eqos=y #IP限速
# CONFIG_PACKAGE_luci-app-control-weburl=y #网址过滤
CONFIG_PACKAGE_luci-app-adguardhome=y #ADguardhome
CONFIG_PACKAGE_luci-app-poweroff=y #关机（增加关机功能）
# CONFIG_PACKAGE_luci-app-argon-config=y #argon主题设置
# CONFIG_PACKAGE_luci-theme-atmaterial=y #atmaterial 三合一主题
CONFIG_PACKAGE_luci-theme-edge=y #edge主题
CONFIG_PACKAGE_luci-app-socat=y
CONFIG_PACKAGE_luci-app-aria2=y
CONFIG_PACKAGE_luci-app-frpc=y
CONFIG_PACKAGE_luci-app-hd-idle=y
CONFIG_PACKAGE_luci-app-mwan3=y
CONFIG_PACKAGE_luci-app-mwan3helper=y
CONFIG_PACKAGE_luci-app-nps=y
CONFIG_PACKAGE_luci-app-qos=y
CONFIG_PACKAGE_luci-app-syncdial=y
CONFIG_PACKAGE_luci-app-haproxy-tcp=y
CONFIG_PACKAGE_luci-app-transmission=y
CONFIG_PACKAGE_luci-app-ttyd=y
CONFIG_PACKAGE_luci-app-uhttpd=y
CONFIG_PACKAGE_luci-app-vssr=y
CONFIG_PACKAGE_luci-app-wrtbwmon-zhcn=y
EOF

# 插件汉化包:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-i18n-aria2-zh-cn=y
CONFIG_PACKAGE_luci-i18n-eqos-zh-cn=y
CONFIG_PACKAGE_luci-i18n-flowoffload-zh-cn=y
CONFIG_PACKAGE_luci-i18n-frpc-zh-cn=y
CONFIG_PACKAGE_luci-i18n-hd-idle-zh-cn=y
CONFIG_PACKAGE_luci-i18n-mwan3-zh-cn=y
CONFIG_PACKAGE_luci-i18n-mwan3helper-zh-cn=y
CONFIG_PACKAGE_luci-i18n-nps-zh-cn=y
CONFIG_PACKAGE_luci-i18n-qos-zh-cn=y
CONFIG_PACKAGE_luci-i18n-socat-zh-cn=y
CONFIG_PACKAGE_luci-i18n-transmission-zh-cn=y
CONFIG_PACKAGE_luci-i18n-ttyd-zh-cn=y
CONFIG_PACKAGE_luci-i18n-uhttpd-zh-cn=y
CONFIG_PACKAGE_luci-i18n-verysync-zh-cn=y
CONFIG_PACKAGE_luci-i18n-wrtbwmon-zh-cn=y
EOF

# Diskman磁盘管理:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-diskman=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_btrfs_progs=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_kmod_md_linear=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_kmod_md_raid456=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_lsblk=y
CONFIG_PACKAGE_luci-app-diskman_INCLUDE_mdadm=y
EOF

# vShadowsocksR插件:
#cat >> .config <<EOF
#CONFIG_PACKAGE_luci-app-ssr-plus=y
#CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Shadowsocks=y
#CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Socks=y
#CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Kcptun=y
#CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray=y
#EOF

# Passwall插件:
cat >> .config <<EOF
CONFIG_PACKAGE_luci-app-passwall=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ipt2socks=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Shadowsocks=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ShadowsocksR=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_ChinaDNS_NG=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_V2ray=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_v2ray-plugin=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_simple-obfs=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_Plus=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Trojan_GO=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_Brook=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_kcptun=y
CONFIG_PACKAGE_luci-app-passwall_INCLUDE_haproxy=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_dns2socks=y
#CONFIG_PACKAGE_luci-app-passwall_INCLUDE_pdnsd=y
#CONFIG_PACKAGE_https-dns-proxy=y
#CONFIG_PACKAGE_kcptun-client=y
#CONFIG_PACKAGE_chinadns-ng=y
#CONFIG_PACKAGE_haproxy=y
#CONFIG_PACKAGE_xray=y
#CONFIG_PACKAGE_v2ray=y
#CONFIG_PACKAGE_v2ray-plugin=y
#CONFIG_PACKAGE_simple-obfs=y
#CONFIG_PACKAGE_trojan-plus=y
#CONFIG_PACKAGE_trojan-go=y
#CONFIG_PACKAGE_brook=y
#CONFIG_PACKAGE_ssocks=y
#CONFIG_PACKAGE_naiveproxy=y
#CONFIG_PACKAGE_ipt2socks=y
#CONFIG_PACKAGE_shadowsocks-libev-config=y
#CONFIG_PACKAGE_shadowsocks-libev-ss-local=y
#CONFIG_PACKAGE_shadowsocks-libev-ss-redir=y
#CONFIG_PACKAGE_shadowsocksr-libev-alt=y
#CONFIG_PACKAGE_shadowsocksr-libev-ssr-local=y
#CONFIG_PACKAGE_pdnsd-alt=y
#CONFIG_PACKAGE_dns2socks=y
EOF

# 常用LuCI插件:
cat >> .config <<EOF
#CONFIG_PACKAGE_luci-app-adbyby-plus=y #adbyby去广告
CONFIG_PACKAGE_luci-app-webadmin=y #Web管理页面设置
CONFIG_PACKAGE_luci-app-ddns=y #DDNS服务
CONFIG_DEFAULT_luci-app-vlmcsd=y #KMS激活服务器
CONFIG_PACKAGE_luci-app-filetransfer=y #系统-文件传输
CONFIG_PACKAGE_luci-app-autoreboot=y #定时重启
CONFIG_PACKAGE_luci-app-upnp=y #通用即插即用UPnP(端口自动转发)
#CONFIG_PACKAGE_luci-app-accesscontrol=y #上网时间控制
CONFIG_PACKAGE_luci-app-wol=y #网络唤醒
#CONFIG_PACKAGE_luci-app-frpc=y #Frp内网穿透
#CONFIG_PACKAGE_luci-app-nlbwmon=y #宽带流量监控
#CONFIG_PACKAGE_luci-app-wrtbwmon=y #实时流量监测
CONFIG_PACKAGE_luci-app-sfe=y #高通开源的 Shortcut FE 转发加速引擎
#CONFIG_PACKAGE_luci-app-haproxy-tcp is not set #Haproxy负载均衡
#CONFIG_PACKAGE_luci-app-diskman is not set #磁盘管理磁盘信息
#CONFIG_PACKAGE_luci-app-transmission is not set #TR离线下载
#CONFIG_PACKAGE_luci-app-qbittorrent is not set #QB离线下载
# CONFIG_PACKAGE_luci-app-amule is not set #电驴离线下载
#CONFIG_PACKAGE_luci-app-xlnetacc is not set #迅雷快鸟
#CONFIG_PACKAGE_luci-app-zerotier is not set #zerotier内网穿透
#CONFIG_PACKAGE_luci-app-hd-idle is not set #磁盘休眠
#CONFIG_PACKAGE_luci-app-unblockmusic is not set #解锁网易云灰色歌曲
# CONFIG_PACKAGE_luci-app-airplay2 is not set #Apple AirPlay2音频接收服务器
# CONFIG_PACKAGE_luci-app-music-remote-center is not set #PCHiFi数字转盘遥控
# CONFIG_PACKAGE_luci-app-usb-printer is not set #USB打印机
# CONFIG_PACKAGE_luci-app-sqm is not set #SQM智能队列管理
#
#VPN相关插件(禁用):
#
# CONFIG_PACKAGE_luci-app-v2ray-server is not set #V2ray服务器
# CONFIG_PACKAGE_luci-app-pptp-server is not set #PPTP VPN 服务器
# CONFIG_PACKAGE_luci-app-ipsec-vpnd is not set #ipsec VPN服务
# CONFIG_PACKAGE_luci-app-openvpn-server is not set #openvpn服务
# CONFIG_PACKAGE_luci-app-softethervpn is not set #SoftEtherVPN服务器
#
#文件共享相关(禁用):
#
#CONFIG_PACKAGE_luci-app-minidlna is not set #miniDLNA服务
#CONFIG_PACKAGE_luci-app-vsftpd is not set #FTP 服务器
#CONFIG_PACKAGE_luci-app-samba is not set #网络共享
#CONFIG_PACKAGE_autosamba is not set #网络共享
#CONFIG_PACKAGE_samba36-server is not set #网络共享
EOF

# LuCI主题:
#cat >> .config <<EOF
#CONFIG_PACKAGE_luci-theme-argon=y
#CONFIG_PACKAGE_luci-theme-netgear=y
#EOF

# 常用软件包:
cat >> .config <<EOF
CONFIG_PACKAGE_curl=y
CONFIG_PACKAGE_htop=y
CONFIG_PACKAGE_nano=y
# CONFIG_PACKAGE_screen=y
# CONFIG_PACKAGE_tree=y
# CONFIG_PACKAGE_vim-fuller=y
CONFIG_PACKAGE_wget=y
CONFIG_PACKAGE_bash=y
CONFIG_PACKAGE_kmod-tun=y
CONFIG_PACKAGE_libcap=y
CONFIG_PACKAGE_libcap-bin=y
CONFIG_PACKAGE_ip6tables-mod-nat=y
CONFIG_PACKAGE_iptables-mod-extra=y
EOF

# 其他软件包:
#cat >> .config <<EOF
#CONFIG_HAS_FPU=y
#EOF

# 去掉默认设置:
cat >> .config <<EOF
# CONFIG_PACKAGE_luci-app-flowoffload is not set #开源 Linux Flow Offload 驱动
# CONFIG_PACKAGE_luci-app-wrtbwmon is not set
# CONFIG_PACKAGE_adbyby is not set
# CONFIG_PACKAGE_dns2socks is not set
# CONFIG_PACKAGE_luci-app-adbyby-plus is not set
# CONFIG_PACKAGE_luci-app-ipsec-vpnd is not set
# CONFIG_PACKAGE_luci-app-rclone_INCLUDE_fuse-utils is not set
# CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-ng is not set
# CONFIG_PACKAGE_luci-app-rclone_INCLUDE_rclone-webui is not set
# CONFIG_PACKAGE_luci-app-ssr-plus is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Redsocks2 is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_ShadowsocksR_Server is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_Trojan is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray is not set
# CONFIG_PACKAGE_luci-app-ssr-plus_INCLUDE_V2ray_plugin is not set
# CONFIG_PACKAGE_luci-app-xlnetacc is not set
# CONFIG_PACKAGE_redsocks2 is not set
# CONFIG_PACKAGE_kmod-ip-vti is not set
# CONFIG_PACKAGE_kmod-ip6-vti is not set
# CONFIG_PACKAGE_kmod-xfrm-interface is not set
# CONFIG_PACKAGE_strongswan-charon-cmd is not set
# CONFIG_PACKAGE_strongswan-default is not set
# CONFIG_PACKAGE_strongswan-isakmp is not set
# CONFIG_PACKAGE_strongswan-libtls is not set
# CONFIG_PACKAGE_strongswan-mod-addrblock is not set
# CONFIG_PACKAGE_strongswan-mod-af-alg is not set
# CONFIG_PACKAGE_strongswan-mod-agent is not set
# CONFIG_PACKAGE_strongswan-mod-attr is not set
# CONFIG_PACKAGE_strongswan-mod-attr-sql is not set
# CONFIG_PACKAGE_strongswan-mod-blowfish is not set
# CONFIG_PACKAGE_strongswan-mod-ccm is not set
# CONFIG_PACKAGE_strongswan-mod-cmac is not set
# CONFIG_PACKAGE_strongswan-mod-connmark is not set
# CONFIG_PACKAGE_strongswan-mod-constraints is not set
# CONFIG_PACKAGE_strongswan-mod-coupling is not set
# CONFIG_PACKAGE_strongswan-mod-ctr is not set
# CONFIG_PACKAGE_strongswan-mod-curl is not set
# CONFIG_PACKAGE_strongswan-mod-curve25519 is not set
# CONFIG_PACKAGE_strongswan-mod-des is not set
# CONFIG_PACKAGE_strongswan-mod-dhcp is not set
# CONFIG_PACKAGE_strongswan-mod-dnskey is not set
# CONFIG_PACKAGE_strongswan-mod-duplicheck is not set
# CONFIG_PACKAGE_strongswan-mod-eap-identity is not set
# CONFIG_PACKAGE_strongswan-mod-eap-md5 is not set
# CONFIG_PACKAGE_strongswan-mod-eap-mschapv2 is not set
# CONFIG_PACKAGE_strongswan-mod-eap-radius is not set
# CONFIG_PACKAGE_strongswan-mod-eap-tls is not set
# CONFIG_PACKAGE_strongswan-mod-farp is not set
# CONFIG_PACKAGE_strongswan-mod-fips-prf is not set
# CONFIG_PACKAGE_strongswan-mod-forecast is not set
# CONFIG_PACKAGE_strongswan-mod-gcm is not set
# CONFIG_PACKAGE_strongswan-mod-gcrypt is not set
# CONFIG_PACKAGE_strongswan-mod-gmpdh is not set
# CONFIG_PACKAGE_strongswan-mod-ha is not set
# CONFIG_PACKAGE_strongswan-mod-ldap is not set
# CONFIG_PACKAGE_strongswan-mod-led is not set
# CONFIG_PACKAGE_strongswan-mod-load-tester is not set
# CONFIG_PACKAGE_strongswan-mod-md4 is not set
# CONFIG_PACKAGE_strongswan-mod-md5 is not set
# CONFIG_PACKAGE_strongswan-mod-mysql is not set
# CONFIG_PACKAGE_strongswan-mod-openssl is not set
# CONFIG_PACKAGE_strongswan-mod-pem is not set
# CONFIG_PACKAGE_strongswan-mod-pgp is not set
# CONFIG_PACKAGE_strongswan-mod-pkcs1 is not set
# CONFIG_PACKAGE_strongswan-mod-pkcs11 is not set
# CONFIG_PACKAGE_strongswan-mod-pkcs12 is not set
# CONFIG_PACKAGE_strongswan-mod-pkcs7 is not set
# CONFIG_PACKAGE_strongswan-mod-pkcs8 is not set
# CONFIG_PACKAGE_strongswan-mod-rc2 is not set
# CONFIG_PACKAGE_strongswan-mod-resolve is not set
# CONFIG_PACKAGE_strongswan-mod-revocation is not set
# CONFIG_PACKAGE_strongswan-mod-sha2 is not set
# CONFIG_PACKAGE_strongswan-mod-smp is not set
# CONFIG_PACKAGE_strongswan-mod-socket-dynamic is not set
# CONFIG_PACKAGE_strongswan-mod-sql is not set
# CONFIG_PACKAGE_strongswan-mod-sqlite is not set
# CONFIG_PACKAGE_strongswan-mod-sshkey is not set
# CONFIG_PACKAGE_strongswan-mod-test-vectors is not set
# CONFIG_PACKAGE_strongswan-mod-uci is not set
# CONFIG_PACKAGE_strongswan-mod-unity is not set
# CONFIG_PACKAGE_strongswan-mod-vici is not set
# CONFIG_PACKAGE_strongswan-mod-whitelist is not set
# CONFIG_PACKAGE_strongswan-mod-xauth-eap is not set
# CONFIG_PACKAGE_strongswan-pki is not set
# CONFIG_PACKAGE_strongswan-scepclient is not set
# CONFIG_PACKAGE_strongswan-swanctl is not set
# CONFIG_PACKAGE_xfrm is not set
EOF

# 
# ========================固件定制部分结束========================
# 


sed -i 's/^[ \t]*//g' ./.config

# 返回工作目录
cd ../..

# 配置文件创建完成
