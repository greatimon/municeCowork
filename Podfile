# Uncomment the next line to define a global platform for your project
platform :ios, '14.0'

target 'municeCowork' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings! # make invisible library build warning when xcode build

  pod 'SnapKit', '~> 5.6.0'
  pod 'SwiftyUserDefaults', '~> 5.0'
  pod 'SwiftDate', '~> 7.0'
  pod 'SwiftLint'
  pod 'Moya/Combine', '~> 15.0'

  # Pods for municeCowork

  target 'municeCoworkTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'municeCoworkUITests' do
    # Pods for testing
  end

end

post_install do |installer|
  installer.generated_projects.each do |project|
    project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '14.0'
         end
    end
  end
end