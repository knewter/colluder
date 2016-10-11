module Wheel.Segment exposing (..)

import Math.Vector2 as Vec2 exposing (Vec2, vec2, getX, getY, toTuple, scale)
import Collage exposing (..)
import Color exposing (Color)
import Text exposing (fromString)
import Element exposing (centered)


type alias Model =
    { strokeColor : Color
    , fillColor : Color
    , degrees : Float
    , rotation : Float
    , label : String
    , radius : Float
    , centerDirection : Vec2
    , dotCenterToEnd : Float
    , holeFactor : Float
    , selected : Bool
    }


type Msg
    = Select Bool
    | SetRadius Float


init : Float -> Float -> Float -> String -> Float -> Model
init holeFactor radius degrees label rotation =
    let
        centerDirection =
            getVector rotation degrees 0.5 1

        rightDirection =
            getVector rotation degrees 1 1
    in
        select False
            { radius = radius
            , strokeColor = Color.black
            , fillColor = Color.hsl (Basics.degrees rotation) 1 0.5
            , degrees = degrees
            , rotation = rotation
            , label = label
            , centerDirection = centerDirection
            , dotCenterToEnd = Vec2.dot centerDirection rightDirection
            , holeFactor = holeFactor
            , selected = True
            }


getVector : Float -> Float -> Float -> Float -> Vec2
getVector rotation degrees offset scale =
    rotate (vec2 scale 0) (-rotation + (offset * -degrees))


update : Msg -> Model -> Model
update msg model =
    case msg of
        Select b ->
            select b model

        SetRadius r ->
            { model | radius = r }


select : Bool -> Model -> Model
select selected model =
    if selected == model.selected then
        model
    else
        { model
            | radius =
                if selected then
                    (model.radius * 1.04)
                else
                    (model.radius / 1.04)
            , strokeColor =
                if selected then
                    Color.complement model.fillColor
                else
                    Color.black
            , selected = selected
        }



--- VIEW


grad : Model -> Color.Gradient
grad model =
    let
        start =
            Vec2.toTuple <| Vec2.scale (model.holeFactor * model.radius) model.centerDirection

        end =
            Vec2.toTuple <| Vec2.scale model.radius model.centerDirection

        ec =
            Color.toHsl model.fillColor
    in
        Color.linear start end <|
            [ ( 0, Color.hsla ec.hue ec.saturation ec.lightness 0.1 )
            , ( 1, Color.hsla ec.hue ec.saturation ec.lightness 0.3 )
            ]


view : Model -> Form
view model =
    let
        shape =
            segmentShape model

        frm =
            group <|
                [ gradient (grad model) shape
                , outlined (segmentLineStyle model) shape
                , segmentLabel model
                ]
    in
        if model.selected then
            frm
        else
            Collage.alpha 0.5 frm


segmentShape : Model -> Shape
segmentShape model =
    let
        count =
            5

        outPositions =
            List.map (\i -> getVector model.rotation model.degrees (i / count) model.radius) [0..count]

        inPositions =
            outPositions
                |> List.map (Vec2.scale model.holeFactor)
                |> List.reverse
    in
        polygon <| List.map toTuple (outPositions ++ inPositions)


segmentLineStyle : Model -> LineStyle
segmentLineStyle model =
    { defaultLine
        | color = model.fillColor
        , width = segmentLineWidth model
        , join = Collage.Smooth
        , cap = Collage.Padded
    }

segmentLineWidth: Model -> Float
segmentLineWidth model =
  let fact = if model.selected then
      0.016
    else
      0.018
  in model.radius * fact

segmentLabel : Model -> Form
segmentLabel model =
    Text.fromString model.label
        |> Text.height (textHeight model)
        |> Text.bold
        |> Text.color (textColor model)
        |> Element.centered
        |> Collage.toForm
        |> move (toTuple <| center model)


textHeight : Model -> Float
textHeight model =
    model.radius * 0.19


textColor : Model -> Color
textColor model =
    if (model.selected) then
        Color.black
    else
        model.fillColor


center : Model -> Vec2
center model =
    getVector model.rotation model.degrees 0.5 (model.radius * 0.5 * (1 + model.holeFactor))


rotate : Vec2 -> Float -> Vec2
rotate v g =
    let
        ix =
            getX v

        iy =
            getY v

        r =
            g * 0.017453293

        s =
            sin r

        c =
            cos r

        sx =
            s * ix

        cx =
            c * ix

        sy =
            s * iy

        cy =
            c * iy

        tx =
            cx - sy

        ty =
            sx + cy
    in
        vec2 tx ty
