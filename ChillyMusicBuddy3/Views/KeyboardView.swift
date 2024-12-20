import SwiftUI

struct KeyboardView: View {
    @State private var moodText: String = ""
    let currentColor: Color
    let nextColor: Color
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Tell us your current mood ✨")
                .font(.system(size: 18))
                .foregroundColor(.white)
            
            VStack(alignment: .leading, spacing: 8) {
                TextField("Enter your mood", text: $moodText)
                    .padding()
                    .background(Color.black)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [currentColor, nextColor]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .foregroundColor(.white)
                
                Text("E.g: I'm feeling okay, maybe some chill songs")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .padding(.leading, 4)
            }
            
            Button(action: {
                // Handle submit action
            }) {
                Text("Submit")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 120, height: 40)
                    .background(
                        Group {
                            if moodText.isEmpty {
                                Color.black
                            } else {
                                LinearGradient(
                                    gradient: Gradient(colors: [currentColor, nextColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            }
                        }
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                LinearGradient(
                                    gradient: Gradient(colors: [currentColor, nextColor]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                lineWidth: 2
                            )
                    )
                    .cornerRadius(12)
            }
            .disabled(moodText.isEmpty)
            
            Spacer()
        }
        .padding()
    }
}

