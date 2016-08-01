module Styles exposing (css, mainNamespace, compile, CssIds(..), CssClasses(..))

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements
import Html.CssHelpers exposing (withNamespace)
import Styles.Variables as V


type CssIds
    = TopControls


type CssClasses
    = Active


compile =
    Css.compile


mainNamespace : Html.CssHelpers.Namespace String class id msg
mainNamespace =
    withNamespace "main"


css : Css.Stylesheet
css =
    (stylesheet << namespace mainNamespace.name)
        [ Css.Elements.body
            [ fontFamily sansSerif
            ]
        , (#) TopControls
            [ descendants
                [ Css.Elements.button
                    [ padding (Css.em 0.5)
                    , textTransform uppercase
                    , backgroundColor V.secondaryBackgroundColor
                    , property "border-width" "1px"
                    , borderStyle solid
                    , borderColor V.buttonBorderColor
                    ]
                ]
            ]
        ]
