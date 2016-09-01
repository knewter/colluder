module Model exposing (Model, Song, Track, Slots, ColluderFlags, track, trackSlots, init)

import Dict exposing (Dict)
import SoundFont.Types exposing (..)
import Material
import Phoenix.Socket
import SoundFont.Msg exposing (..)


type alias ColluderFlags =
    { socketServer : String
    }


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
    , mdl : Material.Model
    , trackBeingEdited : Maybe Int
    , chosenNote : Maybe String
    , phxSocket : Maybe (Phoenix.Socket.Socket Msg)
    , socketServer : String
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
    20


init : ColluderFlags -> Model
init colluderFlags =
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
    , mdl = Material.model
    , trackBeingEdited = Nothing
    , chosenNote = Nothing
    , phxSocket = Nothing
    , socketServer = colluderFlags.socketServer
    }


initialSong : Song
initialSong =
    Dict.empty
        |> Dict.insert 0 track
        |> Dict.insert 1 track
