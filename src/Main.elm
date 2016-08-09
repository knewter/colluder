module Main exposing (..)

import Html.App as Html
import SoundFont.Ports exposing (..)
import SoundFont.Msg exposing (..)
import SoundFont.Subscriptions exposing (..)
import Time
import Update
import Model exposing (Model, Track, init)
import View exposing (view)


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



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        ([ audioContextSub
         , oggEnabledSub
         , fontsLoadedSub
         , playedNoteSub
         , playSequenceStartedSub
         ]
            ++ (tickSub model)
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
