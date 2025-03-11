import SwiftUI

extension Color {
    
    static let accentPrimary = Color(red: 20/255, green: 68/255, blue: 189/255)
    static let accentPrimaryAlpha = Color(red: 20/255, green: 68/255, blue: 189/255, opacity: 0.12)
    static let accentSecondary = Color(red: 26/255, green: 176/255, blue: 164/255)
    static let accentGrey = Color(red: 162/255, green: 165/255, blue: 174/255)
    static let accentGreen = Color(red: 21/255, green: 204/255, blue: 104/255)
    static let accentRed = Color(red: 236/255, green: 13/255, blue: 42/255)
    
    static let labelPrimary = Color.white
    static let labelPrimaryInvariably = Color.white
    static let labelPrimaryInverted = Color.black
    static let labelPrimaryInvertedInvariably = Color.black
    static let labelSecondary = Color.white.opacity(0.8)
    static let labelTertiary = Color.white.opacity(0.6)
    static let labelQuaternary = Color.white.opacity(0.4)
    static let labelQuintuple = Color.white.opacity(0.28)
    
    static let backgroundPrimary = Color(red: 19/255, green: 19/255, blue: 19/255)
    static let backgroundPrimaryAlpha = Color(red: 19/255, green: 19/255, blue: 19/255, opacity: 0.94)
    static let backgroundSecondary = Color(red: 45/255, green: 45/255, blue: 45/255)
    static let backgroundTertiary = Color.white.opacity(0.08)
    static let backgroundQuaternary = Color.white.opacity(0.14)
    static let backgroundDim = Color.black.opacity(0.4)
    
    static let separatorPrimary = Color.white.opacity(0.24)
    static let separatorSecondary = Color.white.opacity(0.16)
    
}
