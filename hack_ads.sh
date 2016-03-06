#!/system/bin/sh

#
# Author: Kejin ( Liang Ke Jin )
# Date: 2016/03/06
# EMail: liungkejin@foxmail.com
#

#
# 该脚本为特定的 android 环境下的 脚本，为了实现自动点击 google 广告 $_$
#

KEY_HOME=3;
KEY_BACK=4;

APP_LX=204;
APP_LY=270;

ADS_LX=473;
ADS_LY=920;

TARGET="MX4";
if [[ $TARGET = "MX4" ]]; then
    APP_LX=156;
    APP_LY=554;

    ADS_LX=957;
    ADS_LY=1850;
fi;



# 除非强制退出，否则一直运行
while true; do
    # 先回到主页面
    # 提前把要点击的应用放在主页上
    input keyevent $KEY_HOME $KEY_HOME && sleep 1; # 睡1s

    # 点击应用
    input tap $APP_LX $APP_LY && sleep 1;

    # 点击广告, 每 10s 点击一次

    while true; do
        input tap $ADS_LX $ADS_LY && sleep 5;
        input keyevent $KEY_BACK && sleep 5;
    done;

    sleep 10;
done;
