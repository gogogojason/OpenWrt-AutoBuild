
#!/bin/bash

# 安装额外依赖软件包
# sudo -E apt-get -y install rename

# 更新feeds文件
# sed -i 's@#src-git helloworld@src-git helloworld@g' feeds.conf.default #启用helloworld
cat feeds.conf.default


# 添加第三方软件包
git clone https://github.com/gogogojason/luci-theme-edge -b 18.06 package/lean/luci-theme-edge
#git clone https://github.com/db-one/dbone-update.git -b 18.06 package/dbone-update
git clone https://github.com/kenzok8/small.git package/small
git clone https://github.com/kenzok8/openwrt-packages.git package/otherpackages
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
device_name='MiRouter'                                                      # 自定义设备名
wifi_name="K2PWiFi"                                                          # 自定义Wifi 名字
wifi_name5g="K2PWiFi_5G"                                                     # 自定义Wifi 名字
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

#创建自定义配置文件 - Sim_K2P

cd build/Sim_K2P
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
CONFIG_TARGET_ramips_mt7621_DEVICE_phicomm_k2p=y
EOF

# 去掉默认设置:
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
