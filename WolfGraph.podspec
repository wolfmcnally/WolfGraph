Pod::Spec.new do |s|
    s.name             = 'WolfGraph'
    s.version          = '0.2.2'
    s.summary          = 'A Swift-based general graph structure with value semantics.'

    s.homepage         = 'https://github.com/wolfmcnally/WolfGraph'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'Wolf McNally' => 'wolf@wolfmcnally.com' }
    s.source           = { :git => 'https://github.com/wolfmcnally/WolfGraph.git', :tag => s.version.to_s }

    s.source_files = 'Sources/WolfGraph/**/*'

    s.swift_version = '5.0'

    s.ios.deployment_target = '11.0'
    s.macos.deployment_target = '10.13'
    s.tvos.deployment_target = '11.0'

    s.module_name = 'WolfGraph'

    s.dependency 'WolfCore'
    s.dependency 'WolfGraphics'
end
