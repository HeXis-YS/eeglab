% EEGPLOTOLD - display data in a horizontal scrolling fashion 
%                with (optional) gui controls (version 2.3)
% Usage: 
%   >> eegplotold(data,srate,spacing,eloc_file,windowlength,title)
%   >> eegplotold('noui',data,srate,spacing,eloc_file,startpoint,color)
%
% Inputs:
%   data         - Input data matrix (chans,timepoints) 
%   srate        - Sampling rate in Hz {default|0: 256 Hz}
%   spacing      - Space between channels (default|0: max(data)-min(data))
%   eloc_file    - Electrode filename as in >> topoplot example
%                  [] -> no labels; default|0 -> integers 1:nchans
%                  vector of integers -> channel numbers
%   windowlength - Number of seconds of EEG displayed {default 10 s}
%   color        - EEG plot color {default black/white}
%   'noui'       - Display eeg in current axes without user controls
%
% Author: Colin Humphries, CNL, Salk Institute, La Jolla, 5/98
%
% See also: EEGPLOT, EEGPLOTGOLD, EEGPLOTSOLD

% Copyright (C) Colin Humphries, CNL, Salk Institute 3/97 from EEGPLOTOLD
%
% This file is part of EEGLAB, see http://www.eeglab.org
% for the documentation and details.
%
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are met:
%
% 1. Redistributions of source code must retain the above copyright notice,
% this list of conditions and the following disclaimer.
%
% 2. Redistributions in binary form must reproduce the above copyright notice,
% this list of conditions and the following disclaimer in the documentation
% and/or other materials provided with the distribution.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
% THE POSSIBILITY OF SUCH DAMAGE.

% Runs under Matlab 5.0+ (not supported for Matlab 4)
% 
% RCS-recorded version number, date, editor and comments
% $Log: eegplotold.m,v $
% Revision 1.3  2007/02/24 02:42:37  toby
% added auto-log line
%  
%
% Edit History:
% 5-14-98 v2.1 fixed bug for small-variance data -ch
% 1-31-00 v2.2 exchanged meaning of > and >>, < and << -sm
% 8-15-00 v2.3 turned on SPACING_EYE and added int vector input for eloc_file -sm
% 12-16-00 added undocumented figure position arg (if not 'noui') -sm
% 01-25-02 reformated help & license, added links -ad 

function [outvar1] = eegplotold(data,p1,p2,p3,p4,p5,p6)

% Defaults (can be re-defined):

DEFAULT_ELOC_FILE = 0;            % Default electrode name file
                                  %   [] - none, 0 - numbered, or filename
DEFAULT_SAMPLE_RATE = 256;        % Samplerate 
DEFAULT_PLOT_COLOR = 'k';         % EEG line color
DEFAULT_AXIS_BGCOLOR = [.8 .8 .8];% EEG Axes Background Color
DEFAULT_FIG_COLOR = [.8 .8 .8];   % Figure Background Color
DEFAULT_AXIS_COLOR = 'k';         % X-axis, Y-axis Color, text Color
DEFAULT_WINLENGTH = 10;           % Number of seconds of EEG displayed
DEFAULT_GRID_SPACING = 1;         % Grid lines every n seconds
DEFAULT_GRID_STYLE = '-';         % Grid line style
YAXIS_NEG = 'off';                % 'off' = positive up 
DEFAULT_NOUI_PLOT_COLOR = 'k';    % EEG line color for noui option
                                  %   0 - 1st color in AxesColorOrder
DEFAULT_TITLEVAL = 2;             % Default title
                                  %   string, 2 - variable name, 0 - none
SPACING_EYE = 'on';               % spacing I on/off
SPACING_UNITS_STRING = '\muV';    % optional units for spacing I Ex. uV
DEFAULT_AXES_POSITION = [0.0964286 0.15 0.842 0.788095];
                                  % dimensions of main EEG axes
if nargin<1
   help eegplotold
   return
end
				  
% %%%%%%%%%%%%%%%%%%%%%%%%
% Setup inputs
% %%%%%%%%%%%%%%%%%%%%%%%%

if ~ischar(data) % If NOT a 'noui' call or a callback from uicontrols

  if nargin == 7  % undocumented feature - allows position to be specd.
    posn = p6;
  else
    posn = NaN;
  end

  % if strcmp(YAXIS_NEG,'on')
  %   data = -data;
  % end

  if nargin < 6
    titleval = 0;
  else
    titleval = p5;
  end
  if nargin < 5
    winlength = 0;
  else
    winlength = p4;
  end
  if nargin < 4
    eloc_file = DEFAULT_ELOC_FILE;
  else
    eloc_file = p3;
  end
  if nargin < 3
    spacing = 0;
  else
    spacing = p2;
  end
  if nargin < 2
    Fs = 0;
  else
    Fs = p1;
  end
  if isempty(titleval)
    titleval = 0;
  end
  if isempty(winlength)
    winlength = 0;
  end
  if isempty(spacing)
    spacing = 0;
  end
  if isempty(Fs)
    Fs = 0;
  end
    
  [chans,frames] = size(data);
  
  if winlength == 0
    winlength = DEFAULT_WINLENGTH;  % Set window length
  end
  
  if ischar(eloc_file)           % Read in electrode names
    fid = fopen(eloc_file);       % Read file
    if fid < 1
      error('error opening electrode file')
    end
    YLabels = fscanf(fid,'%d %f %f%s',[7 128]);
    fclose(fid);
    YLabels = char(YLabels(4:7,:)');
    ii = find(YLabels == '.');
    YLabels(ii) = ' ';
    YLabels = flipud(str2mat(YLabels,' '));
  elseif length(eloc_file) == chans
    YLabels = num2str(eloc_file');
  elseif length(eloc_file) == 1 && eloc_file(1) == 0
    YLabels = num2str((1:chans)');  % Use numbers
  else
    YLabels = [];    % no labels used
  end
  YLabels = flipud(str2mat(YLabels,' '));
  
  if spacing == 0
    spacing = (max(max(data')-min(data')));  % Set spacing to max/min data
    if spacing > 10
      spacing = round(spacing);
    end
  end
  
  if titleval == 0  
    titleval = DEFAULT_TITLEVAL;  % Set title value
  end
  
  if Fs == 0
    Fs = DEFAULT_SAMPLE_RATE;     % Set samplerate
  end
  
  % %%%%%%%%%%%%%%%%%%%%%%%%
  % Prepare figure and axes
  % %%%%%%%%%%%%%%%%%%%%%%%%
  
  if isnan(posn) % no user-supplied position vector
   figh = figure('UserData',[winlength Fs],...
      'Color',DEFAULT_FIG_COLOR,...
      'MenuBar','none','tag','eegplotold');
  else
   figh = figure('UserData',[winlength Fs],...
      'Color',DEFAULT_FIG_COLOR,...
      'MenuBar','none','tag','eegplotold','Position',posn);
  end
 %entry 
  ax1 = axes('tag','eegaxis','parent',figh,...
      'userdata',data,...
      'Position',DEFAULT_AXES_POSITION,...
      'Box','on','xgrid','on',...
      'gridlinestyle',DEFAULT_GRID_STYLE,...
      'Xlim',[0 winlength*Fs],...
      'xtick',[0:Fs*DEFAULT_GRID_SPACING:winlength*Fs],...
      'Ylim',[0 (chans+1)*spacing],...
      'YTick',[0:spacing:chans*spacing],...
      'YTickLabel',YLabels,...
      'XTickLabel',num2str((0:DEFAULT_GRID_SPACING:winlength)'),...
      'TickLength',[.005 .005],...
      'Color',DEFAULT_AXIS_BGCOLOR,...
      'XColor',DEFAULT_AXIS_COLOR,...
      'YColor',DEFAULT_AXIS_COLOR);
  
  if ischar(titleval)      % plot title
    title(titleval)
  elseif titleval == 2
    title(inputname(1))
  end
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up uicontrols
  % %%%%%%%%%%%%%%%%%%%%%%%%%
  
% Four move buttons: << < > >>

  u(1) = uicontrol('Parent',figh, ...
	'Units','points', ...
	'Position',[49.1294 12.7059 50.8235 16.9412], ...
	'Tag','Pushbutton1',...
	'string','<<',...
	'Callback','eegplotold(''drawp'',1)');
  u(2) = uicontrol('Parent',figh, ...
	'Units','points', ...
	'Position',[105.953 12.7059 33.0353 16.9412], ...
	'Tag','Pushbutton2',...
	'string','<',...
	'Callback','eegplotold(''drawp'',2)');
  u(3) = uicontrol('Parent',figh, ...
	'Units','points', ...
	'Position',[195.882 12.7059 33.8824 16.9412], ...
	'Tag','Pushbutton3',...
	'string','>',...
	'Callback','eegplotold(''drawp'',3)');
  u(4) = uicontrol('Parent',figh, ...
	'Units','points', ...
	'Position',[235.765 12.7059 50.8235 16.9412], ...
	'Tag','Pushbutton4',...
	'string','>>',...
	'Callback','eegplotold(''drawp'',4)');

% Text edit fields: EPosition ESpacing

  u(5) = uicontrol('Parent',figh, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Position',[144.988 10.1647 44.8941 19.4824], ...
	'Style','edit', ...
	'Tag','EPosition',...
	'string','0',...
	'Callback','eegplotold(''drawp'',0)');
  u(6) = uicontrol('Parent',figh, ...
	'Units','points', ...
	'BackgroundColor',[1 1 1], ...
	'Position',[379.482-30 11.8 46.5882 19.5], ...
	'Style','edit', ...
	'Tag','ESpacing',...
	'string',num2str(spacing),...
	'Callback','eegplotold(''draws'',0)');

% ESpacing buttons: + -

  u(7) = uicontrol('Parent',figh, ...
	'Units','points', ...
	'Position',[435-30 22.9 22 13.5], ...
	'Tag','Pushbutton5',...
	'string','+',...
	'FontSize',8,...
	'Callback','eegplotold(''draws'',1)');
  u(8) = uicontrol('Parent',figh, ...
	'Units','points', ...
	'Position',[435-30 6.7 22 13.5], ...
	'Tag','Pushbutton6',...
	'string','-',...
	'FontSize',8,...
	'Callback','eegplotold(''draws'',2)');

  set(u,'Units','Normalized')
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Set up uimenus
  % %%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  % Figure Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(7) = uimenu('Parent',figh,'Label','Figure');
  m(8) = uimenu('Parent',m(7),'Label','Orientation');
  uimenu('Parent',m(7),'Label','Close',...
      'Callback','delete(gcbf)')
  
  % Portrait %%%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''portrait'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
		
  uimenu('Parent',m(8),'Label','Portrait','checked',...
      'on','tag','orient','callback',timestring)
  
  % Landscape %%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'PANT1 = get(OBJ1,''parent'');',...
	        'OBJ2 = findobj(''tag'',''orient'',''parent'',PANT1);',...
		'set(OBJ2,''checked'',''off'');',...
		'set(OBJ1,''checked'',''on'');',...
		'set(FIG1,''PaperOrientation'',''landscape'');',...
		'clear OBJ1 FIG1 OBJ2 PANT1;'];
  
  uimenu('Parent',m(8),'Label','Landscape','checked',...
      'off','tag','orient','callback',timestring)
  
  % Display Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(1) = uimenu('Parent',figh,...
      'Label','Display');
  
  % X grid %%%%%%%%%%%%
  m(3) = uimenu('Parent',m(1),'Label','X Grid');
  
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''xgrid'',''on'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(3),'Label','on','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''xgrid'',''off'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(3),'Label','off','Callback',timestring)
  
  % Y grid %%%%%%%%%%%%%
  m(4) = uimenu('Parent',m(1),'Label','Y Grid');
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''ygrid'',''on'');',...
		'clear FIGH AXESH;'];  
  uimenu('Parent',m(4),'Label','on','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''ygrid'',''off'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(4),'Label','off','Callback',timestring)
  
  % Grid Style %%%%%%%%%
  m(5) = uimenu('Parent',m(1),'Label','Grid Style');
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''--'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','- -','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-.'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','_ .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'','':'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','. .','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''gridlinestyle'',''-'');',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(5),'Label','__','Callback',timestring)
  
  % Scale Eye %%%%%%%%%
  timestring = ['[OBJ1,FIG1] = gcbo;',...
	        'eegplotold(''scaleeye'',OBJ1,FIG1);',...
		'clear OBJ1 FIG1;'];
  m(7) = uimenu('Parent',m(1),'Label','Scale I','Callback',timestring);
  
  % Title %%%%%%%%%%%%
  uimenu('Parent',m(1),'Label','Title','Callback','eegplotold(''title'')')
  
  % Settings Menu %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  m(2) = uimenu('Parent',figh,...
      'Label','Settings'); 
  
  % Window %%%%%%%%%%%%
  uimenu('Parent',m(2),'Label','Window',...
      'Callback','eegplotold(''window'')')
  
  % Samplerate %%%%%%%%
  uimenu('Parent',m(2),'Label','Samplerate',...
      'Callback','eegplotold(''samplerate'')')
  
  % Electrodes %%%%%%%%
  m(6) = uimenu('Parent',m(2),'Label','Electrodes');
  
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'set(AXESH,''YTickLabel'',[]);',...
		'clear FIGH AXESH;'];
  uimenu('Parent',m(6),'Label','none','Callback',timestring)
  timestring = ['FIGH = gcbf;',...
	        'AXESH = findobj(''tag'',''eegaxis'',''parent'',FIGH);',...
		'YTICK = get(AXESH,''YTick'');',...
		'YTICK = length(YTICK);',...
		'set(AXESH,''YTickLabel'',flipud(str2mat(num2str((1:YTICK-1)''),'' '')));',...
		'clear FIGH AXESH YTICK;'];
  uimenu('Parent',m(6),'Label','numbered','Callback',timestring)
  uimenu('Parent',m(6),'Label','load file',...
      'Callback','eegplotold(''loadelect'');')
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot EEG Data
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  meandata = mean(data(:,1:round(min(frames,winlength*Fs)))');  
  axes(ax1)
  hold on
  for i = 1:chans
    plot(data(chans-i+1,...
	1:round(min(frames,winlength*Fs)))-meandata(chans-i+1)+i*spacing,...
	'color',DEFAULT_PLOT_COLOR)
  end
  
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  % Plot Spacing I
  % %%%%%%%%%%%%%%%%%%%%%%%%%%
  if strcmp(SPACING_EYE,'on')
    
    YLim = get(ax1,'Ylim');
    A = DEFAULT_AXES_POSITION;
    axes('Position',[A(1)+A(3) A(2) 1-A(1)-A(3) A(4)],...
	'Visible','off','Ylim',YLim,'tag','eyeaxes')
    axis manual
    Xl = [.3 .6 .45 .45 .3 .6];
    Yl = [spacing*2 spacing*2 spacing*2 spacing*1 spacing*1 spacing*1];
    line(Xl,Yl,'color',DEFAULT_AXIS_COLOR,'clipping','off',...
 	'tag','eyeline')
    text(.5,YLim(2)/23+Yl(1),num2str(spacing,4),...
	'HorizontalAlignment','center','FontSize',10,...
	'tag','thescale')
    if strcmp(YAXIS_NEG,'off')
      text(Xl(2)+.1,Yl(1),'+','HorizontalAlignment','left',...
	  'verticalalignment','middle')
      text(Xl(2)+.1,Yl(4),'-','HorizontalAlignment','left',...
	  'verticalalignment','middle')
    else
      text(Xl(2)+.1,Yl(4),'+','HorizontalAlignment','left',...
	  'verticalalignment','middle')
      text(Xl(2)+.1,Yl(1),'-','HorizontalAlignment','left',...
	  'verticalalignment','middle')
    end
    if ~isempty(SPACING_UNITS_STRING)
      text(.5,-YLim(2)/23+Yl(4),SPACING_UNITS_STRING,...
	  'HorizontalAlignment','center','FontSize',10)
    end
    set(m(7),'checked','on')
  
  elseif strcmp(SPACING_EYE,'off')
    YLim = get(ax1,'Ylim');
    A = DEFAULT_AXES_POSITION;
    axes('Position',[A(1)+A(3) A(2) 1-A(1)-A(3) A(4)],...
	'Visible','off','Ylim',YLim,'tag','eyeaxes')
    axis manual
    set(m(7),'checked','off')
    
  end 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% End Main Function
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

else
  switch data
  case 'drawp'
    % Redraw EEG and change position
    figh = gcbf;                          % figure handle
    if strcmp(get(figh,'tag'),'dialog')
      figh = get(figh,'UserData');
    end
    ax1 = findobj('tag','eegaxis','parent',figh); % axes handle
    EPosition = findobj('tag','EPosition','parent',figh); % ui handle
    ESpacing = findobj('tag','ESpacing','parent',figh);   % ui handle
        
    data = get(ax1,'UserData');  % Data (Note: this could also be global)
    timestr = get(EPosition,'string');      % current position
    % if timestr == 'end'
       % time = ceil(frames/Fs)-winlength;
       % fprintf('timestr = %s\n',timestr);
    % else
       time = str2num(timestr);             % current position
    % end
    spacing = str2num(get(ESpacing,'string')); % current spacing
    winlength = get(figh,'UserData');       
    Fs = winlength(2);                      % samplerate
    winlength = winlength(1);               % window length
    
    [chans,frames] = size(data);
        
    if p1 == 1
      time = time-winlength;     % << subtract one window length
    elseif p1 == 2               
      time = time-1;             % < subtract one second
    elseif p1 == 3
      time = time+1;             % > add one second
    elseif p1 == 4
      time = time+winlength;     % >> add one window length
    end
    
    time = max(0,min(time,ceil(frames/Fs)-winlength));
    
    set(EPosition,'string',num2str(time))  % Update edit box
    % keyboard
    % Plot data and update axes
    meandata = mean(data(:,round(time*Fs+1):round(min((time+winlength)*Fs,...
	frames)))');  
    axes(ax1)
    cla
    for i = 1:chans
      plot(data(chans-i+1,round(time*Fs+1):round(min((time+winlength)*Fs,...
	  frames)))-meandata(chans-i+1)+i*spacing,...
	  'color',DEFAULT_PLOT_COLOR,'clipping','off')
    end
    set(ax1,'XTickLabel',...
	num2str((time:DEFAULT_GRID_SPACING:time+winlength)'),...
	'Xlim',[0 winlength*Fs],...
	'XTick',[0:Fs*DEFAULT_GRID_SPACING:winlength*Fs])
  
  case 'draws'
    % Redraw EEG and change scale
    figh = gcbf;                                          % figure handle
    ax1 = findobj('tag','eegaxis','parent',figh);         % axes handle
    EPosition = findobj('tag','EPosition','parent',figh); % ui handle
    ESpacing = findobj('tag','ESpacing','parent',figh);   % ui handle
    
    data = get(ax1,'UserData');                % data
    time = str2num(get(EPosition,'string'));   % current position
    spacing = str2num(get(ESpacing,'string')); % current spacing
    winlength = get(figh,'UserData');  
    
    if isempty(spacing) || isempty(time)
      return  % return if valid numbers are not in the edit boxes
    end
    
    Fs = winlength(2);        % samplerate
    winlength = winlength(1); % window length
    
    orgspacing = round(max(max(data')-min(data'))); % original spacing
    
    [chans,frames] = size(data);   
    
    if p1 == 1
      spacing = spacing + .05*orgspacing; % increase spacing (5%)
    elseif p1 == 2
      spacing = max(0,spacing-.05*orgspacing); % decrease spacing (5%)
      if spacing == 0
	spacing = spacing + .05*orgspacing;
      end
    end
    
    set(ESpacing,'string',num2str(spacing,4))  % update edit box
    % plot data and update axes
    meandata = mean(data(:,round(time*Fs+1):round(min((time+winlength)*Fs,...
	frames)))');  
    axes(ax1)
    cla
    for i = 1:chans
      plot(data(chans-i+1,...
	  round(time*Fs+1):round(min((time+winlength)*Fs,...
	  frames)))-meandata(chans-i+1)+i*spacing,...
	  'color',DEFAULT_PLOT_COLOR,'clipping','off')
    end
    set(ax1,'YLim',[0 (chans+1)*spacing],...
	'YTick',[0:spacing:chans*spacing])
    
    % update scaling eye if it exists
    eyeaxes = findobj('tag','eyeaxes','parent',figh);
    if ~isempty(eyeaxes)
      eyetext = findobj('type','text','parent',eyeaxes,'tag','thescale');
      set(eyetext,'string',num2str(spacing,4))
    end
    
  case 'window'
    % get new window length with dialog box
    fig = gcbf;
    oldwinlen = get(fig,'UserData');
    pos = get(fig,'Position');
    figx = 400;
    figy = 200;
    fhand = figure('Units','pixels',...
        'Position',...
        [pos(1)+pos(3)/2-figx/2 pos(2)+pos(4)/2-figy/2 figx figy],...
        'Resize','off','CloseRequestFcn','','menubar','none',...
        'numbertitle','off','tag','dialog','userdata',fig);
    uicolor = get(fhand,'Color');
    
    uicontrol('Style','Text','Units','Pixels',...
        'String','Enter new window length(secs):',...
        'Position',[20 figy-40 300 25],'HorizontalAlignment','left',...
        'BackgroundColor',uicolor,'FontSize',14)
    
    timestring = ['[OBJ1,FIGH1] = gcbo;',...
	          'FIH0 = get(OBJ1,''UserData'');',...
		  'AXH0 = findobj(''tag'',''eegaxis'',''parent'',FIH0);',...
		  'WLEN = str2num(get(OBJ1,''String''));',...
		  'if ~isempty(WLEN);',...
		    'UDATA = get(FIH0,''UserData'');',...
		    'UDATA(1) = WLEN;',...
		    'set(FIH0,''UserData'',UDATA);',...
		    'eegplotold(''drawp'',0);',...
		    'delete(FIGH1);',...
		  'end;',...
		  'clear OBJ1 FIGH1 FIH0 AXH0 WLEN UDATA;'];
		    
    
    ui1 = uicontrol('Style','Edit','Units','Pixels',...
        'FontSize',12,...
        'Position',[120 figy-100 70 30],...
	'Callback',timestring,'UserData',fig,...
	'String',num2str(oldwinlen(1)));
    
    timestring = ['[OBJ1,FIGH1] = gcbo;',...
	          'FIH0 = get(OBJ1,''UserData'');',...
		  'AXH0 = findobj(''tag'',''eegaxis'',''parent'',FIH0(1));',...
		  'SRAT = str2num(get(FIH0(2),''String''));',...
		  'if ~isempty(SRAT);',...
		    'UDATA = get(FIH0(1),''UserData'');',...
		    'UDATA(2) = SRAT;',...
		    'set(FIH0(1),''UserData'',UDATA);',...
		    'eegplotold(''drawp'',0);',...
		    'delete(FIGH1);',...
		  'end;',...
		  'clear OBJ1 FIGH1 FIH0 AXH0 SRAT UDATA;'];
    
    uicontrol('Style','PushButton','Units','Pixels',...
        'String','OK','FontSize',14,...
        'Position',[figx/4-20 10 65 30],...
        'Callback',timestring,'UserData',[fig,ui1])
    
    TIMESTRING = ['[OBJ1,FIGH1] = gcbo;',...
	        'delete(FIGH1);',...
		'clear OBJ1 FIGH1;'];
	  
    uicontrol('Style','PushButton','Units','Pixels',...
        'String','Cancel','FontSize',14,...
        'Position',[3*figx/4-20 10 65 30],...
        'Callback',TIMESTRING)
    
  case 'samplerate'
    % Get new samplerate
    fig = gcbf;
    oldsrate = get(fig,'UserData');
    pos = get(fig,'Position');
    figx = 400;
    figy = 200;
    fhand = figure('Units','pixels',...
        'Position',...
        [pos(1)+pos(3)/2-figx/2 pos(2)+pos(4)/2-figy/2 figx figy],...
        'Resize','off','CloseRequestFcn','','menubar','none',...
        'numbertitle','off','tag','dialog','userdata',fig);
    uicolor = get(fhand,'Color');
    
    uicontrol('Style','Text','Units','Pixels',...
        'String','Enter new samplerate:',...
        'Position',[20 figy-40 300 25],'HorizontalAlignment','left',...
        'BackgroundColor',uicolor,'FontSize',14)
    
    timestring = ['[OBJ1,FIGH1] = gcbo;',...
	          'FIH0 = get(OBJ1,''UserData'');',...
		  'AXH0 = findobj(''tag'',''eegaxis'',''parent'',FIH0);',...
		  'SRAT = str2num(get(OBJ1,''String''));',...
		  'if ~isempty(SRAT);',...
		    'UDATA = get(FIH0,''UserData'');',...
		    'UDATA(2) = SRAT;',...
		    'set(FIH0,''UserData'',UDATA);',...
		    'eegplotold(''drawp'',0);',...
		    'delete(FIGH1);',...
		  'end;',...
		  'clear OBJ1 FIGH1 FIH0 AXH0 SRAT UDATA;'];
		    
    
    ui1 = uicontrol('Style','Edit','Units','Pixels',...
        'FontSize',12,...
        'Position',[120 figy-100 70 30],...
	'Callback',timestring,'UserData',fig,...
	'String',num2str(oldsrate(2)));
    
    timestring = ['[OBJ1,FIGH1] = gcbo;',...
	          'FIH0 = get(OBJ1,''UserData'');',...
		  'AXH0 = findobj(''tag'',''eegaxis'',''parent'',FIH0(1));',...
		  'SRAT = str2num(get(FIH0(2),''String''));',...
		  'if ~isempty(SRAT);',...
		    'UDATA = get(FIH0(1),''UserData'');',...
		    'UDATA(2) = SRAT;',...
		    'set(FIH0(1),''UserData'',UDATA);',...
		    'eegplotold(''drawp'',0);',...
		    'delete(FIGH1);',...
		  'end;',...
		  'clear OBJ1 FIGH1 FIH0 AXH0 SRAT UDATA;'];
    
    uicontrol('Style','PushButton','Units','Pixels',...
        'String','OK','FontSize',14,...
        'Position',[figx/4-20 10 65 30],...
        'Callback',timestring,'UserData',[fig,ui1])
    
    
    TIMESTRING = ['[OBJ1,FIGH1] = gcbo;',...
	        'delete(FIGH1);',...
		'clear OBJ1 FIGH1;'];
    uicontrol('Style','PushButton','Units','Pixels',...
        'String','Cancel','FontSize',14,...
        'Position',[3*figx/4-20 10 65 30],...
        'Callback',TIMESTRING)  
  
  case 'loadelect'
    % load electrode file
    fig = gcbf;
    pos = get(fig,'Position');
    figx = 400;
    figy = 200;
    fhand = figure('Units','pixels',...
        'Position',...
        [pos(1)+pos(3)/2-figx/2 pos(2)+pos(4)/2-figy/2 figx figy],...
        'Resize','off','CloseRequestFcn','','menubar','none',...
        'numbertitle','off','tag','dialog','userdata',fig);
    uicolor = get(fhand,'Color');
    
    uicontrol('Style','Text','Units','Pixels',...
        'String','Enter electrode file name:',...
        'Position',[20 figy-40 300 25],'HorizontalAlignment','left',...
        'BackgroundColor',uicolor,'FontSize',14)
    	    
    
    ui1 = uicontrol('Style','Edit','Units','Pixels',...
        'FontSize',12,...
	'HorizontalAlignment','left',...
        'Position',[120 figy-100 210 30],...
	'UserData',fig,'tag','electedit');
    
    TIMESTRING = ['[OBJ1,FIGH1] = gcbo;',...
	        'delete(FIGH1);',...
		'clear OBJ1 FIGH1;'];
	  
    uicontrol('Style','PushButton','Units','Pixels',...
        'String','Cancel','FontSize',14,...
        'Position',[3*figx/4-20 10 65 30],...
        'Callback',TIMESTRING)  
    
    timestring = ['[OBJ1,FIGH1] = gcbo;',...
	          'OBJ2 = findobj(''tag'',''electedit'');',...
		  'LAB1 = get(OBJ2,''string'');',...
		  'FIH0 = get(OBJ1,''UserData'');',...
		  'AXH0 = findobj(''tag'',''eegaxis'',''parent'',FIH0);',...
		  'OUT1 = eegplotold(''setelect'',LAB1,AXH0);',...
		  'if (OUT1);',...
		     'delete(FIGH1);',...
		  'end;',...
		  'clear OBJ1 FIGH1 LAB1 OBJ2 FIH0 AXH0 OUT1;'];
    
    uicontrol('Style','PushButton','Units','Pixels',...
      'String','OK','FontSize',14,...
      'Position',[figx/4-20 10 65 30],...
      'Callback',timestring,'UserData',fig)
    
    timestring = ['OBJ2 = findobj(''tag'',''electedit'');',...
	          '[LAB1,LAB2] = uigetfile(''*'',''Electrode File'');',...
		  'if (ischar(LAB1) & ischar(LAB2));',...
		     'set(OBJ2,''string'',[LAB2,LAB1]);',...
		  'end;',...
		  'clear OBJ2 LAB1 LAB2;'];
	    
    uicontrol('Style','PushButton','Units','Pixels',...
      'String','Browse','FontSize',14,...
      'Position',[figx/2-20 10 65 30],'UserData',fig,...
      'Callback',timestring)
    
  
  case 'setelect'
    % Set electrodes    
    eloc_file = p1;
    axeshand = p2;
    outvar1 = 1;
    if isempty(eloc_file)
      outvar1 = 0;
      return
    end
    fid = fopen(eloc_file);
    if fid < 1
      fprintf('Cannot open electrode file.\n\n')
      outvar1 = 0;
      return
    end
    YLabels = fscanf(fid,'%d %f %f  %s',[7 128]);
    if isempty(YLabels)
      fprintf('Error reading electrode file.\n\n')
      outvar1 = 0;
      return
    end
    fclose(fid);
    YLabels = char(YLabels(4:7,:)');
    ii = find(YLabels == '.');
    YLabels(ii) = ' ';
    YLabels = flipud(str2mat(YLabels,' '));
    set(axeshand,'YTickLabel',YLabels)
  
  case 'title'
    % Get new title
    fig = gcbf;
    % oldsrate = get(fig,'UserData');
    eegaxis = findobj('tag','eegaxis','parent',fig);
    oldtitle = get(eegaxis,'title');
    oldtitle = get(oldtitle,'string');
    pos = get(fig,'Position');
    figx = 400;
    figy = 200;
    fhand = figure('Units','pixels',...
        'Position',...
        [pos(1)+pos(3)/2-figx/2 pos(2)+pos(4)/2-figy/2 figx figy],...
        'Resize','off','CloseRequestFcn','','menubar','none',...
        'numbertitle','off','tag','dialog','userdata',fig);
    uicolor = get(fhand,'Color');
    
    uicontrol('Style','Text','Units','Pixels',...
        'String','Enter new title:',...
        'Position',[20 figy-40 300 25],'HorizontalAlignment','left',...
        'BackgroundColor',uicolor,'FontSize',14)
    
    timestring = ['[OBJ1,FIGH1] = gcbo;',...
	          'FIH0 = get(OBJ1,''UserData'');',...
		  'AXH0 = findobj(''tag'',''eegaxis'',''parent'',FIH0);',...
		  'SRAT = get(OBJ1,''String'');',...
		  'AXTH0 = get(AXH0,''title'');',...
		  'if ~isempty(SRAT);',...
		    'set(AXTH0,''string'',SRAT);',...
		  'end;',...
		  'delete(FIGH1);',...
		  'clear OBJ1 AXTH0 FIGH1 FIH0 AXH0 SRAT UDATA;'];
		    
    
    ui1 = uicontrol('Style','Edit','Units','Pixels',...
        'FontSize',12,...
        'Position',[120 figy-100 3*70 30],...
	'Callback',timestring,'UserData',fig,...
	'String',oldtitle);
    
    timestring = ['[OBJ1,FIGH1] = gcbo;',...
	          'FIH0 = get(OBJ1,''UserData'');',...
		  'AXH0 = findobj(''tag'',''eegaxis'',''parent'',FIH0(1));',...
		  'SRAT = get(FIH0(2),''String'');',...
		  'AXTH0 = get(AXH0,''title'');',...
		    'set(AXTH0,''string'',SRAT);',...
		  'delete(FIGH1);',...
		  'clear OBJ1 AXTH0 FIGH1 FIH0 AXH0 SRAT UDATA;'];
    
    uicontrol('Style','PushButton','Units','Pixels',...
        'String','OK','FontSize',14,...
        'Position',[figx/4-20 10 65 30],...
        'Callback',timestring,'UserData',[fig,ui1])
    
    
    TIMESTRING = ['[OBJ1,FIGH1] = gcbo;',...
	        'delete(FIGH1);',...
		'clear OBJ1 FIGH1;'];

    uicontrol('Style','PushButton','Units','Pixels',...
        'String','Cancel','FontSize',14,...
        'Position',[3*figx/4-20 10 65 30],...
        'Callback',TIMESTRING)     
  
  case 'scaleeye'
    % Turn scale I on/off
    obj = p1;
    figh = p2;
    % figh = get(obj,'Parent');
    toggle = get(obj,'checked');
    
    if strcmp(toggle,'on')
      eyeaxes = findobj('tag','eyeaxes','parent',figh);
      children = get(eyeaxes,'children');
      delete(children)
      set(obj,'checked','off')
    elseif strcmp(toggle,'off')
      eyeaxes = findobj('tag','eyeaxes','parent',figh);
      
      ESpacing = findobj('tag','ESpacing','parent',figh);
      spacing = str2num(get(ESpacing,'string'));
      
      axes(eyeaxes)
      YLim = get(eyeaxes,'Ylim');
      Xl = [.35 .65 .5 .5 .35 .65];
      Yl = [spacing*2 spacing*2 spacing*2 spacing*1 spacing*1 spacing*1];
      line(Xl,Yl,'color',DEFAULT_AXIS_COLOR,'clipping','off',...
 	'tag','eyeline')
      text(.5,YLim(2)/23+Yl(1),num2str(spacing,4),...
	'HorizontalAlignment','center','FontSize',10,...
	'tag','thescale')
      if strcmp(YAXIS_NEG,'off')
        text(Xl(2)+.1,Yl(1),'+','HorizontalAlignment','left',...
	    'verticalalignment','middle')
        text(Xl(2)+.1,Yl(4),'-','HorizontalAlignment','left',...
	    'verticalalignment','middle')
      else
        text(Xl(2)+.1,Yl(4),'+','HorizontalAlignment','left',...
	    'verticalalignment','middle')
        text(Xl(2)+.1,Yl(1),'-','HorizontalAlignment','left',...
	    'verticalalignment','middle')
      end
      if ~isempty(SPACING_UNITS_STRING)
        text(.5,-YLim(2)/23+Yl(4),SPACING_UNITS_STRING,...
	    'HorizontalAlignment','center','FontSize',10)
      end
      set(obj,'checked','on')
    end
    
  case 'noui'
    % Plott EEG without ui controls
    data = p1;
    % usage: eegplotold(data,Fs,spacing,eloc_file,startpoint,color)
    
    [chans,frames] = size(data);
    nargs = nargin;
    if nargs < 7
      plotcolor = 0;
    else
      plotcolor = p6;
    end
    if nargs < 6
      starts = 0;
    else
      starts = p5;
    end
    if nargs < 5
      eloc_file = DEFAULT_ELOC_FILE;
    else 
      eloc_file = p4;
    end
    if nargs < 4
      spacing = 0;
    else
      spacing = p3;
    end
    if nargs < 3
      Fs = 0;
    else
      Fs = p2;
    end
    
    if isempty(plotcolor)
      plotcolor = 0;
    end
    if isempty(spacing)
      spacing = 0;
    end
    if isempty(Fs)
      Fs = 0;
    end
    if isempty(starts)
      starts = 0;
    end
    if spacing == 0
      spacing = max(max(data')-min(data'));
    end
    if spacing == 0
        spacing = 1;
    end
    if Fs == 0
      Fs = DEFAULT_SAMPLE_RATE;
    end
    
    range = floor(frames/Fs);
    axhandle = gca;
    
    if plotcolor == 0
      if DEFAULT_NOUI_PLOT_COLOR == 0
        colorord = get(axhandle,'ColorOrder');
        plotcolor = colorord(1,:);
      else
        plotcolor = DEFAULT_NOUI_PLOT_COLOR;
      end
    end
    
    if ~isempty(eloc_file)
      if eloc_file == 0
        YLabels = num2str((1:chans)');
      elseif ischar('eloc_file')
        fid = fopen(eloc_file);
        if fid < 1
          error('error opening electrode file')
        end
        YLabels = fscanf(fid,'%d %f %f %s',[7 128]);
        fclose(fid);
        YLabels = char(YLabels(4:7,:)');
        ii = find(YLabels == '.');
        YLabels(ii) = ' ';
      else 
        YLabels = num2str(eloc_file)';
      end
      YLabels = flipud(str2mat(YLabels,' '));
    else
      YLabels = [];
    end
    set(axhandle,'xgrid','on','GridLineStyle','-',...
      'Box','on','YTickLabel',YLabels,...
      'ytick',[0:spacing:chans*spacing],...
      'Ylim',[0 (chans+1)*spacing],...
      'xtick',[0:Fs:range*Fs],...
      'Xlim',[0 frames],...
      'XTickLabel',num2str((0:1:range)'+starts))
  
    meandata = mean(data');
    axes(axhandle)
    hold on
    for i = 1:chans
      plot(data(chans-i+1,:)-meandata(chans-i+1)+i*spacing,'color',plotcolor)
    end    
  otherwise
      error(['Error - invalid eegplotold() parameter: ',data])
  end  
end

