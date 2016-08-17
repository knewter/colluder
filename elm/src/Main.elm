module Main exposing (..)

import Html.App as Html
import SoundFont.Ports exposing (..)
import SoundFont.Msg exposing (..)
import SoundFont.Subscriptions exposing (..)
import Time
import Json.Decode as JD exposing ((:=))
import Json.Encode as JE
import MidiTable
import Styles
import Phoenix.Socket
import Phoenix.Channel
import Phoenix.Push
import Update
import Model exposing (Model, Track, init)
import View exposing (view)
import Material.Menu as Menu


main : Program Never
main =
    Html.program
        { init = ( init, initCmds init )
        , update = Update.update
        , view = View.view
        , subscriptions = subscriptions
        }


initCmds : Model -> Cmd Msg
initCmds model =
    Cmd.batch
        [ initialiseAudioContext ()
        , requestIsOggEnabled ()
        , requestLoadFonts "soundfonts"
        ]



-- case JD.decodeValue conspireSongDecoder raw of
--     Ok song ->
--         let
--             _ =
--                 Debug.log "raw" raw
--         in
--             { model | song = song } ! []
--
--     Err error ->
--         let
--             _ =
--                 Debug.log "Error" error
--         in
--             model ! []
-- conspireSongDecoder : JD.Decoder Song
-- conspireSongDecoder =
--     JD.succeed
--         Dict.empty
--         |> Dict.insert 0 track
--         |> Dict.insert 1 track


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        phxSub =
            case model.phxSocket of
                Nothing ->
                    []

                Just phxSocket ->
                    [ Phoenix.Socket.listen phxSocket PhoenixMsg ]
    in
        Sub.batch
            ([ audioContextSub
             , oggEnabledSub
             , fontsLoadedSub
             , playedNoteSub
             , playSequenceStartedSub
             , Material.subscriptions Mdl model
             ]
                ++ (tickSub model)
                ++ phxSub
            )


tickSub : Model -> List (Sub Msg)
tickSub model =
    case model.paused of
        True ->
            []

        False ->
            [ Time.every (Time.minute * (interval model)) Tick ]


viewNoteOption : Int -> Track -> ( Int, ( String, Int ) ) -> Html Msg
viewNoteOption trackId track ( noteId, ( note, octave ) ) =
    option [ value <| toString noteId, selected (noteId == track.note.id) ]
        [ text <| note ++ " (" ++ (toString octave) ++ ")" ]


collusionChannelName =
    "collusion:foobar"


interval : Model -> Float
interval model =
    1 / (toFloat model.bpm)
