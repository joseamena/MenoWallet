//
//  SendCrypto.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/16/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct SendCryptoFeature {
    
    @Dependency(\.bitcoinService) private var bitcoinService
    
    @ObservableState
    struct State: Equatable {
        var address: String = ""
        var balance: Decimal = 0
    }
    
    @CasePathable
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case onAppear
        case onSendPressed
        case onBalanceFetched(Decimal)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .run { send in
                    do {
                        let balance = try await bitcoinService.fetchBalance()
                        await send(.onBalanceFetched(balance))
                    } catch {
                        print("JM", error)
                    }
                }
            case .onBalanceFetched(let balance):
                state.balance = balance
                return .none
            case .onSendPressed:
                return .run { send in
                    do {
                        _ = try await bitcoinService.sendToAddress("mrDqzGkz1TcRV9YAfX7QWG7ci9KipcuYDP", 100)
                    } catch {
                        print("JM", error)
                    }
                }
            case .binding:
                return .none
            }
        }
    }
}

struct SendCryptoView: View {
    @Bindable var store: StoreOf<SendCryptoFeature>
    
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
        VStack {
            balance
            recipientAddressInput
            sendButton
        }
    }
    
    private var balance: some View {
        Text(store.balance.asCurrency(currencyCode: "BTC"))
    }
    
    private var recipientAddressInput: some View {
        TextField("Address", text: $store.address)
            .frame(maxWidth: .infinity)
    }
    
    private var sendButton: some View {
        PrimaryButton(action: { store.send(.onSendPressed) }, text: "Send")
            .isDisabled(!store.address.isValidBitcoinAddress)
    }
}
