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
