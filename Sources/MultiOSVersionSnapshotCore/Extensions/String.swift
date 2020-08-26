import Foundation

extension String {
    public var addDoubleQuotes: String {
        return #""\#(self)""#
    }
}
