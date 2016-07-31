module MidiTable exposing (notesOctaves)

import Array exposing (Array)
import Dict exposing (Dict)


notes : Array String
notes =
    [ "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" ]
        |> Array.fromList


noteIds : Array Int
noteIds =
    [0..127]
        |> Array.fromList


notesOctaves : Dict Int ( String, Int )
notesOctaves =
    noteIds
        |> Array.foldl noteIdToNoteAndOctave Dict.empty


noteIdToNoteAndOctave : Int -> Dict Int ( String, Int ) -> Dict Int ( String, Int )
noteIdToNoteAndOctave noteId dict =
    let
        octave =
            noteId // (Array.length notes)

        noteIndex =
            noteId % (Array.length notes)
    in
        case Array.get noteIndex notes of
            Nothing ->
                dict

            Just string ->
                dict
                    |> Dict.insert noteId ( string, octave )
