import Foundation

/**
 Generic request for a resource or a resource collection
 */
public class Request<ResourceType: Resource, SuccessType> {
    /**
     Resource manager to access all  the `Resource` classes
     */
    private let resourceManager = ResourceManager.shared
    
    /**
     Client that will make the request
     */
    private let client: Client
    
    /**
     Path to use for the request
     */
    public let path: String
    
    /**
     HTTP method to use for the request
     */
    public let method: HttpMethod
    
    /**
     Query items to use for the request
     */
    public fileprivate(set) var queryItems: [URLQueryItem] = []
    
    /**
     Resource that will be serialized for the request's body
     */
    public let resource: ResourceType?
    
    /**
     Potential meta information for the client
     */
    public var userInfo: [String: Any] = [:]
    
    /**
     Constructor
     
     - Parameter path: Path to use for the request
     - Parameter method: HTTP Method to use for the request
     - Parameter client: Client to use to execute the request
     */
    public init(path: String, method: HttpMethod, client: Client, resource: ResourceType?) {
        self.path = path
        self.method = method
        self.client = client
        self.resource = resource
    }
    
    /**
     Execute the request
     
     - Returns: The adapted resource response depending on the request  (either a `ResourceResponse` or a `ResourceCollectionResponse`)
     */
    public func result() async throws -> SuccessType {
        let body: Document.JsonObject? = {
            if let resourceObject = self.resource?.toResourceObject().toJson() {
                return ["data": resourceObject]
            }
            return nil
        }()

        do {
            let response = try await client.executeRequest(path: path, method: method, queryItems: queryItems, body: body, userInfo: userInfo)

            var document: Document? = nil
            var resourceStore: [Resource.Signature: (resource: Resource, relationships: Document.RelationshipObjects?)] = [:]

            if let data = response.data, !data.isEmpty {
                do {
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        document = try Document(json: json)
                        if let included = document?.included {
                            resourceStore = self.createResourceStore(resourceObjects: included)
                        }
                    }
                } catch let error {
                    throw RequestError.failure(error, document)
                }
            }

            if SuccessType.self is DataSource<ResourceType>.ResourceResponse.Type {
                if let document = document {
                    switch document.data {
                    case .single(let resourceObject):
                        let resource = ResourceType(resourceObject: resourceObject)
                        if let resourceId = resource.id {
                            resourceStore[Resource.Signature(id: resourceId, type: resource.type)] = (resource, resourceObject.relationships)
                        }

                        resourceStore.forEach {
                            if let relationships = $0.value.relationships {
                                $0.value.resource.resolveRelationships(relationships: relationships, resourceStore: resourceStore)
                            }
                        }

                        return DataSource<ResourceType>.ResourceResponse(document, resource) as! SuccessType
                    case .collection(_):
                        throw RequestError.failure(RequestError.notSingleData, document)
                    case .none:
                        return DataSource<ResourceType>.ResourceResponse(document, nil) as! SuccessType
                    }
                } else {
                    return DataSource<ResourceType>.ResourceResponse(nil, nil) as! SuccessType
                }
            } else if SuccessType.self is DataSource<ResourceType>.ResourceCollectionResponse.Type {
                if let document = document {
                    switch document.data {
                    case .single(_):
                        throw RequestError.failure(RequestError.notCollectionData, document)
                    case .collection(let resourceObjects):
                        let resources: [ResourceType] = resourceObjects.map { resourceObject in
                            let resource = ResourceType(resourceObject: resourceObject)
                            if let resourceId = resource.id {
                                resourceStore[Resource.Signature(id: resourceId, type: resource.type)] = (resource, resourceObject.relationships)
                            }
                            return resource
                        }

                        resourceStore.forEach {
                            if let relationships = $0.value.relationships {
                                $0.value.resource.resolveRelationships(relationships: relationships, resourceStore: resourceStore)
                            }
                        }

                        return DataSource<ResourceType>.ResourceCollectionResponse(document, resources) as! SuccessType
                    case .none:
                        throw RequestError.failure(RequestError.noData, document)
                    }
                } else {
                    throw RequestError.failure(RequestError.emptyResponse, nil)
                }
            } else {
                throw RequestError.failure(RequestError.unknownResponse, document) // Should never happened
            }
        } catch let error {
            switch error {
            case ClientError.failure(_, let data):
                if let data = data {
                    let json: [String: Any]?
                    let document: Document?
                    do {
                        json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                        document = try Document(json: json!)
                    } catch let error {
                        throw RequestError.failure(error, nil)
                    }
                    throw RequestError.failure(error, document)
                } else {
                    throw RequestError.failure(error, nil)
                }
            case RequestError.failure:
                throw error
            default:
                throw RequestError.failure(error, nil)
            }
        }
    }
    
    /**
     Append the given query items to the request's query items
     
     - Parameter queryItems: Query items to append
     - Returns: The request with the query items appended
     */
    public func queryItems(_ queryItems: [URLQueryItem]) -> Self {
        self.queryItems.append(contentsOf: queryItems)
        
        return self
    }
    
    /**
     Append the given sparse fieldsets query to the request's query items
     
     - Parameter fields: Sparse fieldsets query to append
     - Returns: The request with the sparse fieldsets query appended
     */
    public func fields(_ fields: [String: [String]]) -> Self {
        for field in fields {
            queryItems.append(URLQueryItem(name: "fields[\(field.key)]", value: field.value.joined(separator: ",")))
        }
        
        return self
    }
    
    /**
     Append the given include query to the request's query items
     
     - Parameter include: Include query to append
     - Returns: The request with the included query appended
     */
    public func include(_ include: [String]) -> Self {
        queryItems.append(URLQueryItem(name: "include", value: include.joined(separator: ",")))
        
        return self
    }
    
    /**
     Create a resource store initialized with the given resources objects
     
     - Parameter resourceObjects: Resource objects used to initialize the store
     - Returns: A resource store indexing all the resources present in the document
     */
    private func createResourceStore(resourceObjects: [Document.ResourceObject]) -> [Resource.Signature: (resource: Resource, relationships: Document.RelationshipObjects?)] {
        let indexedResources = resourceObjects.compactMap { resourceObject -> (Resource.Signature, (resource: Resource, relationships: Document.RelationshipObjects?))? in
            if let classType = self.resourceManager.resourceClasses[resourceObject.type], let resourceId = resourceObject.id {
                return (Resource.Signature(id: resourceId, type: resourceObject.type), (classType.init(resourceObject: resourceObject), resourceObject.relationships))
            }
            return nil
        }
        return Dictionary(uniqueKeysWithValues: indexedResources)
    }
}

/**
Request for a resource
*/
public class ResourceRequest<ResourceType: Resource>: Request<ResourceType, DataSource<ResourceType>.ResourceResponse> {}

/**
 Request for a resource collection
 */
public class ResourceCollectionRequest<ResourceType: Resource>: Request<ResourceType, DataSource<ResourceType>.ResourceCollectionResponse> {
    /**
     Append the given sort query to the request's query items
     
     - Parameter sort: Sort query to append
     - Returns: The request with the sort query appended
     */
    public func sort(_ sort: [Sort]) -> Self {
        let sortString = sort.map { type in
           switch type {
           case .ascending(let criteria):
               return criteria
           case .descending(let criteria):
               return "-" + criteria
           }
        }.joined(separator: ",")
        queryItems.append(URLQueryItem(name: "sort", value: sortString))
        
        return self
    }
}

/**
 Different sort strategies that can be used for a request
 */
public enum Sort {
    /**
     Ascending sort strategy
     
     - Parameter criteria: Criteria's name for the strategy
     */
    case ascending(_ criteria: String)
    
    /**
     Descending sort strategy
     
     - Parameter criteria: Criteria's name for the strategy
     */
    case descending(_ critera: String)
}

/**
 Different errors that can be returned for a request
 */
public enum RequestError: Error {
    /**
     Allow to correlate an error with a response document

     - Parameter error The error generating the failure
     - Parameter document The response document related to the error
     */
    case failure(_ error: Error, _ document: Document?)
    case unknownResponse
    case emptyResponse
    case noData
    case notCollectionData
    case notSingleData
}
