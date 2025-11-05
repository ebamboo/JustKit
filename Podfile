source 'https://mirrors.tuna.tsinghua.edu.cn/git/CocoaPods/Specs.git'

platform :ios, '15.0'
inhibit_all_warnings!

target 'JustKit' do
  use_frameworks!

  pod 'Alamofire'
  pod 'SDWebImage'
  pod 'MBProgressHUD'
  pod 'HandyJSON'
  pod 'BBPlayerView'

end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        end
    end
end