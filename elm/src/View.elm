module View exposing (view)

import SoundFont.Msg exposing (..)
import Model exposing (Model, Track)
import Styles
import Dict exposing (Dict)
import Html
    exposing
        ( Html
        , Attribute
        , text
        , div
        , input
        , button
        , table
        , tr
        , td
        , select
        , option
        , node
        , h1
        , p
        , strong
        )
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onCheck, onInput, targetValue)
import MidiTable
import Array exposing (Array)
import Material.Scheme
import Material.Layout as Layout
import Material.Color as Color
import Material.Button as Button
import Material.Slider as Slider
import Material.Dialog as Dialog
import Material.Options as Options
import Wheel.View as Wheel


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Teal Color.LightGreen <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            ]
            { header = [ viewHeader model ]
            , drawer = []
            , tabs = ( [], [] )
            , main = [ viewBody model ]
            }


viewHeader : Model -> Html Msg
viewHeader model =
    Layout.row
        []
        [ Layout.title [] [ text "Colluder" ]
        , Layout.spacer
        , Layout.navigation []
            [ Layout.link
                [ Layout.href "https://github.com/knewter/colluder" ]
                [ text "github" ]
            ]
        ]


viewBody : Model -> Html Msg
viewBody model =
    let
        compiled =
            Styles.compile [ Styles.css ]
    in
        div [ style [ ( "padding", "6rem" ) ] ]
            [ node "style" [ type_ "text/css" ] [ text compiled.css ]
            , viewMetadata model
            , viewTopControls model
            , viewSongEditor model
            , viewDialog model
            , viewConnection model
            , Wheel.viewWheel model
            ]


viewDialog : Model -> Html Msg
viewDialog model =
    case model.trackBeingEdited of
        Nothing ->
            viewAbout model

        Just trackId ->
            viewTrackNoteChooser model


noteButton : Model -> Int -> String -> Html Msg
noteButton model noteNum note =
    Button.render Mdl
        [ 7, noteNum ]
        model.mdl
        [ Options.css "width" "2rem"
        , Options.onClick (ChooseNote note)
        ]
        [ text note ]


octaveButton : Model -> Int -> Int -> Html Msg
octaveButton model octaveNum octave =
    Button.render Mdl
        [ 8, octaveNum ]
        model.mdl
        [ Options.css "width" "2rem"
        , Dialog.closeOn "click"
        , Options.onClick (ChooseOctave octave)
        ]
        [ text <| toString octave ]


octaveButtons : Model -> Array (Html Msg)
octaveButtons model =
    MidiTable.octaves
        |> Array.indexedMap (octaveButton model)


noteButtons : Model -> Array (Html Msg)
noteButtons model =
    MidiTable.notes
        |> Array.indexedMap (noteButton model)


pickNoteDialog : Model -> Html Msg
pickNoteDialog model =
    Dialog.view []
        [ Dialog.title [] [ text "Pick the Note" ]
        , Dialog.content []
            (noteButtons model
                |> Array.toList
            )
        , Dialog.actions []
            [ Button.render Mdl
                [ 5 ]
                model.mdl
                [ Dialog.closeOn "click" ]
                [ text "Close" ]
            ]
        ]


pickOctaveDialog : Model -> Html Msg
pickOctaveDialog model =
    Dialog.view []
        [ Dialog.title [] [ text "Pick the Octave" ]
        , Dialog.content []
            (octaveButtons model
                |> Array.toList
            )
        , Dialog.actions []
            [ Button.render Mdl
                [ 6 ]
                model.mdl
                [ Dialog.closeOn "click" ]
                [ text "Close" ]
            ]
        ]


viewTrackNoteChooser : Model -> Html Msg
viewTrackNoteChooser model =
    case model.chosenNote of
        Nothing ->
            pickNoteDialog model

        Just _ ->
            pickOctaveDialog model


viewAbout : Model -> Html Msg
viewAbout model =
    Dialog.view []
        [ Dialog.title [] [ text "About" ]
        , Dialog.content []
            [ p [] [ text "This is a music toy" ]
            ]
        , Dialog.actions []
            [ Button.render Mdl
                [ 3 ]
                model.mdl
                [ Dialog.closeOn "click" ]
                [ text "Close" ]
            ]
        ]


viewTopControls : Model -> Html Msg
viewTopControls model =
    let
        pauseText =
            if model.paused then
                "unpause"
            else
                "pause"
    in
        div []
            [ Button.render Mdl
                [ 0 ]
                model.mdl
                [ Options.onClick TogglePaused ]
                [ text pauseText ]
            , div []
                [ strong [] [ text <| "BPM: " ++ (toString model.bpm) ]
                , Slider.view
                    [ Slider.onChange (round >> SetBPM)
                    , Slider.value <| toFloat model.bpm
                    , Slider.min 0
                    , Slider.max 400
                    ]
                ]
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
                |> Dict.foldl (\trackId track acc -> acc ++ [ (viewTrack model trackId track) ]) []

        { class } =
            Styles.mainNamespace
    in
        div [ class [ Styles.Song ] ]
            [ table [] trackRows
            , Button.render Mdl
                [ 2 ]
                model.mdl
                [ Options.onClick AddTrack ]
                [ text "Add Track" ]
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
                [ type_ "checkbox", checked on, onCheck (CheckNote trackId slotId) ]
                [ text <| toString slotId ]
            ]


viewTrack : Model -> Int -> Track -> Html Msg
viewTrack model trackId track =
    let
        trackCells =
            track.slots
                |> Dict.toList
                |> List.map (viewTrackCell model.currentNote trackId)

        { class } =
            Styles.mainNamespace
    in
        tr [ class [ Styles.Track ] ]
            ([ td [] [ viewTrackMetadata model trackId track ] ]
                ++ trackCells
            )


viewTrackMetadata : Model -> Int -> Track -> Html Msg
viewTrackMetadata model trackId track =
    case MidiTable.getNoteAndOctaveByNoteId track.note.id of
        Nothing ->
            text ""

        Just ( note, octave ) ->
            Button.render Mdl
                [ 4 ]
                model.mdl
                [ Dialog.openOn "click"
                , Options.onClick <| SetEditingTrack trackId
                ]
                [ text <| note ++ (toString octave) ]


viewNoteOption : Int -> Track -> ( Int, ( String, Int ) ) -> Html Msg
viewNoteOption trackId track ( noteId, ( note, octave ) ) =
    option [ value <| toString noteId, selected (noteId == track.note.id) ]
        [ text <| (noteText ( note, octave )) ]


noteText : ( String, Int ) -> String
noteText ( note, octave ) =
    note ++ " (" ++ (toString octave) ++ ")"


viewConnection : Model -> Html Msg
viewConnection model =
    case model.phxSocket of
        Nothing ->
            Button.render Mdl
                [ 9 ]
                model.mdl
                [ Options.onClick ConnectSocket ]
                [ text "Connect to backend" ]

        _ ->
            div [] []
