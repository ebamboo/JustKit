//
//  Created by 姚旭 on 2025/11/28.
//

import Foundation

enum HomeSection {
    case banner
    case hot
    case shop
}

enum HomeItem {
    case banner(BannerModel)
    case hot(HotModel)
    case shop(ShopModel)
}

struct BannerModel {
    let id: Int
}

struct HotModel {
    let id: Int
}

struct ShopModel {
    let id: Int
}
