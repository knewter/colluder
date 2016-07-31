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


main =
    Html.program
        { init = ( init, initCmds ), update = update, view = view, subscriptions = subscriptions }


initCmds =
    Cmd.batch
        [ initialiseAudioContext ()
        , requestIsOggEnabled ()
        , requestLoadFonts "soundfonts"
        ]


type alias Model =
    { audioContext : Maybe AudioContext
    , oggEnabled : Bool
    , fontsLoaded : Bool
    , playedNote : Bool
    , canPlaySequence : Bool
    }


init =
    Model Nothing False False False False


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
        [ button
            [ onClick InitialiseAudioContext
            , id "elm-check-audio-context-button"
            , btnStyle
            ]
            [ text "check audio context" ]
        , button
            [ onClick RequestOggEnabled
            , id "elm-check-ogg-enabled-button"
            , btnStyle
            ]
            [ text "check ogg enabled" ]
        , viewLoadFontButton model
        , viewPlayNoteButton model
        , viewPlayNoteSequenceButton model
        , div [] [ viewEnabled model ]
        , div [] [ viewTrackEditor model ]
        ]


viewTrackEditor : Model -> Html Msg
viewTrackEditor model =
    table []
        [ viewTrackRow model
        ]


viewTrackRow : Model -> Html Msg
viewTrackRow model =
    tr []
        [ td [] [ button [] [ text "1" ] ]
        , td [] [ button [] [ text "2" ] ]
        , td [] [ button [] [ text "3" ] ]
        , td [] [ button [] [ text "4" ] ]
        , td [] [ button [] [ text "5" ] ]
        , td [] [ button [] [ text "6" ] ]
        ]


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
