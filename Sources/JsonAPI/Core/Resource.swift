import Foundation
import Runtime

/**
 Base class for all models representing a JSON API resource
 */
open class Resource : Identifiable, Equatable {
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
     Resource's local id
     */
    public let lid: String

    /**
     Resource's meta data
     */
    public var meta: Document.Meta?
    
    /**
     Resource's link(s)
     */
    public var links: Document.LinksObject?
    
    /**
     Current type information for Runtime reflection library
     */
    private lazy var runtimeTypeInfo = try! typeInfo(of: Swift.type(of: self))

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
    public required init() {
        self.lid = UUID().uuidString
    }
    
    /**
     Constructor
     
     - Parameter resourceObject: Resource object from which to build the resource
     */
    public required init(resourceObject: Document.ResourceObject) {
        self.lid = resourceObject.lid ?? UUID().uuidString

        var mutableSelf = self
        self.id = resourceObject.id
        self.meta = resourceObject.meta
        self.links = resourceObject.links
        
        if let attributes = resourceObject.attributes {
            let _ = initObject(object: self, objectTypeInfo: self.runtimeTypeInfo, attributes: attributes, attributesKeys: self.attributesKeys)
        }
        
        if let relationships = resourceObject.relationships {
            for (relationshipKey, relationship) in relationships {
                let key = self.attributesKeys[relationshipKey] ?? relationshipKey
                if let data = relationship.data, let property = try? runtimeTypeInfo.property(named: key) {
                    switch data {
                    case .single(let identifier):
                        if let identifier = identifier {
                            if let classType = self.resourceManager.resourceClasses[identifier.type] {
                                let resourceObject = try! Document.ResourceObject(json: ["id": identifier.id, "type": identifier.type, "meta": identifier.meta as Any])
                                try? property.set(value: classType.init(resourceObject: resourceObject), on: &mutableSelf)
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
                        try? property.set(value: resources, on: &mutableSelf)
                    }
                }
            }
        }
    }
    
    /**
     Initalize the given object with the given attributes

     - Parameter object: The object to initialize with the given attributes
     - Parameter objectTypeInfo: Object type information for Runtime reflection library
     - Parameter attributes: Attributes that will be used to initialized the given object
     - Parameter attributesKeys: Keys expected in the JSON API resource object's attributes to match the object's attributes
     - Returns: The initalized object
     */
    private func initObject(object: Any, objectTypeInfo: TypeInfo, attributes: Document.JsonObject, attributesKeys: [String: String]) -> Any {
        var mutableObject = object
        for (attributeKey, attributeValue) in attributes {
            let key = attributesKeys[attributeKey] ?? attributeKey
            if let property = try? objectTypeInfo.property(named: key) {
                let originalValue = try! property.get(from: object)
                var value = attributeValue

                if let optionalValue = originalValue as? OptionalProtocol {
                    let optionalValueWrappedType = optionalValue.wrappedType()
                    if let nestedAttributeType = optionalValueWrappedType as? ResourceNestedAttribute.Type {
                        if let nestedAttributes = attributeValue as? Document.JsonObject {
                            let nestedTypeInfo = try! typeInfo(of: optionalValueWrappedType)
                            let nestedObject = try! createInstance(of: nestedTypeInfo.type, constructor: nil)
                            value = initObject(object: nestedObject, objectTypeInfo: nestedTypeInfo, attributes: nestedAttributes, attributesKeys: nestedAttributeType.nestedAttributesKeys)
                        }
                    } else if let optionalCollectionValue = optionalValue as? OptionalCollectionProtocol {
                        let optionalCollectionValueWrappedElementType = optionalCollectionValue.wrappedElementType()
                        if let nestedAttributeType = optionalCollectionValueWrappedElementType as? ResourceNestedAttribute.Type {
                            if let collectionNestedAttributes = attributeValue as? [Document.JsonObject] {
                                let nestedTypeInfo = try! typeInfo(of: optionalCollectionValueWrappedElementType)
                                value = collectionNestedAttributes.map { nestedAttributes -> Any in
                                    let nestedObject = try! createInstance(of: nestedTypeInfo.type, constructor: nil)
                                    return initObject(object: nestedObject, objectTypeInfo: nestedTypeInfo, attributes: nestedAttributes, attributesKeys: nestedAttributeType.nestedAttributesKeys)
                                }
                            }
                        }
                    }
                } else {
                    if originalValue is ResourceNestedAttribute {
                        if let nestedAttributes = attributeValue as? Document.JsonObject {
                            let nestedTypeInfo = try! typeInfo(of: Swift.type(of: originalValue))
                            let nestedAttributeType = nestedTypeInfo.type as! ResourceNestedAttribute.Type
                            value = initObject(object: originalValue, objectTypeInfo: nestedTypeInfo, attributes: nestedAttributes, attributesKeys: nestedAttributeType.nestedAttributesKeys)
                        }
                    } else if let collectionValue = originalValue as? CollectionProtocol {
                        let collectionValueWrappedElementType = collectionValue.wrappedElementType()
                        if let nestedAttributeType = collectionValueWrappedElementType as? ResourceNestedAttribute.Type {
                            if let collectionNestedAttributes = attributeValue as? [Document.JsonObject] {
                                let nestedTypeInfo = try! typeInfo(of: collectionValueWrappedElementType)
                                value = collectionNestedAttributes.map { nestedAttributes -> Any in
                                    let nestedObject = try! createInstance(of: nestedTypeInfo.type, constructor: nil)
                                    return initObject(object: nestedObject, objectTypeInfo: nestedTypeInfo, attributes: nestedAttributes, attributesKeys: nestedAttributeType.nestedAttributesKeys)
                                }
                            }
                        }
                    }
                }

                try? property.set(value: value as Any, on: &mutableObject)
            }
        }
        return object
    }

    /**
     Serialize to a JSON API resource object
     
     - Returns: JSON API resource object representation of the instance
     */
    public func toResourceObject() -> Document.ResourceObject {
        var attributes: Document.JsonObject = [:]
        var relationships: Document.RelationshipObjects = [:]
        
        var mirror: Mirror? = Mirror(reflecting: self)
        var properties: [Mirror.Child] = []
        repeat {
            for property in mirror!.children {
                properties.append(property)
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil && mirror?.subjectType != Resource.self

        for property in properties {
            if let label = property.label {
                let key: String = self.attributesKeys.first { $1 == label }?.key ?? label
                if self.excludedAttributes.contains(key) {
                    continue
                }

                if let optionalValue = property.value as? OptionalProtocol {
                    let optionalValueWrappedType = optionalValue.wrappedType()
                    if optionalValueWrappedType is Resource.Type {
                        relationships[key] = self.resourceToRelationshipObject(resource: property.value as? Resource)
                    } else if let optionalCollectionValue = optionalValue as? OptionalCollectionProtocol {
                        let optionalCollectionValueWrappedElementType = optionalCollectionValue.wrappedElementType()
                        if optionalCollectionValueWrappedElementType is Resource.Type {
                            relationships[key] = self.resourcesToRelationshipObject(resources: property.value as? [Resource])
                        } else {
                            var value: Any? = property.value
                            if let collectionNestedAttribute = value as? [ResourceNestedAttribute] {
                                value = collectionNestedAttribute.map { nestedAttribute -> Document.JsonObject in
                                    serializeNestedAttribute(nestedAttribute: nestedAttribute)
                                }
                            }
                            attributes[key] = value
                        }
                    } else {
                        var value: Any? = property.value
                        if let nestedAttribute = value as? ResourceNestedAttribute {
                            value = serializeNestedAttribute(nestedAttribute: nestedAttribute)
                        }
                        attributes[key] = value
                    }
                } else {
                    switch property.value {
                    case let resource as Resource:
                        relationships[key] = resource.toRelationshipObject()
                    case let resources as [Resource]:
                        relationships[key] = self.resourcesToRelationshipObject(resources: resources)
                    case let nestedAttribute as ResourceNestedAttribute:
                        attributes[key] = serializeNestedAttribute(nestedAttribute: nestedAttribute)
                    case let nestedAttributes as [ResourceNestedAttribute]:
                        attributes[key] = nestedAttributes.map { nestedAttribute -> Document.JsonObject in
                            serializeNestedAttribute(nestedAttribute: nestedAttribute)
                        }
                    default:
                        attributes[key] = property.value
                    }
                }
            }
        }
        
        return Document.ResourceObject(
            id: self.id,
            lid: self.lid,
            type: self.type,
            attributes: attributes.isEmpty ? nil : attributes,
            relationships: relationships.isEmpty ? nil : relationships,
            links: self.links,
            meta: self.meta
        )
    }

    /**
     Serialize to a JSON API resource object and relationships as included

     - Returns: JSON API resource object representation of the instance and relationships as included
     */
    public func toResourceObjectWithIncluded() -> (resourceObject: Document.ResourceObject, included: [Document.ResourceObject]) {
        return toResourceObjectWithIncluded(alreadySerialized: [])
    }

    /**
     Internal method of `toResourceObjectWithIncluded()` to avoid exposing internal parameter used for recursivity

     - Parameter alreadySerialized: Array of resources already serialized to keep track during recursivity and avoid inifnite loops.
     - Returns: JSON API resource object representation of the instance and relationships as included
     */
    private func toResourceObjectWithIncluded(alreadySerialized: [Resource]) -> (resourceObject: Document.ResourceObject, included: [Document.ResourceObject]) {
        var attributes: Document.JsonObject = [:]
        var relationships: Document.RelationshipObjects = [:]
        var included: [Document.ResourceObject] = []

        var mirror: Mirror? = Mirror(reflecting: self)
        var properties: [Mirror.Child] = []
        repeat {
            for property in mirror!.children {
                properties.append(property)
            }
            mirror = mirror?.superclassMirror
        } while mirror != nil && mirror?.subjectType != Resource.self

        for property in properties {
            if let label = property.label {
                let key: String = self.attributesKeys.first { $1 == label }?.key ?? label
                if self.excludedAttributes.contains(key) {
                    continue
                }

                if let optionalValue = property.value as? OptionalProtocol {
                    let optionalValueWrappedType = optionalValue.wrappedType()
                    if optionalValueWrappedType is Resource.Type {
                        let resource = property.value as? Resource
                        relationships[key] = self.resourceToRelationshipObject(resource: resource)
                        if let resource = resource {
                            if resource.id == nil && !alreadySerialized.contains(resource) {
                                let (resourceObject, resourceObjectIncluded) = resource.toResourceObjectWithIncluded(alreadySerialized: alreadySerialized + [self])

                                included.append(resourceObject)
                                included.append(contentsOf: resourceObjectIncluded)
                            }
                        }
                    } else if let optionalCollectionValue = optionalValue as? OptionalCollectionProtocol {
                        let optionalCollectionValueWrappedElementType = optionalCollectionValue.wrappedElementType()
                        if optionalCollectionValueWrappedElementType is Resource.Type {
                            let resources = property.value as? [Resource]
                            relationships[key] = self.resourcesToRelationshipObject(resources: resources)
                            if let resources = resources {
                                resources.forEach { resource in
                                    if resource.id == nil && !alreadySerialized.contains(resource) {
                                        let (resourceObject, resourceObjectIncluded) = resource.toResourceObjectWithIncluded(alreadySerialized: alreadySerialized + [self])

                                        included.append(resourceObject)
                                        included.append(contentsOf: resourceObjectIncluded)
                                    }
                                }
                            }
                        } else {
                            var value: Any? = property.value
                            if let collectionNestedAttribute = value as? [ResourceNestedAttribute] {
                                value = collectionNestedAttribute.map { nestedAttribute -> Document.JsonObject in
                                    serializeNestedAttribute(nestedAttribute: nestedAttribute)
                                }
                            }
                            attributes[key] = value
                        }
                    } else {
                        var value: Any? = property.value
                        if let nestedAttribute = value as? ResourceNestedAttribute {
                            value = serializeNestedAttribute(nestedAttribute: nestedAttribute)
                        }
                        attributes[key] = value
                    }
                } else {
                    switch property.value {
                    case let resource as Resource:
                        relationships[key] = resource.toRelationshipObject()
                        if resource.id == nil && !alreadySerialized.contains(resource) {
                            let (resourceObject, resourceObjectIncluded) = resource.toResourceObjectWithIncluded(alreadySerialized: alreadySerialized + [self])

                            included.append(resourceObject)
                            included.append(contentsOf: resourceObjectIncluded)
                        }
                    case let resources as [Resource]:
                        relationships[key] = self.resourcesToRelationshipObject(resources: resources)
                        resources.forEach { resource in
                            if resource.id == nil && !alreadySerialized.contains(resource) {
                                let (resourceObject, resourceObjectIncluded) = resource.toResourceObjectWithIncluded(alreadySerialized: alreadySerialized + [self])

                                included.append(resourceObject)
                                included.append(contentsOf: resourceObjectIncluded)
                            }
                        }
                    case let nestedAttribute as ResourceNestedAttribute:
                        attributes[key] = serializeNestedAttribute(nestedAttribute: nestedAttribute)
                    case let nestedAttributes as [ResourceNestedAttribute]:
                        attributes[key] = nestedAttributes.map { nestedAttribute -> Document.JsonObject in
                            serializeNestedAttribute(nestedAttribute: nestedAttribute)
                        }
                    default:
                        attributes[key] = property.value
                    }
                }
            }
        }

        let resourceObject = Document.ResourceObject(
            id: self.id,
            lid: self.lid,
            type: self.type,
            attributes: attributes.isEmpty ? nil : attributes,
            relationships: relationships.isEmpty ? nil : relationships,
            links: self.links,
            meta: self.meta
        )

        return (resourceObject, included)
    }
    
    /**
     Serialize the given nested attribute into a JSON object

     - Parameter nestedAttribute: The nested attribute to serialize
     - Returns: The serialized nested attribute as a JSON object
     */
    private func serializeNestedAttribute(nestedAttribute: ResourceNestedAttribute) -> Document.JsonObject {
        var attributes: Document.JsonObject = [:]

        let nestedTypeInfo = try! typeInfo(of: Swift.type(of: nestedAttribute))
        nestedTypeInfo.properties.forEach { property in
            let key: String = nestedAttribute.attributesKeys.first { $1 == property.name }?.key ?? property.name
            if nestedAttribute.excludedAttributes.contains(key) == false {
                let originalValue = try! property.get(from: nestedAttribute)

                switch originalValue {
                case let nestedAttribute as ResourceNestedAttribute:
                    attributes[key] = serializeNestedAttribute(nestedAttribute: nestedAttribute)
                case let nestedAttributes as [ResourceNestedAttribute]:
                    attributes[key] = nestedAttributes.map { nestedAttribute -> Document.JsonObject in
                        serializeNestedAttribute(nestedAttribute: nestedAttribute)
                    }
                default:
                    attributes[key] = originalValue
                }
            }
        }

        return attributes
    }

    /**
     Serialize to a JSON API resource identifier object
     
     - Returns: JSON API resource identifier object representation of the instance
     */
    public func toResourceIdentifierObject() -> Document.ResourceIdentifierObject {
        return try! Document.ResourceIdentifierObject(id: self.id, lid: self.lid, type: self.type, meta: self.meta)
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
        let identifiers = resources?.map { $0.toResourceIdentifierObject() } ?? []
        let data = Document.RelationshipObject.ResourceLinkage.collection(identifiers: identifiers)
        return try! Document.RelationshipObject(links: nil, data: data, meta: nil)
    }
    
    /**
     Resolve the relationships of the resource using the proved resource store
     
     - Parameter relationships: Relationships of the resource
     - Parameter resourceStore: Resource store containing all the resources received in the response (data and included)
     */
    func resolveRelationships(relationships: Document.RelationshipObjects, resourceStore: [Signature: (resource: Resource, relationships: Document.RelationshipObjects?)]) {
        var mutableSelf = self
        relationships.forEach { relationship in
            let key = self.attributesKeys[relationship.key] ?? relationship.key
            if let property = try? runtimeTypeInfo.property(named: key) {
                switch relationship.value.data {
                case .single(let identifier):
                    if let identifier = identifier {
                        if let id = identifier.id, let value = resourceStore[Signature(id: id, type: identifier.type)]?.resource {
                            try? property.set(value: value, on: &mutableSelf)
                        } else if let classType = self.resourceManager.resourceClasses[identifier.type] {
                            let resourceObject = Document.ResourceObject(id: identifier.id, lid: identifier.lid, type: identifier.type, attributes: nil, relationships: nil, links: nil, meta: identifier.meta)
                            try? property.set(value: classType.init(resourceObject: resourceObject), on: &mutableSelf)
                        }
                    }
                case .collection(let identifiers):
                    let values: [Resource] = identifiers.compactMap { identifier in
                        if let id = identifier.id, let value = resourceStore[Signature(id: id, type: identifier.type)]?.resource {
                            return value
                        } else if let classType = self.resourceManager.resourceClasses[identifier.type] {
                            let resourceObject = Document.ResourceObject(id: identifier.id, lid: identifier.lid, type: identifier.type, attributes: nil, relationships: nil, links: nil, meta: identifier.meta)
                            return classType.init(resourceObject: resourceObject)
                        }
                        return nil
                    }
                    try? property.set(value: values, on: &mutableSelf)
                case .none:
                    break
                }
            }
        }
    }
    
    /**
     By default equality is based on the `ResourceObject` representation
     */
    open func equals(rhs: Resource) -> Bool {
        return self.toResourceObject() == rhs.toResourceObject()
    }

    public static func == (lhs: Resource, rhs: Resource) -> Bool {
        return lhs.equals(rhs: rhs)
    }
}

/**
 Protcol to implement for serialization/deserialization of nested attributes inside a `Resource`
 */
public protocol ResourceNestedAttribute {
    /**
     Override the keys expected in the JSON API resource object's attributes to match the nested object's attributes
     Format => [resourceObjectAttributeKey: nestedObjectKey]
     */
    static var nestedAttributesKeys: [String: String] { get }

    /**
     Attributes that won't be serialized when serializing to a JSON API resource object
     */
    static var nestedExcludedAttributes: [String] { get }
}

/**
 Default implementations
 */
public extension ResourceNestedAttribute {
    static var nestedAttributesKeys: [String: String] {
        return [:]
    }

    /**
     Alias of `nestedAttributesKeys` for an instance instead of the type
     */
    var attributesKeys: [String: String] {
        get {
            return Swift.type(of: self).nestedAttributesKeys
        }
    }

    static var nestedExcludedAttributes: [String] {
        return []
    }

    /**
     Alias of `nestedExcludedAttributes` for an instance instead of the type
     */
    var excludedAttributes: [String] {
        get {
            return Swift.type(of: self).nestedExcludedAttributes
        }
    }
}

/**
 The protocol and extension below are only used for the serialization part
 They allow to get the real type of the element inside an `Array`
 */

protocol CollectionProtocol {
    func wrappedElementType() -> Any.Type
}

extension Array : CollectionProtocol {
    func wrappedElementType() -> Any.Type {
        return Element.self
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
