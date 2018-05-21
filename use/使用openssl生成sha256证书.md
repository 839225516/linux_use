##### openssl 生成sha256私有证书  ####

x.509 是PKI 体系中最基础的标准，它最先定义了公钥证书的基本结构：

    SSL公钥证书
    证书废除列表CRL(Certificate revocation lists)

PKCS#12
    
    windows 平台及 mac平台使用的证书标准，通常使用 pfx/p12 作为文件扩展名，
    该标准在X509的基础之上增加了私钥及存取密码。

编码格式

    PEM - Privacy Enhanced Mail, BASE64编码，可读Apache和Unix/Linux 服务器采用的编码格式.
    DER - Distinguished Encoding Rules,二进制格式,不可读.Windows 服务器采用的编码格式.

文件扩展名

    pem/der 数字证书，编码格式与其名称对应；
    crt 数字证书，常见于unix/linux系统；
    cer 数字证书，常见于windows系统；
    key 非证书，一般是公钥或私钥文件；
    csr certificate signing request，证书签名请求文件；
    pfx/p12 - predecessor of PKCS#12，是PKCS#12 标准的证书文件，同时包含了公钥和私钥，存取时需提供密码，采用DER 编码

###### 安装openssl ######
``` shell
# yum install openssl
```

###### 生成RSA密钥  #####
可以生成无密码的RSA公私钥，也可以生成加密的RSA公私钥

1)生成RSA私钥（无加密）
密钥：

    rsa_private.key     私钥
    rsa_public.key      公钥


```shell
# mkdir -p ca
# openssl genrsa -out ca/rsa_private.key 2048

#####生成RSA公钥
# openssl rsa -in ca/rsa_private.key -pubout -out ca/rsa_public.key
```

2)生成RSA私钥（使用aes256加密,带密码）
```shell
# 使用 -passout 代替shell进行密码输入，否则会提示输入密码
# openssl genrsa -aes256 -passout pass:123456 -out ca/rsa_aes_private.key 2048

#### 生成RSA公钥，需要提供密码
# openssl rsa -in ca/rsa_aes_private.key  --passin pass:123456 -pubout -out ca/rsa_aes_public.key
```

####### 密钥转换：
私钥转非加密类型：
> openssl rsa -in ca/rsa_aes_private.key -passin pass:123456 -out ca/rsa_private.key

私钥转加密类型：
> openssl rsa -in ca/rsa_private.key -aes256 -passout pass:123456 -out ca/rsa_aes_private.key

私钥pem转der
> openssl rsa -in rsa_aes_private.key -outform der-out rsa_aes_private.der

查看私钥
> openssl rsa -in ca/rsa_private.key -noout -text

##### 生成证书 
使用已有RSA私钥生成自签名证书

    req 是证书请求子命令
    -new 指生成证书请求
    -x509 指直接输出证书
    -sha256 使用sha256算法
    -days 证书有效期天数
    -subj "/C=CN/ST=GD/L=SZ/O=Test/OU=dev/CN=Test.com/emailAddress=yy@test.com"
> openssl req -new -x509 -sha256 -days 365 -key ca/rsa_private.key -out ca/mycert.crt

查看证书：
> openssl x509 in cert.crt -noout -text

合成pkcs#12 证书

    -export  指定导出pscs#12证书
    -inkey   指定私钥文件
    -passin  为私钥密码（nodes为无加密）
    -password 指定p12文件的密码

把pem转成pkcs12格式
> openssl pkcs12 -export -in ca/cert.crt -inkey ca/rsa_private.key -out ca/server.p12

把pkcs转成crt
> openssl pkcs12 -in ca/server.p12 -out ca/mycerts.crt -nokeys -clcerts

把crt转成cer
> openssl x509 -inform pem -in ca/mycerts.crt -outform der -out ca/mycerts.cer

