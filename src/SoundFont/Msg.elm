module SoundFont.Msg exposing (..)

import SoundFont.Types exposing (..)
import Time


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
    | NoOp
