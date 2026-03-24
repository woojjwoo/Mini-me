import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var players: [Player]
    @Query private var pets: [Pet]
    @Query private var schedules: [DailySchedule]

    @State private var showingResetAlert = false
    @State private var showingScheduleEditor = false
    @State private var showingPetEditor = false

    private var player: Player? { players.first }
    private var pet: Pet? { pets.first }
    private var weekdaySchedule: DailySchedule? { schedules.first { $0.isWeekday } ?? schedules.first }

    var body: some View {
        ZStack {
            PixelTheme.background.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 16) {
                    // Pet section
                    settingsSection(title: "Your Pixel Pal") {
                        if let pet = pet {
                            petRow(pet)
                        }
                    }

                    // Schedule section
                    settingsSection(title: "Daily Schedule") {
                        scheduleRow
                    }

                    // App section
                    settingsSection(title: "App") {
                        infoRow(icon: "info.circle", label: "Version", value: "1.0.0")
                        Divider()
                        dangerRow
                    }
                }
                .padding(16)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingPetEditor) {
            if let pet = pet {
                PetEditorSheet(pet: pet)
                    .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showingScheduleEditor) {
            if let schedule = weekdaySchedule {
                ScheduleEditorSheet(schedule: schedule)
                    .presentationDetents([.large])
            }
        }
        .alert("Reset All Data?", isPresented: $showingResetAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("This will delete your pet, schedule, coins, and all progress. This cannot be undone.")
        }
    }

    // MARK: - Section Builder

    private func settingsSection(title: String, @ViewBuilder content: () -> some View) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(PixelTheme.headlineFont)
                .foregroundColor(PixelTheme.text)

            VStack(spacing: 0) {
                content()
            }
            .background(PixelTheme.cardBackground)
            .cornerRadius(14)
            .shadow(color: PixelTheme.shadowColor, radius: 4, y: 2)
        }
    }

    // MARK: - Pet Row

    private func petRow(_ pet: Pet) -> some View {
        Button {
            HapticService.light()
            showingPetEditor = true
        } label: {
            HStack(spacing: 12) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(petBackgroundColor(pet.color))
                    .frame(width: 44, height: 44)
                    .overlay {
                        Text("🐱")
                            .font(.system(size: 24))
                    }

                VStack(alignment: .leading, spacing: 2) {
                    Text(pet.name)
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    Text(pet.color.displayName)
                        .font(PixelTheme.captionFont)
                        .foregroundColor(PixelTheme.text.opacity(0.5))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Schedule Row

    private var scheduleRow: some View {
        Button {
            HapticService.light()
            showingScheduleEditor = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.clock")
                    .font(.title3)
                    .foregroundColor(PixelTheme.primary)
                    .frame(width: 44, height: 44)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Edit Schedule")
                        .font(PixelTheme.bodyFont)
                        .foregroundColor(PixelTheme.text)
                    if let schedule = weekdaySchedule {
                        Text("\(schedule.blocks.count) blocks")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.5))
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(PixelTheme.text.opacity(0.3))
            }
            .padding(14)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Info Row

    private func infoRow(icon: String, label: String, value: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(PixelTheme.primary)
                .frame(width: 44, height: 44)

            Text(label)
                .font(PixelTheme.bodyFont)
                .foregroundColor(PixelTheme.text)

            Spacer()

            Text(value)
                .font(PixelTheme.captionFont)
                .foregroundColor(PixelTheme.text.opacity(0.5))
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 8)
    }

    // MARK: - Danger Zone

    private var dangerRow: some View {
        Button {
            HapticService.warning()
            showingResetAlert = true
        } label: {
            HStack(spacing: 12) {
                Image(systemName: "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundColor(.red.opacity(0.7))
                    .frame(width: 44, height: 44)

                Text("Reset All Data")
                    .font(PixelTheme.bodyFont)
                    .foregroundColor(.red.opacity(0.8))

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Actions

    private func resetAllData() {
        // Delete all data and return to onboarding
        do {
            try modelContext.delete(model: Player.self)
            try modelContext.delete(model: Pet.self)
            try modelContext.delete(model: Room.self)
            try modelContext.delete(model: RoomSlotAssignment.self)
            try modelContext.delete(model: DailySchedule.self)
            try modelContext.delete(model: TimeBlock.self)
            try modelContext.delete(model: DayLog.self)
            try modelContext.save()
        } catch {
            // Silently handle — worst case user restarts
        }
    }

    private func petBackgroundColor(_ color: PetColor) -> Color {
        switch color {
        case .orangeTabby: Color(hex: "FFD180")
        case .black: Color(hex: "4A4A4A")
        case .white: Color(hex: "F5F5F5")
        }
    }
}

// MARK: - Pet Editor Sheet

struct PetEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let pet: Pet
    @State private var editedName: String = ""
    @State private var editedColor: PetColor = .orangeTabby

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Preview
                    RoundedRectangle(cornerRadius: 20)
                        .fill(previewColor)
                        .frame(width: 100, height: 100)
                        .overlay {
                            Text("🐱")
                                .font(.system(size: 50))
                        }
                        .padding(.top, 20)

                    // Color picker
                    HStack(spacing: 16) {
                        ForEach(PetColor.allCases) { color in
                            VStack(spacing: 4) {
                                Circle()
                                    .fill(colorFill(color))
                                    .frame(width: 44, height: 44)
                                    .overlay {
                                        Circle()
                                            .stroke(editedColor == color ? PixelTheme.primary : Color.clear, lineWidth: 3)
                                    }
                                    .shadow(color: PixelTheme.shadowColor, radius: 2)

                                Text(color.displayName)
                                    .font(PixelTheme.captionFont)
                                    .foregroundColor(PixelTheme.text.opacity(0.7))
                            }
                            .onTapGesture {
                                HapticService.selection()
                                editedColor = color
                            }
                        }
                    }

                    // Name field
                    TextField("Pet name", text: $editedName)
                        .font(PixelTheme.bodyFont)
                        .padding(14)
                        .background(PixelTheme.cardBackground)
                        .cornerRadius(12)
                        .padding(.horizontal, 40)
                        .multilineTextAlignment(.center)

                    Spacer()
                }
            }
            .navigationTitle("Edit Pet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        savePet()
                        HapticService.success()
                        dismiss()
                    }
                    .disabled(editedName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                editedName = pet.name
                editedColor = pet.color
            }
        }
    }

    private var previewColor: Color {
        switch editedColor {
        case .orangeTabby: Color(hex: "FFD180")
        case .black: Color(hex: "4A4A4A")
        case .white: Color(hex: "F5F5F5")
        }
    }

    private func colorFill(_ color: PetColor) -> Color {
        switch color {
        case .orangeTabby: Color(hex: "FFB74D")
        case .black: Color(hex: "4A4A4A")
        case .white: Color(hex: "FAFAFA")
        }
    }

    private func savePet() {
        let trimmed = editedName.trimmingCharacters(in: .whitespaces)
        pet.name = trimmed.isEmpty ? "Pixel" : trimmed
        pet.color = editedColor
        try? modelContext.save()
    }
}

// MARK: - Schedule Editor Sheet

struct ScheduleEditorSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let schedule: DailySchedule
    @State private var blocks: [TimeBlock] = []
    @State private var showingAddBlock = false
    @State private var blockToDelete: TimeBlock?

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                if blocks.isEmpty {
                    VStack(spacing: 12) {
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 40))
                            .foregroundColor(PixelTheme.pending)
                        Text("No blocks yet")
                            .font(PixelTheme.bodyFont)
                            .foregroundColor(PixelTheme.text.opacity(0.5))
                        Text("Tap + to add a time block")
                            .font(PixelTheme.captionFont)
                            .foregroundColor(PixelTheme.text.opacity(0.3))
                    }
                } else {
                    List {
                        ForEach(blocks) { block in
                            HStack(spacing: 12) {
                                Image(systemName: block.blockCategory.icon)
                                    .font(.title3)
                                    .foregroundColor(block.blockCategory.color)
                                    .frame(width: 32)

                                VStack(alignment: .leading, spacing: 2) {
                                    Text(block.label)
                                        .font(PixelTheme.bodyFont)
                                        .foregroundColor(PixelTheme.text)

                                    Text("\(block.startTimeString) · \(block.durationMinutes)min")
                                        .font(PixelTheme.captionFont)
                                        .foregroundColor(PixelTheme.text.opacity(0.5))
                                }

                                Spacer()

                                Text(block.blockCategory.displayName)
                                    .font(.system(size: 10, weight: .medium, design: .rounded))
                                    .foregroundColor(block.blockCategory.color)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(block.blockCategory.color.opacity(0.12))
                                    .cornerRadius(8)
                            }
                            .listRowBackground(PixelTheme.cardBackground)
                        }
                        .onDelete { offsets in
                            deleteBlocks(at: offsets)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("Edit Schedule")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        HapticService.light()
                        showingAddBlock = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddBlock) {
                AddBlockSheet(schedule: schedule) {
                    refreshBlocks()
                }
                .presentationDetents([.medium])
            }
            .onAppear {
                refreshBlocks()
            }
        }
    }

    private func refreshBlocks() {
        blocks = schedule.sortedBlocks
    }

    private func deleteBlocks(at offsets: IndexSet) {
        for index in offsets {
            let block = blocks[index]
            schedule.blocks.removeAll { $0.id == block.id }
            modelContext.delete(block)
        }
        try? modelContext.save()
        HapticService.medium()
        refreshBlocks()
    }
}

// MARK: - Add Block Sheet

struct AddBlockSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let schedule: DailySchedule
    let onAdded: () -> Void

    @State private var selectedCategory: BlockCategory = .routine
    @State private var label: String = ""
    @State private var startHour: Int = 8
    @State private var startMinute: Int = 0
    @State private var duration: Int = 60

    var body: some View {
        NavigationStack {
            ZStack {
                PixelTheme.background.ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Category picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Category")
                                .font(PixelTheme.captionFont)
                                .foregroundColor(PixelTheme.text.opacity(0.6))

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(BlockCategory.allCases) { category in
                                        Button {
                                            HapticService.selection()
                                            selectedCategory = category
                                            if label.isEmpty || BlockCategory.allCases.map(\.displayName).contains(label) {
                                                label = category.displayName
                                            }
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: category.icon)
                                                    .font(.caption)
                                                Text(category.displayName)
                                                    .font(PixelTheme.captionFont)
                                            }
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 8)
                                            .background(selectedCategory == category ? category.color.opacity(0.25) : PixelTheme.cardBackground)
                                            .foregroundColor(selectedCategory == category ? PixelTheme.text : PixelTheme.text.opacity(0.6))
                                            .cornerRadius(10)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(selectedCategory == category ? category.color : Color.clear, lineWidth: 1.5)
                                            )
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                        }

                        // Label
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Label")
                                .font(PixelTheme.captionFont)
                                .foregroundColor(PixelTheme.text.opacity(0.6))

                            TextField("Block name", text: $label)
                                .font(PixelTheme.bodyFont)
                                .padding(12)
                                .background(PixelTheme.cardBackground)
                                .cornerRadius(10)
                        }

                        // Time picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Start Time")
                                .font(PixelTheme.captionFont)
                                .foregroundColor(PixelTheme.text.opacity(0.6))

                            HStack(spacing: 4) {
                                Picker("Hour", selection: $startHour) {
                                    ForEach(0..<24, id: \.self) { h in
                                        Text(formatHour(h)).tag(h)
                                    }
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 100, height: 100)

                                Text(":")
                                    .font(.title2)
                                    .foregroundColor(PixelTheme.text)

                                Picker("Minute", selection: $startMinute) {
                                    Text("00").tag(0)
                                    Text("15").tag(15)
                                    Text("30").tag(30)
                                    Text("45").tag(45)
                                }
                                .pickerStyle(.wheel)
                                .frame(width: 80, height: 100)
                            }
                            .frame(maxWidth: .infinity)
                        }

                        // Duration picker
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Duration")
                                .font(PixelTheme.captionFont)
                                .foregroundColor(PixelTheme.text.opacity(0.6))

                            HStack(spacing: 12) {
                                durationButton(30)
                                durationButton(60)
                                durationButton(90)
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Add Block")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addBlock()
                        HapticService.success()
                        dismiss()
                    }
                    .disabled(label.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func durationButton(_ mins: Int) -> some View {
        Button {
            HapticService.selection()
            duration = mins
        } label: {
            Text("\(mins) min")
                .font(PixelTheme.captionFont)
                .foregroundColor(duration == mins ? .white : PixelTheme.text)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(duration == mins ? PixelTheme.primary : PixelTheme.cardBackground)
                .cornerRadius(10)
        }
        .buttonStyle(.plain)
    }

    private func formatHour(_ h: Int) -> String {
        let hour = h % 12 == 0 ? 12 : h % 12
        let period = h < 12 ? "AM" : "PM"
        return "\(hour) \(period)"
    }

    private func addBlock() {
        let trimmed = label.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        let sortOrder = schedule.blocks.count
        let block = TimeBlock(
            category: selectedCategory,
            label: trimmed,
            startHour: startHour,
            startMinute: startMinute,
            durationMinutes: duration,
            sortOrder: sortOrder
        )
        schedule.blocks.append(block)
        try? modelContext.save()
        onAdded()
    }
}
