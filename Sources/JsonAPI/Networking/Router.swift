/**
 Define the paths to interact with the resources
 */
public protocol Router {
    /**
     Define the path to search resources for the given type
     
     - Parameter type: Type of the resources to search
     - Returns: Path to search resources for the given type
     */
    func search(type: String) -> String
    
    /**
     Define the path to create the given resource
     
     - Parameter resource: Resource to create
     - Returns: Path to create the given resource
     */
    func create(resource: Resource) -> String
    
    /**
     Define the path to read a resource for a given type and id
     
     - Parameter type: Resource's type to read
     - Parameter id: Resource's id to read
     - Returns: Path to read a resource for the given type and id
     */
    func read(type: String, id: String) -> String
    
    /**
     Define the path to update the given resource
     
     - Parameter resource: Resource to update
     - Returns: Path to update the given resource
     */
    func update(resource: Resource) -> String
    
    /**
     Define the path to delete a resource for a given type and id
     
     - Parameter type: Resource's type to delete
     - Parameter id: Resource's id to delete
     - Returns: Path to delete a resource for the given type and id
     */
    func delete(type: String, id: String) -> String
    
    /**
     Define the path to delete the given resource
     
     - Parameter resource: Resource to delete
     - Returns: Path to delete the given resource
     */
    func delete(resource: Resource) -> String
}

