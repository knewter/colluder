module Main exposing (..)

import Html exposing (Html, Attribute, text, div, input, button, table, tr, td, select, option, node)
import Html.Attributes exposing (..)
import Html.Events exposing (on, onClick, onCheck, onInput, targetValue)
import Html.App as Html
import String
import Task
import SoundFont.Ports exposing (..)
import SoundFont.Msg exposing (..)
import SoundFont.Types exposing (..)
import SoundFont.Subscriptions exposing (..)
import Dict exposing (Dict)
import Time
import Json.Decode as JD exposing ((:=))
import MidiTable
import Styles


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
    , paused : Bool
    , bpm : Int
    }


totalNotes : Int
totalNotes =
    20


trackSlots : Dict Int Bool
trackSlots =
    [0..(totalNotes - 1)]
        |> List.foldl (\slotId acc -> Dict.insert slotId False acc) Dict.empty


track : Track
track =
    { note = (MidiNote 69 0.0 1.0)
    , slots = trackSlots
    }


init =
    let
        initialSong =
            Dict.empty
                |> Dict.insert 0 track
                |> Dict.insert 1 track
    in
        { audioContext = Nothing
        , oggEnabled = False
        , fontsLoaded = False
        , playedNote = False
        , canPlaySequence = False
        , song = initialSong
        , currentNote = 0
        , totalNotes = totalNotes
        , paused = False
        , bpm = 128
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

        TogglePaused ->
            { model | paused = not model.paused } ! []

        SetBPM bpm ->
            { model | bpm = bpm } ! []

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

        SetNote trackId midiNote ->
            let
                _ =
                    Debug.log "trackId: " (toString trackId)

                _ =
                    Debug.log "note: " (toString midiNote)

                updateTrack : Maybe Track -> Maybe Track
                updateTrack maybeTrack =
                    case maybeTrack of
                        Just track ->
                            Just { track | note = midiNote }

                        Nothing ->
                            Nothing

                newSong : Song
                newSong =
                    model.song
                        |> Dict.update trackId updateTrack
            in
                { model | song = newSong } ! []

        AddTrack ->
            let
                newTrackId =
                    Dict.size model.song

                newSong =
                    model.song
                        |> Dict.insert newTrackId track
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
    let
        tickSub =
            case model.paused of
                True ->
                    []

                False ->
                    let
                        interval =
                            1 / (toFloat model.bpm)
                    in
                        [ Time.every (Time.minute * interval) Tick ]
    in
        Sub.batch
            ([ audioContextSub
             , oggEnabledSub
             , fontsLoadedSub
             , playedNoteSub
             , playSequenceStartedSub
             ]
                ++ tickSub
            )



-- VIEW


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
            `JD.andThen`
                (\id ->
                    let
                        _ =
                            Debug.log "note id: " id
                    in
                        JD.succeed <| tagger id
                )


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
