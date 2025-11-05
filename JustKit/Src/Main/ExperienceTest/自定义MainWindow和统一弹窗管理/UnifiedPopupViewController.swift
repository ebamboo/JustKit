//
//  Created by 姚旭 on 2025/10/7.
//

import UIKit
import Combine

class UnifiedPopupViewController: UIViewController {

    struct TestConfig {
        var name: String
        var priority: Int
        var time: TimeInterval
    }
    
    var configList: [TestConfig] = [
        TestConfig(name: "a", priority: 100, time: 1),
        TestConfig(name: "b", priority: 200, time: 2),
        TestConfig(name: "c", priority: 300, time: 3),
        TestConfig(name: "d", priority: 250, time: 4),
        TestConfig(name: "e", priority: 200, time: 5)
    ]
    
    lazy var popupViews: [BasePopupView] = configList.map { config in
        let pop = TestPopupView()
        pop.titleLabel.text = config.name
        pop.priority = config.priority
        return pop
    }
    
    var index = 0
    
    var set: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tempList = configList.sorted { item1, item2 in
            if item1.priority < item2.priority { return true }
            if item1.priority == item2.priority { return item1.time < item2.time }
            return false
        }
        tempList.forEach { item in
            print(item)
        }
        
        Timer.publish(every: 2, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] date in
                print("统一弹窗", date)
                guard let self, let window = self.view.window as? MainWindow else { return }
                guard self.index < self.popupViews.count else { return }
                let popupView = self.popupViews[self.index]
                window.popup(popupView)
                self.index += 1
            }
            .store(in: &set)
    }
    
}
