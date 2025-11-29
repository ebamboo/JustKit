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
    
}
