module SoundFont.Msg exposing (..)

import SoundFont.Types exposing (..)
import Time
import Material


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
    | Mdl (Material.Msg Msg)
    | SetEditingTrack Int
    | ChooseNote String
    | ChooseOctave Int
