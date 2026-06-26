//
//  Created by 姚旭 on 2021/5/17.
//

// MARK: - HUD 工具（Toast & Loading）
//
// 基于 MBProgressHUD 封装，同时提供 UIKit（UIView 扩展）和 SwiftUI（ViewModifier）两套 API。
//
// ## 交互阻断
// 展示期间容器视图不响应用户交互：
// - UIKit：MBProgressHUD 默认 isUserInteractionEnabled = true，自动拦截其下方视图的触摸事件。
// - SwiftUI：通过 .allowsHitTesting(item != nil) 控制 overlay 层是否拦截触摸。
//
// ## 新值替换旧值
// 无论是 Toast 还是 Loading，新值传入时都会立即结束当前正在展示的 HUD 并开始新的展示。
// - UIKit：方法开头调用 MBProgressHUD.forView(self)?.hide(animated: false) 立即停止旧 HUD。
//   注意：hide 方法会触发旧 HUD 的 completionBlock（MBProgressHUD 内部行为）。
// - SwiftUI Toast：被替换的 Toast 其 completion 仍会执行（立即触发），
//   id 校验仅保护 item 置空——确保不会误清新 Toast 的状态。
// - SwiftUI Loading：纯状态驱动，无 completion 概念。
//

import UIKit
import MBProgressHUD
import SwiftUI

extension UIView {
    
    private static let hudForegroundColor = UIColor.white
    private static let hudBackgroundColor = UIColor.black
    
    func showToast(message: String, detail: String? = nil, duration: TimeInterval = 1.5, completion: (() -> Void)? = nil) {
        MBProgressHUD.forView(self)?.hide(animated: false)
        
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .text
        hud.removeFromSuperViewOnHide = true
        hud.contentColor = UIView.hudForegroundColor
        hud.bezelView.color = UIView.hudBackgroundColor
        hud.bezelView.style = .solidColor
        
        hud.label.text = message
        hud.detailsLabel.text = detail
        hud.completionBlock = completion
        hud.hide(animated: true, afterDelay: duration)
    }
    
    func startLoading(message: String? = nil, detail: String? = nil) {
        MBProgressHUD.forView(self)?.hide(animated: false)
        
        let hud = MBProgressHUD.showAdded(to: self, animated: true)
        hud.mode = .indeterminate
        hud.removeFromSuperViewOnHide = true
        hud.contentColor = UIView.hudForegroundColor
        hud.bezelView.color = UIView.hudBackgroundColor
        hud.bezelView.style = .solidColor
        
        hud.label.text = message
        hud.detailsLabel.text = detail
    }
    
    func stopLoading() {
        let hud = MBProgressHUD.forView(self)
        hud?.hide(animated: true)
    }
    
}

extension View {
    
    func toast(item: Binding<ToastItem?>) -> some View {
        modifier(ToastModifier(item: item))
    }
    
    func loading(item: Binding<LoadingItem?>) -> some View {
        modifier(LoadingModifier(item: item))
    }
    
}

struct ToastItem: Equatable {
    let id = UUID()
    let message: String
    let detail: String?
    let duration: TimeInterval
    let completion: (() -> Void)?
    
    init(message: String, detail: String? = nil, duration: TimeInterval = 1.5, completion: (() -> Void)? = nil) {
        self.message = message
        self.detail = detail
        self.duration = duration
        self.completion = completion
    }
    
    static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
        lhs.id == rhs.id
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var item: ToastItem?
    
    func body(content: Content) -> some View {
        content.overlay {
            ToastBridgeView(item: $item)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(item != nil)
        }
    }
    
    struct ToastBridgeView: UIViewRepresentable {
        @Binding var item: ToastItem?
        
        class Coordinator {
            var lastID: UUID?
        }
        
        func makeCoordinator() -> Coordinator { Coordinator() }
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            guard let toast = item, toast.id != context.coordinator.lastID else { return }
            context.coordinator.lastID = toast.id
            MBProgressHUD.forView(uiView)?.hide(animated: false)
            uiView.showToast(message: toast.message, detail: toast.detail, duration: toast.duration) { [currentItem = toast] in
                currentItem.completion?()
                if self.item?.id == currentItem.id {
                    self.item = nil
                }
            }
        }
    }

}

// MARK: - Loading

struct LoadingItem: Equatable {
    let message: String?
    let detail: String?
    
    init(message: String? = nil, detail: String? = nil) {
        self.message = message
        self.detail = detail
    }
}

private struct LoadingModifier: ViewModifier {
    @Binding var item: LoadingItem?
    
    func body(content: Content) -> some View {
        content.overlay {
            LoadingBridgeView(item: $item)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(item != nil)
        }
    }
    
    struct LoadingBridgeView: UIViewRepresentable {
        @Binding var item: LoadingItem?
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            if let loading = item {
                if let hud = MBProgressHUD.forView(uiView) {
                    // HUD 已存在，仅更新文案
                    hud.label.text = loading.message
                    hud.detailsLabel.text = loading.detail
                } else {
                    // 创建新 HUD
                    uiView.startLoading(message: loading.message, detail: loading.detail)
                }
            } else {
                uiView.stopLoading()
            }
        }
    }
    
}
