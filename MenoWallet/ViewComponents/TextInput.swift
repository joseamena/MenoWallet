//
//  TextInput.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/15/24.
//

import Foundation
import SwiftUI

struct TextInput: View {
    
    let title: String?
    let placeholder: String
    let text: Binding<String>
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            if let title {
                Text(title)
                    .typography(.body).bold()
            }
            TextField(placeholder, text: text)
                .typography(.body)
                .padding()
                .frame(height: Dimensions.xxl.rawValue)
                .roundedCornerWithBorder(
                    lineWidth: 1,
                    borderColor: .black,
                    radius: Dimensions.small.rawValue,
                    corners: .allCorners
                )
                
        }
    }
}

#Preview {
    TextInput(
        title: "title",
        placeholder: "placeholder",
        text: .constant("input text")
    )
    .padding()
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

extension View {
    func roundedCornerWithBorder(lineWidth: CGFloat, borderColor: Color, radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
            .overlay(RoundedCorner(radius: radius, corners: corners)
                .stroke(borderColor, lineWidth: lineWidth))
    }
}
