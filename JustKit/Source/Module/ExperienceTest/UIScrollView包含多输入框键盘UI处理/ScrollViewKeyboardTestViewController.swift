//
//  Created by 姚旭 on 2025/10/11.
//

import UIKit
import Combine

class ScrollViewKeyboardTestViewController: UIViewController {
    
    @IBOutlet weak var scrollView: UIScrollView! {
        didSet {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    @IBOutlet weak var contentStack: UIStackView!
    
    var activeInputView: UIView? {
        for subview in contentStack.arrangedSubviews {
            if subview.isFirstResponder {
                return subview
            }
        }
        return nil
    }
    
    var keyboardInfo: (isDocked: Bool, frame: CGRect) = (false, .zero)
    
    var set: Set<AnyCancellable> = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { [weak self] notification in
                guard let userInfo = notification.userInfo,
                      let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else { return }
                self?.keyboardInfo = (true, frame)
                self?.adaptForKeyboard()
            }
            .store(in: &set)
        
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
            .sink { [weak self] notification in
                self?.keyboardInfo = (false, .zero)
                self?.adaptForKeyboard()
            }
            .store(in: &set)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adaptForKeyboard()
    }

    func adaptForKeyboard() {
        if let activeInputView, keyboardInfo.isDocked {
            
            let inputFrame = scrollView.convert(activeInputView.bounds, from: activeInputView)
            let keyboardFrame = scrollView.convert(keyboardInfo.frame, from: UIScreen.main.coordinateSpace)
            let intersection = scrollView.bounds.intersection(keyboardFrame)
            let spacing = intersection.minY - inputFrame.maxY
            
            // 1 先设置 contentInset 以适应键盘
            scrollView.contentInset = .init(top: 0, left: 0, bottom: intersection.height, right: 0)
            
            // 2 视条件是否需要调整 contentOffset
            if spacing < 0 {
                let currentOffset = scrollView.contentOffset
                let newOffset: CGPoint = .init(x: currentOffset.x, y: currentOffset.y + abs(spacing))
                scrollView.contentOffset = newOffset
            }
            
        } else {
            
            // 1 先恢复 contentInset 以恢复适应键盘引起的 inset
            scrollView.contentInset = .zero
            
            // 2 视条件是否需要调整 contentOffset
            let currentOffset = scrollView.contentOffset
            let maxOffsetY = max(0, scrollView.contentSize.height - scrollView.bounds.height)
            if currentOffset.y > maxOffsetY {
                scrollView.contentOffset = .init(x: currentOffset.x, y: maxOffsetY)
            }
            
        }
    }

}
