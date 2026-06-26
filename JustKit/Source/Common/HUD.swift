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
// ## Toast 新值替换旧值
// 新 Toast 传入时立即结束当前正在展示的 Toast 并开始新的展示。
// - UIKit：方法开头调用 MBProgressHUD.forView(self)?.hide(animated: false) 立即停止旧 HUD。
//   hide 方法会触发旧 HUD 的 completionBlock（MBProgressHUD 内部行为）。
// - SwiftUI：被替换的 Toast 其 completion 仍会执行（立即触发），
//   id 校验仅保护 item 置空——确保不会误清新 Toast 的状态。
//
// ## Loading 新值替换旧值
// Loading 为纯状态驱动，新值传入时直接更新当前 HUD 的展示内容（无销毁重建）。
// 若 HUD 已存在则仅更新文案，否则创建新 HUD；置 nil（UIKit 调用 hideLoading）时隐藏。
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
    
    func showLoading(message: String? = nil, detail: String? = nil) {
        if let hud = MBProgressHUD.forView(self) {
            hud.label.text = message
            hud.detailsLabel.text = detail
        } else {
            let hud = MBProgressHUD.showAdded(to: self, animated: true)
            hud.mode = .indeterminate
            hud.removeFromSuperViewOnHide = true
            hud.contentColor = UIView.hudForegroundColor
            hud.bezelView.color = UIView.hudBackgroundColor
            hud.bezelView.style = .solidColor
            
            hud.label.text = message
            hud.detailsLabel.text = detail
        }
    }
    
    func hideLoading() {
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
            ToastContainerView(item: $item)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(item != nil)
        }
    }
    
    struct ToastContainerView: UIViewRepresentable {
        @Binding var item: ToastItem?
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            if let toast = item {
                guard toast.id != context.coordinator.lastID else { return }
                context.coordinator.lastID = toast.id
                uiView.showToast(message: toast.message, detail: toast.detail, duration: toast.duration) { [currentItem = toast] in
                    currentItem.completion?()
                    if self.item?.id == currentItem.id {
                        self.item = nil
                    }
                }
            } else {
                MBProgressHUD.forView(uiView)?.hide(animated: false)
            }
        }
        
        class Coordinator { var lastID: UUID? }
        func makeCoordinator() -> Coordinator { Coordinator() }
        
    }

}

// MARK: - Loading

struct LoadingItem {
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
            LoadingContainerView(item: $item)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(item != nil)
        }
    }
    
    struct LoadingContainerView: UIViewRepresentable {
        @Binding var item: LoadingItem?
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            if let loading = item {
                uiView.showLoading(message: loading.message, detail: loading.detail)
            } else {
                uiView.hideLoading()
            }
        }
    }
    
}
