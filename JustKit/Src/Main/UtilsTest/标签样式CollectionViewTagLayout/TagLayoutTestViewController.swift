//
//  Created by 姚旭 on 2022/9/24.
//

import UIKit

class TagLayoutTestViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            let layout = CollectionViewWrapLayout()
//            layout.lineSpacing = 10
//            layout.interitemSpacing = 30
//            layout.itemHeight = 30
//            layout.itemWidthReader { collectionView, indexPath in
//                return CGFloat(Int.random(in: 44...110))
//            }
            
            layout.minimumLineSpacing = 10
            layout.minimumInteritemSpacing = 10
            
//            collectionView.contentInset = .init(top: 0, left: 30, bottom: 0, right: 30)
            
            collectionView.collectionViewLayout = layout
            collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 66
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        cell.backgroundColor = .red
        print(cell.frame.origin)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        .init(width: CGFloat(Int.random(in: 80...200)), height: 30)
    }
}
