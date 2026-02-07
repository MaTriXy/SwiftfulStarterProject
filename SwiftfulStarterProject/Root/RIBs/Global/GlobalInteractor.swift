//
//  GlobalInteractor.swift
//  SwiftfulStarterProject
//
//  
//
@MainActor
protocol GlobalInteractor {
    func trackEvent(eventName: String, parameters: [String: Any]?, type: LogType)
    func trackEvent(event: AnyLoggableEvent)
    func trackEvent(event: LoggableEvent)
    func trackScreenEvent(event: LoggableEvent)
    
    func prepareHaptic(option: HapticOption)
    func playHaptic(option: HapticOption)
    func tearDownHaptic(option: HapticOption)

    func prepareSoundEffect(sound: SoundEffectFile, simultaneousPlayers: Int)
    func playSoundEffect(sound: SoundEffectFile)
    func tearDownSoundEffect(sound: SoundEffectFile)
}
