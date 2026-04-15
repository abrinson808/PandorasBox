//n
//  PandorasBoxApp.swift
//  PandorasBox
//
//  Created by Alex Brinson on 3/31/26.
//

import SwiftUI
import SwiftData

@main
struct PandorasBoxApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: Title.self)
    }
}
