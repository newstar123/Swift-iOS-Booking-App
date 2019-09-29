//
//  FakeBillWorker.swift
//  Qorum
//
//  Created by Sergey Sivak on 2/27/18.
//  Copyright © 2018 Bizico. All rights reserved.
//

import Foundation
import SwiftyJSON

/// iterates through fake stages and returns current stage if tips changed and next stage otherwise
/// if next stage is unavailable it returns current.
private class FakeStageIterator: IteratorProtocol {

    private let stages = [
        "FakeCheckinsVersionTwoStage1",
        "FakeCheckinsVersionTwoStage2",
        "FakeCheckinsVersionTwoStage3",
        "FakeCheckinsVersionTwoStage4"
    ]
    
    private var index: Int = -1
    
    fileprivate var isTipsChanged: Bool = false
    
    fileprivate var timeLeftToRideDiscount: Int = 0
    
    func next() -> JSON? {
        /* not going to next stage if tips are changed */
        if isTipsChanged {
            isTipsChanged = false
            var sameStage = stage(at: index)
            sameStage?["ridesafeDiscountStatus"]["time"]["timeLeftToRideDiscount"].int = timeLeftToRideDiscount
            return sameStage
        }
        index += 1
        let nextStage = stage(at: index)
        timeLeftToRideDiscount = nextStage?["ridesafeDiscountStatus"]["time"]["timeLeftToRideDiscount"].int ?? 0
        return nextStage
    }
    
    func current() -> JSON? {
        return stage(at: index)
    }
    
    private func stage(at index: Int) -> JSON? {
        let index = min(max(0, index), stages.count-1)
        let file = Bundle.main.url(forResource: stages[index], withExtension: "json")!
        if let data = try? Data(contentsOf: file) {
            return JSON(data)
        }
        return nil
    }
    
}

class FakeCheckinWorker: BillWorker {
    
    var checkin: Checkin?
    
    private var tips: BillModels.Tip = .percents(18) {
        didSet(oldValue) { stageIterator.isTipsChanged = tips != oldValue }
    }
    
    private let stageIterator = FakeStageIterator()
    
    private var fakeUberTimer: Timer?
    
    private func update(checkin: Checkin, with stage: JSON?) {
        checkin.inject(stage)
        checkin.inject(tips)
        self.checkin = checkin
        fakeUberTimer?.invalidate()
        if stageIterator.timeLeftToRideDiscount > 0 {
            fakeUberTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
                guard let self = self else { return }
                if self.stageIterator.timeLeftToRideDiscount > 0 {
                    self.stageIterator.timeLeftToRideDiscount -= 1
                }
            }
            fakeUberTimer?.fire()
        }
    }
    
    private func process(result: APIResult<Checkin>,
                         with stage: JSON?) -> APIResult<Checkin> {
        switch result {
        case let .value(checkin):
            update(checkin: checkin, with: stage)
            return .value(checkin)
        case let .error(error):
            if let checkin = self.checkin {
                update(checkin: checkin, with: stage)
                return .value(checkin)
            } else {
                return .error(error)
            }
        }
    }
    
    override func updateCheckIn(checkinId: Int,
                                completion: @escaping (APIResult<Checkin>) -> Void) {
        super.updateCheckIn(checkinId: checkinId) { [weak self] result in
            guard let self = self else { return }
            completion(self.process(result: result,
                                    with: self.stageIterator.next()))
        }
    }
    
    override func checkOut(checkinId: Int,
                  completion: @escaping APIHandler<Checkin>) {
        super.checkOut(checkinId: checkinId) { [weak self] result in
            guard let self = self else { return }
            completion(self.process(result: result,
                                    with: self.stageIterator.current()))
        }
    }
    
    override func updateGratuity(checkinId: Int,
                                 tip: BillModels.Tip,
                                 completion: @escaping (APIResult<JSON>) -> Void) {
        tips = tip
        completion(.value(JSON()))
    }
    
    deinit {
        fakeUberTimer?.invalidate()
    }
    
}

extension Checkin {
    
    fileprivate func inject(_ json: JSON?) {
        guard let json = json else { return }
        bill = Bill.safelyFrom(json: json["billItems"])
        if let bill = bill {
            bill.totals = BillTotals.safelyFrom(json: json["totals"])
            if let discount = json["discount"].int {
                bill.discount = discount
            }
            if let gratuity = json["gratuity"].int {
                bill.gratuity = gratuity
            }
            if let exactGratuity = json["exact_gratuity"].int {
                bill.exactGratuity = exactGratuity
            }
        }
        ridesafeStatus = RidesafeStatus.safelyFrom(json: json["ridesafeDiscountStatus"])
        if let uberDiscount = json["rideDiscount"]["discount_value"].int {
            uberDiscountValue = uberDiscount
        }
    }
    
    fileprivate func inject(_ tips: BillModels.Tip) {
        guard let bill = bill, !bill.items.isEmpty else { return }
        /* erase current tips */
        bill.totals.total -= bill.gratuityPrice
        bill.gratuity = 0
        bill.exactGratuity = 0
        /* apply fake tips */
        let total = bill.totals.subTotal + bill.totals.freeDrinksPrice
        switch tips {
        case .percents(let percents):
            bill.exactGratuity = nil
            bill.gratuity = percents
        case .cents(let cents):
            bill.exactGratuity = cents
            bill.gratuity = cents * 100 / total
        }
        let minExact = Int(kTipsMinAmount * 100)
        let minPercent = 0
        if minExact > (total * minPercent + 50) / 100 && minExact > bill.gratuityPrice {
            /* tips less then $0.00 */
            bill.exactGratuity = minExact
            bill.gratuity = minExact * 100 / total
        } else if (total * minPercent + 50) / 100 > bill.gratuityPrice && (total * minPercent + 50) / 100 > minExact {
            /* tips less then 0% */
            bill.exactGratuity = (total * minPercent + 50) / 100
            bill.gratuity = minPercent
        }
        bill.totals.total += bill.gratuityPrice
    }
    
}
