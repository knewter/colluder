module Main exposing (..)

import Html exposing (Html, Attribute, text, div, input, button, table, tr, td)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onCheck)
import Html.App as Html
import String
import Task
import SoundFont.Ports exposing (..)
import SoundFont.Msg exposing (..)
import SoundFont.Types exposing (..)
import SoundFont.Subscriptions exposing (..)
import Dict exposing (Dict)
import Time


main =
    Html.program { init = ( init, initCmds init ), update = update, view = view, subscriptions = subscriptions }


initCmds model =
    Cmd.batch
        [ initialiseAudioContext ()
        , requestIsOggEnabled ()
        , requestLoadFonts "soundfonts"
        ]


type alias Song =
    Dict Int Track


type alias Track =
    { note : MidiNote
    , slots : Dict Int Bool
    }


type alias Model =
    { audioContext : Maybe AudioContext
    , oggEnabled : Bool
    , fontsLoaded : Bool
    , playedNote : Bool
    , canPlaySequence : Bool
    , song : Song
    , currentNote : Int
    , totalNotes : Int
    }


init =
    let
        initialSong =
            Dict.empty
                |> Dict.insert 0 track1
                |> Dict.insert 1 track2

        track1Slots =
            Dict.empty
                |> Dict.insert 0 False
                |> Dict.insert 1 False
                |> Dict.insert 2 False
                |> Dict.insert 3 False
                |> Dict.insert 4 False

        track1 =
            { note = (MidiNote 69 0.0 1.0)
            , slots = track1Slots
            }

        track2Slots =
            Dict.empty
                |> Dict.insert 0 False
                |> Dict.insert 1 False
                |> Dict.insert 2 False
                |> Dict.insert 3 False
                |> Dict.insert 4 False

        track2 =
            { note = (MidiNote 50 0.0 1.0)
            , slots = track2Slots
            }
    in
        { audioContext = Nothing
        , oggEnabled = False
        , fontsLoaded = False
        , playedNote = False
        , canPlaySequence = False
        , song = initialSong
        , currentNote = 0
        , totalNotes = 5
        }


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

        Tick _ ->
            let
                newNote =
                    (model.currentNote + 1) % model.totalNotes

                newModel =
                    { model | currentNote = newNote }
            in
                newModel ! (requestNotes newModel)

        CheckNote trackId slotId on ->
            let
                updateTrack : Maybe Track -> Maybe Track
                updateTrack maybeTrack =
                    let
                        newSlots track' =
                            track'.slots
                                |> Dict.update slotId
                                    (\v ->
                                        case v of
                                            Just True ->
                                                Just False

                                            Just False ->
                                                Just True

                                            Nothing ->
                                                Nothing
                                    )
                    in
                        case maybeTrack of
                            Just track ->
                                Just { track | slots = (newSlots track) }

                            Nothing ->
                                Nothing

                newSong : Song
                newSong =
                    model.song
                        |> Dict.update trackId updateTrack
            in
                { model | song = newSong } ! []

        NoOp ->
            ( model, Cmd.none )


requestNotes : Model -> List (Cmd Msg)
requestNotes model =
    model
        |> getNotes model.currentNote
        |> List.map requestPlayNote


getNotes : Int -> Model -> List MidiNote
getNotes currentNote model =
    model.song
        |> Dict.foldl
            (\_ track acc ->
                case Dict.get currentNote track.slots of
                    Just True ->
                        track.note :: acc

                    Just False ->
                        acc

                    Nothing ->
                        acc
            )
            []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ audioContextSub
        , oggEnabledSub
        , fontsLoadedSub
        , playedNoteSub
        , playSequenceStartedSub
        , Time.every Time.second Tick
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
        [ viewMetadata model
        , viewTrackEditor model
        ]


viewMetadata : Model -> Html Msg
viewMetadata model =
    div []
        [ text <| "Current note: " ++ (toString model.currentNote) ]


viewTrackEditor : Model -> Html Msg
viewTrackEditor model =
    let
        trackRows =
            model.song
                |> Dict.foldl (\trackId track acc -> acc ++ [ (viewTrackRow trackId track) ]) []
    in
        table []
            trackRows


viewTrackCell : Int -> ( Int, Bool ) -> Html Msg
viewTrackCell trackId ( slotId, on ) =
    td [] [ input [ type' "checkbox", checked on, onCheck (CheckNote trackId slotId) ] [ text <| toString slotId ] ]


viewTrackRow : Int -> Track -> Html Msg
viewTrackRow trackId track =
    let
        trackCells =
            track.slots
                |> Dict.toList
                |> List.map (viewTrackCell trackId)
    in
        tr []
            ([ td [] [ text (toString track.note) ] ]
                ++ trackCells
            )


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
