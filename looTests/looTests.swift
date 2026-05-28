//
//  looTests.swift
//  looTests
//

import Testing
import Foundation
@testable import loo

// MARK: - Helpers

private func makeWashroom(
    id: String = UUID().uuidString,
    name: String = "Test Washroom",
    gender: WashroomGender = .both,
    accessible: Bool = false,
    feeBdt: Int = 0,
    averageRating: Double? = nil,
    babyChanging: Bool? = nil,
    menstrualProducts: Bool? = nil,
    wuduArea: Bool? = nil,
    openingHoursRaw: String? = nil,
    lastVerifiedAt: Date? = nil
) -> Washroom {
    Washroom(
        id: id, name: name,
        gender: gender, accessible: accessible, feeBdt: feeBdt,
        latitude: 23.7, longitude: 90.4,
        averageRating: averageRating,
        wuduArea: wuduArea,
        babyChanging: babyChanging,
        menstrualProducts: menstrualProducts,
        lastVerifiedAt: lastVerifiedAt,
        openingHoursRaw: openingHoursRaw
    )
}

private func date(hour: Int, minute: Int = 0) -> Date {
    var c = DateComponents()
    c.year = 2026; c.month = 5; c.day = 28
    c.hour = hour; c.minute = minute
    return Calendar.current.date(from: c)!
}

// MARK: - WashroomGender

@Suite("WashroomGender") struct GenderTests {
    @Test func womenFriendlyCoversFemaleBothFamily() {
        #expect(WashroomGender.female.isWomenFriendly)
        #expect(WashroomGender.both.isWomenFriendly)
        #expect(WashroomGender.family.isWomenFriendly)
    }

    @Test func womenFriendlyExcludesMaleAndHijra() {
        #expect(!WashroomGender.male.isWomenFriendly)
        // Hijra is a separate third-gender space, not a women's space.
        #expect(!WashroomGender.hijra.isWomenFriendly)
    }
}

// MARK: - Washroom.isOpen

@Suite("Washroom.isOpen(at:)") struct OpeningHoursTests {
    @Test func nilHoursReturnsNil() {
        #expect(makeWashroom(openingHoursRaw: nil).isOpen(at: date(hour: 12)) == nil)
    }

    @Test func twentyFourSevenAlwaysOpen() {
        let w = makeWashroom(openingHoursRaw: "24/7")
        #expect(w.isOpen(at: date(hour: 3)) == true)
        #expect(w.isOpen(at: date(hour: 23, minute: 59)) == true)
    }

    @Test func sameDayWindow() {
        let w = makeWashroom(openingHoursRaw: "10:00-22:00")
        #expect(w.isOpen(at: date(hour: 9, minute: 59))  == false)
        #expect(w.isOpen(at: date(hour: 10))             == true)
        #expect(w.isOpen(at: date(hour: 15))             == true)
        #expect(w.isOpen(at: date(hour: 22))             == false) // exclusive close
        #expect(w.isOpen(at: date(hour: 22, minute: 1))  == false)
    }

    @Test func windowCrossingMidnight() {
        let w = makeWashroom(openingHoursRaw: "22:00-02:00")
        #expect(w.isOpen(at: date(hour: 21, minute: 59)) == false)
        #expect(w.isOpen(at: date(hour: 22))             == true)
        #expect(w.isOpen(at: date(hour: 0))              == true)
        #expect(w.isOpen(at: date(hour: 1, minute: 59))  == true)
        #expect(w.isOpen(at: date(hour: 2))              == false)
    }

    @Test func malformedHoursReturnsNil() {
        #expect(makeWashroom(openingHoursRaw: "not-a-range").isOpen(at: date(hour: 12)) == nil)
        #expect(makeWashroom(openingHoursRaw: "10:00").isOpen(at: date(hour: 12)) == nil)
        #expect(makeWashroom(openingHoursRaw: "ab:cd-ef:gh").isOpen(at: date(hour: 12)) == nil)
    }
}

// MARK: - FilterOptions.apply

@Suite("FilterOptions.apply") struct FilterTests {
    @Test func defaultOptionsKeepEverything() {
        let pool = [makeWashroom(), makeWashroom(gender: .male), makeWashroom(feeBdt: 50)]
        #expect(FilterOptions().apply(to: pool).count == 3)
    }

    @Test func genderFilterIsExact() {
        let pool = [
            makeWashroom(gender: .male),
            makeWashroom(gender: .female),
            makeWashroom(gender: .hijra),
        ]
        var opts = FilterOptions(); opts.genderFilter = .hijra
        let result = opts.apply(to: pool)
        #expect(result.count == 1 && result.first?.gender == .hijra)
    }

    @Test func womenFriendlyOnlyExcludesMaleAndHijra() {
        let pool = [
            makeWashroom(gender: .male),
            makeWashroom(gender: .female),
            makeWashroom(gender: .both),
            makeWashroom(gender: .hijra),
        ]
        var opts = FilterOptions(); opts.womenFriendlyOnly = true
        let result = opts.apply(to: pool)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.gender.isWomenFriendly })
    }

    @Test func freeOnlyExcludesPaid() {
        let pool = [makeWashroom(feeBdt: 0), makeWashroom(feeBdt: 5)]
        var opts = FilterOptions(); opts.freeOnly = true
        #expect(opts.apply(to: pool).count == 1)
    }

    @Test func amenityFiltersRequireTrueNotNil() {
        let pool = [
            makeWashroom(babyChanging: nil),
            makeWashroom(babyChanging: false),
            makeWashroom(babyChanging: true),
        ]
        var opts = FilterOptions(); opts.babyChangingOnly = true
        #expect(opts.apply(to: pool).count == 1)
    }

    @Test func wuduAreaFilter() {
        let pool = [makeWashroom(wuduArea: true), makeWashroom(wuduArea: nil)]
        var opts = FilterOptions(); opts.wuduAreaOnly = true
        #expect(opts.apply(to: pool).count == 1)
    }

    @Test func openNowUsesParser() {
        let pool = [
            makeWashroom(openingHoursRaw: "24/7"),
            makeWashroom(openingHoursRaw: "10:00-22:00"),
            makeWashroom(openingHoursRaw: nil),
        ]
        var opts = FilterOptions(); opts.openNow = true
        // At 3am, only 24/7 should pass; "10-22" closed, nil hours treated as closed
        let result = opts.apply(to: pool, now: date(hour: 3))
        #expect(result.count == 1)
        #expect(result.first?.openingHoursRaw == "24/7")
    }

    @Test func minRatingFilter() {
        let pool = [
            makeWashroom(averageRating: 4.5),
            makeWashroom(averageRating: 3.0),
            makeWashroom(averageRating: nil),
        ]
        var opts = FilterOptions(); opts.minRating = 4.0
        #expect(opts.apply(to: pool).count == 1)
    }

    @Test func filtersStack() {
        let pool = [
            makeWashroom(gender: .female, accessible: true,  feeBdt: 0, babyChanging: true),
            makeWashroom(gender: .female, accessible: false, feeBdt: 0, babyChanging: true),
            makeWashroom(gender: .female, accessible: true,  feeBdt: 5, babyChanging: true),
        ]
        var opts = FilterOptions()
        opts.womenFriendlyOnly = true
        opts.accessibleOnly    = true
        opts.freeOnly          = true
        opts.babyChangingOnly  = true
        #expect(opts.apply(to: pool).count == 1)
    }
}
