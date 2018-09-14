platform :ios, '10.3'

post_install do |installer|
    installer.pods_project.build_configurations.each do |config|
        config.build_settings.delete('CODE_SIGNING_ALLOWED')
        config.build_settings.delete('CODE_SIGNING_REQUIRED')
    end
end

target 'bookchecker' do
  use_frameworks!

  # Pods for bookchecker
pod 'Alamofire', '~> 4.7'
pod 'SVProgressHUD'
pod 'RealmSwift', '~> 3.7'
pod 'SwiftyJSON', '~> 4.0'
pod 'Cosmos', '~> 16.0'
pod 'SDWebImage', '~> 4.0'
pod 'Firebase/Core'
pod 'SwiftMessages'

end
