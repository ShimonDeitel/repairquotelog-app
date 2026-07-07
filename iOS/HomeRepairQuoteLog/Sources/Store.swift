import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published var items: [HomeRepairQuoteLogItem] = []
    @Published var isPro: Bool = false

    /// Free tier limit is intentionally well above seed data count so a fresh
    /// install never trips the paywall immediately.
    static let freeLimit = 15

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("repairquotelog_items.json")
        load()
    }

    func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([HomeRepairQuoteLogItem].self, from: data) else {
            items = [
        HomeRepairQuoteLogItem(contractor: "Reliable Roofing Co.", amount: "4200", job: "Roof shingle replacement"),
        HomeRepairQuoteLogItem(contractor: "Ace Plumbing", amount: "650", job: "Water heater install"),
        HomeRepairQuoteLogItem(contractor: "BrightPath Electric", amount: "1150", job: "Panel upgrade")
            ]
            save()
            return
        }
        items = decoded
    }

    func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }

    var canAddMore: Bool {
        isPro || items.count < Store.freeLimit
    }

    @discardableResult
    func add(_ item: HomeRepairQuoteLogItem) -> Bool {
        guard canAddMore else { return false }
        items.insert(item, at: 0)
        save()
        return true
    }

    func update(_ item: HomeRepairQuoteLogItem) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: HomeRepairQuoteLogItem) {
        items.removeAll(where: { $0.id == item.id })
        save()
    }
}
