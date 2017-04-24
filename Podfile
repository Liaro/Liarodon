platform :ios, '9.0'
project './Liarodon.xcodeproj'
use_frameworks!

target 'Liarodon' do
    pod 'Fabric'
    pod 'Crashlytics'
    pod 'APIKit', :git => 'https://github.com/ishkawa/APIKit.git', :branch => 'develop/4.0'
    pod 'Himotoki'
    pod 'KeychainAccess'
    pod 'KeyboardObserver'
    pod 'NVActivityIndicatorView'
    pod 'Kingfisher'
    pod 'SnapKit'
    pod 'ImageViewer'
    pod 'DateToolsSwift'
    pod '1PasswordExtension'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.1'
        end
    end
end
