module Main exposing (..)

import Html exposing (Html, Attribute, text, div, input, button, table, tr, td)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick)
import Html.App as Html
import String
import Task
import SoundFont.Ports exposing (..)
import SoundFont.Types exposing (..)
import SoundFont.Msg exposing (..)
import SoundFont.Subscriptions exposing (..)
import Dict exposing (Dict)


main =
    Html.program { init = ( init, initCmds ), update = update, view = view, subscriptions = subscriptions }


initCmds =
    Cmd.batch
        [ initialiseAudioContext ()
        , requestIsOggEnabled ()
        , requestLoadFonts "soundfonts"
        ]


type alias Song =
    List Track


type alias Track =
    Dict Int Bool


type alias Model =
    { audioContext : Maybe AudioContext
    , oggEnabled : Bool
    , fontsLoaded : Bool
    , playedNote : Bool
    , canPlaySequence : Bool
    , song : Song
    }


init =
    let
        initialSong =
            [ track1 ]

        track1 =
            Dict.empty
                |> Dict.insert 1 True
                |> Dict.insert 2 False
                |> Dict.insert 3 False
                |> Dict.insert 4 False
                |> Dict.insert 5 False
    in
        Model Nothing False False False False initialSong


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InitialiseAudioContext ->
            ( model
            , initialiseAudioContext ()
            )

        ResponseAudioContext context ->
            ( { model | audioContext = Just context }
            , Cmd.none
            )

        RequestOggEnabled ->
            ( model
            , requestIsOggEnabled ()
            )

        ResponseOggEnabled enabled ->
            ( { model | oggEnabled = enabled }
            , Cmd.none
            )

        RequestLoadFonts dir ->
            ( model
            , requestLoadFonts dir
            )

        ResponseFontsLoaded loaded ->
            ( { model | fontsLoaded = loaded }
            , Cmd.none
            )

        RequestPlayNote note ->
            ( model
            , requestPlayNote note
            )

        ResponsePlayedNote played ->
            ( { model | playedNote = played }
            , Cmd.none
            )

        RequestPlayNoteSequence notes ->
            ( model
            , requestPlayNoteSequence notes
            )

        ResponsePlaySequenceStarted playing ->
            ( { model | canPlaySequence = playing }
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ audioContextSub
        , oggEnabledSub
        , fontsLoadedSub
        , playedNoteSub
        , playSequenceStartedSub
        ]



-- VIEW


viewEnabled : Model -> Html Msg
viewEnabled m =
    let
        audio =
            case (m.audioContext) of
                Just ac ->
                    toString ac

                _ ->
                    "no"

        ogg =
            if (m.oggEnabled) then
                "yes"
            else
                "no"

        fonts =
            if (m.fontsLoaded) then
                "yes"
            else
                "no"

        played =
            if (m.playedNote) then
                "yes"
            else
                "no"

        canPlay =
            if (m.canPlaySequence) then
                "yes"
            else
                "no"
    in
        text
            ("audio enabled: "
                ++ audio
                ++ " ogg enabled: "
                ++ ogg
                ++ " fonts loaded: "
                ++ fonts
                ++ " played note: "
                ++ played
                ++ " can play sequence: "
                ++ canPlay
            )


view : Model -> Html Msg
view model =
    div []
        [ viewTrackEditor model ]


viewTrackEditor : Model -> Html Msg
viewTrackEditor model =
    let
        trackRows =
            model.song
                |> List.map viewTrackRow
    in
        table []
            trackRows


viewTrackCell : ( Int, Bool ) -> Html Msg
viewTrackCell ( id, on ) =
    td [] [ input [ type' "checkbox", checked on ] [ text <| toString id ] ]


viewTrackRow : Track -> Html Msg
viewTrackRow track =
    let
        trackCells =
            track
                |> Dict.toList
                |> List.map viewTrackCell
    in
        tr []
            trackCells


viewLoadFontButton : Model -> Html Msg
viewLoadFontButton model =
    case (model.audioContext) of
        Just ac ->
            button
                [ onClick (RequestLoadFonts "soundfonts")
                , id "elm-load-font-button"
                , btnStyle
                ]
                [ text "load soundfonts" ]

        _ ->
            div [] []


viewPlayNoteButton : Model -> Html Msg
viewPlayNoteButton model =
    if (model.fontsLoaded) then
        button
            [ onClick (RequestPlayNote (MidiNote 69 0.0 1.0))
            , id "elm-play-note-button"
            , btnStyle
            ]
            [ text "Play A" ]
    else
        div [] []


viewPlayNoteSequenceButton : Model -> Html Msg
viewPlayNoteSequenceButton model =
    let
        sequence =
            [ (MidiNote 60 0.0 1.0)
            , (MidiNote 62 0.3 1.0)
            , (MidiNote 64 0.6 1.0)
            , (MidiNote 65 0.9 1.0)
            , (MidiNote 67 1.2 1.0)
            , (MidiNote 69 1.5 1.0)
            , (MidiNote 71 1.8 1.0)
            , (MidiNote 72 2.1 1.0)
            ]
    in
        if (model.fontsLoaded) then
            button
                [ onClick (RequestPlayNoteSequence sequence)
                , id "elm-play-note-sequence-button"
                , btnStyle
                ]
                [ text "play sample scale" ]
        else
            div [] []


btnStyle : Attribute msg
btnStyle =
    style
        [ ( "font-size", "1em" )
        , ( "text-align", "center" )
        ]
