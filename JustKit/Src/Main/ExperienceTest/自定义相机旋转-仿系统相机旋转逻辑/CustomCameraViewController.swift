//
//  Created by 姚旭 on 2025/9/29.
//

import UIKit
import AVFoundation

class CustomCameraViewController: UIViewController {
    
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
