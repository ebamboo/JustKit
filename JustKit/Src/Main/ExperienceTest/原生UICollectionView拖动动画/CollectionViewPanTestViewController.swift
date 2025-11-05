//
//  Created by 姚旭 on 2021/12/20.
//

import UIKit

///
/// UICollectionView 原生的拖动重排 api
/// 第一步：给 UICollectionView 添加 UIPanGestureRecognizer 事件（一般会设有专门的控制是否可移动控件）
/// 第二步：在 UIPanGestureRecognizer 事件中，UICollectionView 调用 move 相关的方法（详情请查看本示例）
/// 第三步：实现 UICollectionViewDataSource 关于move的方法来控制是否能移动以及移动对应的数据源操作
///
class CollectionViewPanTestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView!
    var imageNames: [String]!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageNames = (1...8).map({ i in
            return String(format: "%02ld", i)
        })
        
        collectionView.register(UINib(nibName: "PanTestCollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "PanTestCollectionViewCell")
        
        // 添加 UIPanGestureRecognizer 手势
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(sender:)))
        collectionView.addGestureRecognizer(pan)
    }

    // 手势方法
    @objc func panAction(sender: UIPanGestureRecognizer) {
        let position = sender.location(in: collectionView)
        switch sender.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: position) {
                collectionView.beginInteractiveMovementForItem(at: indexPath)
            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(position)
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    // ==================== 
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let content = imageNames[sourceIndexPath.item]
        imageNames.remove(at: sourceIndexPath.item)
        imageNames.insert(content, at: destinationIndexPath.item)
    }
    // ====================
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageNames.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PanTestCollectionViewCell", for: indexPath) as! PanTestCollectionViewCell
        cell.testImageView.image = UIImage(named: imageNames[indexPath.item])
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let w = (collectionView.bounds.width - 20)/3
        return CGSize(width: w, height: w)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }

    // 一些可选的有意思的动画效果
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.1) {
          cell.transform = CGAffineTransform.identity.scaledBy(x: 0.8, y: 0.8)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else { return }
        UIView.animate(withDuration: 0.1) {
          cell.transform = CGAffineTransform.identity
        }
    }
    
}
