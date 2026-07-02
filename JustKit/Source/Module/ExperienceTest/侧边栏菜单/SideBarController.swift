//
//  Created on 2026/1/5.
//

import UIKit


/// 侧滑菜单控制器配置
struct SideBarConfiguration {
    /// 侧滑菜单显示模式
    /// - push: 菜单"推着"主视图整体向右移动
    /// - overlay: 主视图大小和位置不变，侧边菜单栏"覆盖在"主视图上
    enum MenuDisplayMode {
        case push
        case overlay
    }
    
    /// 菜单显示模式（默认 overlay）
    var menuDisplayMode: MenuDisplayMode = .overlay
    
    /// 菜单宽度（默认 280pt）
    var menuWidth: CGFloat = 280
    
    /// 动画时长（默认 0.3s）
    var animationDuration: TimeInterval = 0.3
    
    /// 阴影蒙层最大透明度（默认 0.5）
    var shadowMaxAlpha: CGFloat = 0.5
    
    /// 滑动阈值比例（默认 0.5，即菜单宽度的 50%）
    var swipeThresholdRatio: CGFloat = 0.5
    
    /// 速度阈值（默认 500，单位：pt/s）
    var velocityThreshold: CGFloat = 500
    
}


/// 侧滑菜单控制器
///
/// 一个支持两种显示模式的侧滑菜单容器控制器：
/// - `.push` 模式：菜单推动主视图向右移动
/// - `.overlay` 模式：菜单覆盖在主视图上
///
/// 支持的手势交互：
/// - 左边缘滑动打开菜单
/// - 平移手势拖动菜单
/// - 点击阴影蒙层关闭菜单
class SideBarController: UIViewController {
    
    // MARK: - Public Properties
    
    let configuration: SideBarConfiguration
    
    /// 菜单是否打开（只读）
    private(set) var isMenuOpen = false
    
    // MARK: - Public Methods
    
    /// 切换菜单的打开/关闭状态
    func toggleMenu() {
        if isMenuOpen {
            closeMenu()
        } else {
            openMenu()
        }
    }
    
    // MARK: - UI Components
    
    /// 侧边菜单视图控制器
    private var menuViewController: UIViewController
    
    /// 主视图控制器
    private var mainViewController: UIViewController
    
    /// 阴影蒙层视图（用于遮挡主视图）
    private lazy var shadowView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    // MARK: - Initialization
    
    /// 初始化侧滑菜单控制器（使用配置对象）
    /// - Parameters:
    ///   - main: 主视图控制器
    ///   - menu: 侧边菜单视图控制器
    ///   - configuration: 侧滑菜单配置，默认为标准配置
    init(
        main: UIViewController,
        menu: UIViewController,
        configuration: SideBarConfiguration = SideBarConfiguration()
    ) {
        self.mainViewController = main
        self.menuViewController = menu
        self.configuration = configuration
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented - Use init(main:menu:configuration:) instead")
    }
    
    // MARK: - Lifecycle
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        // 视图布局更新时，根据当前菜单状态更新视图位置
        updateViews(with: isMenuOpen ? configuration.menuWidth : 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupGestures()
    }
    
    // MARK: - Setup
    
    /// 设置视图层级和初始位置
    private func setupViews() {
        // 1. 添加菜单视图控制器
        addChild(menuViewController)
        view.addSubview(menuViewController.view)
        menuViewController.view.frame = CGRect(
            x: -configuration.menuWidth,  // 初始位置在屏幕左侧外
            y: 0,
            width: configuration.menuWidth,
            height: view.bounds.height
        )
        menuViewController.didMove(toParent: self)
        
        // 2. 添加主视图控制器（放在最底层）
        addChild(mainViewController)
        view.insertSubview(mainViewController.view, at: 0)
        mainViewController.view.frame = view.bounds
        mainViewController.didMove(toParent: self)
        
        // 3. 添加阴影蒙层到主视图上
        mainViewController.view.addSubview(shadowView)
        shadowView.frame = mainViewController.view.bounds
        shadowView.isHidden = true  // 初始隐藏
    }
    
    /// 设置手势识别器
    private func setupGestures() {
        // 1. 左边缘滑动手势（用于打开菜单）
        let edgePanGesture = UIScreenEdgePanGestureRecognizer(
            target: self,
            action: #selector(handleEdgePan(_:))
        )
        edgePanGesture.edges = .left
        mainViewController.view.addGestureRecognizer(edgePanGesture)
        
        // 2. 平移手势（用于拖动菜单）
        let panGesture = UIPanGestureRecognizer(
            target: self,
            action: #selector(handlePan(_:))
        )
        mainViewController.view.addGestureRecognizer(panGesture)
        
        // 3. 点击手势（用于关闭菜单）
        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(shadowViewTapped)
        )
        shadowView.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Gesture Handlers
    
    /// 处理左边缘滑动手势
    @objc private func handleEdgePan(_ gesture: UIScreenEdgePanGestureRecognizer) {
        handlePanGesture(gesture)
    }
    
    /// 处理平移手势
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        handlePanGesture(gesture)
    }
    
    /// 统一处理平移手势逻辑
    /// - Parameter gesture: 平移手势识别器
    private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            // 开始拖动时显示阴影蒙层
            shadowView.isHidden = false
            
        case .changed:
            // 拖动过程中更新菜单位置
            var newX = translation.x
            
            if !isMenuOpen {
                // 菜单关闭状态：从 0 开始向右滑动，限制在 [0, configuration.menuWidth] 范围内
                newX = max(0, min(newX, configuration.menuWidth))
            } else {
                // 菜单打开状态：从 configuration.menuWidth 开始计算，限制在 [0, configuration.menuWidth] 范围内
                newX = configuration.menuWidth + translation.x
                newX = max(0, min(newX, configuration.menuWidth))
            }
            
            updateViews(with: newX)
            
        case .ended, .cancelled:
            // 拖动结束，根据位移和速度决定是打开还是关闭菜单
            let threshold = configuration.menuWidth * configuration.swipeThresholdRatio
            var shouldOpen = false
            
            if !isMenuOpen {
                // 菜单关闭状态：滑动超过阈值或速度足够快则打开
                shouldOpen = translation.x > threshold || velocity.x > configuration.velocityThreshold
            } else {
                // 菜单打开状态：向左滑动超过阈值或向左速度足够快则关闭
                shouldOpen = !(translation.x < -threshold || velocity.x < -configuration.velocityThreshold)
            }
            
            if shouldOpen {
                openMenu()
            } else {
                closeMenu()
            }
            
        default:
            break
        }
    }
    
    /// 处理阴影蒙层点击事件
    @objc private func shadowViewTapped() {
        closeMenu()
    }
    
}


private extension SideBarController {
    
    // MARK: - View Updates
    
    /// 更新菜单位置、主视图位置和阴影蒙层效果
    /// - Parameter offset: 菜单的 X 轴偏移量（0: 关闭, menuWidth: 打开）
    func updateViews(with offset: CGFloat) {
        // 1. 更新菜单位置：从左侧外向右移动
        menuViewController.view.frame = CGRect(
            x: -configuration.menuWidth + offset,
            y: 0,
            width: configuration.menuWidth,
            height: view.bounds.height
        )
        
        // 2. 更新主视图位置（根据显示模式）
        switch configuration.menuDisplayMode {
        case .push:
            // Push 模式：主视图随菜单向右移动
            mainViewController.view.frame = CGRect(
                x: offset,
                y: 0,
                width: view.bounds.width,
                height: view.bounds.height
            )
        case .overlay:
            // Overlay 模式：主视图位置和大小不变
            mainViewController.view.frame = view.bounds
        }
        
        // 3. 更新阴影蒙层：位置随主视图，透明度随菜单打开程度
        shadowView.frame = mainViewController.view.bounds
        let progress = min(offset / configuration.menuWidth, 1.0)
        shadowView.backgroundColor = UIColor.black.withAlphaComponent(progress * configuration.shadowMaxAlpha)
    }
    
    // MARK: - Menu Control
    
    /// 打开菜单（带动画）
    func openMenu() {
        isMenuOpen = true
        shadowView.isHidden = false
        
        UIView.animate(
            withDuration: configuration.animationDuration,
            delay: 0,
            options: .curveEaseOut
        ) {
            self.updateViews(with: self.configuration.menuWidth)
        }
    }
    
    /// 关闭菜单（带动画）
    func closeMenu() {
        isMenuOpen = false
        
        UIView.animate(
            withDuration: configuration.animationDuration,
            delay: 0,
            options: .curveEaseOut
        ) {
            self.updateViews(with: 0)
        } completion: { _ in
            // 动画完成后隐藏阴影蒙层
            self.shadowView.isHidden = true
        }
    }
    
}
