//
//  SplashView.swift
//  IceFishLogbook
//
//  Created by Anton Danilov on 5/1/26.
//

import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    
    var body: some View {
        if isActive {
            MainTabView()
        } else {
            VStack {
                Image(systemName: "snowflake.circle")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundColor(.blue)
                Text("Ice Fish Logbook")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.blue)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.blue.opacity(0.05).ignoresSafeArea())
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    withAnimation {
                        isActive = true
                    }
                }
            }
        }
    }
}


struct MainTabView: View {
    @State private var sessions: [FishingSession] = loadSessions()
    
    var body: some View {
        TabView {
            LogbookView(sessions: $sessions)
                .tabItem {
                    Label("Logbook", systemImage: "book")
                }
            
            SessionsView(sessions: $sessions)
                .tabItem {
                    Label("Sessions", systemImage: "list.bullet")
                }
            
            CalendarView(sessions: $sessions)
                .tabItem {
                    Label("Calendar", systemImage: "calendar")
                }
            
            SettingsView(sessions: $sessions)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .accentColor(.blue)
        .onAppear {
            sessions = loadSessions()
        }
    }
}
