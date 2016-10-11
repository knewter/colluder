module Wheel.View exposing (..)

import Array
import Html exposing (Html)
import Element exposing (toHtml)
import Collage exposing (collage)
import Wheel.Donut as Donut
import Wheel.Segment as Segment
import Math.Vector2 as Vec2 exposing (vec2, Vec2,getX, getY)
import SoundFont.Types exposing (MidiNote)
import SoundFont.Msg as Msg exposing (Msg(..))
import MidiTable
import Model exposing (Model, Track)
import Dict exposing (Dict)

wheelSize : Vec2
wheelSize = vec2 500 500

viewWheel : Model -> Html Msg
viewWheel model =
    let
        sizedMdl =
            Donut.update (Donut.Resize wheelSize) <| toDonut model

        playingNoteNames =
            List.filterMap (toNote model) <| Dict.values model.song

        upSeg x seg =
            if isSelected playingNoteNames seg.label then
                Segment.select True seg
            else
                seg

        wheel =
            { sizedMdl | segments = Dict.map upSeg sizedMdl.segments }

    in
        toHtml <|
            collage (round <| getX wheelSize) (round <| getY wheelSize)
                [ Donut.view wheel
                ]


toNote : Model -> Track -> Maybe String
toNote model track =
    case Dict.get model.currentNote track.slots of
        Nothing ->
            Nothing

        Just b ->
            if b then
                Just <| getNoteText track.note
            else
                Nothing

toDonut : Model -> Donut.Model
toDonut model =
    fst <| Donut.init <| Array.toList <| MidiTable.notes


getNoteText : MidiNote -> String
getNoteText midi =
    case MidiTable.getNoteAndOctaveByNoteId midi.id of
        Nothing ->
            ""

        Just ( note, octave ) ->
            Debug.log "selected:" note




isSelected : List String -> String -> Bool
isSelected notes note =
    List.any (\s -> s == note) notes
