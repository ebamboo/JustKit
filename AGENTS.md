# AGENTS.md

## 项目概述

JustKit 是一个 iOS 开发工具集与经验方案合集项目，使用 Swift 编写。项目以示例 App 的形式组织，包含三大模块：**经验方案**（常见 UI/交互解决方案）、**项目工具**（可直接复用的业务组件）和**通用工具**（基础扩展与工具类）。项目本身既是工具库也是对应的演示工程。

## 技术栈

- **语言**: Swift
- **最低部署版本**: iOS 15.0
- **依赖管理**: CocoaPods
- **核心依赖**:
  - Alamofire — 网络请求
  - SDWebImage — 图片加载
  - MBProgressHUD — HUD 提示
  - HandyJSON — JSON 解析
  - BBPlayerView — 视频播放

## 项目结构

```
JustKit/
├── AppDelegate.swift          # 应用入口
├── SceneDelegate.swift        # 场景生命周期
├── TabViewController.swift    # 主 Tab 控制器（经验方案 / 项目工具 / 通用工具）
├── Resource/                  # 资源文件（图片、PDF 等）
└── Source/
    ├── Common/                # 项目级通用组件
    │   ├── HTTP.swift         # 基于 Alamofire 的协议驱动式 HTTP 工具
    │   ├── HTTPConvenience.swift
    │   ├── HTTPOptions.swift
    │   ├── SSE.swift          # Server-Sent Events 会话管理
    │   ├── SSEEvent.swift
    │   ├── MediaBrowser/      # 图片/视频浏览器组件
    │   ├── MediaView/         # 媒体展示视图组件
    │   ├── FlowImageView.swift
    │   ├── NestedScrollView.swift
    │   ├── Stepper.swift
    │   ├── UIView+HUD.swift
    │   └── Macros.swift       # 全局宏/常量
    ├── Utils/                 # 通用基础工具
    │   ├── Extension/         # UIKit/Foundation 扩展（Array、String、UIImage、UIView 等）
    │   └── Foundation/        # 自定义基础组件（布局、动画、渐变、Keychain 等）
    └── Module/                # 功能演示模块
        ├── ExperienceTest/    # 经验方案演示（键盘处理、动画、拖拽、嵌套滚动等）
        ├── CommonTest/        # 项目工具演示（MediaBrowser、MediaView 等）
        └── UtilsTest/        # 通用工具演示（Tag布局、Switch、渐变、Popover 等）
```

## 构建与运行

```bash
# 安装依赖
pod install

# 使用 workspace 打开项目
open JustKit.xcworkspace
```

使用 Xcode 打开 `JustKit.xcworkspace`（非 .xcodeproj），选择模拟器或真机运行即可。

## 开发规范

### 代码风格
- 使用 Swift 原生语法风格，注释使用中文
- 协议驱动设计（如 `HTTPRequest` 协议定义网络请求接口）
- 枚举组织 API 接口，每个 case 对应一个具体接口
- 文件/类命名使用英文，模块文件夹可使用中文描述性命名

### 架构模式
- 网络层：协议 + 枚举模式（`HTTPRequest` 协议 + 枚举实现）
- 组件化：每个通用组件独立文件，通过 Extension 增强系统类
- 演示模块：每个功能方案独立文件夹，包含独立的 ViewController

### 新增功能
- **新增通用工具**: 在 `Source/Utils/Extension/` 或 `Source/Utils/Foundation/` 中添加
- **新增项目组件**: 在 `Source/Common/` 中添加
- **新增经验方案演示**: 在 `Source/Module/ExperienceTest/` 中新建文件夹
- **新增通用工具演示**: 在 `Source/Module/UtilsTest/` 中新建文件夹
- **新增项目组件演示**: 在 `Source/Module/CommonTest/` 中新建文件夹

### 注意事项
- CocoaPods 源使用清华镜像：`https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git`
- 项目使用 `use_frameworks!`，所有 Pod 以动态框架形式引入
- 使用 Bridging Header（`JustKit-Bridging-Header.h`）支持 OC 桥接
