# AGENTS.md

## 项目概述

JustKit 是一个 iOS 开发工具集与经验方案合集项目，使用 Swift 编写（部分演示模块含 Objective-C）。项目以示例 App 的形式组织，包含三大模块：**通用工具**（基础扩展与工具类）、**项目工具**（可直接复用的业务组件）和**经验方案**（常见 UI/交互解决方案）。项目本身既是工具库也是对应的演示工程。

## 技术栈

- **语言**: Swift（部分演示含 OC）
- **最低部署版本**: iOS 15.0
- **依赖管理**: CocoaPods
- **核心依赖**:
  - Alamofire — 网络请求
  - SDWebImage — 图片加载
  - MBProgressHUD — HUD 提示

## 项目结构

```
JustKit/
├── AppDelegate.swift              # 应用入口
├── SceneDelegate.swift            # 场景生命周期
├── TabViewController.swift        # 主 Tab 控制器（经验方案 / 项目工具 / 通用工具）
├── JustKit-Bridging-Header.h      # OC 桥接头文件
├── Resource/                      # 资源文件（图片、PDF 等）
└── Source/
    ├── Utils/                     # 通用基础工具（不依赖第三方库，可跨项目直接复用）
    │   ├── Extension/             # UIKit/Foundation 扩展
    │   │   ├── AutoCancellable/   # 统一自动取消机制（store(on:) 模式）
    │   │   │   ├── AutoCancellable.swift          # 核心：AutoCancellable 句柄 + NSObject.autoCancellables 容器
    │   │   │   ├── CADisplayLink+Cancellable.swift
    │   │   │   ├── Notification+Cancellable.swift
    │   │   │   ├── NSKeyValueObservation+Cancellable.swift
    │   │   │   ├── ScriptMessageSubscription+Cancellable.swift
    │   │   │   └── Timer+Cancellable.swift
    │   │   ├── ClosureAdapter/    # Target-Action 闭包化适配器
    │   │   │   ├── CADisplayLink+Closure.swift
    │   │   │   ├── UIBarButtonItem+Closure.swift
    │   │   │   ├── UIControl+Closure.swift
    │   │   │   ├── UIGestureRecognizer+Closure.swift
    │   │   │   └── WKUserContentController+Closure.swift
    │   │   ├── Array+Tools.swift              # 分块 chunked(by:)、稳定去重 removingDuplicates(by:)
    │   │   ├── Codable+Default.swift          # 解码时提供默认值，字段缺失或类型不匹配不崩溃
    │   │   ├── Date+Tools.swift               # 日期字符串互转、日期组件构建、农历转换
    │   │   ├── NSObject+Cancellables.swift    # Combine 订阅容器 objc_cancellables
    │   │   ├── NSObject+Countdown.swift       # 倒计时（后台修正、自动取消、重复调用覆盖）
    │   │   ├── NSObject+Keyboard.swift        # 键盘弹出/收起事件一键订阅
    │   │   ├── String+Sub.swift               # 安全整数下标和范围取子串（越界返回 nil）
    │   │   ├── String+Tools.swift             # 文字尺寸计算、URL 编码
    │   │   ├── String+Verify.swift            # 手机号/身份证/中文验证、通用正则匹配
    │   │   ├── UIColor+Tools.swift            # 十六进制/0-255 创建颜色、RGBA 分量读取、随机颜色
    │   │   ├── UIImage+Generation.swift       # 纯色图片生成、动态外观适配图片、自定义颜色二维码
    │   │   ├── UIImage+Rotation.swift         # 任意角度旋转（可选水平镜像）
    │   │   ├── UIView+ContextMenu.swift       # 声明式上下文菜单（contextMenu 属性赋值即生效）
    │   │   ├── UIView+Stack.swift             # UIStackView 中自定义间距 afterSpacing（@IBInspectable）
    │   │   ├── UIViewController+Child.swift   # 子控制器添加/移除便捷方法
    │   │   └── UIViewController+Present.swift # Alert/ActionSheet/Popover 便捷展示
    │   └── Class/                 # 自定义基础组件
    │       ├── Layout/            # CollectionView 布局
    │       │   ├── CompositionalLayout/  # UICollectionViewCompositionalLayout SwiftUI 风格 DSL 封装
    │       │   │   ├── Configuration.swift   # 全局配置（滚动方向、Section 间距、全局 Header/Footer）
    │       │   │   ├── Element.swift         # 核心协议、@resultBuilder 构建器
    │       │   │   ├── Group.swift           # Group 类型（水平/垂直排列）
    │       │   │   ├── Item.swift            # Item + Supplementary 类型
    │       │   │   └── Section.swift         # Section + Boundary + Decoration 类型
    │       │   ├── GridFlowLayout.swift       # 闭包动态计算 itemSize 的网格布局
    │       │   └── LeftFlowLayout.swift       # 左对齐流式布局（Tag 布局）
    │       ├── Storage/           # 持久化
    │       │   ├── Keychain.swift     # Keychain Services 类型安全封装（增删查改）
    │       │   └── Preference.swift   # UserDefaults @propertyWrapper 属性包装器
    │       ├── View/              # 自定义视图
    │       │   ├── DashLine.swift         # 虚线视图（水平/垂直、可配颜色/长度/间距）
    │       │   ├── GradientBorder.swift   # 渐变色圆角边框（支持暗黑模式自适应）
    │       │   ├── GradientLabel.swift    # 渐变色文字（Core Graphics sourceIn 混合）
    │       │   ├── GradientView.swift     # CAGradientLayer 作为 backing layer 的渐变视图
    │       │   ├── HitAreaButton.swift    # 可配置点击热区的按钮（hitInsets 扩展/收缩）
    │       │   ├── ToggleSwitch.swift     # 仿 UISwitch 自定义开关（自定义尺寸、双态背景色、防抖）
    │       │   └── UnevenCornerView.swift # 四角独立圆角视图
    │       ├── ExecutionLimiter.swift          # 按标识限制任务最大执行次数（线程安全）
    │       └── ModalSlideTransitionDelegate.swift  # 模态上下左右四方向滑动转场代理
    ├── Common/                    # 项目级通用组件（迁移时需少量适配）
    │   ├── HTTP.swift             # 基于 Alamofire 的协议驱动式 HTTP 工具
    │   ├── HTTPConvenience.swift  # HTTP 便捷扩展（业务响应体解析、错误分类）
    │   ├── SSE.swift              # 基于 URLSession 的 Server-Sent Events 会话管理
    │   ├── SSEEvent.swift         # 遵循 WHATWG 规范的 SSE 事件模型与解析
    │   ├── ImageGridView.swift    # 图片网格视图（浏览/编辑模式，高度自适应）
    │   └── UIView+HUD.swift       # 基于 MBProgressHUD 的 Toast 和加载指示器扩展
    └── Module/                    # 功能演示模块
        ├── UtilsTest/             # 通用工具演示
        │   ├── ContextMenu/
        │   ├── Keychain/
        │   ├── ModelAnimator/
        │   ├── Popover弹窗测试/
        │   ├── UICollectionView新布局swiftUI风格封装/
        │   ├── UIImage+Rotation 测试/
        │   ├── 标签样式CollectionViewTagLayout/
        │   ├── 仿UISwitch控件CommonSwitch/
        │   ├── 渐变视图测试/
        │   ├── 渐变圆角边框和渐变文字/
        │   ├── 自定义虚线视图DashView/
        │   └── 自定义UIView每个圆角大小RoundView/
        ├── CommonTest/            # 项目工具演示
        │   └── ImageGridView/
        └── ExperienceTest/        # 经验方案演示
            ├── 单视频播放/
            ├── 视频播放列表/
            ├── 视频图片混合浏览视图/
            │   ├── BBPlayerView/                  # BBPlayerView OC 视频播放组件
            │   └── MediaBrowser/                  # 媒体浏览器组件
            ├── 视频图片混合显示视图/
            │   └── MediaView/                     # 媒体展示组件
            ├── 图片浏览器/
            ├── Bar/
            ├── UICollectionView新布局和数据源/
            ├── UIPageViewController/
            ├── UIScrollView 嵌套/
            ├── UIScrollView包含多输入框键盘UI处理/
            ├── Xib或Storyboard添加Object/
            ├── 评论类似的显示和隐藏输入框/
            ├── 实时检测输入框是否合法/
            ├── 文件预览、打开、分享/
            ├── 系统原生分享/
            ├── 悬浮可滑动按钮/
            ├── 循环动画旋转适配(扫描动画测试)/
            ├── 原生UICollectionView拖动动画/
            ├── 自定义 UICollectionViewFlowLayout/
            ├── 自定义相机旋转-仿系统相机旋转逻辑/
            └── 自定义MainWindow和统一弹窗管理/
```

## Utils — 通用基础工具

不依赖第三方库，可跨项目直接复用。

### Extension/AutoCancellable — 统一自动取消机制

通过 `store(on:)` 模式将订阅/观察者的生命周期绑定到 owner 对象，owner 释放时自动清理。

- `AutoCancellable`：核心句柄类，deinit 时执行 cleanup 闭包
- `NSObject.autoCancellables`：关联对象存储容器
- 覆盖：Timer / CADisplayLink / Notification / NSKeyValueObservation / ScriptMessageSubscription

### Extension/ClosureAdapter — Target-Action 闭包化

通过内部 ClosureProxy + 关联对象实现 target-action 到闭包的桥接。

- `CADisplayLink.init(handler:)` — 闭包初始化
- `UIBarButtonItem.init(title:style:action:)` / `.init(image:style:action:)` — 闭包初始化
- `UIControl.addActionHandler(for:_:)` / `.removeAllActionHandlers(for:)` — 多事件闭包绑定
- `UIGestureRecognizer.init(action:)` / `.addActionHandler(_:)` — 闭包初始化和追加
- `WKUserContentController.addScriptMessageHandler(for:_:)` — JS 消息闭包处理，返回 ScriptMessageSubscription

### Extension — 其他扩展

- `Array+Tools` — chunked(by:) 分块、removingDuplicates(by:) 稳定去重
- `Codable+Default` — 解码带默认值，字段缺失或类型不匹配不抛异常
- `Date+Tools` — 日期字符串互转、日期组件构建、农历日期（六十甲子纪年）
- `NSObject+Cancellables` — Combine 订阅容器 objc_cancellables
- `NSObject+Countdown` — 倒计时（后台修正、自动取消、重复调用覆盖）
- `NSObject+Keyboard` — 键盘弹出/收起一键订阅（KeyboardInfo 封装帧信息/动画参数）
- `String+Sub` — 安全整数下标取子串（越界返回 nil），支持多种 Range 和 sub(at:length:)
- `String+Tools` — 文字高度/宽度计算、RFC 3986 URL 编码
- `String+Verify` — 手机号/18位身份证（含校验码）/中文检测、Rule 通用正则匹配
- `UIColor+Tools` — 0-255 整数/十六进制整数/十六进制字符串创建、RGBA 分量、hexString、随机颜色
- `UIImage+Generation` — 纯色图片、动态外观适配图片（Light/Dark 切换）、自定义颜色二维码
- `UIImage+Rotation` — 任意角度旋转（可选水平镜像），画布自动扩展为外接矩形
- `UIView+ContextMenu` — contextMenu 属性赋值即添加长按上下文菜单
- `UIView+Stack` — afterSpacing 设置 UIStackView 中视图间距（@IBInspectable）
- `UIViewController+Child` — addChild(_:in:layout:) / removeChild / removeSelf
- `UIViewController+Present` — presentAlert / presentSheet / presentPopover（支持隐藏箭头 + onDismiss）

### Class/Layout — CollectionView 布局

- `CompositionalLayout/` — 基于 @resultBuilder 的声明式 DSL，将 NSCollectionLayout 系列类型封装为 SwiftUI 风格 API（Configuration → Section → Group → Item），支持 if/else/for 控制流
- `GridFlowLayout` — 通过闭包动态计算 itemSize，自动适配屏幕旋转和分屏
- `LeftFlowLayout` — 左对齐布局（修正系统默认两端对齐），适用于 Tag 场景

### Class/Storage — 持久化

- `Keychain` — Keychain Services 的类型安全封装，静态方法 data/setData/items/deleteItems，支持 Accessibility 访问策略和同步选项
- `Preference` — @propertyWrapper，wrappedValue 为 Value?，基于 UserDefaults.standard

### Class/View — 自定义视图

- `DashLine` — 虚线视图，水平/垂直方向，@IBInspectable 配置颜色/长度/间距
- `GradientBorder` — 渐变色圆角边框（CAGradientLayer + CAShapeLayer mask），支持暗黑模式
- `GradientLabel` — 渐变色文字 UILabel 子类（Core Graphics sourceIn 混合模式）
- `GradientView` — layerClass 为 CAGradientLayer 的渐变视图
- `HitAreaButton` — hitInsets 控制点击热区（负值外扩、正值内缩）
- `ToggleSwitch` — 仿 UISwitch，继承 UIControl，自定义尺寸/双态背景色/防抖
- `UnevenCornerView` — 四角独立圆角半径（CAShapeLayer mask）

### Class — 其他组件

- `ExecutionLimiter` — 按 label 限制任务最大执行次数，线程安全
- `ModalSlideTransitionDelegate` — 模态滑动转场代理（上/下/左/右四方向，可配 duration 和 animationOptions）

## Common — 项目级工具组件

迁移到其他项目时需做少量源码适配（如替换图片加载库、调整 HUD 实现等）。

### 网络层（HTTP + HTTPConvenience）

基于 Alamofire 的协议驱动式网络工具。

- `HTTPRequest` 协议：定义请求要素（method / url / headers / body）
- `HTTP.Body` 枚举：none / binary / plain / json / form / multipart / fileData / fileURL
- `HTTP.dataRequest` / `uploadRequest` / `downloadRequest`：数据请求、上传、下载
- `HTTPRequestDidFail`：全局请求失败发布者（PassthroughSubject）
- `BusinessBody<T>`：业务响应体模型（code / message / data）
- `BusinessError`：业务错误分类（.business / .decoding / .underlying）
- `HTTP.dataRequestForPayload`：自动解析 + code 校验 + payload 提取

### SSE（SSE + SSEEvent）

基于原生 URLSession 的 Server-Sent Events 实现，无第三方依赖。

- `SSE.dataTask(with:headers:eventHandler:completionHandler:)`：发起 SSE 连接
- `SSEEvent`：遵循 WHATWG 规范的事件模型（event / data / id / retry）
- 事件回调在主线程执行，手动 cancel 不触发 completionHandler
- 缓冲区上限 2MB，超限自动终止

### ImageGridView

基于 UICollectionView 封装的图片网格视图。

- 浏览模式（.browse）和编辑模式（.edit，含添加/删除按钮）
- `Configuration`：间距、图片尺寸计算闭包、添加/删除图标、图片加载器、最大数量
- `ImageSource`：.image(UIImage) / .url(URL)
- intrinsicContentSize 自适应高度，支持 Auto Layout

### UIView+HUD

基于 MBProgressHUD 的 HUD 扩展。

- `showToast(message:detail:duration:completion:)` — 文本提示
- `startLoading(message:detail:)` / `stopLoading()` — 加载指示器

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
