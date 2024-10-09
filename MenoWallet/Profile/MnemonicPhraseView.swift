//
//  MnemonicPhraseView.swift
//  MenoWallet
//
//  Created by Jose A Mena on 10/3/24.
//

import Foundation
import SwiftUI

struct MnemonicPhraseView: View {
    
    var phrase: String
    
    var phraseArray: [String] {
        phrase.components(separatedBy: " ")
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
       mnemonicPhrase
    }
    
    private var mnemonicPhrase: some View {
        VStack {
            LazyVGrid(columns: columns, spacing: 10) {
                ForEach(Array(zip(phraseArray.indices, phraseArray)), id: \.0) { index, item in
                    HStack {
                        Text("\(index + 1). \(item)")
                            .typography(.body)
                        Spacer()
                    }
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .frame(idealHeight: 200, maxHeight: 300)
            .background(Color.Theme.background)
            .cornerRadius(Dimensions.medium.rawValue)
            .shadow(radius: 10, x: 5, y: 5)
        }
    }
}
