module Main exposing (..)

import Html exposing (Html, div, text)
import Html.App as Html


main : Program Never
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { title : String
    , song : List Int
    }


init : ( Model, Cmd Msg )
init =
    { title = "Zelda Theme"
    , song = []
    }
        ! []



-- UPDATE


type Msg
    = NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    model ! []


view : Model -> Html Msg
view model =
    div [] [ text "music" ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
