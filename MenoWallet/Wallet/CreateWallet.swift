//
//  CreateWallet.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

//@Reducer
struct CreateWalletFeature: Reducer {
    
    @Dependency(\.keychain) private var keychain
    @Dependency(\.walletService) private var walletService
    
    @ObservableState
    struct State: Equatable {
        var mnemonic: [String] = []
        var passphrase: String = ""
        var privateKeyData: Data?
    }
    
    @CasePathable
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onGenerateMnemonicPhraseTapped
        case onMnemonicGenerated(words: [String], data: Data)
        case saveAndContinue
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .onGenerateMnemonicPhraseTapped:
                return .run { [passphrase = state.passphrase] send in
                    let (words, data) = walletService.createNewWallet(passphrase)
                    await send(.onMnemonicGenerated(words: words, data: data))
                }
            case .onMnemonicGenerated(let words, let data):
                state.mnemonic = words
                state.privateKeyData = data
                return .none
            case .binding:
                return .none
            case .saveAndContinue:
                guard let privateKeyData = state.privateKeyData else {
                    return .none
                }
                keychain.saveDataValueForKey(privateKeyData, .privateKey)
                
                if !state.passphrase.isEmpty {
                    keychain.saveStringValueForKey(state.passphrase, .walletPassphrase)
                }
                return .none
            }
        }
    }
}

struct CreateWalletView: View {
    @Bindable var store: StoreOf<CreateWalletFeature>

    var body: some View {
        ZStack {
            Color.Theme.background.ignoresSafeArea()
            content
                .padding()
        }
        .task {
            await store.send(.onAppear).finish()
        }
    }
    
    private var content: some View {
        mnemonicPhrase
    }

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var mnemonicPhrase: some View {
        VStack {
            Text("Your Generated Mnemonic Phrase")
                .multilineTextAlignment(.center)
                .typography(.title)
            
            maybeGeneratedMnemonicPhrase
            
            Text("Write it down and keep it safe")
                .multilineTextAlignment(.center)
                .typography(.body)
            
            Spacer()
            
            continueButton
        }
    }
    
    @ViewBuilder
    private var maybeGeneratedMnemonicPhrase: some View {
        VStack {
            Group {
                if store.mnemonic.isEmpty {
                    Button("Tap To Generate Your Phrase") {
                        store.send(.onGenerateMnemonicPhraseTapped)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .typography(.title2)
                } else {
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(Array(zip(store.mnemonic.indices, store.mnemonic)), id: \.0) { index, item in
                            HStack {
                                Text("\(index + 1). \(item)")
                                    .typography(.body)
                                Spacer()
                            }
                        }
                    }
                    .padding()
                }
            }
            .frame(maxWidth: .infinity)
            .frame(idealHeight: 200, maxHeight: 300)
            .background(Color.Theme.background)
            .cornerRadius(Dimensions.medium.rawValue)
            .shadow(radius: 10, x: 5, y: 5)
        
            TextInput(
                title: "Enter passphrase",
                placeholder: "passphrase",
                text: $store.passphrase
            )
        }
    }
    
    private var continueButton: some View {
        PrimaryButton(action: { store.send(.saveAndContinue) }, text: "Save and continue")
            .disabled(store.privateKeyData == nil)
            .opacity(store.privateKeyData != nil ? 1 : 0.5)
    }
}

//#Preview {
//    CreateWalletView(
//        store: .init(
//            initialState: CreateWalletFeature.State(),
//            reducer: { CreateWalletFeature() }
//        )
//    )
//}
