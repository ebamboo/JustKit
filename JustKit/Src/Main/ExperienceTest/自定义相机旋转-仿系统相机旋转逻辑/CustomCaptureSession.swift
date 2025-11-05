//
//  Created by 姚旭 on 2025/9/29.
//

import UIKit
import AVFoundation

class CustomCaptureSession: AVCaptureSession {
    
    // 在此方法内根据实际业务进行初始化和设置
    override init() {
        super.init()
        
        let videoInput: AVCaptureDeviceInput
        do {
            guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
            guard canAddInput(videoInput) else { return }
            addInput(videoInput)
        } catch {
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        guard canAddOutput(metadataOutput) else { return }
        addOutput(metadataOutput)
        
        // 设置识别类型
        metadataOutput.metadataObjectTypes = [.qr]
        metadataOutput.setMetadataObjectsDelegate(self, queue: .main)
    }
    
}

extension CustomCaptureSession: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 以下是当做二维码识别处理方式
        guard let metadataObject = metadataObjects.first,
              let qrCodeObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let string = qrCodeObject.stringValue else { return }
        print("result-----",string)
    }
    
}
