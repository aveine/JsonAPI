import XCTest
import JsonAPI

class ScrudRouterTests: XCTestCase {
    let router: Router = ScrudRouter()
    let type: String = "articles"
    let id: String = "customId"
    let resource: Resource = Article()
    
    func testSearch() {
        XCTAssertEqual(self.router.search(type: self.type), self.type)
    }
    
    func testCreate() {
        XCTAssertEqual(self.router.create(resource: self.resource), self.type)
    }
    
    func testRead() {
        XCTAssertEqual(self.router.read(type: self.type, id: self.id), "\(self.type)/\(self.id)")
    }
    
    func testUpdate() {
        resource.id = self.id
        XCTAssertEqual(self.router.update(resource: self.resource), "\(self.resource.type)/\(self.resource.id ?? "")")
        
        resource.id = nil
        XCTAssertEqual(self.router.update(resource: self.resource), "\(self.type)/")
    }
    
    func testDelete() {
        XCTAssertEqual(self.router.delete(type: self.type, id: self.id), "\(self.type)/\(self.id)")
    }
    
    func testDeleteByResource() {
        resource.id = self.id
        XCTAssertEqual(self.router.delete(resource: self.resource), "\(self.resource.type)/\(self.resource.id ?? "")")
        
        resource.id = nil
        XCTAssertEqual(self.router.delete(resource: self.resource), "\(self.type)/")
    }
    
}
