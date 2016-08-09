module View exposing (view)

import SoundFont.Msg exposing (..)
import Model exposing (Model, Track)
import Styles
import Dict exposing (Dict)
import Html exposing (Html, Attribute, text, div, input, button, table, tr, td, select, option, node, h1)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onCheck, onInput, targetValue)
import SoundFont.Types exposing (..)
import MidiTable
import Json.Decode as JD exposing ((:=))
import String
import Material.Scheme
import Material.Layout as Layout
import Material.Color as Color
import Material.Button as Button
import Material.Textfield as Textfield
import Material.Menu as Menu


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Teal Color.LightGreen <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            ]
            { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "Colluder" ] ]
            , drawer = []
            , tabs = ( [], [] )
            , main = [ viewBody model ]
            }


viewBody : Model -> Html Msg
viewBody model =
    let
        compiled =
            Styles.compile Styles.css
    in
        div [ style [ ( "padding", "2rem" ) ] ]
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
        div []
            [ Button.render Mdl
                [ 0 ]
                model.mdl
                [ Button.onClick TogglePaused ]
                [ text pauseText ]
            , Textfield.render Mdl
                [ 1 ]
                model.mdl
                [ Textfield.onInput (SetBPM << Result.withDefault 128 << String.toInt)
                , Textfield.floatingLabel
                , Textfield.label "BPM"
                , Textfield.value (toString model.bpm)
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
                [ Button.onClick AddTrack ]
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
                [ type' "checkbox", checked on, onCheck (CheckNote trackId slotId) ]
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


onChange : (Int -> Msg) -> Html.Attribute Msg
onChange tagger =
    on "change" <|
        (JD.at [ "target", "selectedIndex" ] JD.int)
            `JD.andThen` (JD.succeed << tagger)


viewTrackMetadata : Model -> Int -> Track -> Html Msg
viewTrackMetadata model trackId track =
    let
        setNote : Int -> Msg
        setNote noteId =
            SetNote trackId (MidiNote noteId 0.0 1.0)

        midiNotesStartingPoint : Int
        midiNotesStartingPoint =
            300

        menuItems : List (Menu.Item Msg)
        menuItems =
            (MidiTable.notesOctaves
                |> Dict.toList
                |> List.map
                    --(viewNoteOption trackId track)
                    (\( k, ( note, octave ) ) ->
                        (Menu.item
                            [ Menu.onSelect (setNote k) ]
                            [ text (noteText ( note, octave )) ]
                        )
                    )
            )
    in
        Menu.render Mdl
            [ midiNotesStartingPoint + trackId ]
            model.mdl
            [ Menu.ripple, Menu.bottomLeft ]
            menuItems



-- select [ onChange setNote ]
--     (MidiTable.notesOctaves
--         |> Dict.toList
--         |> List.map (viewNoteOption trackId track)
--     )


viewNoteOption : Int -> Track -> ( Int, ( String, Int ) ) -> Html Msg
viewNoteOption trackId track ( noteId, ( note, octave ) ) =
    option [ value <| toString noteId, selected (noteId == track.note.id) ]
        [ text <| (noteText ( note, octave )) ]


noteText : ( String, Int ) -> String
noteText ( note, octave ) =
    note ++ " (" ++ (toString octave) ++ ")"
