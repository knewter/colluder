myapp.ports.initialiseAudioContext.subscribe(detectAudioContext);

function detectAudioContext() {
    myapp.context = getAudioContext();
    myapp.ports.getAudioContext.send(myapp.context);
}

myapp.ports.requestIsOggEnabled.subscribe(detectOggEnabled);

function detectOggEnabled() {
    enabled = canPlayOgg();
    myapp.ports.oggEnabled.send(enabled);
}

myapp.ports.requestLoadFonts.subscribe(loadSoundFonts);

function loadSoundFonts(dirname) {
    myapp.context = getAudioContext();
    var name = 'acoustic_grand_piano'
    var dir = dirname + '/'
    if (canPlayOgg()) {
      extension = '-ogg.js'
    }
    else {
      extension = '-mp3.js'
    }    
    Soundfont.nameToUrl = function (name) { return dir + name + extension }
    Soundfont.loadBuffers(myapp.context, name)
        .then(function (buffers) {
          console.log("buffers:", buffers)
          myapp.buffers = buffers;
          myapp.ports.fontsLoaded.send(true);
        })
}

myapp.ports.requestPlayNote.subscribe(playNote);

/* play a midi note */
function playNote(midiNote) {
  var res = playMidiNote(midiNote); 
  myapp.ports.playedNote.send(res);
}


myapp.ports.requestPlayNoteSequence.subscribe(playMidiNoteSequence);

/* play a sequence of midi notes */
function playMidiNoteSequence(midiNotes) {
  /* console.log("play sequence"); */
  if (myapp.buffers) { 
    midiNotes.map(playMidiNote);
    myapp.ports.playSequenceStarted.send(true);
  }
  else {
    myapp.ports.playSequenceStarted.send(false);
  }
}

/* IMPLEMENTATION */

/* Get the audio context */
getAudioContext = function() {
  return new (window.AudioContext || window.webkitAudioContext)();
};

/* can the browser play ogg format? */
canPlayOgg = function() {
  var audioTester = document.createElement("audio");
  if (audioTester.canPlayType('audio/ogg')) {
    /* console.log("browser supports ogg"); */
    return true;
  }
  else {
    /* console.log("browser does not support ogg"); */
    return false;
  }
}

/* play a midi note */
function playMidiNote(midiNote) {
  if (myapp.buffers) { 
    /* console.log("playing buffer at time: " + midiNote.timeOffset + " with gain: " + midiNote.gain + " for note: " + midiNote.id) */
    var buffer = myapp.buffers[midiNote.id]
    var source = myapp.context.createBufferSource();
    var gainNode = myapp.context.createGain();
    var time = myapp.context.currentTime + midiNote.timeOffset;
    gainNode.gain.value = midiNote.gain;
    source.buffer = buffer;
    source.connect(gainNode);
    gainNode.connect(myapp.context.destination)
    source.start(time);
    return true;
  }
  else {
    return false;
  }
};

