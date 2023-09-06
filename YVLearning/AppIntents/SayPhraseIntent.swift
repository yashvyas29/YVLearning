//
//  SayPhraseIntent.swift
//  YVLearning
//
//  Created by Yash Vyas on 31/05/23.
//

import AppIntents

// 1
@available(iOS 16.0, *)
struct IntentProvider: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        return [AppShortcut(intent: SayPhraseIntent(), phrases: [
            "Repeat a phrase",
            "Say a phrase",
            "Repeat something back"
        ])]
    }
}

// 2
@available(iOS 16.0, *)
struct SayPhraseIntent: AppIntent {
    // 3
    static var title: LocalizedStringResource = "Say a phrase."
    static var description = IntentDescription("Just says whatever phrase you type in.")
    
    // 4
    @Parameter(title: "Phrase")
    var phrase: String?
    
    // 5
    func perform() async throws -> some ProvidesDialog {
        guard let providedPhrase = phrase else {
            throw $phrase.needsValueError("What phrase do you want to say?")
        }
        
        return .result(dialog: IntentDialog(stringLiteral: providedPhrase))
    }
}
