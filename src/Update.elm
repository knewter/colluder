module Update exposing (update)

import SoundFont.Types exposing (..)
import SoundFont.Msg exposing (..)
import Dict exposing (Dict)
import Model exposing (Model, Song, Track, Slots, track, trackSlots)
import SoundFont.Ports exposing (..)
import Material


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
            ( { model
                | song =
                    model.song
                        |> Dict.insert (nextTrackId model.song) track
              }
            , Cmd.none
            )

        Mdl msg' ->
            Material.update msg' model


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
