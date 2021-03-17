/**
 Define the different operations for a resource
 */
public class DataSource<ResourceType: Resource> {
    public typealias ResourceCollectionSuccessBlock = (_ resources: [ResourceType], _ document: Document) -> Void
    public typealias ResourceSuccessBlock = (_ resource: ResourceType?, _ document: Document?) -> Void
    
    /**
     Represent the different strategies that can be use to generate urls in a datasource
     */
    public enum Strategy {
        /**
         Strategy with a single url used for ALL the requests
         
         - Parameter path: Path to use as a single url used for ALL the requests
         */
        case path(_ path: String)
        
        /**
         Strategy with a `Router` that will provide the right url dependening on the request
         
         - Parameter router: Router to use  that will provide the right url dependening on the request
         */
        case router(_ router: Router)
    }
    
    /**
     Represent the annotation strategy to use to resolve the path annotations
     */
    private enum AnnotationStrategy {
        /**
         Strategy based on a resource
         
         - Parameter resource: Resource to use to replace the annotations on the path
         */
        case resource(_ resource: ResourceType)
        
        /**
         Strategy based on a type and a potential id
         
         - Parameter type: Value to use to replace the annotation `<type>` on the path
         - Parameter id: Value to use to replace the annotation `<id>` on the path
         */
        case resourceIdentifier(type: String, id: String?)
    }
    
    /**
     Client to use to requests the URLs
     */
    private let client: Client
    
    /**
     Strategy to use to build the paths to interact with the resources
     */
    private let strategy: Strategy
    
    /**
     Constructor
     
     - Parameter client: Client to use to request the URLs
     - Parameter strategy: Strategy to use to build the paths to interact with the resources
     */
    public init(client: Client, strategy: Strategy) {
        self.client = client
        self.strategy = strategy
    }
    
    /**
     Generate a request to search for that resource type
     
     - Returns: Request to search for that resource type
     */
    public func search() -> ResourceCollectionRequest<ResourceType> {
        let path: String = {
            switch self.strategy {
            case .router(let router):
                return router.search(type: ResourceType.resourceType)
            case .path(let path):
                return replaceAnnotations(on: path, with: AnnotationStrategy.resourceIdentifier(type: ResourceType.resourceType, id: nil))
            }
        }()
        
        return ResourceCollectionRequest<ResourceType>(path: path, method: HttpMethod.get, client: self.client, resource: nil)
    }
    
    /**
     Generate a request to create the given resource
     
     - Parameter resource: Resource to create
     - Returns: Request to create the given resource
     */
    public func create(_ resource: ResourceType) -> ResourceRequest<ResourceType> {
        let path: String = {
            switch self.strategy {
            case .router(let router):
                return router.create(resource: resource)
            case .path(let path):
                return replaceAnnotations(on: path, with: AnnotationStrategy.resource(resource))
            }
        }()
        
        return ResourceRequest<ResourceType>(path: path, method: HttpMethod.post, client: self.client, resource: resource)
    }
    
    /**
     Generate a request to read a resource
     
     - Parameter id: Resource's id to read
     - Returns: Request to read a resource based on the given resource's id
     */
    public func read(id: String) -> ResourceRequest<ResourceType> {
        let path: String = {
            switch self.strategy {
            case .router(let router):
                return router.read(type: ResourceType.self.resourceType, id: id)
            case .path(let path):
                return replaceAnnotations(on: path, with: AnnotationStrategy.resourceIdentifier(type: ResourceType.resourceType, id: id))
            }
        }()
        
        return ResourceRequest<ResourceType>(path: path, method: HttpMethod.get, client: self.client, resource: nil)
    }
    
    /**
     Generate a request to update the given resource
     
     - Parameter resource: Resource to update
     - Returns: Request to update the given resource
     */
    public func update(_ resource: ResourceType) -> ResourceRequest<ResourceType> {
        let path: String = {
            switch self.strategy {
            case .router(let router):
                return router.update(resource: resource)
            case .path(let path):
                return replaceAnnotations(on: path, with: AnnotationStrategy.resource(resource))
            }
        }()
        
        return ResourceRequest<ResourceType>(path: path, method: HttpMethod.patch, client: self.client, resource: resource)
    }
    
    /**
     Generate a request to delete a resource
     
     - Parameter id: Resource's id to delete
     - Returns: Request to delete a resource based on the given resource's id
     */
    public func delete(id: String) -> ResourceRequest<ResourceType> {
        let path: String = {
            switch self.strategy {
            case .router(let router):
                return router.delete(type: ResourceType.self.resourceType, id: id)
            case .path(let path):
                return replaceAnnotations(on: path, with: AnnotationStrategy.resourceIdentifier(type: ResourceType.resourceType, id: id))
            }
        }()
        
        return ResourceRequest<ResourceType>(path: path, method: HttpMethod.delete, client: self.client, resource: nil)
    }
    
    /**
     Generate a request to delete the given resource
     
     - Parameter resource: Resource to delete
     - Returns: Request to delete the given resource
     */
    public func delete(_ resource: ResourceType) -> ResourceRequest<ResourceType> {
        let path: String = {
            switch self.strategy {
            case .router(let router):
                return router.delete(resource: resource)
            case .path(let path):
                return replaceAnnotations(on: path, with: AnnotationStrategy.resource(resource))
            }
        }()
        
        return ResourceRequest<ResourceType>(path: path, method: HttpMethod.delete, client: self.client, resource: nil)
    }
    
    /**
     Replace the annotations on the given path
     
     - Parameter path: Path on wich to replace the annotations
     - Parameter strategy: Strategy to use to replace the annotations
     - Returns: Path with the replaced annotations
     */
    private func replaceAnnotations(on path: String, with strategy: AnnotationStrategy) -> String {
        switch strategy {
        case .resource(let resource):
            return path
                .replacingOccurrences(of: "<type>", with: resource.type)
                .replacingOccurrences(of: "<id>", with: resource.id ?? "<id>")
        case .resourceIdentifier(let type, let id):
            return path
                .replacingOccurrences(of: "<type>", with: type)
                .replacingOccurrences(of: "<id>", with: id ?? "<id>")
        }
    }
}

