module Main exposing (..)

import Html
import SoundFont.Ports exposing (..)
import SoundFont.Msg exposing (..)
import SoundFont.Subscriptions exposing (..)
import Time
import Phoenix.Socket
import Update
import Model exposing (Model, Track, ColluderFlags)
import View exposing (view)
import Material


main : Program ColluderFlags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = Update.update
        , view = View.view
        , subscriptions = subscriptions
        }


init : ColluderFlags -> ( Model, Cmd Msg )
init colluderFlags =
    let
        model =
            Model.init colluderFlags
    in
        ( model, initCmds model )


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


interval : Model -> Float
interval model =
    1 / (toFloat model.bpm)
