module MidiTable exposing (notes, octaves, notesOctaves, getNoteAndOctaveByNoteId, getNoteIdByNoteAndOctave)

{- This is the midi table: http://www.blog.finetanks.com/wp-content/uploads/2010/03/midi_table.png -}

import Array exposing (Array)
import Dict exposing (Dict)


notes : Array String
notes =
    [ "C", "C#", "D", "D#", "E", "F", "F#", "G", "G#", "A", "A#", "B" ]
        |> Array.fromList


octaves : Array Int
octaves =
    [ 3, 4, 5, 6, 7 ]
        |> Array.fromList


noteIds : Array Int
noteIds =
    List.range 1 127
        |> Array.fromList


notesOctaves : Dict Int ( String, Int )
notesOctaves =
    noteIds
        |> Array.foldl insertNoteIdToNoteAndOctave Dict.empty


insertNoteIdToNoteAndOctave : Int -> Dict Int ( String, Int ) -> Dict Int ( String, Int )
insertNoteIdToNoteAndOctave noteId dict =
    case noteIdToNoteAndOctave noteId of
        Nothing ->
            dict

        Just ( note, octave ) ->
            dict
                |> Dict.insert noteId ( note, octave )


noteIdToNoteAndOctave : Int -> Maybe ( String, Int )
noteIdToNoteAndOctave noteId =
    let
        octave =
            noteId // (Array.length notes)

        noteIndex =
            noteId % (Array.length notes)
    in
        case Array.get noteIndex notes of
            Nothing ->
                Nothing

            Just string ->
                Just ( string, octave )


getNoteIdByNoteAndOctave : ( String, Int ) -> Maybe Int
getNoteIdByNoteAndOctave ( note, octave ) =
    indexOf ( note, octave ) (Dict.values notesOctaves)


getNoteAndOctaveByNoteId : Int -> Maybe ( String, Int )
getNoteAndOctaveByNoteId noteId =
    Dict.get noteId notesOctaves


indexOf : a -> List a -> Maybe Int
indexOf el list =
    let
        indexOf_ list_ index =
            case list_ of
                [] ->
                    Nothing

                x :: xs ->
                    if x == el then
                        Just index
                    else
                        indexOf_ xs (index + 1)
    in
        indexOf_ list 0
