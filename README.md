# resign
### iOS app重签名的脚本

#### 使用前需要打开脚本配置以下几个参数，前面几行
// 这里配置ipa包和证书所在的路径

cd ~/Desktop/resign

// 这里修改电脑登录密码

MacPassword="qwer"

// 这里修改证书密码

CerPassword="2021"

#### 重签名的文件夹需要提供签名所需要的**证书**、**描述文件**、要签名的**ipa**包
证书名字根据分发环境的区别分别为**dis.p12**、**dev.p12**

描述文件名字根据分发环境的区别分别为**dis.mobileprovision**、**adhoc.mobileprovision**、**dev.mobileprovision**
不需要全部都提供，根据需要提供



![](https://user-images.githubusercontent.com/16502006/129834156-452c2f61-6685-4212-aa06-375c49b8e629.png)
