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
  - BBPlayerView — 视频播放

## 项目结构

```
JustKit/
├── AppDelegate.swift              # 应用入口
├── SceneDelegate.swift            # 场景生命周期
├── TabViewController.swift        # 主 Tab 控制器（经验方案 / 项目工具 / 通用工具）
├── Resource/                      # 资源文件（图片、PDF 等）
└── Source/
    ├── Common/                    # 项目级通用组件（迁移时需少量适配）
    │   ├── HTTP.swift             # 基于 Alamofire 的协议驱动式 HTTP 工具
    │   ├── HTTPConvenience.swift  # HTTP 便捷扩展
    │   ├── SSE.swift              # Server-Sent Events 会话管理
    │   ├── SSEEvent.swift         # SSE 事件模型
    │   ├── ImageGridView.swift    # 图片网格视图（浏览/编辑模式，高度自适应）
    │   ├── UIView+HUD.swift       # 基于 MBProgressHUD 的 HUD 扩展
    │   ├── MediaBrowser/          # 图片/视频浏览器组件
    │   └── MediaView/             # 媒体展示视图组件
    ├── Utils/                     # 通用基础工具（跨项目直接复用）
    │   ├── Extension/             # UIKit/Foundation 扩展
    │   │   ├── AutoCancellable/   # 统一可取消订阅协议（Timer、Notification、KVO、CADisplayLink 等）
    │   │   ├── ClosureAdapter/    # Target-Action 闭包化适配器（UIControl、UIGestureRecognizer、UIBarButtonItem 等）
    │   │   ├── Array+Tools.swift
    │   │   ├── Codable+Default.swift
    │   │   ├── Date+Tools.swift
    │   │   ├── NSObject+Cancellables.swift
    │   │   ├── NSObject+Countdown.swift
    │   │   ├── NSObject+Keyboard.swift
    │   │   ├── String+Sub.swift
    │   │   ├── String+Tools.swift
    │   │   ├── String+Verify.swift
    │   │   ├── UIColor+Tools.swift
    │   │   ├── UIImage+Generation.swift
    │   │   ├── UIImage+Rotation.swift
    │   │   ├── UIImage+Thumbnail.swift
    │   │   ├── UIStackView+Tools.swift
    │   │   ├── UIView+ContextMenu.swift
    │   │   ├── UIView+Layout.swift
    │   │   ├── UIView+Stack.swift
    │   │   ├── UIViewController+Child.swift
    │   │   └── UIViewController+Present.swift
    │   └── Class/                 # 自定义基础组件
    │       ├── Layout/            # CollectionView 布局
    │       │   ├── CompositionalLayout/  # UICollectionViewCompositionalLayout SwiftUI 风格封装
    │       │   ├── GridFlowLayout.swift  # 网格流式布局
    │       │   └── LeftFlowLayout.swift  # 左对齐流式布局（Tag 布局）
    │       ├── Storage/           # 持久化
    │       │   ├── Keychain.swift     # Keychain 存取封装
    │       │   └── Preference.swift   # UserDefaults 属性包装器
    │       ├── View/              # 自定义视图
    │       │   ├── DashLine.swift         # 虚线视图
    │       │   ├── GradientBorder.swift   # 渐变圆角边框
    │       │   ├── GradientLabel.swift    # 渐变文字
    │       │   ├── GradientView.swift     # 渐变视图
    │       │   ├── HitAreaButton.swift    # 可扩展点击区域的按钮
    │       │   ├── ToggleSwitch.swift     # 自定义开关控件
    │       │   └── UnevenCornerView.swift # 不等圆角视图
    │       ├── ExecutionLimiter.swift     # 执行限流器（节流/防抖）
    │       └── ModalSlideTransitionDelegate.swift  # 模态滑动转场代理
    └── Module/                    # 功能演示模块
        ├── ExperienceTest/        # 经验方案演示
        │   ├── Bar/
        │   ├── UICollectionView新布局和数据源/
        │   ├── UIPageViewController/
        │   ├── UIScrollView 嵌套/
        │   ├── UIScrollView包含多输入框键盘UI处理/
        │   ├── Xib或Storyboard添加Object/
        │   ├── 评论类似的显示和隐藏输入框/
        │   ├── 实时检测输入框是否合法/
        │   ├── 文件预览、打开、分享/
        │   ├── 系统原生分享/
        │   ├── 悬浮可滑动按钮/
        │   ├── 循环动画旋转适配(扫描动画测试)/
        │   ├── 原生UICollectionView拖动动画/
        │   ├── 自定义 UICollectionViewFlowLayout/
        │   ├── 自定义相机旋转-仿系统相机旋转逻辑/
        │   └── 自定义MainWindow和统一弹窗管理/
        ├── CommonTest/            # 项目工具演示
        │   ├── ImageGridView/
        │   ├── MediaBrowser/
        │   └── MediaView/
        └── UtilsTest/             # 通用工具演示
            ├── ContextMenu/
            ├── Keychain/
            ├── ModelAnimator/
            ├── Popover弹窗测试/
            ├── UICollectionView新布局swiftUI风格封装/
            ├── UIImage+Rotation 测试/
            ├── 标签样式CollectionViewTagLayout/
            ├── 仿UISwitch控件CommonSwitch/
            ├── 渐变视图测试/
            ├── 渐变圆角边框和渐变文字/
            ├── 自定义虚线视图DashView/
            └── 自定义UIView每个圆角大小RoundView/
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

### 组件定位
- `Source/Common/`：项目级工具组件，迁移到其他项目时需做少量源码适配（如替换图片加载库、调整 HUD 实现等）
- `Source/Utils/`：通用基础工具，不依赖第三方库，可跨项目直接复用

### 新增功能
- **新增通用扩展**: 在 `Source/Utils/Extension/` 中添加
- **新增通用组件**: 在 `Source/Utils/Class/` 对应子目录中添加（Layout / Storage / View）
- **新增项目组件**: 在 `Source/Common/` 中添加
- **新增经验方案演示**: 在 `Source/Module/ExperienceTest/` 中新建文件夹
- **新增通用工具演示**: 在 `Source/Module/UtilsTest/` 中新建文件夹
- **新增项目组件演示**: 在 `Source/Module/CommonTest/` 中新建文件夹

### 注意事项
- CocoaPods 源使用清华镜像：`https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git`
- 项目使用 `use_frameworks!`，所有 Pod 以动态框架形式引入
- 使用 Bridging Header（`JustKit-Bridging-Header.h`）支持 OC 桥接
