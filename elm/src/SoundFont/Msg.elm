module SoundFont.Msg exposing (..)

import SoundFont.Types exposing (..)
import Time
import Phoenix.Socket


type Msg
    = InitialiseAudioContext
    | ResponseAudioContext AudioContext
    | RequestOggEnabled
    | ResponseOggEnabled Bool
    | RequestLoadFonts String
    | ResponseFontsLoaded Bool
    | RequestPlayNote MidiNote
    | ResponsePlayedNote Bool
    | RequestPlayNoteSequence MidiNotes
    | ResponsePlaySequenceStarted Bool
    | Tick Time.Time
    | CheckNote Int Int Bool
    | SetNote Int MidiNote
    | AddTrack
    | TogglePaused
    | SetBPM Int
    | ConnectSocket
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | NoOp
