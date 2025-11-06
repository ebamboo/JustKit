//
//  Created by 姚旭 on 2025/9/29.
//

import UIKit
import AVFoundation

class CustomCameraViewController: UIViewController {
    
    ///
    /// 使用相机时，系统要求应用必须全屏，因此在实际需要使用打开相机之前，判断是否全屏。
    /// 判断应用是否全屏展示
    ///
    var isFullScreen: Bool {
        guard let window = view.window, let screen = window.windowScene?.screen else { return false }
        let windowFrame = window.convert(window.bounds, to: screen.coordinateSpace)
        return windowFrame.equalTo(screen.bounds)
    }
    
    private var preview: CustomCameraView {
        view as! CustomCameraView
    }
    
    nonisolated let session = CustomCaptureSession()
    
    @concurrent var isAuthorized: Bool {
        get async {
            let status = AVCaptureDevice.authorizationStatus(for: .video)
            // Determine whether a person previously authorized camera access.
            var isAuthorized = status == .authorized
            // If the system hasn't determined their authorization status,
            // explicitly prompt them for approval.
            if status == .notDetermined {
                isAuthorized = await AVCaptureDevice.requestAccess(for: .video)
            }
            return isAuthorized
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        preview.connect(with: session)
        
        Task.detached { [weak self] in
            let isAuthorized = await self?.isAuthorized ?? false
            if isAuthorized {
                self?.session.startRunning()
            }
        }
        
    }
    
    deinit {
        session.stopRunning()
    }

}
