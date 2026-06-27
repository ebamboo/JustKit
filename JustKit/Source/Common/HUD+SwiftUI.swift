//
//  Created by 姚旭 on 2026/6/27.
//

import SwiftUI

struct ToastItem {
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
}

struct LoadingItem {
    let message: String?
    let detail: String?
    init(message: String? = nil, detail: String? = nil) {
        self.message = message
        self.detail = detail
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
                uiView.hideToast()
            }
        }
        class Coordinator { var lastID: UUID? }
        func makeCoordinator() -> Coordinator { Coordinator() }
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
