//
//  Created by 姚旭 on 2021/5/17.
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
    
}

struct ToastItem: Equatable {
    let id = UUID()
    let message: String
    var detail: String? = nil
    var duration: TimeInterval = 1.5
    var completion: (() -> Void)? = nil
    
    static func == (lhs: ToastItem, rhs: ToastItem) -> Bool {
        lhs.id == rhs.id
    }
}

private struct ToastModifier: ViewModifier {
    @Binding var item: ToastItem?
    @State var lastID: UUID? // 用于防止 SwiftUI 多次调用 updateUIView 时重复展示同一条 Toast
    
    func body(content: Content) -> some View {
        content.overlay {
            ToastBridgeView(item: $item, lastID: $lastID)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .allowsHitTesting(item != nil)
        }
    }
    
    struct ToastBridgeView: UIViewRepresentable {
        @Binding var item: ToastItem?
        @Binding var lastID: UUID?
        
        func makeUIView(context: Context) -> UIView {
            let view = UIView()
            view.backgroundColor = .clear
            return view
        }
        
        func updateUIView(_ uiView: UIView, context: Context) {
            // guard 放在 async 内部，确保检查 lastID 时取到的是最新值，
            // 避免 updateUIView 被连续调用时因 async 延迟导致重复展示
            DispatchQueue.main.async {
                guard let toast = item, toast.id != lastID else { return }
                lastID = toast.id
                // 新 Toast 到来时，立即隐藏旧 HUD，避免叠加
                MBProgressHUD.forView(uiView)?.hide(animated: false)
                let currentID = toast.id
                let userCompletion = toast.completion
                uiView.showToast(message: toast.message, detail: toast.detail, duration: toast.duration) {
                    // 仅当 item 未被新的 Toast 覆盖时才回调并置空，被替换的 Toast 不触发 completion
                    if item?.id == currentID {
                        userCompletion?()
                        item = nil
                    }
                }
            }
        }
    }

}
