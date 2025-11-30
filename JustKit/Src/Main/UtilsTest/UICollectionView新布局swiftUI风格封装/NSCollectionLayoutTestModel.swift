//
//  Created by 姚旭 on 2025/11/28.
//

import Foundation

enum HomeSection {
    case banner
    case hot
    case shop
}

enum HomeItem: Hashable {
    case banner(BannerModel)
    case hot(HotModel)
    case shop(ShopModel)
}

struct BannerModel: Hashable {
    let id: Int
}

struct HotModel: Hashable {
    let id: Int
}

struct ShopModel: Hashable {
    let id: Int
}
