import Foundation

struct HomeRepairQuoteLogItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var contractor: String
    var amount: String
    var job: String
    var createdAt: Date = Date()
}
