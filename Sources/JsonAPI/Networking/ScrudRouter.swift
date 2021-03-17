/**
 Router for classical SCRUD paths architecture
 
 - Search: resourceType
 - Create: resourceType
 - Read: resourceType/id
 - Update: resourceType/id
 - Delete: resourceType/id
 */
public class ScrudRouter: Router {
    /**
     Constructor
     Do nothing special
     */
    public init() {}
    
    public func search(type: String) -> String {
        return type
    }
    
    public func create(resource: Resource) -> String {
        return resource.type
    }
    
    public func read(type: String, id: String) -> String {
        return "\(type)/\(id)"
    }

    public func update(resource: Resource) -> String {
        return "\(resource.type)/\(resource.id ?? "")"
    }

    public func delete(type: String, id: String) -> String {
        return "\(type)/\(id)"
    }
    
    public func delete(resource: Resource) -> String {
        return "\(resource.type)/\(resource.id ?? "")"
    }
}
