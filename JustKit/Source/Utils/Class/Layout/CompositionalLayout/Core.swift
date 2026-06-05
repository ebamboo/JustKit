//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

public enum CompositionalLayout {
    
    /// 遵循该协议的类型须为 struct；
    /// configured 默认实现通过 var copy = self 值拷贝来实现不可变调用链，class 类型无法正确拷贝。
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