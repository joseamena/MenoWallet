//
//  ProfileFeature.swift
//  MenoWallet
//
//  Created by Jose A Mena on 10/3/24.
//


import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct ProfileFeature {
    
    @Dependency(\.walletService) private var walletService
    @Dependency(\.continuousClock) var clock
    
    @ObservableState
    struct State: Equatable {
        var mnemonicPhrase: String?
        var passphrase: String?
        var hideMnemonic = true
        var count = 30
        var isCounting = false
    }
    
    enum Action {
        case onAppear
        case onMnemonicAndPassphraseFetched(mnemonic: String?, passphrase: String?)
        case onRevealButtonTapped
        case timerTick
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .merge(
                    .run { send in
                        for await _ in clock.timer(interval: .seconds(1)) {
                            await send(.timerTick)
                        }
                    },
                    .run { send in
                        let passphrase = walletService.getPassphrase()
                        let privateKey = walletService.getPrivateKey()
                        
                        let mnemonicPhrase = privateKey?.toMnemonicPhrase(with: passphrase)
                        await send(
                            .onMnemonicAndPassphraseFetched(
                                mnemonic: mnemonicPhrase,
                                passphrase: passphrase
                            )
                        )
                    }
                )
            case .onMnemonicAndPassphraseFetched(let mnemonic, let passphrase):
                state.mnemonicPhrase = mnemonic
                state.passphrase = passphrase
                return .none
            case .onRevealButtonTapped:
                state.hideMnemonic = false
                state.isCounting = true
                return .none
            case .timerTick:
                guard state.isCounting else {
                    return .none
                }
                state.count -= 1
                if state.count == 0 {
                    state.isCounting = false
                    state.count = 30
                    state.hideMnemonic = true
                }
                return .none
            }
        }
    }
}

struct ProfileView: View {
    
    @Bindable var store: StoreOf<ProfileFeature>
    
    var body: some View {
        ZStack {
            Color.Theme.gradientBackground.ignoresSafeArea()
            content
                .padding()
        }
        .task {
            await store.send(.onAppear).finish()
        }
    }
    
    private var content: some View {
        VStack {
            Text("Your backup phrase")
                .typography(.title2)
            maybeMnemonicPhrase
            Spacer()
            maybeMessage
        }
    }
    
    @ViewBuilder
    private var maybeMnemonicPhrase: some View {
        if let mnemonic = store.mnemonicPhrase {
            VStack {
                VStack {
                    MnemonicPhraseView(phrase: mnemonic)
                    if let passphrase = store.passphrase {
                        Text("passphrase: \(passphrase)")
                            .typography(.body)
                    }
                }
                .blur(radius: store.hideMnemonic ? 10 : 0)
               
                warning
                revealButton
            }
        }
    }
    
    private var warning: some View {
        Text("Your Mnenomic phrase is secret, and known only to you, do not share with anyone, or they will have access to your funds")
            .multilineTextAlignment(.leading)
            .typography(.body)
    }
    
    private var revealButton: some View {
        PrimaryButton(action: { store.send(.onRevealButtonTapped) }, text: "Reveal")
            .disabled(store.isCounting)
    }
    
    @ViewBuilder
    private var maybeMessage: some View {
        if store.isCounting {
            Text("Will hide in \(store.count) seconds")
                .typography(.caption)
        }
    }
}
