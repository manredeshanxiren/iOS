//
//  MemorizeApp.swift
//  Memorize
//
//  Created by qingyangmi on 2025/3/10.
//

import SwiftUI

@main
struct MemorizeApp: App {
    
    @StateObject var game = EmojiMemorizeGame()
    
    var body: some Scene {
        WindowGroup {
            EmojiMemoryGameView(viewModel: game)
        }
    }
}
