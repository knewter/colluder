module SoundFont.Types exposing (..)

{-| Audio Node
-}

{-
   Types that are shared between elm and javascript.

   This is partly experimental - to see what elm's custom and borders protection actually does.
   It seems that if you mention an object field's name in an elm type, it will be accepted as long
   as its type is supported.  If you don't mention a name, then it will be ignored.

   This means that javascript types with binary fields are effectively useless if you want to store them
   in elm and pass them back to javascript later via another port.  Notice that AudioNode is the empty tuple.
-}


type alias AudioNode =
    {}


{-| Audio Context
-}
type alias AudioContext =
    { currentTime : Float
    , destination : AudioNode
    , sampleRate : Int
    }


{-| Midi Note
-}
type alias MidiNote =
    { id : Int
    , timeOffset : Float
    , gain : Float
    }


{-| Midi Notes
-}
type alias MidiNotes =
    List MidiNote
