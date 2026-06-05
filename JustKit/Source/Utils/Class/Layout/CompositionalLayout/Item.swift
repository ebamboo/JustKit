//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

// MARK: - Supplementary

extension CompositionalLayout {
    
    /// Item 级别的附属视图，附着在单个 Item（Cell）上，常用于角标、标签、未读数等装饰。
    ///
    /// 通过 `alignment` 指定在 Item 上的锚点位置，通过 `offset` 微调偏移。
    /// Supplementary 不参与 Item 的布局计算，仅覆盖在 Item 之上，不会撑开或影响 Item 的尺寸。
    ///
    /// **视图注册：**
    /// 使用 `UICollectionView.register(_:forSupplementaryViewOfKind:withReuseIdentifier:)` 注册，
    /// `kind` 须与布局中传入的 `kind` 一致；
    /// 在 `dataSource.supplementaryViewProvider` 或
    /// `collectionView(_:viewForSupplementaryElementOfKind:at:)` 中提供视图。
    ///
    /// **注意事项：**
    /// - `kind` 在同一个 Item 内不可重复，否则会布局异常。
    /// - `zIndex` 默认为 0，若需要角标显示在其他 Supplementary 之上，可适当调高。
    public struct Supplementary: Element {
        
        public enum Offset {
            case absolute(CGPoint)
            case fractional(CGPoint)
        }
        
        public let layoutSize: NSCollectionLayoutSize
        public let kind: String
        public let alignment: NSDirectionalRectEdge
        public let offset: Offset // 对齐之后，进行偏移; 只会影响位置，不会影响 cell 布局；
        
        public var contentInsets: NSDirectionalEdgeInsets = .zero
        public var zIndex: Int = 0
        
        public init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            kind: String,
            alignment: NSDirectionalRectEdge,
            offset: Offset = .absolute(.zero)
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.kind = kind
            self.alignment = alignment
            self.offset = offset
        }
        
        public var value: NSCollectionLayoutSupplementaryItem {
            let containerAnchor: NSCollectionLayoutAnchor = {
                switch offset {
                case .absolute(let point):
                    return .init(edges: alignment, absoluteOffset: point)
                case .fractional(let point):
                    return .init(edges: alignment, fractionalOffset: point)
                }
            }()
            let result = NSCollectionLayoutSupplementaryItem(
                layoutSize: layoutSize,
                elementKind: kind,
                containerAnchor: containerAnchor
            )
            result.contentInsets = contentInsets
            result.zIndex = zIndex
            return result
        }
        
    }
    
}

// MARK: - Item

extension CompositionalLayout {
    
    public struct Item: ItemConvertible {
        
        public let layoutSize: NSCollectionLayoutSize
        public let supplementaries: [Supplementary]
        
        public var contentInsets: NSDirectionalEdgeInsets = .zero
        
        public init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.supplementaries = []
        }
        
        public init(
            width: NSCollectionLayoutDimension,
            height: NSCollectionLayoutDimension,
            @ElementBuilder<Supplementary> supplementaries: () -> [Supplementary]
        ) {
            self.layoutSize = .init(widthDimension: width, heightDimension: height)
            self.supplementaries = supplementaries()
        }
        
        public var value: NSCollectionLayoutItem {
            let result = NSCollectionLayoutItem(
                layoutSize: layoutSize,
                supplementaryItems: supplementaries.map({ $0.value })
            )
            result.contentInsets = contentInsets
            return result
        }
        
    }
    
}