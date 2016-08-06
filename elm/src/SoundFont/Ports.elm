port module SoundFont.Ports exposing (..)

import SoundFont.Types exposing (..)


-- outgoing ports (for commands to javascript)


port initialiseAudioContext : () -> Cmd msg


port requestIsOggEnabled : () -> Cmd msg


port requestLoadFonts : String -> Cmd msg


port requestPlayNote : MidiNote -> Cmd msg


port requestPlayNoteSequence : MidiNotes -> Cmd msg



-- incoming ports (for subscriptions from javascript)


{-| get the audio context.
 Probably not much use because it is incomplete and cannot be passed back to javascript
-}
port getAudioContext : (AudioContext -> msg) -> Sub msg


{-| does the browser support the Ogg-Vorbis standard?
-}
port oggEnabled : (Bool -> msg) -> Sub msg


{-| Have the soundfonts been loaded OK?
-}
port fontsLoaded : (Bool -> msg) -> Sub msg


{-| Have we played the individual note?
-}
port playedNote : (Bool -> msg) -> Sub msg


{-| Have we started to play the note sequence?
-}
port playSequenceStarted : (Bool -> msg) -> Sub msg
