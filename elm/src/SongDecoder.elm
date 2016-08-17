module SongDecoder exposing (..)

import Json.Decode exposing (..)
import Dict exposing (Dict)
import String
import Model exposing (Track, Song)
import SoundFont.Types exposing (MidiNote)


decodeSlots : Decoder (Dict Int Bool)
decodeSlots =
    (dict bool)
        |> map dictStringToDictIntMapper


decodeTrack : Decoder Track
decodeTrack =
    object2 Track
        ("note" := decodeMidiNote)
        ("slots" := decodeSlots)


decodeSong : Decoder Song
decodeSong =
    ("tracks" := ((dict decodeTrack) |> map dictStringToDictIntMapper))


decodeMidiNote : Decoder MidiNote
decodeMidiNote =
    int |> map (\i -> MidiNote i 0.0 1.0)


dictStringToDictIntMapper : Dict String a -> Dict Int a
dictStringToDictIntMapper dict =
    let
        intifyKey : ( String, a ) -> ( Int, a )
        intifyKey ( k, v ) =
            case String.toInt (k) of
                Err _ ->
                    ( 0, v )

                Ok i ->
                    ( i, v )
    in
        dict
            |> Dict.toList
            |> List.map intifyKey
            |> Dict.fromList
