platform :ios, '9.0'

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
pod 'RealmSwift'
pod 'SwiftyJSON'
pod 'AlamofireImage', '~> 3.3'
pod 'Cosmos', '~> 16.0'

end
