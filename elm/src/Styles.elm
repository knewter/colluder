module Styles exposing (css, mainNamespace, compile, CssIds(..), CssClasses(..))

import Css exposing (..)
import Css.Namespace exposing (namespace)
import Css.Elements
import Html.CssHelpers exposing (withNamespace)
import Styles.Variables as V


type CssIds
    = TopControls


type CssClasses
    = CurrentNote
    | Track
    | Song
    | Checked


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
        , (.) Track
            [ children
                [ Css.Elements.td
                    [ padding (Css.px 0)
                    , margin (Css.px 0)
                    , width (Css.em 1)
                    , height (Css.em 1)
                    , backgroundColor V.noteBackgroundColor
                    , borderRightWidth (Css.px 1)
                    , borderRightColor (rgba 0 0 0 0.0)
                    , borderRightStyle solid
                    , children
                        [ Css.Elements.input
                            [ opacity (Css.int 0)
                            , width (Css.pct 100)
                            , height (Css.pct 100)
                            ]
                        ]
                    , (withClass Checked)
                        [ backgroundColor (rgba 255 0 0 0.3) |> important
                        ]
                    ]
                ]
            ]
        , (.) CurrentNote
            [ backgroundColor V.currentNoteBackgroundColor |> important
            , borderRightColor (rgba 0 0 0 1.0) |> important
            ]
        , (.) Song
            [ children
                [ Css.Elements.table
                    [ property "border-spacing" "0"
                    ]
                ]
            ]
        ]
