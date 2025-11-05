//
//  Created by 姚旭 on 2025/9/29.
//

import UIKit
import AVFoundation

extension CustomCameraView {
    
    /// Connects the session with the preview layer, which allows the layer
    /// to provide a live view of the captured content.
    func connect(with session: AVCaptureSession) {
        Task { @MainActor in
            previewLayer.session = session
            previewLayer.connection?.videoOrientation = orientation
        }
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self else { return }
            self.previewLayer.connection?.videoOrientation = self.orientation
        }
    }
    
}

class CustomCameraView: UIView {
    
    override class var layerClass: AnyClass {
        AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        layer as! AVCaptureVideoPreviewLayer
    }
    
    // 根据iPhone或者iPad支持的旋转请求设置相关的方向
    private var orientation: AVCaptureVideoOrientation {
        guard UIDevice.current.userInterfaceIdiom == .pad else { return .portrait }
        // iPad 设备自由旋转根据各个方向返回响应的值
        switch UIDevice.current.orientation {
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft: return .landscapeRight
        case .landscapeRight: return .landscapeLeft
        default: return .portrait }
    }
    
    private var observer: NSObjectProtocol?
    
    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
}
