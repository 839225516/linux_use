## nginx常用配置  ##

#### 1)后端反向代理及负载均衡  ####
``` conf
upstream static_code {
	server 172.20.6.20:9088;
}   

server {
	listen 80; 
	server_name mftest.jlpay.com;

	location / { 
		proxy_pass http://static_code;
		proxy_redirect off;
		proxy_set_header Host $http_host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto http;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_connect_timeout 60s;
		proxy_read_timeout 120s;
	}   
} 
```

#### 2)证书配置  #####
``` conf
server {
	listen 443 ssl default backlog=4096;
	server_name test.test.com;
	charset utf-8;
	proxy_ignore_client_abort on;

	ssl on;
	ssl_certificate      ssl/xxxx.crt;
	ssl_certificate_key  ssl/xxxx.key;
	ssl_session_timeout  5m;
	ssl_protocols        SSLv3 TLSv1.2;
	ssl_ciphers          HIGH:!ADH:!EXPORT56:RC4+RSA:+MEDIUM;
	ssl_prefer_server_ciphers   on;

	location / {
		proxy_pass http://upstream;
		proxy_redirect off;
		proxy_set_header Host $http_host;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
		proxy_set_header X-Forwarded-Proto https;
		proxy_set_header X-Real-IP $remote_addr;
		proxy_connect_timeout 60s;
		proxy_read_timeout 120s;
	}
}
```

#### 3)http正向代理  ####
```conf
server {
	listen       8880;
	location / {
		proxy_pass  http://$host$request_uri;
		proxy_set_header Host $host;
		proxy_set_header X-Real-IP  $remote_addr;
		proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
   }
}
```

#### 4)文件弹窗下载  #####
``` conf
location ~*.(txtpdf|doc|xls)$ {
	add_header Content-Disposition "attachment;";
}
```