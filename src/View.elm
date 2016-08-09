module View exposing (view)

import SoundFont.Msg exposing (..)
import Model exposing (Model, Track)
import Styles
import Dict exposing (Dict)
import Html exposing (Html, Attribute, text, div, input, button, table, tr, td, select, option, node)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onCheck, onInput, targetValue)
import SoundFont.Types exposing (..)
import MidiTable
import Json.Decode as JD exposing ((:=))
import String


view : Model -> Html Msg
view model =
    let
        compiled =
            Styles.compile Styles.css
    in
        div []
            [ node "style" [ type' "text/css" ] [ text compiled.css ]
            , viewMetadata model
            , viewTopControls model
            , viewSongEditor model
            ]


viewTopControls : Model -> Html Msg
viewTopControls model =
    let
        { id } =
            Styles.mainNamespace

        pauseText =
            case model.paused of
                True ->
                    "unpause"

                False ->
                    "pause"
    in
        div [ id Styles.TopControls ]
            [ button [ onClick TogglePaused ] [ text pauseText ]
            , input
                [ onInput (SetBPM << Result.withDefault 128 << String.toInt)
                , placeholder "BPM"
                , type' "number"
                , value (toString model.bpm)
                ]
                []
            ]


viewMetadata : Model -> Html Msg
viewMetadata model =
    div []
        [ div [] [ text <| "Current note: " ++ (toString model.currentNote) ]
        , div [] [ text <| "Paused: " ++ (toString model.paused) ]
        ]


viewSongEditor : Model -> Html Msg
viewSongEditor model =
    let
        trackRows =
            model.song
                |> Dict.foldl (\trackId track acc -> acc ++ [ (viewTrack model.currentNote trackId track) ]) []

        { class } =
            Styles.mainNamespace
    in
        div [ class [ Styles.Song ] ]
            [ table [] trackRows
            , button [ onClick AddTrack ] [ text "Add Track" ]
            ]


viewTrackCell : Int -> Int -> ( Int, Bool ) -> Html Msg
viewTrackCell currentNote trackId ( slotId, on ) =
    let
        { classList } =
            Styles.mainNamespace

        isCurrentNote =
            slotId == currentNote
    in
        td
            [ classList [ ( Styles.CurrentNote, isCurrentNote ), ( Styles.Checked, on ) ] ]
            [ input
                [ type' "checkbox", checked on, onCheck (CheckNote trackId slotId) ]
                [ text <| toString slotId ]
            ]


viewTrack : Int -> Int -> Track -> Html Msg
viewTrack currentNote trackId track =
    let
        trackCells =
            track.slots
                |> Dict.toList
                |> List.map (viewTrackCell currentNote trackId)

        { class } =
            Styles.mainNamespace
    in
        tr [ class [ Styles.Track ] ]
            ([ td [] [ viewTrackMetadata trackId track ] ]
                ++ trackCells
            )


onChange : (Int -> Msg) -> Html.Attribute Msg
onChange tagger =
    on "change" <|
        (JD.at [ "target", "selectedIndex" ] JD.int)
            `JD.andThen` (JD.succeed << tagger)


viewTrackMetadata : Int -> Track -> Html Msg
viewTrackMetadata trackId track =
    let
        setNote : Int -> Msg
        setNote noteId =
            SetNote trackId (MidiNote noteId 0.0 1.0)
    in
        select [ onChange setNote ]
            (MidiTable.notesOctaves
                |> Dict.toList
                |> List.map (viewNoteOption trackId track)
            )


viewNoteOption : Int -> Track -> ( Int, ( String, Int ) ) -> Html Msg
viewNoteOption trackId track ( noteId, ( note, octave ) ) =
    option [ value <| toString noteId, selected (noteId == track.note.id) ]
        [ text <| note ++ " (" ++ (toString octave) ++ ")" ]
