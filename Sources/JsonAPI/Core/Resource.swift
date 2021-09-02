import Foundation

/**
 Base class for all models representing a JSON API resource
 */
@objcMembers
open class Resource : NSObject, Identifiable {
    /**
     Represent a unique signature for a resource
     Can be used as key in dictionnaries
     */
    public struct Signature: Hashable {
        let id: String
        let type: String
    }
    
    /**
     Resource manager to access all  the `Resource` classes
     */
    private let resourceManager = ResourceManager.shared
    
    /**
     Resource's id
     */
    public var id: String?
    
    /**
     Resource's meta data
     */
    public var meta: Document.Meta?
    
    /**
     Resource's link(s)
     */
    public var links: Document.LinksObject?
    
    /**
     Override the keys expected in the JSON API resource object's attributes to match the model's attributes
     Format => [resourceObjectAttributeKey: modelKey]
     */
    open class var resourceAttributesKeys: [String: String] {
        return [:]
    }
    
    /**
     Alias of `resourceAttributesKeys` for an instance instead of the class type
     */
    public private(set) lazy var attributesKeys: [String: String] = Swift.type(of: self).resourceAttributesKeys
    
    /**
     Attributes that won't be serialized when serializing to a JSON API resource object
     */
    open class var resourceExcludedAttributes: [String] {
        return []
    }
    
    /**
     Alias of `resourceExcludedAttributes` for an instance instead of the class type
     */
    public private(set) lazy var excludedAttributes: [String] = Swift.type(of: self).resourceExcludedAttributes
    
    /**
     Define the resource type
     By default it is the class' name
     */
    open class var resourceType: String {
        return String(describing: self)
    }
    
    /**
     Alias of `resourceType` for an instance instead of the class type
     */
    public private(set) lazy var type: String = Swift.type(of: self).resourceType
    
    /**
     Constructor
     */
    public override init() {
        super.init()
    }
    
    /**
     Constructor
     
     - Parameter resourceObject: Resource object from which to build the resource
     */
    public required init(resourceObject: Document.ResourceObject) {
        super.init()
        self.id = resourceObject.id
        self.meta = resourceObject.meta
        self.links = resourceObject.links
        
        if let attributes = resourceObject.attributes {
            for (attributeKey, attributeValue) in attributes {
                let key = self.attributesKeys[attributeKey] ?? attributeKey
                self.setValue(attributeValue, forKey: key)
            }
        }
        
        if let relationships = resourceObject.relationships {
            for (relationshipKey, relationship) in relationships {
                let key = self.attributesKeys[relationshipKey] ?? relationshipKey
                if let data = relationship.data {
                    switch data {
                    case .single(let identifier):
                        if let identifier = identifier {
                            if let classType = self.resourceManager.resourceClasses[identifier.type] {
                                let resourceObject = try! Document.ResourceObject(json: ["id": identifier.id, "type": identifier.type, "meta": identifier.meta as Any])
                                self.setValue(classType.init(resourceObject: resourceObject), forKey: key)
                            }
                        }
                    case .collection(let identifiers):
                        let resources = identifiers.compactMap { identifier -> Resource? in
                            if let classType = self.resourceManager.resourceClasses[identifier.type] {
                                let resourceObject = try! Document.ResourceObject(json: ["id": identifier.id, "type": identifier.type, "meta": identifier.meta as Any])
                                return classType.init(resourceObject: resourceObject)
                            }
                            return nil
                        }
                        self.setValue(resources, forKey: key)
                    }
                }
            }
        }
    }
    
    /**
     Serialize to a JSON API resource object
     
     - Returns: JSON API resource object representation of the instance
     */
    public func toResourceObject() -> Document.ResourceObject {
        var attributes: Document.JsonObject = [:]
        var relationships: Document.RelationshipObjects = [:]
        
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if let label = child.label {
                let key: String = self.attributesKeys.first { $1 == label }?.key ?? label
                if self.excludedAttributes.contains(key) {
                    continue
                }
                
                if let optionalValue = child.value as? OptionalProtocol {
                    if optionalValue.wrappedType() is Resource.Type {
                        relationships[key] = self.resourceToRelationshipObject(resource: child.value as? Resource)
                    } else if let optionalCollectionValue = optionalValue as? OptionalCollectionProtocol {
                        if optionalCollectionValue.wrappedElementType() is Resource.Type {
                            relationships[key] = self.resourcesToRelationshipObject(resources: child.value as? [Resource])
                        } else {
                            attributes[key] = child.value
                        }
                    }
                    else {
                        attributes[key] = child.value
                    }
                } else {
                    switch child.value {
                    case let resource as Resource:
                        relationships[key] = resource.toRelationshipObject()
                    case let resources as [Resource]:
                        relationships[key] = self.resourcesToRelationshipObject(resources: resources)
                    default:
                        attributes[key] = child.value
                    }
                }
            }
        }
        
        return Document.ResourceObject(
            id: self.id,
            type: self.type,
            attributes: attributes.isEmpty ? nil : attributes,
            relationships: relationships.isEmpty ? nil : relationships,
            links: self.links,
            meta: self.meta
        )
    }
    
    /**
     Serialize to a JSON API resource identifier object
     
     - Returns: JSON API resource identifier object representation of the instance if `id` is set
     */
    public func toResourceIdentifierObject() -> Document.ResourceIdentifierObject? {
        if let id = self.id {
            return Document.ResourceIdentifierObject(id: id, type: self.type, meta: self.meta)
        }
        return nil
    }
    
    /**
     Serialize to a JSON API relationship object
     
     - Returns: JSON API relationship object representation of the instance
     */
    public func toRelationshipObject() -> Document.RelationshipObject {
        let identifier = self.toResourceIdentifierObject()
        let data = Document.RelationshipObject.ResourceLinkage.single(identifier: identifier)
        return try! Document.RelationshipObject(links: nil, data: data, meta: nil)
    }
    
    /**
     Serialize the given resource into a JSON API relationship object
     
     - Returns: JSON API relationship object representation of the given resource
     */
    private func resourceToRelationshipObject(resource: Resource?) -> Document.RelationshipObject? {
        let identifier = resource?.toResourceIdentifierObject()
        let data = Document.RelationshipObject.ResourceLinkage.single(identifier: identifier)
        return try! Document.RelationshipObject(links: nil, data: data, meta: nil)
    }
    
    /**
     Serialize the given resources into a JSON API relationship object
     
     - Returns: JSON API relationship object representation of the given resources
     */
    private func resourcesToRelationshipObject(resources: [Resource]?) -> Document.RelationshipObject? {
        let identifiers = resources?.compactMap { $0.toResourceIdentifierObject() } ?? []
        let data = Document.RelationshipObject.ResourceLinkage.collection(identifiers: identifiers)
        return try! Document.RelationshipObject(links: nil, data: data, meta: nil)
    }
    
    /**
     Resolve the relationships of the resource using the proved resource store
     
     - Parameter relationships: Relationships of the resource
     - Parameter resourceStore: Resource store containing all the resources received in the response (data and included)
     */
    func resolveRelationships(relationships: Document.RelationshipObjects, resourceStore: [Signature: (resource: Resource, relationships: Document.RelationshipObjects?)]) {
        relationships.forEach { relationship in
            let key = self.attributesKeys[relationship.key] ?? relationship.key
            switch relationship.value.data {
            case .single(let identifier):
                if let identifier = identifier {
                    if let value = resourceStore[Signature(id: identifier.id, type: identifier.type)]?.resource {
                        self.setValue(value, forKey: key)
                    } else if let classType = self.resourceManager.resourceClasses[identifier.type] {
                        let resourceObject = try! Document.ResourceObject(json: ["id": identifier.id, "type": identifier.type, "meta": identifier.meta as Any])
                        self.setValue(classType.init(resourceObject: resourceObject), forKey: key)
                    }
                }
            case .collection(let identifiers):
                let values: [Resource] = identifiers.compactMap { identifier in
                    if let value = resourceStore[Signature(id: identifier.id, type: identifier.type)]?.resource {
                        return value
                    } else if let classType = self.resourceManager.resourceClasses[identifier.type] {
                        let resourceObject = try! Document.ResourceObject(json: ["id": identifier.id, "type": identifier.type, "meta": identifier.meta as Any])
                        return classType.init(resourceObject: resourceObject)
                    }
                    return nil
                }
                self.setValue(values, forKey: key)
            case .none:
                break
            }
        }
    }
    
    open override func setValue(_ value: Any!, forUndefinedKey key: String) {
        // We ignore any values that were not defined in our model
    }
}


/**
 The protocols and extensions belows are only used for the serialization part
 They allow to get the real type behind an `Any` when in reality it is a `Any?`
 See this related topic : https://forums.swift.org/t/casting-from-any-to-optional/21883/6
 */

protocol OptionalProtocol {
    func wrappedType() -> Any.Type
}

protocol OptionalCollectionProtocol {
    func wrappedElementType() -> Any.Type
}

extension Optional: OptionalProtocol {
    func wrappedType() -> Any.Type {
        return Wrapped.self
    }
}

extension Optional: OptionalCollectionProtocol where Wrapped: Collection {
    func wrappedElementType() -> Any.Type {
        return Wrapped.Element.self
    }
}
