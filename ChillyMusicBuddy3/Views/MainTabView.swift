import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isShowingNewPostModal = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                HomeView()
                    .tabItem {
                        Image(systemName: "house.fill")
                    }
                    .tag(0)
                
                FavoritesView()
                    .tabItem {
                        Image(systemName: "bolt.heart.fill")
                    }
                    .tag(1)
                
                Color.clear
                    .tabItem {
                        Image(systemName: "plus")
                    }
                    .tag(2)
                
                MoodInputView() // Changed from MusicView to avoid recursion
                    .tabItem {
                        Image(systemName: "music.note")
                    }
                    .tag(3)
                
                ProfileView()
                    .tabItem {
                        Image(systemName: "person.fill")
                    }
                    .tag(4)
            }
            .accentColor(Color(hex: "57D0FF"))
            .onAppear {
                UITabBar.appearance().backgroundColor = .black
            }
            
            ShazamButton(action: {
                isShowingNewPostModal = true
            })
            .offset(y: -15) // Adjusted back to -15 for better alignment
        }
        .sheet(isPresented: $isShowingNewPostModal) {
            NewPostModal()
        }
    }
}

struct HomeView: View {
    var body: some View {
        ChillyPlaylistView()
    }
}

struct FavoritesView: View {
    var body: some View {
        Text("Favorites")
            .foregroundColor(.white)
    }
}

// Renamed MusicView to MoodInputView to avoid naming conflict
typealias MoodInputView = MusicView

struct ProfileView: View {
    var body: some View {
        Text("Profile")
            .foregroundColor(.white)
    }
}

struct NewPostModal: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Text("New Post")
                .foregroundColor(.white)
                .navigationBarTitle("New Post", displayMode: .inline)
                .navigationBarItems(trailing: Button("Close") {
                    presentationMode.wrappedValue.dismiss()
                })
        }
        .preferredColorScheme(.dark)
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
            .preferredColorScheme(.dark)
    }
}
