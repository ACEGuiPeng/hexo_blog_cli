---
title: SQLAlchemy不完全指南
tags: [sqlalchemy,guide]
toc: true
comment: false
date: 2019-01-20 11:58:21
permalink:
categories: guide
description:
image:
---
<img src="sqlalchemy-guide/952555-20160729110817044-661804168.png" alt="" style="width:100%" />

<!-- more -->

<hr />

## 1 ORM
### 1.1 定义
ORM（Object Relational Mapping,对象关系映射）
1. Object，对象
面向对象思想

2. Relational，关系
关系型数据库的数据关系

3. Mapping，映射
对象与表结构之间的对应关系

### 1.2 三个核心原则
1. 简单
以最简单的方式建模

2. 传达性
数据库结构文档化

3. 精确性
基于数据模型创建正确标准化的结构

## 2 基础语法
### 2.1 数据库连接
#### 2.1.1 样例代码
```python
#!/usr/bin/env python
# encoding: utf-8
from sqlalchemy import create_engine
from sqlalchemy.pool import QueuePool


def get_new_connection():
    new_engine = create_engine('mysql+pymysql://root:123456@192.168.0.213/test?charset=utf8', encoding='utf-8',
                               echo=True, poolclass=QueuePool, pool_pre_ping=True, pool_size=256, max_overflow=256)
    return new_engine

```
#### 2.1.2 参数解释
| 参数  |  样例  |  作用  |
| :------------: | :------------: | :------------ |
|  echo  |  True/False |  是否在控制台输出sql语句  |
| poolclass | QueuePool | 连接池类型 |
| pool_pre_ping | True | 连接在使用前先测试(Tips：V1.2新特性) |
|pool_size| 256 | 连接池大小，默认5 |
| max_overflow | 256 | 允许连接溢出的大小，默认10 |

#### 2.1.3 对比SQL
```SQL
mysql -h 192.168.213 -uroot -p123456 --database review_db
```

### 2.2 描述表结构
#### 2.2.1 样例代码
```python
#!/usr/bin/env python
# encoding: utf-8
from datetime import datetime

from sqlalchemy import Integer, create_engine, Column, String, Enum, Text, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.pool import QueuePool

new_engine = create_engine('mysql+pymysql://root:123456@192.168.0.213/test?charset=utf8', encoding='utf-8',
                           echo=True, poolclass=QueuePool, pool_pre_ping=True, pool_size=256, max_overflow=256)
Base = declarative_base()


class ManualReportUpload(Base):
    __tablename__ = 'manual_report_upload'
    id = Column(Integer, primary_key=True, autoincrement=True)
    site = Column(String(16), default='')
    type = Column(Enum(['a', 'b', 'c']), index=True, nullable=False)
    file_path = Column(Text())
    create_date = Column(DateTime(), default=datetime.now)
    modify_date = Column(DateTime(), onupdate=datetime.now)

```
#### 2.2.2 参数解释
| 参数  |  样例  |  作用  |
| :------------: | :------------: | :------------ |
|  echo  |  True/False |  是否在控制台输出sql语句  |
| poolclass | QueuePool | 连接池类型 |
| pool_pre_ping | True | 连接在使用前先测试(Tips：V1.2新特性) |
|pool_size| 256 | 连接池大小，默认5 |
| max_overflow | 256 | 允许连接溢出的大小，默认10 |

###  2.3 关系描述
#### 2.3.1 一对一
##### 样例代码
```python
#!/usr/bin/env python
# encoding: utf-8

from sqlalchemy import Integer, create_engine, Column, String, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.pool import QueuePool

new_engine = create_engine('mysql+pymysql://root:123456@192.168.0.213/test?charset=utf8', encoding='utf-8',
                           echo=True, poolclass=QueuePool, pool_pre_ping=True, pool_size=256, max_overflow=256)
Base = declarative_base()


class User(Base):
    __tablename__ = 'user'

    id = Column(Integer, primary_key=True)
    username = Column(String(64), nullable=False, index=True)
    password = Column(String(64), nullable=False)
    email = Column(String(64), nullable=False, index=True)
    userinfo = relationship('UserInfo', backref='user', uselist=False)


class UserInfo(Base):
    __tablename__ = 'user_info'

    id = Column(Integer, primary_key=True)
    name = Column(String(64))
    qq = Column(String(11))
    phone = Column(String(11))
    link = Column(String(64))
    user_id = Column(Integer, ForeignKey('user.id'))

```
#### 2.3.2 一对多
##### 样例代码
```python
#!/usr/bin/env python
# encoding: utf-8

from sqlalchemy import Integer, create_engine, Column, String, ForeignKey, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.pool import QueuePool

new_engine = create_engine('mysql+pymysql://root:123456@192.168.0.213/test?charset=utf8', encoding='utf-8',
                           echo=True, poolclass=QueuePool, pool_pre_ping=True, pool_size=256, max_overflow=256)
Base = declarative_base()


class User(Base):
    __tablename__ = 'user'

    id = Column(Integer, primary_key=True)
    username = Column(String(64), nullable=False, index=True)
    password = Column(String(64), nullable=False)
    email = Column(String(64), nullable=False, index=True)
    articles = relationship('Article', backref='author')


class Article(Base):
    __tablename__ = 'article'

    id = Column(Integer, primary_key=True)
    title = Column(String(255), nullable=False, index=True)
    content = Column(Text)
    user_id = Column(Integer, ForeignKey('user.id'))

```

#### 2.3.3 多对多
##### 样例代码
```python
# !/usr/bin/env python
# encoding: utf-8

from sqlalchemy import Integer, create_engine, Column, String, ForeignKey, Table, Text
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.pool import QueuePool

new_engine = create_engine('mysql+pymysql://root:123456@192.168.0.213/test?charset=utf8', encoding='utf-8',
                           echo=True, poolclass=QueuePool, pool_pre_ping=True, pool_size=256, max_overflow=256)
Base = declarative_base()
article_tag = Table(
    'article_tag', Base.metadata,
    Column('article_id', Integer, ForeignKey('article.id')),
    Column('tag_id', Integer, ForeignKey('tag.id'))
)


class Article(Base):
    __tablename__ = 'article'

    id = Column(Integer, primary_key=True)
    title = Column(String(255), nullable=False, index=True)
    content = Column(Text)
    user_id = Column(Integer, ForeignKey('user.id'))


class Tag(Base):
    __tablename__ = 'tag'

    id = Column(Integer, primary_key=True)
    name = Column(String(64), nullable=False, index=True)

```
多对多需要定义成**两个一对多**

### 2.4 创建表
#### 样例代码
```python
#!/usr/bin/env python
# encoding: utf-8
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.pool import QueuePool

Base = declarative_base()


def create_tables():
    new_engine = create_engine('mysql+pymysql://root:123456@192.168.0.213/test?charset=utf8', encoding='utf-8',
                               echo=True, poolclass=QueuePool, pool_pre_ping=True, pool_size=256, max_overflow=256)

    Base.metadata.create_all(new_engine)

```

## 3 表操作
### 3.1 查询
#### 3.1.1 普通查询
```python
ret = session.query(Users).all()
ret = session.query(Users.name, Users.extra).all()
ret = session.query(Users).filter_by(name='alex').all()
ret = session.query(Users).filter_by(name='alex').first()
```
#### 3.1.2 条件查询
```python
ret = session.query(Users).filter_by(name='alex').all()
ret = session.query(Users).filter(Users.id > 1, Users.name == 'eric').all()
ret = session.query(Users).filter(Users.id.between(1, 3), Users.name == 'eric').all()
ret = session.query(Users).filter(Users.id.in_([1,3,4])).all()
ret = session.query(Users).filter(~Users.id.in_([1,3,4])).all()
ret = session.query(Users).filter(Users.id.in_(session.query(Users.id).filter_by(name='eric'))).all()
from sqlalchemy import and_, or_
ret = session.query(Users).filter(and_(Users.id > 3, Users.name == 'eric')).all()
ret = session.query(Users).filter(or_(Users.id < 2, Users.name == 'eric')).all()
ret = session.query(Users).filter(
    or_(
        Users.id < 2,
        and_(Users.name == 'eric', Users.id > 3),
        Users.extra != ""
    )).all()
```
#### 3.1.3 模糊查询
```python
ret = session.query(Users).filter(Users.name.like('e%')).all()
ret = session.query(Users).filter(~Users.name.like('e%')).all()
```
#### 3.1.4 分组
```python
from sqlalchemy.sql import func

ret = session.query(Users).group_by(Users.extra).all()
ret = session.query(
    func.max(Users.id),
    func.sum(Users.id),
    func.min(Users.id)).group_by(Users.name).all()

ret = session.query(
    func.max(Users.id),
    func.sum(Users.id),
    func.min(Users.id)).group_by(Users.name).having(func.min(Users.id) >2).all()

```
#### 3.1.5 排序
```python
ret = session.query(Users).order_by(Users.name.desc()).all()
```
#### 3.1.6 分页
```python
ret = session.query(Users).order_by(Users.name.desc()).limit(page_size).offset(page_index)
```
#### 3.1.7 连表查询
```python
ret = session.query(Users, Favor).filter(Users.id == Favor.nid).all()
ret = session.query(Person).join(Favor).all()
ret = session.query(Person).join(Favor, isouter=True).all()
```
#### 3.1.8 联合查询
```python
q1 = session.query(Users.name).filter(Users.id > 2)
q2 = session.query(Favor.caption).filter(Favor.nid < 2)
ret = q1.union(q2).all()

q1 = session.query(Users.name).filter(Users.id > 2)
q2 = session.query(Favor.caption).filter(Favor.nid < 2)
ret = q1.union_all(q2).all()
```
### 3.2 添加
```python
obj = Users(name="alex0", password='123')
session.add(obj)
session.add_all([
    Users(name="alex1", password='456'),
    Users(name="alex2", password='789'),
])
session.commit()
```
### 3.3 更新
```python
session.query(Users).filter(Users.id > 2).update({"name" : "099"},synchronize_session="fetch")
session.query(Users).filter(Users.id > 2).update({Users.name: Users.name + "099"}, synchronize_session=False)
session.query(Users).filter(Users.id > 2).update({"num": Users.num + 1}, synchronize_session="evaluate")
session.commit()
```
### 3.4 删除
```python
session.query(Users).filter(Users.id > 2).delete()
session.commit()
```
## 4 多线程场景下使用（前后台）
### 场景1：前端查询，后台插入
当后台插入数据时，前端查询要插入的数据，此时出现这个错误

```python
Traceback (most recent call last):
  File "src/api/customer/manual_review_search.py", line 44, in get
  File "src/mysqls/manual_review.py", line 97, in select_manual_review_record
  File "sqlalchemy/orm/query.py", line 3223, in count
  File "sqlalchemy/orm/query.py", line 2976, in scalar
  File "sqlalchemy/orm/query.py", line 2947, in one
  File "sqlalchemy/orm/query.py", line 2917, in one_or_none
  File "sqlalchemy/orm/query.py", line 2988, in __iter__
  File "sqlalchemy/orm/query.py", line 3009, in _execute_and_instances
  File "sqlalchemy/orm/query.py", line 3018, in _get_bind_args
  File "sqlalchemy/orm/query.py", line 3000, in _connection_from_session
  File "sqlalchemy/orm/session.py", line 1035, in connection
  File "sqlalchemy/orm/session.py", line 1040, in _connection_for_bind
  File "sqlalchemy/orm/session.py", line 409, in _connection_for_bind
  File "sqlalchemy/engine/base.py", line 2123, in contextual_connect
  File "sqlalchemy/engine/base.py", line 2162, in _wrap_pool_connect
  File "sqlalchemy/engine/base.py", line 1476, in _handle_dbapi_exception_noconnection
  File "sqlalchemy/util/compat.py", line 265, in raise_from_cause
  File "sqlalchemy/util/compat.py", line 248, in reraise
  File "sqlalchemy/engine/base.py", line 2158, in _wrap_pool_connect
  File "sqlalchemy/pool.py", line 403, in connect
  File "sqlalchemy/pool.py", line 821, in _checkout
  File "sqlalchemy/engine/default.py", line 476, in do_ping
  File "pymysql/cursors.py", line 170, in execute
  File "pymysql/cursors.py", line 328, in _query
  File "pymysql/connections.py", line 516, in query
  File "pymysql/connections.py", line 727, in _read_query_result
  File "pymysql/connections.py", line 1066, in read
  File "pymysql/connections.py", line 670, in _read_packet
sqlalchemy.exc.InternalError: (pymysql.err.InternalError) 
Packet sequence number wrong - got 128 expected 1 (Background on this error at: http://sqlalche.me/e/2j85)

```
### 原因
google查出是因为pymysql不支持多线程（电梯：https://github.com/PyMySQL/PyMySQL/issues/425） 

### 场景2：多线程/多进程共享engine
其中一个线程完成了插入，有时会导致另外一个线程丢失连接，错误如下

```python
The above exception was the direct cause of the following exception:

Traceback (most recent call last):
  File "src/api/partner/partner_file_uploader.py", line 37, in get
  File "contextlib.py", line 77, in __exit__
  File "src/wrappers/mysql_wrapper.py", line 47, in session_scope
  File "sqlalchemy/orm/session.py", line 907, in rollback
  File "sqlalchemy/orm/session.py", line 532, in rollback
  File "sqlalchemy/util/compat.py", line 249, in reraise
  File "sqlalchemy/orm/session.py", line 497, in rollback
  File "sqlalchemy/engine/base.py", line 1632, in rollback
  File "sqlalchemy/engine/base.py", line 1670, in _do_rollback
  File "sqlalchemy/engine/base.py", line 706, in _rollback_impl
  File "sqlalchemy/engine/base.py", line 1413, in _handle_dbapi_exception
  File "sqlalchemy/util/compat.py", line 265, in raise_from_cause
  File "sqlalchemy/util/compat.py", line 248, in reraise
  File "sqlalchemy/engine/base.py", line 704, in _rollback_impl
  File "sqlalchemy/dialects/mysql/base.py", line 1777, in do_rollback
  File "pymysql/connections.py", line 432, in rollback
  File "pymysql/connections.py", line 396, in _read_ok_packet
  File "pymysql/connections.py", line 656, in _read_packet
  File "pymysql/connections.py", line 702, in _read_bytes
sqlalchemy.exc.OperationalError: (pymysql.err.OperationalError) 
(2013, 'Lost connection to MySQL server during query') (Background on this error at: http://sqlalche.me/e/e3q8)
```
### 原因
google查出是因为mysql的session与connection是一一对应的，当其中一个session关闭的时候，connection也会关闭。如果另外一个线程使用了相同的的connection，就会导致丢失连接

### 导致现象的代码

```python
class MysqlWrapper(object):
    def __init__(self):
        self.session_maker = None
        self.engine = None
        self.session = None
        self.scope_session = None

    def create_tables(self, base):
        try:
            log.info('creating sql tables.')
            base.metadata.create_all(self.engine)
        except Exception as e:
            log.error('create tables failed {}'.format(str(e)))

    # 主要问题代码
    def connect_mysql(self):
        try:
            self.engine = create_engine('{}?charset=utf8'.format(SETTING.URL_MYSQL),
                                        encoding=COMMON_CONST.CODE_UTF8, echo=SETTING.SQL_ECHO_SHOW,
                                        poolclass=QueuePool, pool_pre_ping=True, pool_size=SETTING.POOL_SIZE,
                                        max_overflow=SETTING.MAX_OVERFLOW) # 客户端建立与mysql server的connection
            self.session_maker = sessionmaker(bind=self.engine) # session factory绑定connection

        except Exception as e:
            log.exception(str(e))
            raise e

    def get_session(self) -> Session:
        return scoped_session(self.session_maker)() # session factory 返回thread local safe session对象

    @contextlib.contextmanager
    def session_scope(self):
        new_session = None
        try:
            new_session = self.get_session()
            yield new_session
            new_session.commit()
        except Exception as e:
            new_session.rollback()
            raise e
        finally:
            if new_session:
                new_session.close() # session关闭 session返回connection的session池
    # 主要问题代码结束
```

## 解决方案
简单来讲，就是一个线程分配一个connection,使得线程之间连接互不影响,修正后的代码如下

```python
class MysqlWrapper(object):
    def __init__(self):
        self.web_engine = None
        self.back_engine = None

    def create_tables(self, base):
        try:
            log.info('creating sql tables.')
            base.metadata.create_all(self.web_engine)
        except Exception as e:
            log.error('create tables failed {}'.format(str(e)))

    def connect_mysql(self):
        try:
            self.web_engine = self.get_new_connection()
            self.back_engine = self.get_new_connection()
        except Exception as e:
            log.exception(str(e))
            raise e

    def get_session(self, is_web: bool) -> Session:
        if is_web:
            session_maker = sessionmaker(self.web_engine)
        else:
            session_maker = sessionmaker(self.back_engine)

        session = scoped_session(session_maker)
        return session()

    @staticmethod
    def get_new_connection():
        new_engine = create_engine('{}?charset=utf8'.format(SETTING.URL_MYSQL),
                                   encoding=COMMON_CONST.CODE_UTF8, echo=SETTING.SQL_ECHO_SHOW,
                                   poolclass=QueuePool, pool_pre_ping=True, pool_size=SETTING.POOL_SIZE,
                                   max_overflow=SETTING.MAX_OVERFLOW)
        return new_engine

    @contextlib.contextmanager
    def session_scope(self, is_web=False):
        new_session = None
        try:
            new_session = self.get_session(is_web)
            yield new_session
            new_session.commit()
        except Exception as e:
            new_session.rollback()
            raise e
        finally:
            if new_session:
                new_session.close()
```
