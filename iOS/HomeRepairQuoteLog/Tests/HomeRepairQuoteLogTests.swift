import XCTest
@testable import HomeRepairQuoteLog

@MainActor
final class StoreTests: XCTestCase {
    var store: Store!

    override func setUp() {
        super.setUp()
        store = Store()
        store.items = []
        store.isPro = false
    }

    func testAddItem() {
        let item = HomeRepairQuoteLogItem(contractor: "A", amount: "B", job: "C")
        let added = store.add(item)
        XCTAssertTrue(added)
        XCTAssertEqual(store.items.count, 1)
    }

    func testFreeLimitBlocksAdd() {
        for i in 0..<Store.freeLimit {
            store.add(HomeRepairQuoteLogItem(contractor: "\(i)", amount: "B", job: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit)
        let blocked = store.add(HomeRepairQuoteLogItem(contractor: "over", amount: "B", job: "C"))
        XCTAssertFalse(blocked)
        XCTAssertEqual(store.items.count, Store.freeLimit)
    }

    func testProBypassesLimit() {
        store.isPro = true
        for i in 0..<(Store.freeLimit + 5) {
            store.add(HomeRepairQuoteLogItem(contractor: "\(i)", amount: "B", job: "C"))
        }
        XCTAssertEqual(store.items.count, Store.freeLimit + 5)
    }

    func testDeleteItem() {
        let item = HomeRepairQuoteLogItem(contractor: "A", amount: "B", job: "C")
        store.add(item)
        store.delete(item)
        XCTAssertTrue(store.items.isEmpty)
    }

    func testUpdateItem() {
        var item = HomeRepairQuoteLogItem(contractor: "A", amount: "B", job: "C")
        store.add(item)
        item.contractor = "Updated"
        store.update(item)
        XCTAssertEqual(store.items.first?.contractor, "Updated")
    }

    func testCanAddMoreTrueInitially() {
        XCTAssertTrue(store.canAddMore)
    }

    func testDeleteAtOffsets() {
        store.add(HomeRepairQuoteLogItem(contractor: "A", amount: "B", job: "C"))
        store.add(HomeRepairQuoteLogItem(contractor: "D", amount: "E", job: "F"))
        store.delete(at: IndexSet(integer: 0))
        XCTAssertEqual(store.items.count, 1)
    }

    func testPersistenceRoundTrip() {
        store.add(HomeRepairQuoteLogItem(contractor: "Persist", amount: "B", job: "C"))
        let reloaded = Store()
        XCTAssertTrue(reloaded.items.contains(where: { $0.contractor == "Persist" }))
    }
}
