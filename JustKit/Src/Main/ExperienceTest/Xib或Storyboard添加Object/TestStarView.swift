//
//  Created by 姚旭 on 2022/8/8.
//

import UIKit


class TestStarView: UIView {

    var topImageView: UIImageView = {
        let imgV = UIImageView()
        imgV.frame = CGRect(x: 10, y: 10, width: 60, height: 60)
        imgV.clipsToBounds = true
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    var testLabel: UILabel = {
        let label = UILabel()
        label.frame = CGRect(x: 100, y: 10, width: 60, height: 60)
        return label
    }()
    var bottomImageView: UIImageView = {
        let imgV = UIImageView()
        imgV.frame = CGRect(x: 200, y: 10, width: 60, height: 60)
        imgV.clipsToBounds = true
        imgV.contentMode = .scaleAspectFill
        return imgV
    }()
    
    // =============================
    
    @IBOutlet private var config: TestConfigModel! {
        didSet {
            commonInit()
        }
    }
    
    // =============================
    
    init(frame: CGRect, config: TestConfigModel) {
        self.config = config // 初始化时不会调用 didSet
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func commonInit() {
        addSubview(topImageView)
        addSubview(testLabel)
        addSubview(bottomImageView)
        
        topImageView.image = config.topImage
        testLabel.text = "\(config.num)"
        bottomImageView.image = config.bottomImage
    }

}
