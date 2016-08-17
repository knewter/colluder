module Tests exposing (..)

import Test exposing (..)
import Expect
import String
import SongDecoder
import Json.Decode as JD
import Dict
import Model exposing (..)
import SoundFont.Types exposing (MidiNote)


all : Test
all =
    describe "Colluder Test Suite"
        [ test "decoding slots" <|
            \() ->
                Expect.equal (JD.decodeString SongDecoder.decodeSlots "{\"0\": true}") (Ok exampleSlotsWith1Slot)
        , test "decoding a track" <|
            \() ->
                Expect.equal (JD.decodeString SongDecoder.decodeTrack "{ \"note\": 42, \"slots\": { \"0\": true } }") (Ok exampleTrackWith1Slot)
        , test "decoding a song" <|
            \() ->
                Expect.equal (JD.decodeString SongDecoder.decodeSong "{ \"tracks\": { \"0\": { \"note\": 42, \"slots\": { \"0\": true } } } }") (Ok exampleSong)
        ]


exampleSong : Song
exampleSong =
    Dict.empty |> Dict.insert 0 exampleTrackWith1Slot


exampleTrackWith1Slot : Track
exampleTrackWith1Slot =
    Track exampleNote exampleSlotsWith1Slot


exampleSlotsWith1Slot : Slots
exampleSlotsWith1Slot =
    Dict.empty |> Dict.insert 0 True


exampleNote : MidiNote
exampleNote =
    MidiNote 42 0.0 1.0
