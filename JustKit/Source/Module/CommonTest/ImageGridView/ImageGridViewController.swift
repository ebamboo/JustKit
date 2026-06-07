//
//  Created by 姚旭 on 2021/11/27.
//

import UIKit

class ImageGridViewController: UIViewController {

    private lazy var gridView: ImageGridView = {
        var config = ImageGridView.Configuration()
        config.contentInsets = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        config.spacing = 12
        config.imageSizeProvider = { gridView in
            let columns: CGFloat = 4
            let insets = gridView.configuration.contentInsets
            let spacing = gridView.configuration.spacing
            let totalSpacing = insets.left + insets.right + spacing * (columns - 1)
            let side = floor((gridView.bounds.width - totalSpacing) / columns)
            return CGSize(width: side, height: side)
        }
        config.addIcon = UIImage(named: "bb-image-addition")
        config.deleteIcon = UIImage(named: "bb-image-deletion")
        config.maximumImageCount = 13
        
        let view = ImageGridView(frame: .zero, configuration: config)
        view.backgroundColor = .systemGroupedBackground
        return view
    }()

    private lazy var modeSwitch: UISegmentedControl = {
        let control = UISegmentedControl(items: ["浏览", "编辑"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(modeChanged), for: .valueChanged)
        return control
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "ImageGridView"
        view.backgroundColor = .systemBackground

        view.addSubview(modeSwitch)
        modeSwitch.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            modeSwitch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            modeSwitch.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        gridView.backgroundColor = .gray
        view.addSubview(gridView)
        gridView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gridView.topAnchor.constraint(equalTo: modeSwitch.bottomAnchor, constant: 20),
            gridView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            gridView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        gridView.didTapAddButton = { [weak self] in
            guard let self else { return }
            let image = ImageGridView.ImageSource.image(UIImage(named: "16")!)
            self.gridView.appendImages([image])
        }
        gridView.didTapImage = { index, source in
            print("tap index = \(index)")
        }
        gridView.didDeleteImage = { index, source in
            print("delete index = \(index)")
        }

        let images: [ImageGridView.ImageSource] = (1...3).map { i in
            let name = String(format: "%02d", i)
            return .image(UIImage(named: name)!)
        }
        gridView.mode = .edit
        modeSwitch.selectedSegmentIndex = 1
        gridView.setImages(images)
    }

    @objc private func modeChanged() {
        gridView.mode = modeSwitch.selectedSegmentIndex == 0 ? .browse : .edit
    }
}
