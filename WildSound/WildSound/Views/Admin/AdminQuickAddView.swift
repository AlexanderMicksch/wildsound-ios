//
//  AdminQuickAddView.swift
//  WildSound
//
//  Created by Alexander Micksch on 15.08.25.
//

import SwiftUI
import SwiftData

struct AdminQuickAddView: View {
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Animal.name, order: .forward) private var animals: [Animal]
    
    @State private var nameInput: String = ""
    @State private var storagePathInput: String = ""
    @State private var wikiTitleDeInput: String = ""
    @State private var showSavedBanner: Bool = false
    @State private var selectedSoundSource: SoundSource = .xenoCanto
    
    private var isValid: Bool {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStoragePath = storagePathInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWikiTitleDe = wikiTitleDeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return !trimmedName.isEmpty
        && Self.isValidStoragePath(trimmedStoragePath)
        && !trimmedWikiTitleDe.isEmpty
    }
    
    private static func isValidStoragePath(_ path: String) -> Bool {
        guard !path.isEmpty else { return false }
        if path.lowercased().hasPrefix("http") { return false }
        return path.contains("/")
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Neues Tier hinzufügen") {
                    TextField("Name", text: $nameInput)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    
                    TextField("Storage-Pfad (Firebase Storage)", text: $storagePathInput)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .keyboardType(.asciiCapable)
                    
                    TextField("Wikipedia-Titel (DE)", text: $wikiTitleDeInput)
                        .textInputAutocapitalization(.words)
                        .autocorrectionDisabled()
                    
                    Section("Herkunft des Sounds") {
                        Picker("Quelle", selection: $selectedSoundSource) {
                            ForEach(SoundSource.allCases, id: \.self) { source in
                                Text(source.displayName).tag(source)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    
                    Button("Hinzufügen", action: addAnimal)
                        .disabled(!isValid)
                }
                
                Section("Gespeicherte Tiere (\(animals.count))") {
                    if animals.isEmpty {
                        Text("Noch keine Tiere gespeichert")
                            .foregroundStyle(.secondary)
                    } else {
                        List {
                            ForEach(animals, id: \.id) { animal in
                                VStack(alignment: .leading, spacing: 5) {
                                    Text(animal.name).bold()
                                    Text(animal.storagePath)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                            .onDelete(perform: deleteAnimals)
                        }
                        .frame(minHeight: 120)
                    }
                }
            }
            .navigationTitle("Admin - Quick Add")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Felder leeren", role: .destructive) {
                        nameInput = ""
                        storagePathInput = ""
                        wikiTitleDeInput = ""
                    }
                    .disabled(nameInput.isEmpty && storagePathInput.isEmpty && wikiTitleDeInput.isEmpty)
                }
            }
            .overlay(alignment: .bottom) {
                if showSavedBanner {
                    Text("Gespeichert CHECK")
                        .padding(.horizontal, 10)
                        .padding(.vertical, 10)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                        .padding(.bottom, 15)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
    }
    
    private func addAnimal() {
        let trimmedName = nameInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedStoragePath = storagePathInput.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedWikiTitleDe = wikiTitleDeInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let newAnimal = Animal(
            name: trimmedName,
            storagePath: trimmedStoragePath,
            wikiTitleDe: trimmedWikiTitleDe,
            wikiTitleEn: nil,
            isFavorite: false,
            guessedCount: 0,
            soundSource: selectedSoundSource
        )
        
        modelContext.insert(newAnimal)
        _ = try? modelContext.save()
        
        nameInput = ""
        storagePathInput = ""
        wikiTitleDeInput = ""
        
        withAnimation(.easeInOut(duration: 0.2)) { showSavedBanner = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            withAnimation(.easeInOut(duration: 0.2)) { showSavedBanner = false }
        }
    }
    
    private func deleteAnimals(_ indexSet: IndexSet) {
        for index in indexSet {
            modelContext.delete(animals[index])
        }
        _ = try? modelContext.save()
    }
}

#Preview {
    AdminQuickAddView()
}
