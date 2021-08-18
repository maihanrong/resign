#
#

cd ~/Desktop/mySign
echo "签名开始..."
# 这里修改电脑登录密码
MacPassword="qwer"
# 这里修改证书密码
CerPassword="2021"
echo "证书密码:$CerPassword"

IpaPath=`find . -name "*.ipa" -print`
echo $IpaPath
unzip -q -o $IpaPath
TempPath=`find . -name "__MACOSX" -print`
rm -rf $TempPath

BundleIdentifier=`/usr/libexec/PlistBuddy -c "Print :CFBundleIdentifier" Payload/*.app/Info.plist`
echo "Bundle ID:$BundleIdentifier"

security unlock-keychain -p $CerPassword ~/Library/Keychains/login.keychain
security list-keychains -s ~/Library/Keychains/login.keychain

CERTIFICATE_SHA_VALUE=""

# 删除证书和临时文件
function delCerAndTemp()
{

# 删除临时文件
rm Entitlements.plist
rm Mobileprovision.plist
# 删除证书
security delete-certificate -Z "$CERTIFICATE_SHA_VALUE"
}

function installCertificate()
{
mode=$1
echo "$mode Start"

MobileprovisionName=
CertificateName=

if [ $mode = "dis" ]; then
MobileprovisionName=`find . -name "dis.mobileprovision" -print`
CertificateName=`find . -name "dis.p12" -print`
fi

if [ $mode = "adhoc" ]; then
MobileprovisionName=`find . -name "adhoc.mobileprovision" -print`
CertificateName=`find . -name "dis.p12" -print`
fi

if [ $mode = "dev" ]; then
MobileprovisionName=`find . -name "dev.mobileprovision" -print`
CertificateName=`find . -name "dev.p12" -print`
fi

MOBILEPROVISION=`security cms -D -i $MobileprovisionName`
echo $MOBILEPROVISION > Mobileprovision.plist

ENTITLEMENTS=`/usr/libexec/PlistBuddy -x -c "print :Entitlements" Mobileprovision.plist`
echo $ENTITLEMENTS > Entitlements.plist

APPLICATIONIDENTIFIER=`/usr/libexec/PlistBuddy -c "Print :application-identifier" Entitlements.plist`
echo "证书中的Bundle ID:$APPLICATIONIDENTIFIER"

TEAMNAME=`/usr/libexec/PlistBuddy  -c "Print :TeamName" Mobileprovision.plist`
echo "TEAMNAME:$TEAMNAME"

AppIDName=`/usr/libexec/PlistBuddy  -c "Print :AppIDName" Mobileprovision.plist`
echo "AppIDName:$AppIDName"


# 删除签名
rm -rf Payload/*.app/_CodeSignature/
# 复制描述文件
cp -rf $MobileprovisionName Payload/*.app/embedded.mobileprovision

security import $CertificateName -k ~/Library/Keychains/login.keychain -P "$CerPassword"
# SHA-1 hash: 16635684959265DBCE20E6BBAD4F577DF9A0975C
CERTIFICASHA=`security find-certificate -a -c "$TEAMNAME" -Z login.keychain | grep ^SHA-1`
CERTIFICATE_SHA_VALUE=`echo "$CERTIFICASHA"|awk -F ' ' '{print $3}'`
echo "identity:$CERTIFICATE_SHA_VALUE"

# 动态库重签名
codesign -f -s "$CERTIFICATE_SHA_VALUE" Payload/*.app/Frameworks/*

# 游戏重签名
codesign -f -s "$CERTIFICATE_SHA_VALUE" --entitlements Entitlements.plist Payload/*.app/

# 归档
re_IPA=`echo "${AppIDName}_${mode}_$(date +%m%d).ipa"`
zip -qr "$re_IPA" Payload/

# 删除证书和临时文件
delCerAndTemp

echo "$mode End"
}

if [ -e dis.mobileprovision -a -e dis.p12 ]; then
installCertificate "dis"
fi
if [ -e adhoc.mobileprovision -a -e dis.p12 ]; then
installCertificate "adhoc"
fi
if [ -e dev.mobileprovision -a -e dev.p12 ]; then
installCertificate "dev"
fi


#echo "删除临时文件..."
rm -rf Payload

echo "签名结束。"


