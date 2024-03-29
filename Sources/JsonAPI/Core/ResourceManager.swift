import Foundation

/**
 Register all the `Resource` classes
 */
class ResourceManager {
    /**
     Singleton instance of the class
     */
    static let shared = ResourceManager()
    
    /**
     Store all the classes that subtype `Resource`
     */
    var resourceClasses: [String: Resource.Type] = [:]
    
    /**
     Constructor
     Will lookup for every class that subtype `Resource` and register them in `resourceClasses`
     */
    private init() {
        var count = UInt32(0)
        if let classListPointer = objc_copyClassList(&count) {
            UnsafeBufferPointer(start: classListPointer, count: Int(count)).forEach { classInfo in
              if class_hasSuperclass(classInfo, Resource.self), let resourceClass = classInfo as? Resource.Type {
                    self.resourceClasses[resourceClass.resourceType] = resourceClass
                }
            }
        }
    }

  private func class_hasSuperclass( _ cls: AnyClass?, _ target: AnyClass? ) -> Bool {
    let superCls: AnyClass? = class_getSuperclass(cls)
    if superCls == target { return true }
    if superCls == nil { return false }
    return class_hasSuperclass(superCls, target)
  }

}
