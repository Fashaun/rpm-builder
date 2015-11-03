# 打包 files 成為 rpm

```
$ bash rpm_build_for_files_archive.sh 
Usage> bash rpm_build_for_files_archive.sh SOURCE_DIR RPM_OUTPUT_DIR RPM_PACKAGE_NAME RPM_PACKAGE_VERSION RPM_PACKAGE_VERSION RPM_PACKAGE_INSTALL_DIR
```

```
$ bash rpm_build_for_files_archive.sh /etc/yum.repos.d/ /tmp test-yum 1.0 1 /opt
產出 /tmp/test-yum-1.0-1.noarch.rpm

$ bash bash rpm_build_for_files_archive.sh /etc/nginx/ /tmp test-nginx 1.0 1 /opt
產出 /tmp/test-nginx-1.0-1.noarch.rpm
```

# 安裝測試

```
$ rpm -ivh /tmp/test-yum-1.0-1.noarch.rpm 
正在準備…             ########################################### [100%]
   1:test-yum         ########################################### [100%]
$ ls -R /opt/test-yum/
/opt/test-yum.repos/:
CentOS-Base.repo  CentOS-Debuginfo.repo  CentOS-fasttrack.repo  CentOS-Media.repo  CentOS-Vault.repo  nginx.repo

$ rpm -ivh /tmp/test-nginx-1.0-1.noarch.rpm
正在準備…             ########################################### [100%]
   1:test-nginx             ########################################### [100%]
$ ls -R /opt/test-nginx/
/opt/test-nginx/:
conf.d  mime.types  nginx.conf

/opt/test-nginx/conf.d:
default.conf  example_ssl.conf
```
