import SwiftUI

struct ChillyPlaylistView: View {
    @State private var playlistId: String = ""
    
    private let gradientColors = [
        Color(hex: "00C0F9"),
        Color(hex: "DC00FE")
    ]
    
    var body: some View {
        ZStack {
            // Background color
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 24) {
                // Title and subtitle
                Text("Chilly")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(.white)
                
                Text("Let me hear you.")
                    .font(.system(size: 24))
                    .foregroundColor(.gray)
                
                // Penguin image
                Image("chilly-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 120, height: 120)
                    .background(Color(hex: "00C0F9"))
                    .cornerRadius(12)
                
                // Playlist ID section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Sample Playlist ID: xxxxxxxxxxxxxxxxxxxxx")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                    
                    TextField("Enter your Spotify Playlist ID", text: $playlistId)
                        .textFieldStyle(CustomTextFieldStyle())
                }
                
                // Main buttons
                Button(action: { }) {
                    GradientButton(text: "Load Full Playlist")
                }
                
                Spacer()
                
                // Additional buttons
                Button(action: { }) {
                    GradientButtonOutline(text: "Open Playlist in Spotify")
                }
                
                Button(action: { }) {
                    GradientButtonOutline(text: "Clear Full Playlist")
                }
                
                
            }
            .padding()
        }
    }
}

// Custom UI Components
struct GradientButton: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [Color(hex: "00C0F9"), Color(hex: "DC00FE")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(12)
    }
}

struct GradientButtonOutline: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.system(size: 16, weight: .semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "00C0F9"), Color(hex: "DC00FE")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
    }
}

struct CustomTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.black)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(
                        LinearGradient(
                            gradient: Gradient(colors: [Color(hex: "00C0F9"), Color(hex: "DC00FE")]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .foregroundColor(.white)
    }
}


//// Color extension for hex colors
//extension Color {
//    init(hex: String) {
//        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
//        var int: UInt64 = 0
//        Scanner(string: hex).scanHexInt64(&int)
//        let a, r, g, b: UInt64
//        switch hex.count {
//        case 3:
//            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
//        case 6:
//            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
//        case 8:
//            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
//        default:
//            (a, r, g, b) = (255, 0, 0, 0)
//        }
//        self.init(
//            .sRGB,
//            red: Double(r) / 255,
//            green: Double(g) / 255,
//            blue: Double(b) / 255,
//            opacity: Double(a) / 255
//        )
//    }
//}

// Preview
struct ChillyPlaylistView_Previews: PreviewProvider {
    static var previews: some View {
        ChillyPlaylistView()
    }
}

