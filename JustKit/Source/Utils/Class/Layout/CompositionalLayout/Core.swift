//
//  Created by 姚旭 on 2025/11/29.
//

import UIKit

enum CompositionalLayout {
    
    protocol Element {
        func configured(_ block: (inout Self) -> Void) -> Self
    }
    
    protocol ItemConvertible: Element {
        associatedtype Value: NSCollectionLayoutItem
        var value: Value { get }
    }
    
}

extension CompositionalLayout.Element {
    
    func configured(_ block: (inout Self) -> Void) -> Self {
        var copy = self;  block(&copy); return copy
    }
    
}

extension CompositionalLayout {
    
    @resultBuilder
    struct ElementBuilder<Expression: Element> {
        
        typealias Component = [Expression]
        
        static func buildExpression(_ expression: Expression) -> Component {
            [expression]
        }
        
        static func buildBlock() -> Component {
            []
        }
        
        static func buildBlock(_ components: Component...) -> Component {
            components.flatMap { $0 }
        }
        
        static func buildOptional(_ component: Component?) -> Component {
            component ?? []
        }
        
        static func buildEither(first component: Component) -> Component {
            component
        }
        
        static func buildEither(second component: Component) -> Component {
            component
        }
        
        static func buildArray(_ components: [Component]) -> Component {
            components.flatMap { $0 }
        }
        
    }
    
    @resultBuilder
    struct ItemConvertibleBuilder {
        
        typealias Expression = any ItemConvertible
        typealias Component = [Expression]
        
        static func buildExpression(_ expression: Expression) -> Component {
            [expression]
        }
        
        static func buildBlock() -> Component {
            []
        }
        
        static func buildBlock(_ components: Component...) -> Component {
            components.flatMap { $0 }
        }
        
        static func buildOptional(_ component: Component?) -> Component {
            component ?? []
        }
        
        static func buildEither(first component: Component) -> Component {
            component
        }
        
        static func buildEither(second component: Component) -> Component {
            component
        }
        
        static func buildArray(_ components: [Component]) -> Component {
            components.flatMap { $0 }
        }
        
    }
    
}
