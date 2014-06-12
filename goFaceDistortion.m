function [ finalMsg ] = goFaceDistortion ( vpNummer , outputFileStr , buttonBoxON, debugEnabled )


% initialisieren der fehlenden Variablen
if nargin <4
  if ~exist('vpNummer'      , 'var') ;  vpNummer      = []; endif
  if ~exist('outputFileStr' , 'var') ;  outputFileStr = []; endif
  if ~exist('buttonBoxON'   , 'var') ;  buttonBoxON   = []; endif
  if ~exist('debugEnabled'  , 'var') ;  debugEnabled  = []; endif
endif

% default werte initialisieren
 if isempty(vpNummer)      ;  vpNummer      = 001    ; endif
 if isempty(outputFileStr) ;  outputFileStr = 'xkcd' ; endif
 if isempty(buttonBoxON)   ;  buttonBoxON   = false  ; endif
 if isempty(debugEnabled)  ;  debugEnabled  = false  ; endif

%%  [ finalMsg ] = goFaceDistortion ( vpNummer , outputFileStr , buttonBoxON, debugEnabled )
%  ----------------------------------------------------------------------------
%  Input:
%
%    vpNummer      = 001 (default)
%        Number of the participant. IMPRTANT this must be a number, because the
%        random seed is generated with this variable.
%
%    outputFileStr = 'xkcd' (default)
%        String variable that is added to the outputfile name
%        e.g. [experimentName 001 outputFileStr]
%
%    buttonBoxON   = false (default)
%        false == use the keyboard to get the rating input
%        true  == use a buttonbox
%
%    debugEnabled  = false (default)
%        false == 
%        true  ==
%
%  ----------------------------------------------------------------------------
%  Output:
%
%    finalMsg = custom message with no purpose but it will be nice.   I promise!
%
%  ----------------------------------------------------------------------------
%  Function
%  This scrip is creating the face distortion effect with a rating afterwards.
%  A example of this can be found here:
%                                    http://www.youtube.com/watch?v=wM6lGNhPujE
%
%  
%  The main script hast two phases:
%
%    imagepresentation phase
%
%               3    30     34      30    3
%	3	%%%%%%%%%%%%%%%%%%%%%%%%%%%           % = border / free space
%		%% ####### %%%%% ####### %%           # = actual face
%		%% ####### %%%%% ####### %%           Ö = eyes
%	94	%% #Ö###Ö# %%+%% #Ö###Ö# %%           + = fixation cross
%		%% ####### %%%%% ####### %%
%		%% ####### %%%%% ####### %%
%	3	%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  
%    rating phase
%
%               3            94           3
%	3	%%%%%%%%%%%%%%%%%%%%%%%%%%%           % = border / free space
%		%% %%%%%%%%%%%%%%%%%%%%% %%           T = rating text
%		%% %%%%%%%%%%%%%%%%%%%%% %%           N = numbers or buttons
%	94	%% %%%%% TTTTTTTTT %%%%% %%
%		%% %%% N %%% N %%% N %%% %%
%		%% %%%%%%%%%%%%%%%%%%%%% %%
%	3	%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%  ----------------------------------------------------------------------------
%  Requirements
%    Psychtoolbox-3  https://psychtoolbox-3.github.io/overview/
%    awesomeStuff    https://github.com/wuschLOR/awesomeStuff
%
%  ----------------------------------------------------------------------------
%  History
%  2014-06-11 mg  written
%  ----------------------------------------------------------------------------


%  --------------------------------------------------------------------------  %
%%  openGL
%  This script calls Psychtoolbox commands available only in OpenGL-based
%  versions of the Psychtoolbox. The Psychtoolbox command AssertPsychOpenGL will
%  issue an error message if someone tries to execute this script on a computer
%  without an OpenGL Psychtoolbox

AssertOpenGL;

%  --------------------------------------------------------------------------  %
%% debug
%  generell ist der default dass debug aus ist. sobald irgendetwas als die debuginformation angegeben wird wir debug angeworfen
%  Zur Zeit beeinflusst debug das Ausgabelevel der Warnungen und überspringt die VP Dateneingabe

switch debugEnabled
  case true
    debugLvl = 'dangerzone' % debug is turned on
        
  case false
    debugLvl = 'butter' % debug is false
endswitch

switch debugLvl
  case 'butter'
  
    %  http://psychtoolbox.org/faqwarningprefs
    newEnableFlag = 1;
    oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', newEnableFlag);
    %  enableFlag can be:
    %  0  normal settingsnewEnableFlag
    %  1  suppresses the printout of warnings

    newLevelVerbosity = 1
    oldLevelVerbosity = Screen('Preference', 'Verbosity', newLevelVerbosity);
    %  newLevelVerbosity can be any of:
    %  ~0) Disable all output - Same as using the 'SuppressAllWarnings' flag.
    %  ~1) Only output critical errors.
    %  ~2) Output warnings as well.
    %  ~3) Output startup information and a bit of additional information. This is the default.
    %  ~4) Be pretty verbose about information and hints to optimize your code and system.
    %  ~5) Levels 5 and higher enable very verbose debugging output, mostly useful for debugging PTB itself, not generally useful for end-users.
    vpNummerStr= num2str(vpNummer);

  case 'dangerzone'
    newEnableFlag = 0;
    oldEnableFlag = Screen('Preference', 'SuppressAllWarnings', newEnableFlag);

    newLevelVerbosity = 3
    oldLevelVerbosity = Screen('Preference', 'Verbosity', newLevelVerbosity);
    versionptb=Screen('Version') %% das als txt irgendwo ausgeben

    vpNummerStr = num2str( strftime( '%Y%m%d%H%M%S' ,localtime (time () ) ) );
    
endswitch

%% Generating the outputpaths
resultsFolder    = ['.' filesep 'results' filesep]
resultsFolderStr = [resultsFolder vpNummerStr '_' outputFileStr]

fileNameDiary           = [resultsFolderStr '_diary.mat']
fileNameBackupWorkspace = [resultsFolderStr '_backupWS.mat']
fileNameOutput          = [resultsFolderStr '_output.csv']

diary (fileNameDiary)


nextSeed = vpNummer % nextSeed wird für für alle random funktionen benutzt


%  --------------------------------------------------------------------------  %
%%  disable random input tothe console

ListenChar(2)

%  Keys pressed by the subject often show up in the Matlab command window as
%  well, cluttering that window with useless character junk. You can prevent
%  this from happening by disabling keyboard input to Matlab: Add a
%  ListenChar(2); command at the beginning of your script and a
%  ListenChar(0); to the end of your script to enable/disable transmission of
%  keypresses to Matlab. If your script should abort and your keyboard is
%  dead, press CTRL+C to reenable keyboard input -- It is the same as
%  ListenChar(0). See 'help ListenChar' for more info.



%  --------------------------------------------------------------------------  %
%% Tasten festlegen

KbName('UnifyKeyNames'); %keine ahnung warum oder was das macht aber

keyEscape = KbName('escape');

keyConfirm = KbName ('Return');


%  --------------------------------------------------------------------------  %
%%  textstyles

newTextFont = 'Courier New';
newTextSize = 20;
newTextColor= [00 00 00];


%  --------------------------------------------------------------------------  %
%%  screen innizialisieren

screenNumbers=Screen('Screens');
screenID = max(screenNumbers); % benutzt den Bildschirm mit der höchsten ID
%  screenID = 1; %benutzt den Bildschirm 1 bei Bedarf ändern

%  öffnet den Screen 
%  windowPtr = spezifikation des Screens die später zum ansteueren verwendet wird
%  rect hat wenn es ohne attribute initiert wird die größe des Bildschirms
%  also: von 0,0 oben links zu 1600, 900 unten rechts 

  [windowPtr,rect] = Screen('OpenWindow', screenID ,[], [50 50 650 650]);
%  [windowPtr,rect] = Screen('OpenWindow', screenID ,[], [0 0 1280 800]);
%   [windowPtr,rect] = Screen('OpenWindow', screenID ,[], [1 1 1279 799]);
%  [windowPtr,rect] = Screen('OpenWindow', screenID );

% Screen('BlendFunction', windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); original
% Screen('BlendFunction', windowPtr, GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
%  das hatte was mit dem transparenten hintergund zu tun - keine ahnung was das wirklich macht
[sourceFactorOld, destinationFactorOld]=Screen('BlendFunction', windowPtr, GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
Screen('BlendFunction', windowPtr, sourceFactorOld, destinationFactorOld)

HideCursor(screenID)
flipSlack =Screen('GetFlipInterval', windowPtr)
%  flipSlack =0
flipSlack = flipSlack/2 % das verhindert das das ganze kürzer wird hier noch etwas rumspielen - da es so manchmal zu kurze anzeigezeiten kommen kann 


oldTextFont  = Screen('TextFont'  , windowPtr , newTextFont );
oldTextSize  = Screen('TextSize'  , windowPtr , newTextSize );
oldTextColor = Screen('TextColor' , windowPtr , newTextColor);


%  --------------------------------------------------------------------------  %
%%  einlesen der Ordner:

logoImg   = getImgFolder( 'startup' , 'png' );

blockRatingInfo       = getImgFolder( 'tex rating'       , 'png' );
blockInstructionInfo  = getImgFolder( 'tex instructions' , 'png' );


  stimImgType ='png'
  stim01Info = getImgFolder( 'stim01' , stimImgType );
  stim02Info = getImgFolder( 'stim02' , stimImgType );
  stim03Info = getImgFolder( 'stim03' , stimImgType );
  stim04Info = getImgFolder( 'stim04' , stimImgType );
  stim05Info = getImgFolder( 'stim05' , stimImgType );
  stim06Info = getImgFolder( 'stim06' , stimImgType );
  stim07Info = getImgFolder( 'stim07' , stimImgType );
  stim08Info = getImgFolder( 'stim08' , stimImgType );
  stimEmpty  = getImgFolder( 'stimEmpty' ,  stimImgType);




%  --------------------------------------------------------------------------  %
%% bilder einlesen

  blockRatingTex      = makeTex(windowPtr, blockRatingInfo      , 'tex rating');
  blockInstructionTex = makeTex(windowPtr, blockInstructionInfo , 'tex instructions');

  stim01Tex =  makeTex(windowPtr , stim01Info , 'stim01');
  stim02Tex =  makeTex(windowPtr , stim02Info , 'stim02');
  stim03Tex =  makeTex(windowPtr , stim03Info , 'stim03');
  stim04Tex =  makeTex(windowPtr , stim04Info , 'stim04');
  stim05Tex =  makeTex(windowPtr , stim05Info , 'stim05');
  stim06Tex =  makeTex(windowPtr , stim06Info , 'stim06');
  stim07Tex =  makeTex(windowPtr , stim07Info , 'stim07');
  stim08Tex =  makeTex(windowPtr , stim08Info , 'stim08');
  stim00Tex =  makeTex(windowPtr , stimEmpty  , 'stimEmpty');


%  --------------------------------------------------------------------------  %
%% Blöcke Definieren

 dauer = 60; % dauer des des jeweiligen Block

 %  Namen geben
  blockDef(1).description = '4 W Weiblich';
  blockDef(2).description = '4 W Männlich';
  blockDef(3).description = '4 S Weiblich';
  blockDef(4).description = '4 S Männlich';
  blockDef(5).description = '4 A';
  blockDef(6).description = '4 W W + M';
  blockDef(7).description = '4 W W invertiert';
  blockDef(8).description = '4 W W negativiert';
  blockDef(9).description = '4 W W nur rechts';
  blockDef(10).description = '4 W W nur links';
  blockDef(11).description = '1 W W ';
  blockDef(12).description = '10 W W ';

%  präsentationszeit definieren 
  blockDef(1).presentationTime = 0.25;
  blockDef(2).presentationTime = 0.25;
  blockDef(3).presentationTime = 0.25;
  blockDef(4).presentationTime = 0.25;
  blockDef(5).presentationTime = 0.25;
  blockDef(6).presentationTime = 0.25;
  blockDef(7).presentationTime = 0.25;
  blockDef(8).presentationTime = 0.25;
  blockDef(9).presentationTime = 0.25;
  blockDef(10).presentationTime = 0.25;
  blockDef(11).presentationTime = 1;
  blockDef(12).presentationTime = 0.1;

%paarungen definieren 
  blockDef(1).texColum = [stim01Tex stim01Tex];
  blockDef(2).texColum = [stim02Tex stim02Tex];
  blockDef(3).texColum = [stim03Tex stim03Tex];
  blockDef(4).texColum = [stim04Tex stim04Tex];
  blockDef(5).texColum = [stim05Tex stim05Tex];
  blockDef(6).texColum = [stim06Tex stim06Tex];
  blockDef(7).texColum = [stim07Tex stim07Tex];
  blockDef(8).texColum = [stim08Tex stim08Tex];
  blockDef(9).texColum = [stim01Tex stim00Tex];
  blockDef(10).texColum = [stim00Tex stim01Tex];
  blockDef(11).texColum = [stim01Tex stim01Tex];
  blockDef(12).texColum = [stim01Tex stim01Tex];

  o = length(blockDef);

%  Stimuli randomisieren
  for i=1:o
    multi = dauer / blockDef(i).presentationTime;
    multi = multi / length(blockDef(i).texColum);
    multi = ceil( multi )
    % rechnet aus wie viel Durchläufe passieren werden (kann die angegebene zeit überschreiten da die Priorität auf die anzeige aller Stimuli liegt da die Präsentation eines halben Satzes doof wäre)
    [blockDef(i).texColumRand , nextSeed ] = randomizeColMatrix( blockDef(i).texColum , nextSeed , multi , false , false );
  endfor
%  das entsprechende Rating zur Bedingung hinzufügen
  for i=1:o
      blockDef(i).texRating = blockRatingTex(i);
  endfor
% instructions 
  for i=1:o
      blockDef(i).texInstructions = blockInstructionTex(i);
  endfor
% wie lang wird das Kreuz vor einsetzen der Stimuli angezeigt
  zeit.fixcross = 2; % zeit.fixcross für alle Blöcke auf 2 Sekunden setzen
  for i=1:o
      blockDef(i).timeFixcross = zeit.fixcross;
  endfor

% Blöcke insgesammt randomisieren
  rand('state' , nextSeed)
  newSequence = randperm( length(blockDef) );
  for i=1:o
      blockDefRand(:,:) = blockDef(newSequence);
  endfor

%  --------------------------------------------------------------------------  %
%% Positionen
%               3    30     34      30    3
%	15	%%%%%%%%%%%%%%%%%%%%%%%%%%%           % = border / free space
%		%% ####### %%%%% ####### %%           # = actual face
%		%% ####### %%%%% ####### %%           Ö = eyes
%	94	%% #Ö###Ö# %%+%% #Ö###Ö# %%           + = fixation cross
%		%% ####### %%%%% ####### %%
%		%% ####### %%%%% ####### %%
%	15	%%%%%%%%%%%%%%%%%%%%%%%%%%%

% x values for all locations

x.edgeLeftStart    = rect(1);
x.edgeLeftEnd      = rect(3) / 100 *  3;

    x.midStart     = rect(3) / 100 * 33;
    x.midCenter    = rect(3) / 2;
    x.midEnd       = rect(3) / 100 * 67;

x.edgeRightStart   = rect(3) / 100 * 97;
x.edgeRightEnd     = rect(3);

% x IMAGE LEFT
  x.imgLeftStart     = x.edgeLeftEnd;
  x.imgLeftEnd       = x.midStart;
    x.imgLeftCenter  = x.edgeLeftEnd + (x.midStart - x.edgeLeftEnd)/2;

% x IMAGE RIGTHT
  x.imgRightStart    = x.midEnd;
  x.imgRightEnd      = x.edgeRightStart;
    x.imgRightCenter = x.midEnd + (x.edgeRightStart - x.midEnd)/2;
  
x.center           = rect(3) / 2;

% y values for all locations

y.edgeTopStart     = rect(2);
y.edgeTopEnd       = rect(4) / 100 *  3;

y.edgeBotStart     = rect(4) / 100 * 97;
y.edgeBotEnd       = rect(4);

  y.imgTopStart    = rect(4) / 100 * 15;
  y.imgBotEnd      = rect(4) / 100 * 85;
      y.imgCenter    = y.edgeTopEnd + (y.edgeBotStart - y.edgeTopEnd)/2;

  y.imgRatingStart    = rect(4) / 100 * 77;
  y.imgRatingEnd      = rect(4) / 100 * 97;
    y.imgRatingCenter = y.imgRatingStart + (y.imgRatingEnd - y.imgRatingStart)/2;
  
y.center           = rect(4) / 2;

% putting together die rects [ x y x y]
rectImgLeft        = [x.imgLeftStart  y.imgTopStart    x.imgLeftEnd     y.imgBotEnd    ];
rectImgRight       = [x.imgRightStart y.imgTopStart    x.imgRightEnd    y.imgBotEnd    ];
rectImgInstruction = [x.edgeLeftEnd   y.edgeTopEnd     x.edgeRightStart y.edgeBotStart ];
rectImgRating      = [x.edgeLeftEnd   y.imgRatingStart x.edgeRightStart y.imgRatingEnd ];


%  --------------------------------------------------------------------------  %
%% berechnen der skalierten Bilder + Lokalisation

o = length(blockDefRand)
for j=1:o % für alle definierten Blöcke

  m = length(blockDefRand(j).texColumRand);
  for i = 1:m % für alle vorhandenen Elemente im texColumRand

    %  herrausfinden wie groß die textur ist - anhand des tex pointers
    texRectLeft      = Screen('Rect' , blockDefRand(j).texColumRand(i,1) );
    texRectRight     = Screen('Rect' , blockDefRand(j).texColumRand(i,2) );
    % verkleinern erstellen eines recht in das die textur gemalt wird ohne sich zu verzerren
    finRectLeft  = putRectInRect( rectImgLeft  , texRectLeft  );
    finRectRight = putRectInRect( rectImgRight , texRectRight );
    % abspeichern
    blockDefRand(j).finRectLeft(i,1) = {finRectLeft};
    blockDefRand(j).finRectRight(i,2)= {finRectRight};
  endfor
  
endfor

for j=1:o
  texRating  = Screen('Rect' , blockRatingTex(j) );
  finRectRating = putRectInRect (rectImgRating , texRating);
  blockDefRand(j).finRectRating = {finRectRating};
endfor

for j=1:o
  texInstructions  = Screen('Rect' , blockDefRand(j).texInstructions );
  finRectInstructions = putRectInRect (rectImgInstruction , texInstructions);
  blockDefRand(j).finRectInstructions = {finRectInstructions};
endfor

%  --------------------------------------------------------------------------  %
%% BLÖCKE
% hier passiert das eigentliche Experiment

o = length(blockDefRand);
for j=1:o  % für alle definierten Blöcke

  Screen( 'DrawTexture' , windowPtr , blockDefRand(j).texInstructions , [] , blockDefRand(j).finRectInstructions{});
  Screen('Flip', windowPtr);
  KbPressWait;

  m = length(blockDefRand(j).texColumRand);
  [empty, empty , timeBlockBegin ]=Screen('Flip', windowPtr);
  
  nextFlip =0
  drawFixCross (windowPtr , [18 18 18] , x.center , y.center , 80 , 2 );

  tic
  [empty,empty,crossFlip ]=Screen('Flip', windowPtr , nextFlip);
  nextFlip = crossFlip + blockDefRand(j).timeFixcross;
  

  for i = 1:m

#     Screen('FrameRect', windowPtr , [255 20 147] , rectImgLeft  );
#     Screen('FrameRect', windowPtr , [255 20 147] , rectImgRight );
  
    %  malen den textur + umstellen der blende und zurückstellen der blende
    Screen('BlendFunction', windowPtr, GL_ONE_MINUS_SRC_ALPHA, GL_SRC_ALPHA);
    Screen('DrawTexture', windowPtr, blockDefRand(j).texColumRand(i,1) , [] , blockDefRand(j).finRectLeft(i,1){} );
    Screen('DrawTexture', windowPtr, blockDefRand(j).texColumRand(i,2) , [] , blockDefRand(j).finRectRight(i,2){} );
    Screen('BlendFunction', windowPtr, sourceFactorOld, destinationFactorOld);

    %  Fixationskreuz
    drawFixCross (windowPtr , [18 18 18] , x.center , y.center , 80 , 2 );
    
    [empty, empty , lastFlip ] =Screen('Flip', windowPtr , nextFlip)
    nextFlip = lastFlip + blockDefRand(j).presentationTime - flipSlack

  endfor
  
  [empty,empty,timeBlockEnd ]=Screen('Flip', windowPtr , nextFlip)
  timeBlockTicToc = toc

  %  Blende wieder zurückstellen
  Screen('BlendFunction', windowPtr, sourceFactorOld, destinationFactorOld)

  % Rating anzeigen
  switch buttonBoxON
    case false
      Screen( 'DrawTexture' , windowPtr , blockDefRand(j).texRating , [] , blockDefRand(j).finRectRating{})
      Screen('Flip', windowPtr)

      % reaktionszeit abgreifen
      [pressedButtonTime , pressedButtonValue , pressedButtonStr , pressedButtonCode] = getRating

      timeReactionSinceBlockBegin = pressedButtonTime - timeBlockBegin
      timeReactionSinceBlockEnd   = pressedButtonTime - timeBlockEnd
    case true
      % i should think about something
    otherwise
      % critical error - this should not happen
  endswitch

%    dem outputfile werte zuweisen
  headings        = { ...
    'vpNummer' , ...
    'BunusString' , ...
    'Index' , ...
    'Block' , ...
    'KeyString' , ...
    'KeyValue'  , ...
    'ReaktionszeitBlockStart' , ...
    'ReaktionszeitBlockEnd' , ...
    'tic toc (sec)'   }

  outputCell(j,:) = {...
    vpNummer  ,...
    outputFileStr , ...
    num2str(j),...
    blockDefRand(j).description ,...
    pressedButtonStr ,...
    pressedButtonValue , ...
    timeReactionSinceBlockBegin , ...
    timeReactionSinceBlockEnd , ...
    timeBlockTicToc  }
  % attatch names to the outputCell
  outputCellFin= [headings ; outputCell]
  %  speicherndes output files
  cell2csv ( fileNameOutput , outputCellFin, ';')
endfor

%  und hier ist es vorbei

%  --------------------------------------------------------------------------  %
%%  Data saving

infotainment(windowPtr , 'saving your data')

%  den workspace sichern (zur fehlersuche usw)
save (fileNameBackupWorkspace)

% attatch names to the outputCell
outputCellFin= [headings ; outputCell]

%  speicherndes output files 
cell2csv ( fileNameOutput , outputCellFin, ';')


diary off

%  --------------------------------------------------------------------------  %
%%  end all processes
infotainment(windowPtr , 'target aquired for termination')

ListenChar(0)
Screen('closeall')

finalMsg = 'geschafft'

endfunction
