//
//  Created by 姚旭 on 2025/11/29.
//

import Foundation

extension Array {
    
    /// 把数组按照 chunkSize 个元素为一组进行分块
    func chunked(by chunkSize: Int) -> [[Element]] {
        guard !self.isEmpty else { return [] }
        let stride = stride(from: 0, to: self.count, by: chunkSize)
        let chunks = stride.map { startIndex in
            let endIndex = Swift.min(startIndex + chunkSize, count)
            let chunk = self[startIndex..<endIndex]
            return Array(chunk)
        }
        return chunks
    }
    
    /// 去除重复元素，重复的元素保留第一个
    /// 使用指定的 keyPath 属性进行比较
    func removingDuplicates<T: Hashable>(by keyPath: KeyPath<Element, T>) -> [Element] {
        var seen = Set<T>()
        var result: [Element] = []
        forEach { element in
            let value = element[keyPath: keyPath]
            if !seen.contains(value) {
                seen.insert(value)
                result.append(element)
            }
        }
        return result
    }
    
}
