import SwiftUI

struct ModeCardView: View {
    let title: String
    let subtitle: String
    let iconName: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack(spacing: 20) {
            Image(systemName: iconName)
                .font(.system(size: 40, weight: .regular))
                .foregroundStyle(.white)
                .frame(width: 50)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.leading)

                Text(subtitle)
                    .font(.callout)
                    .opacity(0.8)
                    .multilineTextAlignment(.leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.headline)
                .opacity(0.7)
        }
        .foregroundStyle(.white)
        .padding(EdgeInsets(top: 25, leading: 20, bottom: 25, trailing: 20))
        .background(gradient)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(
            color: .black.opacity(0.2),
            radius: 10,
            y: 5
        )
    }
}
