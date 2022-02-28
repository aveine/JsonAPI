Pod::Spec.new do |spec|
  spec.name         = "JsonAPISwift"
  spec.version      = "1.3.0"
  spec.summary      = "A Swift JSON:API standard implementation."
  spec.description  = <<-DESC
JsonAPI is a Swift JSON:API standard implementation.<br>
It has been greatly inspired from another library: [Vox](https://github.com/aronbalog/Vox).

This library allows several types of use, from framework style to "raw" JSON:API object manipulation.
                   DESC
  spec.homepage     = "https://github.com/aveine/JsonAPI"
  spec.license      = "MIT"
  spec.author       = { "Christopher Paccard" => "christopher.paccard@aveine.paris" } 
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/aveine/JsonAPI.git", :tag => "#{spec.version}" }
  spec.source_files = "Sources/JsonAPI/**/*.swift"
  spec.module_name  = "JsonAPI"

  spec.dependency 'Runtime', '~> 2.2.2'

  spec.swift_version = '5.1'
  spec.ios.deployment_target = '13.4'
end
