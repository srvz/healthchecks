## 开发环境
```
git clone https://github.com/healthchecks/healthchecks.git
cd healthchecks
python3 -m venv hc-venv
source hc-venv/bin/activate
pip install -r requirements.txt
```

## 运行
```
# 初始化数据库
./manage.py migrate
# 创建管理员账户，可创建多个
./manage.py createsuperuser
# 运行，调试时使用此方式
./manage.py runserver
```

## 构建基础镜像
构建基础镜像可以节省很多后续修改重新构建发布镜像的时间

```
docker build -f Base.dockerfile -t srvz/healthchecks:base .
```

## 构建发布镜像

```
docker build -t srvz/healthchecks:v1.18 .
```

## 运行

参考 `/script/deploy.sh`

## 根据配置生成条目，同时同步到 zookeeper，未配置 zookeeper 地址则不同步

参考 `script/create-checks.js` `script/conf.example.js`

```
npm i node-zookeeper-client healthchecks-io-client
mkdir tmp
cp script/conf.example.js conf.js
node script/create-checks.js tmp/conf.example.js
```