//
//  SendReceiveCrypto.swift
//  MenoWallet
//
//  Created by Jose A Mena on 9/16/24.
//

import ComposableArchitecture
import Foundation
import SwiftUI

@Reducer
struct SendReceiveCryptoFeature {
    
    @ObservableState
    struct State: Equatable {
        let coinType: WalletService.CoinType
        @Presents var destination: Destination.State?
    }
    
    @Reducer(state: .equatable)
    enum Destination {
        case send(SendCryptoFeature)
        case receive(ReceiveCryptoFeature)
    }
    
    @CasePathable
    enum Action {
        case onAppear
        case onSendPressed
        case onReceivePressed
        case destination(PresentationAction<Destination.Action>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onAppear:
                return .none
            case .onSendPressed:
                state.destination = .send(.init())
                return .none
            case .onReceivePressed:
                state.destination = .receive(.init(coinType: state.coinType))
                return .none
            case .destination:
                return .none
            }
        }
        .ifLet(\.$destination, action: \.destination)
    }
}

struct SendReceiveCryptoView: View {
    
    @Bindable var store: StoreOf<SendReceiveCryptoFeature>
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
        ]
    var body: some View {
        LazyVGrid(columns: columns) {
            Button(action: { store.send(.onSendPressed) }, label: {
                VStack {
                    Image(systemName: "arrow.left.arrow.right")
                        .foregroundStyle(.white)
                    Text("Send")
                        .foregroundStyle(.white)
                }
                
            })
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                Color.gray
            )
            .cornerRadius(Dimensions.medium.rawValue)

            Button(action: { store.send(.onReceivePressed) }, label: {
                VStack {
                    Image(systemName: "square.and.arrow.down.fill")
                        .foregroundStyle(.white)
                    Text("Receive")
                        .foregroundStyle(.white)
                }
            })
            .frame(maxWidth: .infinity)
            .frame(height: 150)
            .background(
                Color.gray
            )
            
            .cornerRadius(Dimensions.medium.rawValue)
        }
        .task {
            await store.send(.onAppear).finish()
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.receive,
                action: \.destination.receive
            )
        ) { store in
            ReceiveCryptoView(store: store)
        }
        .sheet(
            item: $store.scope(
                state: \.destination?.send,
                action: \.destination.send
            )
        ) { store in
            SendCryptoView(store: store)
        }
    }
}

#Preview {
    SendReceiveCryptoView(
        store: .init(
            initialState: SendReceiveCryptoFeature.State(coinType: .bitcoin),
            reducer:  {
                SendReceiveCryptoFeature()
            }
        )
    )
}
