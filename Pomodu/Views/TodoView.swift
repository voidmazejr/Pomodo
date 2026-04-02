import SwiftUI
import SwiftData

struct TodoView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \Task.order, order: .forward) private var tasks: [Task]
    @StateObject private var vm = TodoViewModel()

    var body: some View {
        VStack(spacing: 0) {
            if tasks.isEmpty {
                Spacer()
                Text("no tasks yet")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
                Spacer()
            } else {
                List {
                    ForEach(tasks) { task in
                        // Pass the task to the row
                        TodoRow(
                            task: task,
                            onToggle: { vm.toggleDone(task) },
                            onDelete: { vm.deleteTask(task, context: context) }
                        )
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                    }
                    .onMove { source, destination in
                        vm.moveTask(tasks: tasks, from: source, to: destination)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }

            // Input section
            HStack(spacing: 6) {
                TextField("add a task…", text: $vm.newTaskTitle)
                    .textFieldStyle(.plain)
                    .font(.system(size: 12))
                    .foregroundColor(.white)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 6)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(7)
                    .onSubmit { vm.addTask(context: context) }

                Button("+") { vm.addTask(context: context) }
                    .buttonStyle(.plain)
                    .font(.system(size: 15))
                    .foregroundColor(.gray)
                    .frame(width: 28, height: 28)
                    .background(Color.white.opacity(0.07))
                    .cornerRadius(7)
            }
            .padding(.top, 8)
        }
        .padding(12)
    }
}

struct TodoRow: View {
    @Bindable var task: Task // Ensures the UI updates when isDone changes
    var onToggle: () -> Void
    var onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(
                        task.isDone ? Color.white.opacity(0.9) : Color.gray.opacity(0.5),
                        lineWidth: 0.5
                    )
                    .frame(width: 14, height: 14)
                    .background(task.isDone ? Color.white.opacity(0.9) : Color.clear)
                    .cornerRadius(4)

                if task.isDone {
                    Image(systemName: "checkmark")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.black)
                }
            }
            .contentShape(Rectangle()) // Makes the whole square clickable
            .onTapGesture { onToggle() }

            Text(task.title)
                .font(.system(size: 12))
                .foregroundColor(task.isDone ? .gray : .white)
                .strikethrough(task.isDone, color: .gray)

            Spacer()

            // Pomodoro Dots
            HStack(spacing: 3) {
                ForEach(0..<4, id: \.self) { i in
                    Circle()
                        .fill(i < task.pomodorosCompleted ? Color.white.opacity(0.85) : Color.white.opacity(0.15))
                        .frame(width: 5, height: 5)
                }
            }
        }
        .padding(.vertical, 7)
        .padding(.horizontal, 4) // Added a tiny bit of breath for the List container
        .background(Color.black.opacity(0.001)) // Helps with drag-and-drop hit testing
        .overlay(
            Rectangle()
                .fill(Color.white.opacity(0.07))
                .frame(height: 0.5),
            alignment: .bottom
        )
        .contextMenu {
            Button("Delete task", role: .destructive) { onDelete() }
        }
    }
}
