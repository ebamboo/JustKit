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
/// Configuration（全局配置）
/// └── Section（分区）
///     ├── Group（容器）
///     │   ├── Item（基本单元 → Cell）
///     │   │   └── Supplementary（附属视图 → 角标）
///     │   └── Group（嵌套容器）
///     ├── BoundarySupplementary（边界附属视图 → Header / Footer）
///     └── Decoration（装饰视图 → 背景）
/// ```
///
/// - `Item`：最小布局单元，对应一个 Cell，可携带 `Supplementary`（角标/标签）。
/// - `Group`：Item 的容器，按水平或垂直方向排列子元素；支持嵌套以实现复杂布局。
/// - `Section`：核心分区单元，每个 Section 独立定义布局规则、Header/Footer 和背景装饰。
/// - `Configuration`：全局配置，控制滚动方向、Section 间距和全局 Header/Footer。
///
/// ## 典型场景
///
/// - 多 Section 差异化布局（如首页 Banner + 热门 + 商品列表）
/// - Section 级别的正交滚动（横向轮播）
/// - 自适应高度的 Header / Footer（Section 级别或全局级别）
/// - Header 吸顶（`pinToVisibleBounds`）
/// - Cell 角标（`Supplementary`）
/// - Section 背景装饰（`Decoration`）
/// - Group 嵌套实现复合卡片、不等分网格等复杂排列
///
/// ## 基本用法
///
/// ```swift
/// // 1. 构建 Section
/// let section = CompositionalLayout.Section {
///     CompositionalLayout.Group(width: .fractionalWidth(1), height: .absolute(80)) {
///         CompositionalLayout.Item(width: .fractionalWidth(1), height: .fractionalHeight(1))
///     }
/// }
///
/// // 2. 创建布局
/// let layout = UICollectionViewCompositionalLayout { sectionIndex, _ in
///     return section.value
/// }
///
/// // 3. 全局配置
/// layout.configuration = CompositionalLayout.Configuration(scrollDirection: .vertical).value
/// ```
///
/// ## 注意事项
///
/// - 所有类型均为 struct，通过 `configured(_:)` 链式修改属性（值语义拷贝）。
/// - `Supplementary` 和 `BoundarySupplementary` 通过 `UICollectionView` 注册视图；
///   `Decoration` 通过 `UICollectionViewCompositionalLayout` 注册视图。
/// - `kind` 是附属视图的唯一标识，注册和布局中必须保持一致。
/// - Section 的 Group 会被重复使用以填充内容区域，每个 Section 只定义一个 Group。
/// - Result Builder 支持 `if`/`else`、`for...in` 等控制流，可按数据动态构建布局。
public enum CompositionalLayout {
    
    public protocol Element {
        func configured(_ block: (inout Self) -> Void) -> Self
    }
    
    public protocol ItemConvertible: Element {
        associatedtype Value: NSCollectionLayoutItem
        var value: Value { get }
    }
    
}

extension CompositionalLayout.Element {
    
    public func configured(_ block: (inout Self) -> Void) -> Self {
        var copy = self;  block(&copy); return copy
    }
    
}

extension CompositionalLayout {
    
    @resultBuilder
    public struct ElementBuilder<Expression: Element> {
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
    public struct ItemConvertibleBuilder {
        public typealias Expression = any ItemConvertible
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
    
}
