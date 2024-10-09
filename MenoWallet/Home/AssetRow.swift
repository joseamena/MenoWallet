//
//  AssetRow.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import SwiftUI

struct AssetRow: View {
    let imageUrl: String
    let title: String
    let code: String?
    let price: String
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: imageUrl))
            VStack(alignment: .leading) {
                Text(title)
                    .typography(.title2)
                if let code {
                    Text(code)
                        .typography(.caption)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text(price)
                    .typography(.body)
            }
        }
        .padding()
        .background {
            Color.Theme.background
        }
        .cornerRadius(Dimensions.medium.rawValue)
        .shadow(radius: 10, x: 5, y: 5)
    }
}

#Preview {
    AssetRow(
        imageUrl: "https://lcw.nyc3.cdn.digitaloceanspaces.com/production/currencies/32/eth.png",
        title: "Litecoin",
        code: "LTC",
        price: "$51,234.54"
    )
}
