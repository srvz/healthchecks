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
# 创建管理员账户
./manage.py createsuperuser
# 运行
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

