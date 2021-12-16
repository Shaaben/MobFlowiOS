Pod::Spec.new do |spec|

  spec.platform = :ios
  spec.name         = "MobFlowiOS"
  spec.version      = "2.0.0"
  spec.requires_arc = true
  spec.summary      = "A short description of MobFlowiOS."
  spec.description  = <<-DESC
  A much much longer description of MobFlowiOS.
                      DESC
  spec.homepage     = 'https://github.com/Shaaben/MobFlowiOS'
  spec.license = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Mohamad" => "h.mohammad@smartmobiletech.org" }
  spec.source = { 
    :git => 'https://github.com/Shaaben/MobFlowiOS.git', 
    :tag => spec.version.to_s 
  }
  spec.framework = 'UIKit'
  spec.dependency 'Adjust'
  spec.dependency 'ReachabilitySwift'
  spec.dependency 'Firebase'
  spec.dependency 'Firebase/Analytics'
  spec.dependency 'Firebase/Messaging'
  spec.dependency 'Firebase/RemoteConfig'
  spec.dependency 'Branch'
  spec.source_files  = "MobFlowiOS/*.{swift}"
  spec.resources = "MobFlowiOS/*.{storyboard,xib,xcassets,lproj,png}"
  spec.swift_version = '5'
  spec.ios.deployment_target = '14.0'

end
