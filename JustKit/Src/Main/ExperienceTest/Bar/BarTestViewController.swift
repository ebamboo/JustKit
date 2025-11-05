//
//  Created by 姚旭 on 2021/4/12.
//

import UIKit

class BarTestViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemTeal
        let label = UILabel()
        label.frame = .init(x: 100, y: 100, width: 200, height: 32)
        label.text = "详见 BarReaderController"
        view.addSubview(label)
    }
    
}

class BarReaderController: UITabBarController {
   
    // MARK: - life circle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNaviBar()
        self.setupTabBar()
    }
    
    // MARK: - 设置导航栏
    func setupNaviBar() {
        
        /// 设置 navigationBar
        /// translucent: 导航栏是否透明; barTintColor: 导航栏颜色（背景）; tintColor: 导航栏痕迹颜色
        /// 注意：痕迹颜色会作用在系统自带的 barButtonItem 上，如字体颜色，图片颜色（可通过设置 render 为 UIImageRenderingModeAlwaysOriginal 避免痕迹颜色的影响）。不会作用在标题上
        /// 一般通过修改 backgroundImage 来改变 navigationBar/tabBar 颜色。
        UINavigationBar.appearance().isTranslucent = true
//        UINavigationBar.appearance().barTintColor = UIColor.init(red: 0.3, green: 0.9, blue: 0.6, alpha: 1.0)
        UINavigationBar.appearance().tintColor = UIColor.orange
        
        /// 设置导航栏标题
        UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.systemPink,
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.medium)
        ]
        
        /// 设置导航栏返回按钮
        /// 或图片文字组合，或单独的图片，一般不存在单独文字
        /// 注意1：不需要文字时，通过 setBackButtonTitlePositionAdjustment 方法把文字置在屏幕外
        /// 注意2：返回图规格 @3x 66*66 @2x 44*44 @1x 22*22 时可以通过水平offset隐藏标题，并保持返回图垂直居中，title按钮不会占用位置
        ///       返回图规格 @3x 132*132 @2x 88*88 @1x 44*44 时可以通过垂直offset隐藏标题，并保持返回图垂直居中，title按钮还会占用位置
        ///       推荐使用 @1x 22 规格方式，因为不会占用返回按钮位置
        /// 注意3：自定义返回图片必须同时设置 backIndicatorImage 和 backIndicatorTransitionMaskImage
        UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffset.init(horizontal: -9999, vertical: 0.0), for: .default)
        UINavigationBar.appearance().backIndicatorImage = UIImage(named: "navigation-item-back")
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage(named: "navigation-item-back")
        
        /// 去除分割线
        UINavigationBar.appearance().shadowImage = UIImage()
    }
    
    // MARK: - 设置分栏
    func setupTabBar() {
        /// 添加子视图控制器到 UITabBarController 中，并设置 tabBarItem 对应的标题、图片。
        /// 注意1：self.navigationItem.title--sets navigation bar title.
        ///       self.tabBarItem.title--sets tab bar title.
        ///       self.title--sets both of these.
        /// 注意2：图片大小必须遵守规则，@3x 90*90，@2 60*60， @1 30*30
        let itemVCs = [UIViewController(), UIViewController()]
        let itemTitles = ["主页", "我的"]
        let itemImages = ["tabbar-item-home", "tabbar-item-mine"]
        for i in 0...1 {
            let itemVC = itemVCs[i]
            itemVC.tabBarItem.title = itemTitles[i]
            itemVC.tabBarItem.image = UIImage.init(named: itemImages[i])
            let itemNavi = UINavigationController.init(rootViewController: itemVC)
            self.addChild(itemNavi)
        }
        
        /// 设置 tabBar
        /// translucent: 标签栏是否透明; barTintColor: 标签栏颜色（背景）; tintColor: 标签栏痕迹颜色
        /// 注意：痕迹颜色默认是标题和图片选中的颜色，图片可以设置 Render 为 UIImageRenderingModeAlwaysOriginal 取消痕迹颜色渲染，展示原图效果
        self.tabBar.isTranslucent = true
//        self.tabBar.barTintColor = UIColor.orange
        self.tabBar.tintColor = UIColor.systemPink
        
        /// 通过 UITabBarItem、UIBarItem 设置关心的 UITabBarItem 属性如：设置 UITabBarItem 的 font
//        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: UIFont.systemFont(ofSize: 19)], for: .normal)
        
        /// 去除分割线
//        UITabBar.appearance().shadowImage = UIImage.init()
    }

}
