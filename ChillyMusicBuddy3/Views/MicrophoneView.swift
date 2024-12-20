import SwiftUI

struct MicrophoneView: View {
    let currentColor: Color
    let nextColor: Color
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Speak Your Mood 🎤")
                .font(.system(size: 18))
                .foregroundColor(.white)
            
            // Placeholder for microphone functionality
            Button(action: {
                // Handle microphone action
            }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "1F2937"))
                        .frame(width: 200, height: 200)
                        .overlay(
                            Circle()
                                .stroke(
                                    LinearGradient(
                                        gradient: Gradient(colors: [currentColor, nextColor]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        )
                    
                    Image(systemName: "mic.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white)
                }
            }
            
            Spacer()
        }
        .padding()
    }
}

