module Update exposing (update)

import SoundFont.Types exposing (..)
import SoundFont.Msg exposing (..)
import Dict exposing (Dict)
import Model exposing (Model, Song, Track, Slots, track, trackSlots)
import SoundFont.Ports exposing (..)
import Material
import MidiTable exposing (getNoteIdByNoteAndOctave)
import Debug


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "msg: " msg of
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
                -- TODO: Check how to trivially update model and pass new model to Cmd - some package?
                newModel =
                    model
                        |> updateNotes
            in
                ( newModel
                , Cmd.batch <| requestNotes newModel
                )

        CheckNote trackId slotId on ->
            ( { model
                | song = model.song |> Dict.update trackId (checkSlot slotId)
              }
            , Cmd.none
            )

        SetNote trackId midiNote ->
            ( { model
                | song =
                    model.song
                        |> Dict.update trackId (setMidiNote midiNote)
              }
            , Cmd.none
            )

        AddTrack ->
            let
                newTrackId =
                    Dict.size model.song

                newSong =
                    model.song
                        |> Dict.insert newTrackId track
            in
                addTrack
                    ({ model | song = newSong } ! [])
                    newTrackId
                    track

        SetEditingTrack trackId ->
            ( { model | trackBeingEdited = Just trackId }, Cmd.none )

        ChooseNote note ->
            ( { model | chosenNote = Just note }, Cmd.none )

        ChooseOctave octave ->
            let
                _ =
                    Debug.log "model: " model
            in
                case model.trackBeingEdited of
                    Nothing ->
                        model ! []

                    Just trackId ->
                        case model.chosenNote of
                            Nothing ->
                                model ! []

                            Just note ->
                                case getNoteIdByNoteAndOctave ( note, octave ) of
                                    Nothing ->
                                        model ! []

                                    Just noteId ->
                                        let
                                            newModel =
                                                { model | chosenNote = Nothing, trackBeingEdited = Nothing }
                                        in
                                            update (SetNote trackId (MidiNote noteId 0.0 1.0)) newModel

        ConnectSocket ->
            let
                collusionChannel =
                    Phoenix.Channel.init collusionChannelName

                phxSocketInit =
                    initPhxSocket

                ( phxSocket, phxJoinCmd ) =
                    Phoenix.Socket.join collusionChannel phxSocketInit

                phxSocket2 =
                    phxSocket
                        |> Phoenix.Socket.on "collusion:state" collusionChannelName ReceiveState
            in
                ( { model | phxSocket = Just phxSocket2 }
                , Cmd.map PhoenixMsg phxJoinCmd
                )

        ReceiveState raw ->
            model ! []

        Mdl msg' ->
            Material.update msg' model

        NoOp ->
            ( model, Cmd.none )

        PhoenixMsg msg ->
            case model.phxSocket of
                Nothing ->
                    model ! []

                Just modelPhxSocket ->
                    let
                        ( phxSocket, phxCmd ) =
                            Phoenix.Socket.update msg modelPhxSocket
                    in
                        ( { model | phxSocket = Just phxSocket }
                        , Cmd.map PhoenixMsg phxCmd
                        )


nextTrackId : Song -> Int
nextTrackId song =
    Dict.size song


setMidiNote : MidiNote -> Maybe Track -> Maybe Track
setMidiNote midiNote maybeTrack =
    Maybe.map (\t -> { t | note = midiNote }) maybeTrack


updateNotes : Model -> Model
updateNotes model =
    { model | currentNote = (model.currentNote + 1) % model.totalNotes }


newSlots : Int -> Slots -> Slots
newSlots slotId =
    Dict.update slotId
        (Maybe.map not)


checkSlot : Int -> Maybe Track -> Maybe Track
checkSlot slotId maybeTrack =
    Maybe.map
        (\t -> { t | slots = (newSlots slotId t.slots) })
        maybeTrack


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


addTrack : ( Model, Cmd Msg ) -> Int -> Track -> ( Model, Cmd Msg )
addTrack ( model, cmd ) trackId track =
    case model.phxSocket of
        Nothing ->
            ( model, cmd )

        Just modelPhxSocket ->
            let
                payload =
                    (JE.object [])

                push' =
                    Phoenix.Push.init "track:add" collusionChannelName
                        |> Phoenix.Push.withPayload payload

                ( phxSocket, phxCmd ) =
                    Phoenix.Socket.push push' modelPhxSocket
            in
                ( { model
                    | phxSocket = Just phxSocket
                  }
                , Cmd.batch
                    [ cmd
                    , Cmd.map PhoenixMsg phxCmd
                    ]
                )


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


initPhxSocket : Phoenix.Socket.Socket Msg
initPhxSocket =
    Phoenix.Socket.init socketServer
        |> Phoenix.Socket.withDebug
