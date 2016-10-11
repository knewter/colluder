module Wheel.Donut exposing (..)

import Math.Vector2 as Vec2 exposing (Vec2, vec2, getX, getY)
import Collage as Co exposing (Form, defaultLine, LineStyle)
import Dict exposing (Dict)
import Wheel.Segment as Segment

type alias Model =
    { segments : Dict Int Segment.Model
    , radius : Float
    , width : Float
    , holeFactor : Float
    }


type Msg
    = Resize Vec2
    | Click Vec2
    | SegmentMsg Int Segment.Msg


init : List String -> ( Model, Cmd Msg )
init labels =
    let
        hole =
            0.6
    in
        { segments = createSegments hole labels
        , radius = 0
        , width = 1.0
        , holeFactor = hole
        }
            ! []


createSegments : Float -> List String -> Dict Int Segment.Model
createSegments hole labels =
    let
        defaultSegSize =
            (360 / toFloat (List.length labels))
    in
        List.map (Segment.init hole 0 (defaultSegSize * 0.9)) labels
            |> List.indexedMap (\i x -> ( i, x (toFloat i * defaultSegSize) ))
            |> Dict.fromList


update : Msg -> Model -> Model
update msg model =
    case msg of
        SegmentMsg id msg ->
            let
                upSeg x seg =
                    if x == id then
                        Segment.update msg seg
                    else
                        seg
            in
                { model | segments = Dict.map upSeg model.segments }

        Resize vec ->
            let
                newRad =
                    (*) 0.45 <| (Basics.min (getX vec) (getY vec))

                msgs =
                    Dict.map (\id v -> SegmentMsg id <| Segment.SetRadius newRad) model.segments
            in
                Dict.foldl (\k v -> update v) { model | radius = newRad } msgs

        Click pos ->
            let
                norm =
                    Vec2.normalize pos

                por =
                    posOnRing (Vec2.length pos) model
            in
                { model | segments = Dict.map (updateSegment por norm) model.segments }


updateSegment : Bool -> Vec2 -> Int -> Segment.Model -> Segment.Model
updateSegment onRing norm i seg =
    Segment.update (Segment.Select <| (onRing && onSegment norm i seg)) seg


selectSegmentMsg : Bool -> Int -> Segment.Model -> Msg
selectSegmentMsg doSelect id segment =
    SegmentMsg id <| Segment.Select doSelect


posOnRing : Float -> Model -> Bool
posOnRing len model =
    len <= model.radius && len >= model.radius * model.holeFactor


onSegment : Vec2 -> Int -> Segment.Model -> Bool
onSegment norm id segment =
    (segment.dotCenterToEnd < Vec2.dot norm segment.centerDirection)


view : Model -> Form
view model =
    Dict.toList model.segments
        |> List.unzip
        |> snd
        |> List.map Segment.view
        |> Co.group
