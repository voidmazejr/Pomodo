import SwiftData
import SwiftUI
import Combine

@MainActor
class TodoViewModel: ObservableObject {
    @Published var newTaskTitle: String = ""

    func addTask(context: ModelContext) {
        let trimmed = newTaskTitle.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let taskCount = (try? context.fetchCount(FetchDescriptor<Task>())) ?? 0
        let task = Task(title: trimmed, order: taskCount)
        context.insert(task)
        newTaskTitle = ""
    }

    func toggleDone(_ task: Task) {
        task.isDone.toggle()
    }

    func deleteTask(_ task: Task, context: ModelContext) {
        context.delete(task)
    }

    func moveTask(tasks: [Task], from source: IndexSet, to destination: Int) {
        var reordered = tasks
        reordered.move(fromOffsets: source, toOffset: destination)
        for (index, task) in reordered.enumerated() {
            task.order = index
        }
    }
}
