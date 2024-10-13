//
//  ImportWallet.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/13/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct ImportWalletFeature {

    @Dependency(\.dismiss) private var dismiss
    @Dependency(\.walletService) private var walletService

    @ObservableState
    struct State: Equatable {
        var mnemonicPhrase: String = ""
        var passphrase: String = ""
    }

    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onContinueTapped
        case onCancelTapped
    }

    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .onContinueTapped:
                return .run { [state] send in
                    try walletService.importWallet(state.mnemonicPhrase, state.passphrase)
                }
            case .onCancelTapped:
                return .run { _ in await dismiss() }
            case .binding:
                return .none
            }
        }
    }
}

struct ImportWalletView: View {
    
    @Bindable var store: StoreOf<ImportWalletFeature>
   
    var body: some View {
        ZStack {
            Color.Theme.background.ignoresSafeArea()
            content
                .padding()
        }
        .navigationBarBackButtonHidden()
    }

    private var content: some View {
        VStack {
            title
            phraseInput
            passPhraseInput
            Spacer()
            buttons
        }
    }
    
    private var title: some View {
        Text("Import Wallet")
            .typography(.title).bold()
            .padding(.top, Dimensions.extraLarge.rawValue)
    }
    
    private var phraseInput: some View {
        VStack {
            TextEditor(text: $store.mnemonicPhrase)
                .autocapitalization(.none)
                .frame(height: 200)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding()
                .background(Color.white)
                .cornerRadius(10)
                .shadow(radius: 3)
            
            Text("Enter your 12-24 word mnemonic phrase to recover your wallet.")
                .foregroundColor(Color.Theme.veryDarkGray)
                .font(.subheadline)
                .padding(.horizontal)
        }
    }
    
    private var passPhraseInput: some View {
        SecureField("Enter passphrase (optional)", text: $store.passphrase)
            .autocapitalization(.none)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
            .shadow(radius: 3)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
            .padding(.horizontal)
    }
    
    private var buttons: some View {
        HStack(spacing: Dimensions.medium.rawValue) {
            SecondaryButton(action: { store.send(.onCancelTapped) }, text: "Cancel")
            PrimaryButton(action: { store.send(.onContinueTapped) }, text: "Continue")
        }
        .padding(.horizontal)
        .padding(.bottom, 40)
    }
}
