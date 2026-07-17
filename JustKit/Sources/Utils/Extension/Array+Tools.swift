//
//  Created by 姚旭 on 2025/11/29.
//

import Foundation

public extension Array {
    
    /// 按固定大小分块，例如 [1,2,3,4,5].chunked(by: 2) -> [[1,2],[3,4],[5]]
    /// - Parameter chunkSize: 每块的元素数量，必须大于 0
    func chunked(by chunkSize: Int) -> [[Element]] {
        guard chunkSize > 0, !isEmpty else { return [] }
        return Swift.stride(from: 0, to: count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, count)])
        }
    }
    
    /// 稳定去重：按指定 keyPath 去除重复元素，仅保留首次出现的元素，结果保持原数组的相对顺序
    /// - Parameter keyPath: 用于判断重复的属性路径，对应类型需遵循 Hashable
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        return filter { seen.insert($0[keyPath: keyPath]).inserted }
    }
    
}
