//
//  Created by 姚旭 on 2025/10/8.
//

import UIKit


class TestPopupView: BasePopupView {
    
    // MARK: - UI Components
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    // MARK: - Properties
    
    var contentViewBottomConstraint: NSLayoutConstraint?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        // 添加背景视图
        addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            backgroundView.topAnchor.constraint(equalTo: topAnchor),
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // 添加内容视图
        addSubview(contentView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        let contentHeight: CGFloat = 300
        contentViewBottomConstraint = contentView.bottomAnchor.constraint(
            equalTo: bottomAnchor,
            constant: contentHeight // 初始在屏幕外
        )
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            contentView.heightAnchor.constraint(equalToConstant: contentHeight),
            contentViewBottomConstraint!
        ])
        
        // 添加内容（示例）
        setupContent()
    }
    
    // 标题
    let titleLabel = {
        let label = UILabel()
        label.text = "弹窗标题"
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    private func setupContent() {
        
        // 关闭按钮
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("关闭", for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        closeButton.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        
        // 添加到内容视图
        contentView.addSubview(titleLabel)
        contentView.addSubview(closeButton)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            closeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20),
            closeButton.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            closeButton.widthAnchor.constraint(equalToConstant: 100),
            closeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        backgroundView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    @objc private func backgroundTapped() {
        hide()
    }
    
    @objc private func closeButtonTapped() {
        hide()
    }
    
    
    func hide() {
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
            self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.contentViewBottomConstraint?.constant = self.contentView.frame.height
            self.layoutIfNeeded()
        } completion: { _ in
            self.removeFromSuperview()
        }
    }
    
    override func animate() {
         // 执行显示动画
         UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
             self.backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
             self.contentViewBottomConstraint?.constant = -20 // 显示在底部
             self.layoutIfNeeded()
         }
     }
    
}
