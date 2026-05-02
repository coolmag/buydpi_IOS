//
//  DomainTestResultView.swift
//  ByeByeDPI
//
//  Created by developer on 13.03.2026.
//

import SwiftUI

struct DomainTestResultView: View {
    
    fileprivate let _domain: String
    fileprivate let _successRequestsCount: UInt8
    fileprivate let _totalRequestsCount: UInt8
    fileprivate let _successTest: Bool
    
    fileprivate var _formattedRequestsInfo: String {
        get {
            return String(_successRequestsCount) + "/" + String(_totalRequestsCount)
        }
    }
    
    init(domain: String, successRequestsCount: UInt8, totalRequestsCount: UInt8, successTest: Bool) {
        _domain = domain
        _successRequestsCount = successRequestsCount
        _totalRequestsCount = totalRequestsCount
        _successTest = successTest
    }
    
    var body: some View {
        var fgColor = Color(uiColor: R.color.grSecondary ?? .gray)
        if (_successTest) {
            fgColor = Color.green
        }
        return HStack(alignment: .center, spacing: .zero) {
            Text(_domain)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(fgColor)
            Spacer(minLength: 8)
            Text(_formattedRequestsInfo)
                .font(.caption)
                .lineLimit(1)
                .foregroundColor(fgColor)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 8.0) {
        DomainTestResultView(domain: "short-site.com", successRequestsCount: 1, totalRequestsCount: 2, successTest: true)
        DomainTestResultView(domain: "short-site2.com", successRequestsCount: 0, totalRequestsCount: 2, successTest: false)
        DomainTestResultView(domain: "short-site3.com", successRequestsCount: 2, totalRequestsCount: 2, successTest: true)
        DomainTestResultView(domain: "site-with-long-lon-long-long-long-long-long-long-long-long-long-long-long-long-long-long-long-long-long-name.com", successRequestsCount: 1, totalRequestsCount: 2, successTest: true)
    }
}
