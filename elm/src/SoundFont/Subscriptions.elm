module SoundFont.Subscriptions exposing (..)

import SoundFont.Ports exposing (..)
import SoundFont.Types exposing (..)
import SoundFont.Msg exposing (..)


-- SUBSCRIPTIONS


audioContextSub : Sub Msg
audioContextSub =
    getAudioContext ResponseAudioContext


oggEnabledSub : Sub Msg
oggEnabledSub =
    oggEnabled ResponseOggEnabled


fontsLoadedSub : Sub Msg
fontsLoadedSub =
    fontsLoaded ResponseFontsLoaded


playedNoteSub : Sub Msg
playedNoteSub =
    playedNote ResponsePlayedNote


playSequenceStartedSub : Sub Msg
playSequenceStartedSub =
    playSequenceStarted ResponsePlaySequenceStarted
