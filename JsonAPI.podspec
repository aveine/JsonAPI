Pod::Spec.new do |spec|
  spec.name         = "JsonAPI"
  spec.version      = "1.0.0"
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
  spec.source_files  = "JsonAPI"
end
