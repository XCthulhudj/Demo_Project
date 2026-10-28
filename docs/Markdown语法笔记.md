# Markdown / GFM 语法笔记

> 整理自「guodongxiaren/README」教程，去掉作者推广部分，按“能不能立刻用”重排。

> 适用范围：GitHub 的 README / Issue / Wiki，以及各类支持 GFM 的编辑器（Typora、Obsidian、VS Code 等）。

---

## 0. 三条通用规则（先记这个）

| 规则 | 说明 |
|---|---|
| **空行** | 块级元素（标题、列表、表格、代码块、引用）前后留一个空行最稳。**表格前面没有空行经常不渲染** |
| **空格** | `#` 后、`-` 后、`1.` 后、`>` 后都必须有空格，少一个就不是语法，只是普通文字 |
| **转义** | 想显示元字符本身，前面加反斜杠，完整清单见第 15 节 |

---

## 1. 标题

**语法**

````
# 一级标题
## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
###### 六级标题
````

也支持 Setext 风格（只有两级，用下划线）：

````
一级标题
========

二级标题
--------
````

**效果**

# 一级标题
## 二级标题
### 三级标题
#### 四级标题
##### 五级标题
###### 六级标题

> 建议一篇文档只用 1 个 `#`，其余从 `##` 开始，层级不要跳。

---

## 2. 段落与换行

| 想要的效果 | 写法 |
|---|---|
| 分成两个段落 | 中间**空一行** |
| 段内换行（行距小） | 上一行末尾加**两个空格**再回车 |
| 段内换行（强制） | 行尾写 `<br>` |
| 强制分两段 | `<br><br>` 或直接空行 |

```markdown
第一行末尾加两个空格··
第二行就换行了，但还在同一段。

直接回车是没用的，
这两行会被拼成一行。
```

直接回车是没用的，
这两行会被拼成一行。

---

## 3. 文字样式

| 语法 | 效果 | 说明 |
|---|---|---|
| `*斜体*` | *斜体* | 星号或下划线都行 |
| `_斜体_` | _斜体_ | |
| `**粗体**` | **粗体** | |
| `__粗体__` | __粗体__ | |
| `***粗斜体***` | ***粗斜体*** | |
| `~~删除线~~` | ~~删除线~~ | GFM 扩展，标准 Markdown 没有 |
| `` `行内代码` `` | `行内代码` | 也常用来做**文字高亮 / tag** |
| `***~~混合~~***` | ***~~混合~~*** | 可以嵌套 |

> **“文字高亮”就是行内代码**：`` `linux` `` `` `socket` `` → `linux` `socket`。原文里说的“高亮”指的就是这个，不是真加背景色。

---

## 4. 分隔线

三种写法等价，效果相同：

```markdown
***
---
___
```

> 用 `---` 时，**上一行如果是文字，会被当成二级标题**（Setext）。想安全就单独一行写，或改用 `***`。

---

## 5. 列表

### 5.1 无序列表

```markdown
* 昵称：果冻虾仁
- 别名：隔壁老王
+ 英文名：Jelly
```

* 昵称：果冻虾仁
- 别名：隔壁老王
+ 英文名：Jelly

### 5.2 有序列表

```markdown
1. 封装
2. 继承
3. 多态
```

> 数字不必连续，全写 `1.` 渲染出来也会自动编号；但为了源码可读，建议老实写序号。

### 5.3 多级列表

```markdown
* 编程语言
  * 脚本语言
    * Python
```

* 编程语言
  * 脚本语言
    * Python

> 缩进用 **2 或 4 个空格**（同一篇里保持一致）；**用 Tab 有时会失效**，尤其是嵌套三层以上。

### 5.4 任务列表（复选框）

```markdown
- [x] 需求分析
- [x] 系统设计
- [ ] 编码
- [ ] 测试
```

- [x] 需求分析
- [x] 系统设计
- [ ] 编码
- [ ] 测试

> 在 GitHub 的 **Issue / PR** 里可以直接点击勾选；README 里只能显示状态，点不了。

---

## 6. 引用

```markdown
> 一级引用
>> 二级引用
>>> 三级引用
```

> 一级引用
>> 二级引用
>>> 三级引用

引用里可以放**任何东西**（列表、代码、标题），只要每行都以 `>` 开头：

```markdown
> **标题**
> - 列表项
> - 列表项
```

> **标题**
> - 列表项
> - 列表项

---

## 7. 代码

### 7.1 行内代码

```markdown
`printf("hello")`
```

`printf("hello")`

> 要显示一个反引号本身，就用**两个**反引号把它夹住，例如 `` `` ` `` `` 会显示成 `` ` ``。

### 7.2 代码块（缩进式）

行首加 **4 个空格或 1 个 Tab**（太容易出错，不推荐）：

    hello
    这一块是缩进式代码

### 7.3 代码块（围栏式，推荐）

````
```python
def hello():
    print("hi")
```
````

```python
def hello():
    print("hi")
```

> 代码块内部要再套一层围栏时，外层改用 **四个反引号** 包住即可。

### 7.4 语法高亮

在围栏后面写语言名：`python` `c` `cpp` `java` `js` `bash` `json` `yaml` `sql` `html` `xml` `powershell`……

```bash
echo "hello GitHub"
```

```cpp
std::string &operator+(const std::string& a, const std::string& b);
```

### 7.5 diff 语法（GFM）

````
```diff
+ 新增的一行
- 删除的一行
! 修改的一行
# 注释
```
````

```diff
+ 人闲桂花落，
- 夜静春山空。
! 月出惊山鸟，
# 时鸣春涧中。
```

---

## 8. 表格

### 8.1 基本写法

```markdown
| 表头1 | 表头2 |
| ----- | ----- |
| 单元  | 单元  |
```

| 表头1 | 表头2 |
| ----- | ----- |
| 单元  | 单元  |

> 前后都要有**空行**；单元里的 `|` 要写成 `\|`；列宽不用对齐，源码乱一点不影响渲染。

### 8.2 对齐

```markdown
| 左对齐 | 居中 | 右对齐 |
| :----- | :--: | -----: |
| a      | b    |      1 |
```

| 左对齐 | 居中 | 右对齐 |
| :----- | :--: | -----: |
| a      | b    |      1 |

### 8.3 单元格里混其他语法

**粗体**、*斜体*、~~删除线~~、`代码`、[链接](#8-表格) 都能用：

| 名字 | 描述 |
| --- | --- |
| Help | ~~Display the~~ help window. |
| Close | _Closes_ a window |

> 表格里**不能**放多行内容（换行会断表）。需要多行就用 `<br>`。

---

## 9. 链接

### 9.1 行内式（最常用）

```markdown
[我的博客](https://blog.csdn.net/guodongxiaren "悬停显示的文字")
```

[我的博客](https://blog.csdn.net/guodongxiaren "悬停显示的文字")

### 9.2 引用式（URL 统一放文末，适合复用）

```markdown
正文里写：[我的知乎][zhihu]

文末定义：
[zhihu]: https://www.zhihu.com/people/guodongxiaren "我的知乎"
```

正文里写：[我的知乎][zhihu]

[zhihu]: https://www.zhihu.com/people/guodongxiaren "我的知乎"

> 好处：同一个链接多处引用、只改一处；正文也更干净。标识符随便起（字母/数字），**大小写不敏感**。

### 9.3 自动链接

```markdown
<https://github.com>
```

<https://github.com>

> GFM 里裸 URL（`https://…`）也会自动变成链接；但用 `<>` 包起来最保险。

### 9.4 链接本仓库文件（相对路径）

```markdown
[我的简介](./example/profile.md)
[示例目录](./example)
```

> 相对路径**大小写敏感**（Linux 上尤其），别写错；指向目录时结尾可以不带 `/`。

### 9.5 锚点（跳到本文某处）

```markdown
[回到顶部](#markdown--gfm-语法笔记)
[跳到表格](#8-表格)
```

[跳到表格](#8-表格)

> 规则：标题文字转成小写、空格变 `-`、英文标点去掉；**中文标题现在 GitHub 也支持**了。
> 但跨平台（Typora/VS Code/某些博客）不一定一致，最稳的是手写锚点：
> `<a id="mytarget"></a>` + `[跳到](#mytarget)`。

---

## 10. 图片

### 10.1 基本写法

```markdown
![百度logo](http://www.baidu.com/img/bdlogo.gif "百度logo")
```

![百度logo](http://www.baidu.com/img/bdlogo.gif "百度logo")

- `alt`：图片加载失败时显示的文字，也影响 SEO / 无障碍
- `title`：鼠标悬停提示，**必须加引号**
- 引用本仓库图片用相对路径：`![](./img/logo.png)`
- 引用别人仓库的图：`https://github.com/用户/仓库/raw/分支/路径.png`

### 10.2 图片链接（点图片跳转）

```markdown
[![百度logo](http://www.baidu.com/img/bdlogo.gif)](https://www.baidu.com)
```

[![百度logo](http://www.baidu.com/img/bdlogo.gif)](https://www.baidu.com)

外层是链接、内层是图片。也可以都用引用式，写起来最清爽：

```markdown
[![weibo-logo]][weibo]
```

### 10.3 控制图片大小（用 HTML）

```markdown
<img src="logo.png" width="120" alt="logo">
```

> 纯 Markdown 语法**没法**控制尺寸，必须用 `<img>`；GitHub 会保留 `width`/`height`，但会过滤 `style`。

---

## 11. GFM 扩展（GitHub 专属）

### 11.1 任务列表 / 删除线

已在第 3、5 节讲过：`~~删除~~`、`- [x] 已完成`。

### 11.2 Alerts（提示框，5 种）

````
> [!NOTE]
> 提示信息

> [!TIP]
> 技巧

> [!IMPORTANT]
> 重要

> [!WARNING]
> 警告

> [!CAUTION]
> 危险
````

> [!NOTE]
> 提示信息

> [!TIP]
> 技巧

> [!IMPORTANT]
> 重要

> [!WARNING]
> 警告

> [!CAUTION]
> 危险

> 必须 `> [!NOTE]` **单独一行**，后面每一行都要以 `>` 开头；不支持的渲染器里会退化成普通引用。

### 11.3 Emoji

```markdown
:smile: :rocket: :warning: :+1:
```

:smile: :rocket: :warning: :+1:

> 符号码查 [emoji-cheat-sheet](https://github.com/ikatyang/emoji-cheat-sheet)；也可以直接粘 Unicode 表情 🙂。

### 11.4 脚注（部分渲染器支持）

```markdown
正文里加个脚注[^1]。

[^1]: 这里是脚注内容。
```

正文里加个脚注[^1]。

[^1]: 这里是脚注内容。

### 11.5 数学公式（GitHub 支持）

```markdown
行内 $E = mc^2$，独立公式：

$$
\int_0^1 x^2\,dx = \frac{1}{3}
$$
```

行内 $E = mc^2$

---

## 12. 常用 HTML 补充

### 12.1 折叠（details / summary）

```html
<details>
<summary>点击展开：Linux 环境</summary>

##### 编译
xxxx

##### 安装
xxxx

</details>
```

<details>
<summary>点击展开：Linux 环境</summary>

##### 编译
xxxx

##### 安装
xxxx

</details>

### 12.2 居中

```html
<div align="center">

| 表头1 | 表头2 |
| --- | --- |
| 单元 | 单元 |

</div>
```

<div align="center">

| 表头1 | 表头2 |
| --- | --- |
| 单元 | 单元 |

</div>

> 表格、图片、任何一段内容都能用 `<div align="center">` 包起来居中。

### 12.3 其他好用的标签

| 标签 | 用途 | 例子 |
|---|---|---|
| `<br>` | 强制换行 | |
| `<kbd>` | 按键样式 | <kbd>Ctrl</kbd> + <kbd>C</kbd> |
| `<sub>` / `<sup>` | 下标 / 上标 | H<sub>2</sub>O，x<sup>2</sup> |
| `<img width="100">` | 图片尺寸 | |
| `<details>` | 折叠 | 见上 |

> GitHub 会**过滤** `<script>`、`<style>`、`class`、`id`（除 `<a id>` 外）等，别指望写太花的东西。

---

## 13. 其他实用组件

### 13.1 徽章（shields.io）

```markdown
![LICENSE](https://img.shields.io/badge/license-MIT-green)
![Author](https://img.shields.io/badge/Author-guodongxiaren-blue.svg)
```

![LICENSE](https://img.shields.io/badge/license-MIT-green)
![Author](https://img.shields.io/badge/Author-guodongxiaren-blue.svg)

> 站点：<https://shields.io>，改 `label-message-color` 三段即可。

### 13.2 目录（TOC）

- GitHub 会自动给 README 生成目录（页面左上角菜单键），**不用手写**；
- 其他平台可以用 `[TOC]`，或手写链接列表（本文件开头那种）。

### 13.3 Star 历史

```markdown
[![Star History Chart](https://api.star-history.com/svg?repos=用户/仓库&type=Date)](https://star-history.com/#用户/仓库&Date)
```

---

## 14. 易错点清单（踩过才知道）

| 现象 | 原因 | 解法 |
|---|---|---|
| 表格没变成表格 | 前面缺空行 | 表格上一行留空 |
| `#` 标题没生效 | 井号后没空格 | `# 标题`，不是 `#标题` |
| 列表嵌套乱掉 | 缩进用了 Tab 或空格数不一致 | 统一 2 或 4 个空格 |
| 列表后面接的文字被吞进列表 | 缺空行 | 列表后空一行再写 |
| 下划线把上一行变成大标题 | `---` 触发了 Setext | 换成 `***`，或前面空行 |
| 删除线不生效 | 渲染器不支持 GFM | 换平台，或改用 `<del>` |
| 中文锚点跳不过去 | 平台差异 | 手写 `<a id="x"></a>` |
| 代码块被里面的三反引号截断 | 围栏冲突 | 外层改用四个反引号 |
| 图片不显示 | 相对路径大小写错 / 私有仓库需要 token | 检查大小写，或换成绝对 URL |
| 表格里出现竖线（断列） | 竖线没转义 | 写成 `\|`（反斜杠转义） |
| HTML 样式无效 | GitHub 过滤 `style`/`class` | 只用 `align`、`width` 这类白名单属性 |

---

## 15. 需要转义的字符

```
\   `   *   _   {   }   [   ]   (   )   #   +   -   .   !   |   >   ~   <   :   &
```

> 实际只有会引起歧义时才需要转义；比如正文里写 `C:\path`、`a*b*c`、`#tag`。

---

## 16. 最小可用 README 模板

````markdown
# 项目名

一句话说明它是干什么的。

![badge](https://img.shields.io/badge/license-MIT-green)

## 特性
- 特性一
- 特性二

## 安装
```bash
npm install xxx
```

## 用法
```python
import xxx
xxx.run()
```

## 目录结构
| 路径 | 说明 |
| --- | --- |
| `src/` | 源码 |
| `docs/` | 文档 |

## 许可
MIT
````

---

## 附：一页速查

| 想做什么 | 写什么 |
|---|---|
| 标题 | `## 标题` |
| 粗体 / 斜体 / 删除线 | `**b**` `*i*` `~~s~~` |
| 行内代码 | `` `code` `` |
| 代码块 | 三个反引号 + 语言名，如 `py` |
| 引用 | `> 引用` |
| 无序 / 有序 | `- 项` / `1. 项` |
| 任务列表 | `- [x] 完成` |
| 表格 | `\| a \| b \|` + `\| --- \| --- \|` |
| 链接 | `[文字](url "title")` |
| 图片 | `![alt](url "title")` |
| 图片链接 | `[![alt](img)](url)` |
| 分隔线 | `---` 或 `***` |
| 折叠 | `<details><summary>标题</summary>…</details>` |
| 提示框 | `> [!NOTE]` + 每行 `>` |
| 换行 | 行尾两个空格，或 `<br>` |
