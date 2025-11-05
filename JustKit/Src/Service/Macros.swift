//
//  Created by 姚旭 on 2021/4/21.
//

import UIKit

let systemVersion = UIDevice.current.systemVersion
let appVersion = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String

let homePath = NSHomeDirectory()
let documentsPath = homePath + "/Documents"
let cachesPath = homePath + "/Library/Caches"

var screenWidth: CGFloat { UIScreen.main.bounds.size.width }
var screenHeight: CGFloat { UIScreen.main.bounds.size.height }

var deviceWidth: CGFloat { min(screenWidth, screenHeight) }
var deviceHeight: CGFloat { max(screenWidth, screenHeight) }
