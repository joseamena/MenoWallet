//
//  ReceiveCrypto.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/16/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct ReceiveCryptoFeature {
    
    @Dependency(\.keychain) private var keychain
    @Dependency(\.walletService) private var walletService
    
    @ObservableState
    struct State {
        var address: String?
    }
    
    enum Action {
        case onAppear
        case addressGenerated(String?)
        case copyToClipboard
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    let address = walletService.getAddressForCoin(.bitcoin)
                    await send(.addressGenerated(address))
                }
            case .addressGenerated(let address):
                state.address = address
                return .none
            case .copyToClipboard:
                let pasteboard = UIPasteboard.general
                pasteboard.string = state.address
                return .none
            }
        }
    }
}

struct ReceiveCryptoView: View {
    @Bindable var store: StoreOf<ReceiveCryptoFeature>
    
    var body: some View {
        ZStack {
            Color.Theme.background.ignoresSafeArea()
            content
                .padding()
        }
    }
    
    
    private var content: some View {
        VStack {
            qrCode
            store.address.map(Text.init)
            PrimaryButton(action: { store.send(.copyToClipboard) }, text: "Copy to clipboard")
        }
        .task {
            await store.send(.onAppear).finish()
        }
    }
    
    @ViewBuilder
    private var qrCode: some View {
        if let address = store.address, let uiImage = generateQRCode(from: address){
            Image(uiImage: uiImage)
                .resizable()
                .interpolation(.none)
                .aspectRatio(1, contentMode: .fit)
        }
    }
    
    private func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)
        let context = CIContext()
        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            filter.setValue("H", forKey: "inputCorrectionLevel")

            let transform = CGAffineTransform(scaleX: 3, y: 3)
            
            if let output = filter.outputImage?.transformed(by: transform),
                let cgImage = context.createCGImage(output, from: output.extent) {
                return UIImage(cgImage: cgImage)
            }
        }

        return nil
    }
}
