import XCTest
import JsonAPI

class DataSourceTests: XCTestCase {
    class AClient: Client {
        func executeRequest(path: String, method: HttpMethod, queryItems: [URLQueryItem]?, body: Document.JsonObject?, userInfo: [String : Any]?) async throws -> ClientSuccessResponse {
            return ClientSuccessResponse(nil, nil)
        }
    }
    static let client = AClient()
    static let router = ScrudRouter()
    static let resource = AResource()
    static let resourceNoId = AResource()
    
    static let path = "/custom/path/<type>"
    static let resolvedPath = DataSourceTests.path.replacingOccurrences(of: "<type>", with: DataSourceTests.resource.type)
    
    static let pathId = "/custom/path/<type>/<id>"
    static let resolvedPathId = DataSourceTests.pathId.replacingOccurrences(of: "<type>", with: DataSourceTests.resource.type).replacingOccurrences(of: "<id>", with: DataSourceTests.resource.id ?? "<id>")
    
    static let dataSourceRouter = DataSource<AResource>(client: DataSourceTests.client, strategy: .router(DataSourceTests.router))
    static let dataSourcePath = DataSource<AResource>(client: DataSourceTests.client, strategy: .path(DataSourceTests.path))
    static let dataSourcePathId = DataSource<AResource>(client: DataSourceTests.client, strategy: .path(DataSourceTests.pathId))
    
    override func setUp() {
        DataSourceTests.resource.id = "1"
    }
    
    func testSearch() {
        XCTAssertEqual(DataSourceTests.dataSourceRouter.search().path, DataSourceTests.router.search(type: DataSourceTests.resource.type))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.search().method, HttpMethod.get)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.search().resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.search().path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.search().method, HttpMethod.get)
        XCTAssertEqual(DataSourceTests.dataSourcePath.search().resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.search().path, "\(DataSourceTests.resolvedPath)/<id>")
        XCTAssertEqual(DataSourceTests.dataSourcePathId.search().method, HttpMethod.get)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.search().resource, nil)
    }
    
    func testCreate() {
        XCTAssertEqual(DataSourceTests.dataSourceRouter.create(DataSourceTests.resource).path, DataSourceTests.router.create(resource: DataSourceTests.resource))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.create(DataSourceTests.resource).method, HttpMethod.post)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.create(DataSourceTests.resource).resource, DataSourceTests.resource)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.create(DataSourceTests.resource).path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.create(DataSourceTests.resource).method, HttpMethod.post)
        XCTAssertEqual(DataSourceTests.dataSourcePath.create(DataSourceTests.resource).resource, DataSourceTests.resource)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.create(DataSourceTests.resource).path, DataSourceTests.resolvedPathId)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.create(DataSourceTests.resource).method, HttpMethod.post)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.create(DataSourceTests.resource).resource, DataSourceTests.resource)
        
        
        XCTAssertEqual(DataSourceTests.dataSourceRouter.create(DataSourceTests.resourceNoId).path, DataSourceTests.router.create(resource: DataSourceTests.resourceNoId))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.create(DataSourceTests.resourceNoId).method, HttpMethod.post)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.create(DataSourceTests.resourceNoId).resource, DataSourceTests.resourceNoId)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.create(DataSourceTests.resourceNoId).path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.create(DataSourceTests.resourceNoId).method, HttpMethod.post)
        XCTAssertEqual(DataSourceTests.dataSourcePath.create(DataSourceTests.resourceNoId).resource, DataSourceTests.resourceNoId)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.create(DataSourceTests.resourceNoId).path, "\(DataSourceTests.resolvedPath)/<id>")
        XCTAssertEqual(DataSourceTests.dataSourcePathId.create(DataSourceTests.resourceNoId).method, HttpMethod.post)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.create(DataSourceTests.resourceNoId).resource, DataSourceTests.resourceNoId)
    }
    
    func testRead() {
        XCTAssertEqual(DataSourceTests.dataSourceRouter.read(id: DataSourceTests.resource.id!).path, DataSourceTests.router.read(type: DataSourceTests.resource.type, id: DataSourceTests.resource.id!))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.read(id: DataSourceTests.resource.id!).method, HttpMethod.get)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.read(id: DataSourceTests.resource.id!).resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.read(id: DataSourceTests.resource.id!).path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.read(id: DataSourceTests.resource.id!).method, HttpMethod.get)
        XCTAssertEqual(DataSourceTests.dataSourcePath.read(id: DataSourceTests.resource.id!).resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.read(id: DataSourceTests.resource.id!).path, DataSourceTests.resolvedPathId)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.read(id: DataSourceTests.resource.id!).method, HttpMethod.get)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.read(id: DataSourceTests.resource.id!).resource, nil)
    }
    
    func testUpdate() {
        XCTAssertEqual(DataSourceTests.dataSourceRouter.update(DataSourceTests.resource).path, DataSourceTests.router.update(resource: DataSourceTests.resource))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.update(DataSourceTests.resource).method, HttpMethod.patch)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.update(DataSourceTests.resource).resource, DataSourceTests.resource)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.update(DataSourceTests.resource).path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.update(DataSourceTests.resource).method, HttpMethod.patch)
        XCTAssertEqual(DataSourceTests.dataSourcePath.update(DataSourceTests.resource).resource, DataSourceTests.resource)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.update(DataSourceTests.resource).path, DataSourceTests.resolvedPathId)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.update(DataSourceTests.resource).method, HttpMethod.patch)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.update(DataSourceTests.resource).resource, DataSourceTests.resource)
        
        
        XCTAssertEqual(DataSourceTests.dataSourceRouter.update(DataSourceTests.resourceNoId).path, DataSourceTests.router.update(resource: DataSourceTests.resourceNoId))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.update(DataSourceTests.resourceNoId).method, HttpMethod.patch)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.update(DataSourceTests.resourceNoId).resource, DataSourceTests.resourceNoId)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.update(DataSourceTests.resourceNoId).path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.update(DataSourceTests.resourceNoId).method, HttpMethod.patch)
        XCTAssertEqual(DataSourceTests.dataSourcePath.update(DataSourceTests.resourceNoId).resource, DataSourceTests.resourceNoId)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.update(DataSourceTests.resourceNoId).path, "\(DataSourceTests.resolvedPath)/<id>")
        XCTAssertEqual(DataSourceTests.dataSourcePathId.update(DataSourceTests.resourceNoId).method, HttpMethod.patch)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.update(DataSourceTests.resourceNoId).resource, DataSourceTests.resourceNoId)
    }
    
    func testDelete() {
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(id: DataSourceTests.resource.id!).path, DataSourceTests.router.delete(type: DataSourceTests.resource.type, id: DataSourceTests.resource.id!))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(id: DataSourceTests.resource.id!).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(id: DataSourceTests.resource.id!).resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(id: DataSourceTests.resource.id!).path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(id: DataSourceTests.resource.id!).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(id: DataSourceTests.resource.id!).resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(id: DataSourceTests.resource.id!).path, DataSourceTests.resolvedPathId)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(id: DataSourceTests.resource.id!).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(id: DataSourceTests.resource.id!).resource, nil)
    }
    
    func testDeleteByResource() {
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(DataSourceTests.resource).path, DataSourceTests.router.delete(resource: DataSourceTests.resource))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(DataSourceTests.resource).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(DataSourceTests.resource).resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(DataSourceTests.resource).path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(DataSourceTests.resource).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(DataSourceTests.resource).resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(DataSourceTests.resource).path, DataSourceTests.resolvedPathId)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(DataSourceTests.resource).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(DataSourceTests.resource).resource, nil)
        
        
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(DataSourceTests.resourceNoId).path, DataSourceTests.router.delete(resource: DataSourceTests.resourceNoId))
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(DataSourceTests.resourceNoId).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourceRouter.delete(DataSourceTests.resourceNoId).resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(DataSourceTests.resourceNoId).path, DataSourceTests.resolvedPath)
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(DataSourceTests.resourceNoId).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourcePath.delete(DataSourceTests.resourceNoId).resource, nil)
        
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(DataSourceTests.resourceNoId).path, "\(DataSourceTests.resolvedPath)/<id>")
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(DataSourceTests.resourceNoId).method, HttpMethod.delete)
        XCTAssertEqual(DataSourceTests.dataSourcePathId.delete(DataSourceTests.resourceNoId).resource, nil)
    }
}
