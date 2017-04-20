platform :ios, '9.0'
project './Liarodon.xcodeproj'
use_frameworks!

target 'Liarodon' do
    pod 'APIKit'
    pod 'Himotoki'
    pod 'KeychainAccess'
    pod 'KeyboardObserver'
    pod 'NVActivityIndicatorView'
    pod 'Kingfisher'
    pod 'SnapKit'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = '3.1'
        end
    end
end
