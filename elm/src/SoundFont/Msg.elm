module SoundFont.Msg exposing (..)

import SoundFont.Types exposing (..)
import Time
import Phoenix.Socket
import Json.Encode as JE
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
    | SetBPM Int
    | TogglePaused
    | ConnectSocket
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ReceiveState JE.Value
    | Mdl (Material.Msg Msg)
    | SetEditingTrack Int
    | ChooseNote String
    | ChooseOctave Int
    | NoOp
