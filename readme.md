# 说明

让天下没有难做的GLPI！


* 使用镜像：	php:7.3-apache
				mysql:5.7
* 使用GLPI版本:	9.4.5经典版
* 其他中文优化项如下：
	locale/zh_CN.UTF-8
	TIMEZONE: Asia/Shanghai
* 容器内glpi目录权限：	chown -R www-data:www-data
* 容器内GLPI计划任务：	glpi_cron

* 出品：GLPI中国爱好者交流群：1097440406
* By:老天@281388879
* 容器: https://github.com/leangjia/glpi-docker-cn
* GLPI 官方网站: https://glpi-project.org/
* GLPI 官方文档: https://glpi-install.readthedocs.io/en/latest/install/index.html
* GLPI 稳定版: https://github.com/glpi-project/glpi/releases



# 步骤

**第一步**

    ```
    $ cp .env.example .env
    $ cp .mysql.env.example .mysql.env      # 留意修改mysql的账号和密码
    $ docker-compose build
    Successfully built 1e8b04b73dbd
    Successfully tagged glpi-production:latest
    $ docker-compose up -d
    $ docker container ls | grep glpi
    CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                               NAMES
    450ca3617c50        glpi-production     "docker-php-entrypoi…"   7 minutes ago       Up 7 minutes        0.0.0.0:80->80/tcp, 443/tcp         glpi
    b9b87da7aa14        mysql:5.7           "docker-entrypoint.s…"   7 minutes ago       Up 7 minutes        0.0.0.0:3306->3306/tcp, 33060/tcp   mysql-glpi
    ```


**第二步**

* 打开谷歌或火狐浏览器（IE可能会丢失样式）并访问网址 http://localhost 或参考官方文档 [installation steps](https://glpi-install.readthedocs.io/en/latest/install/index.html#installation).

    ```
    参考.mysql.env文件设置数据库参数
    在中文界面数据库地址填写容器名mysql-glpi（英文界面SQL server (MariaDB or MySQL) ）: mysql-glpi
    在数据库账号填写（SQL user）: root
    数据库密码SQL password: zh@CN
    ```

* 可选步骤：删除install安装文件，为安全起见，生产环境必须删除install安装文件 [remove installation file](https://glpi-install.readthedocs.io/en/latest/install/index.html#post-installation).

    ```
    $ docker exec -it 450ca3617c50 /bin/bash -c "rm /var/www/html/glpi/install/install.php"
    ```



# 其他资料：GLPI 环境要求

https://glpi-install.readthedocs.io/en/latest/prerequisites.html

# 其他资料：GLPI 版本

* [glpi](https://github.com/glpi-project/glpi/releases)
* [mysql:5.7](https://hub.docker.com/_/mysql)


# 其他资料：

**Apache2 配置文件**

* ``containers/apache2/``

**php.ini配置文件**

* ``containers/php/conf.d/``

**GLPI 源码打补丁的方法**

* ``patches/``

  ```
  $ ls
  glpi_official/  glpi_original/
  $ diff -u glpi_official/inc/somecode.php glpi_original/inc/somecode.php > inc-somecode.php.patch
  ```

**插件安装命令如下**

* Copy to ``/var/www/html/glpi/plugins/`` 

  ```
  $ wget https://github.com/pluginsGLPI/ocsinventoryng/releases/download/1.6.0/glpi-ocsinventoryng-1.6.0.tar.gz
  $ tar -xzf glpi-ocsinventoryng-1.6.0.tar.gz
  $ ls
  ocsinventoryng/
  $ docker cp ocsinventoryng/ glpi:/var/www/html/glpi/plugins/
  $ docker exec -it glpi chown -R www-data: /var/www/html/glpi/plugins/ocsinventoryng
  ```

**自定义添加语言包**

* 用poedit工具软件新建 po 和 mo 文件，将这两个文件复制到glpi的locales目录 ``/var/www/html/glpi/locales`` .例如：

  ```
  $ docker cp zh_CN.mo glpi:/var/www/html/glpi/locales/
  $ docker cp zh_CN.po glpi:/var/www/html/glpi/locales/
  ```

**数据恢复操作：恢复 MySQL 的 dump 备份文件**

* 恢复方法

  ```
  $ cp xxx.sql ./dump/
  $ docker exec -it glpi /bin/bash -c "mysql -uroot -p${PASSWD} ${DBNAME} < /tmp/xxx.sql"
  ```
