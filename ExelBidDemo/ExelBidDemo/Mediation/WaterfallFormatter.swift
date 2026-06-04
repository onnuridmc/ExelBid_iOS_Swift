import Foundation
import ExelBidSDK

/// Shared `EBWaterfallEvent` → log-line formatter used by all four
/// Mediated* example screens so the trace shape stays consistent across
/// formats.
enum WaterfallFormatter {

    static func format(_ event: EBWaterfallEvent) -> String {
        switch event {
        case .fetching:
            return "fetching…"
        case .fetched(let networks):
            return "fetched: [\(networks.joined(separator: ", "))]"
        case .trying(let net, _, let pos, let total):
            return "\(pos)/\(total) trying → \(net)"
        case .won(let net, _, let latency):
            return "won: \(net) (\(Int(latency * 1000))ms)"
        case .lost(let net, _, let reason):
            return "lost: \(net) (\(reasonString(reason)))"
        case .noFill:
            return "noFill — all networks failed"
        }
    }

    private static func reasonString(_ reason: EBWaterfallFailReason) -> String {
        switch reason {
        case .adapterNotRegistered:
            return "adapterNotRegistered"
        case .loadFailed(let error):
            return "loadFailed: \(error.localizedDescription)"
        case .timeout(let seconds):
            return "timeout \(seconds)s"
        case .cancelled:
            return "cancelled"
        }
    }
}
