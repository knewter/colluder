module Model exposing (Model, Song, Track, Slots, track, trackSlots, init)

import Dict exposing (Dict)
import SoundFont.Types exposing (..)


type alias Song =
    Dict Int Track


type alias Track =
    { note : MidiNote
    , slots : Slots
    }


type alias Slots =
    Dict Int Bool


type alias Model =
    { audioContext : Maybe AudioContext
    , oggEnabled : Bool
    , fontsLoaded : Bool
    , playedNote : Bool
    , canPlaySequence : Bool
    , song : Song
    , currentNote : Int
    , totalNotes : Int
    , paused : Bool
    , bpm : Int
    }


track : Track
track =
    { note = (MidiNote 69 0.0 1.0)
    , slots = trackSlots
    }


trackSlots : Slots
trackSlots =
    [0..(totalNotes - 1)]
        |> List.foldl (\slotId acc -> Dict.insert slotId False acc) Dict.empty


totalNotes : Int
totalNotes =
    16


init : Model
init =
    { audioContext = Nothing
    , oggEnabled = False
    , fontsLoaded = False
    , playedNote = False
    , canPlaySequence = False
    , song = initialSong
    , currentNote = 0
    , totalNotes = totalNotes
    , paused = False
    , bpm = 128
    }


initialSong : Song
initialSong =
    Dict.empty
        |> Dict.insert 0 track
        |> Dict.insert 1 track
