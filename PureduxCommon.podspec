Pod::Spec.new do |s|
  s.name             = 'PureduxCommon'
  s.version          = '1.0.0'
  s.summary          = 'Puredux Common Utils'

# TODO: Add long description here.
# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/KazaiMazai/PureduxCommon'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Sergey Kazakov' => 'kazaimazai@gmail.com' }
  s.source           = { :git => 'https://github.com/KazaiMazai/PureduxCommon.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.3'

  s.source_files = 'Sources/**/*.swift'

end
