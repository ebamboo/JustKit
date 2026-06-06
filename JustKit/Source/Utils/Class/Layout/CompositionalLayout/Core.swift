//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

/// `UICollectionViewCompositionalLayout` 的声明式 DSL 封装。
///
/// 基于 `@resultBuilder` 将原生 `NSCollectionLayout*` 系列类型封装为
/// 可嵌套、声明式的 DSL，用更直观的层级结构替代命令式的布局代码。
///
/// ## 层级结构
///
/// ```
/// LayoutConfiguration（全局配置）
/// └── LayoutSection（分区）
///     ├── LayoutGroup（容器）
///     │   ├── LayoutItem（基本单元 → Cell）
///     │   │   └── LayoutSupplementary（附属视图 → 角标）
///     │   └── LayoutGroup（嵌套容器）
///     ├── LayoutBoundary（边界附属视图 → Header / Footer）
///     └── LayoutDecoration（装饰视图 → 背景）
/// ```
///
/// - `LayoutItem`：最小布局单元，对应一个 Cell，可携带 `LayoutSupplementary`（角标/标签）。
/// - `LayoutGroup`：Item 的容器，按水平或垂直方向排列子元素；支持嵌套以实现复杂布局。
/// - `LayoutSection`：核心分区单元，每个 Section 独立定义布局规则、Header/Footer 和背景装饰。
/// - `LayoutConfiguration`：全局配置，控制滚动方向、Section 间距和全局 Header/Footer。
///
/// ## 典型场景
///
/// - 多 Section 差异化布局（如首页 Banner + 热门 + 商品列表）
/// - Section 级别的正交滚动（横向轮播）
/// - 自适应高度的 Header / Footer（Section 级别或全局级别）
/// - Header 吸顶（`pinToVisibleBounds`）
/// - Cell 角标（`LayoutSupplementary`）
/// - Section 背景装饰（`LayoutDecoration`）
/// - Group 嵌套实现复合卡片、不等分网格等复杂排列
///
/// ## 基本用法
///
/// ```swift
/// // 1. 构建 Section
/// let section = LayoutSection {
///     LayoutGroup(width: .fractionalWidth(1), height: .absolute(80)) {
///         LayoutItem(width: .fractionalWidth(1), height: .fractionalHeight(1))
///     }
/// }
///
/// // 2. 创建布局
/// let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
///     return section.value
/// }
///
/// // 3. 全局配置
/// layout.configuration = LayoutConfiguration(scrollDirection: .vertical).value
/// ```
///
/// ## 注意事项
///
/// - 所有类型均为 struct，通过 `configured(_:)` 链式修改属性（值语义拷贝）。
/// - `LayoutSupplementary` 和 `LayoutBoundary` 通过 `UICollectionView` 注册视图；
///   `LayoutDecoration` 通过 `UICollectionViewCompositionalLayout` 注册视图。
/// - `kind` 是附属视图的唯一标识，注册和布局中必须保持一致。
/// - Section 的 Group 会被重复使用以填充内容区域，每个 Section 只定义一个 Group。
/// - Result Builder 支持 `if`/`else`、`for...in` 等控制流，可按数据动态构建布局。

public protocol LayoutElement {}
public extension LayoutElement {
    func configured(_ block: (inout Self) -> Void) -> Self {
        var copy = self;  block(&copy); return copy
    }
}

public protocol LayoutItemConvertible: LayoutElement {
    associatedtype Value: NSCollectionLayoutItem
    var value: Value { get }
}

@resultBuilder
public struct LayoutElementBuilder<Expression: LayoutElement> {
    public typealias Component = [Expression]
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
    public static func buildBlock() -> Component {
        []
    }
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }
    public static func buildEither(first component: Component) -> Component {
        component
    }
    public static func buildEither(second component: Component) -> Component {
        component
    }
    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }
}

@resultBuilder
public struct LayoutItemConvertibleBuilder {
    public typealias Expression = any LayoutItemConvertible
    public typealias Component = [Expression]
    public static func buildExpression(_ expression: Expression) -> Component {
        [expression]
    }
    public static func buildBlock() -> Component {
        []
    }
    public static func buildBlock(_ components: Component...) -> Component {
        components.flatMap { $0 }
    }
    public static func buildOptional(_ component: Component?) -> Component {
        component ?? []
    }
    public static func buildEither(first component: Component) -> Component {
        component
    }
    public static func buildEither(second component: Component) -> Component {
        component
    }
    public static func buildArray(_ components: [Component]) -> Component {
        components.flatMap { $0 }
    }
}
