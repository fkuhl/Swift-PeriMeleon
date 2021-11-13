//
//  DataChecker.swift
//  PMClient
//
//  Created by Frederick Kuhl on 1/20/20.
//  Copyright © 2020 TyndaleSoft LLC. All rights reserved.
//

import SwiftUI
import Combine

class DataChecker: ObservableObject {
    @ObservedObject var document: PeriMeleonDocument
    private let checkingQueue = DispatchQueue(label: "com.tamelea.PMClient.dataChecker", qos: .background)
    private var subject: PassthroughSubject<[DataCheckReport], Never>? = nil
    private var publisher: AnyPublisher<[DataCheckReport], Never>? = nil
    private var sub: Cancellable? = nil

    @Published public var reports = [DataCheckReport]()
    
    init(document: PeriMeleonDocument) {
        self.document = document
        subject = PassthroughSubject<[DataCheckReport], Never>()
        publisher = subject?.eraseToAnyPublisher()
        sub = publisher?
            .receive(on: RunLoop.main)
            .assign(to: \.reports, on: self)
    }
    
    func check() {
        checkingQueue.async {
            self.checkData()
        }
    }
    
    func checkData() {
        let reports: [DataCheckReport] = document.activeMembers.compactMap {
            guard let lastTransaction = $0.transactions.last else {
                return nil //nothing to check
            }
            let lastTT = lastTransaction.type
            let status = $0.status
            let name = $0.fullName()
            switch status {
            case .NONCOMMUNING:
                switch lastTT {
                case .BIRTH, .RECEIVED:
                    return nil
                default:
                    return DataCheckReport(name: name, status: status, trans: lastTT)
                }
            case .COMMUNING:
                switch lastTT {
                case .PROFESSION, .RECEIVED, .SUSPENSION_LIFTED, .RESTORED:
                    return nil
                default:
                    return DataCheckReport(name: name, status: status, trans: lastTT)
                }
            case .ASSOCIATE:
                if lastTT == .RECEIVED { return nil }
                return DataCheckReport(name: name, status: status, trans: lastTT)
            case .EXCOMMUNICATED:
                if lastTT == .EXCOMMUNICATED { return nil }
                return DataCheckReport(name: name, status: status, trans: lastTT)
            case .SUSPENDED:
                if lastTT == .SUSPENDED { return nil }
                return DataCheckReport(name: name, status: status, trans: lastTT)
            case .DISMISSAL_PENDING:
                if lastTT == .DISMISSAL_PENDING { return nil }
                return DataCheckReport(name: name, status: status, trans: lastTT)
            case .DISMISSED:
                if lastTT == .DISMISSED { return nil }
                return DataCheckReport(name: name, status: status, trans: lastTT)
            case .REMOVED:
                if lastTT == .REMOVED_ADMIN { return nil }
                return DataCheckReport(name: name, status: status, trans: lastTT)
            case .DEAD:
                if lastTT == .DIED { return nil }
                return DataCheckReport(name: name, status: status, trans: lastTT)
                case .PASTOR:
                return nil //this shouldn't arise: no trans
            }
        }
        subject?.send(reports)
    }
}
