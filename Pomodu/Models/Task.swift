import SwiftData
import Foundation

@Model
class Task {
    var title: String
    var isDone: Bool
    var pomodorosCompleted: Int
    var createdAt: Date
    var order: Int

    init(title: String, order: Int = 0) {
        self.title = title
        self.isDone = false
        self.pomodorosCompleted = 0
        self.createdAt = Date()
        self.order = order
    }
}
