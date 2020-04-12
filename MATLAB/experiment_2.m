function varargout = hri_gui(varargin)
% HRI_GUI MATLAB code for hri_gui.fig
%      HRI_GUI, by itself, creates a new HRI_GUI or raises the existing
%      singleton*.
%
%      H = HRI_GUI returns the handle to a new HRI_GUI or the handle to
%      the existing singleton*.
%
%      HRI_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in HRI_GUI.M with the given input arguments.
%
%      HRI_GUI('Property','Value',...) creates a new HRI_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before hri_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to hri_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above title to modify the response to help hri_gui

% Last Modified by GUIDE v2.5 07-Jun-2019 13:34:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @hri_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @hri_gui_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before hri_gui is made visible.
function hri_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to hri_gui (see VARARGIN)

% Choose default command line output for hri_gui
handles.output = hObject;

hri_constants;

handles.question = findobj('Tag', 'title');
handles.counter = findobj('Tag', 'counter');
handles.description = findobj('Tag', 'explication');
handles.yes = findobj('Tag', 'Yes');
handles.no = findobj('Tag', 'No');
handles.start = findobj('Tag', 'start');
handles.go = findobj('Tag', 'go');
handles.nb = findobj('Tag', 'nbExp');
handles.count = 0;
handles.nbExp = 1;
handles.data = [];

if isempty(varargin)
    % Find which serial port corresponds to the board.
    if ~isempty(instrfind)
        fclose(instrfind);
    end
    comPort = hri_comm.getHriComPort();
    
    if isempty(comPort)
        warning('The board is not detected.');
        handles.hbh = [];
        guidata(hObject, handles);
        return;
    else
        fprintf('The board was detected on %s.\n', comPort);
    end
else
    comPort = varargin{1};
end

% Open the serial link with the board.
handles.hbh = hri_comm(comPort, ...
                       @(varsList) hri_gui_UpdateVarsList(hObject, varsList));
open(handles.hbh);
display(length(handles.hbh.getVarsList));
handles.ForceId = 4;
handles.force = 0.025;
handles.refForce = 0.005;
handles.flag = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes hri_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = hri_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function hri_gui_UpdateVarsList(hObject, varsList)
hri_constants;
handles = guidata(hObject);
handles.varsList = varsList;
guidata(hObject, handles);

function main_window_CloseRequestFcn(hObject, ~, ~) %#ok<DEFNU>

handles = guidata(hObject);

if isfield(handles, 'hbh')
    delete(handles.hbh);
    handles = rmfield(handles, 'hbh');
end

guidata(hObject, handles);

delete(hObject);
close(gcf);

% --- Executes on button press in Yes.
function Yes_Callback(hObject, eventdata, handles)
% hObject    handle to Yes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.yes, 'Visible', 'off');
set(handles.no, 'Visible', 'off');
if handles.nbExp < 20
    handles.nbExp = handles.nbExp + 1;
    handles.count = handles.count + 1;
    if handles.flag == 0
        localData = [handles.force - handles.refForce, 1];
    else
        localData = [0, 1];
        handles.flag = 0;
    end
    handles.data = [handles.data; localData];
    assignin('base','data', handles.data);
    if handles.count < 2
        handles.force = handles.force + (0.1*handles.force);
    elseif handles.count == 2
        handles.force = handles.force - (0.1*handles.force);
        handles.count = 0;
    end
    set(handles.question, 'String', 'Please barely touch the paddle with your index finger');
    set(handles.description, 'Visible', 'on');
    set(handles.description, 'String', 'Please try to keep your hand as steady as possible, and use the most sensitive part of your index finger');
    set(handles.go, 'Visible', 'on');
    set(handles.nb, 'String', num2str(handles.nbExp));
else
    if handles.flag == 0
        localData = [handles.force - handles.refForce, 1];
    else
        localData = [0, 1];
        handles.flag = 0;
    end
    handles.data = [handles.data; localData];
    assignin('base','data', handles.data);
    set(handles.question, 'String', 'Thank you for your participation ! :)');
    set(handles.nb, 'Visible', 'off');
end
guidata(hObject, handles);

% --- Executes on button press in No.
function No_Callback(hObject, eventdata, handles)
% hObject    handle to No (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.yes, 'Visible', 'off');
set(handles.no, 'Visible', 'off');
if handles.nbExp < 20
    handles.nbExp = handles.nbExp + 1;
    if handles.flag == 0
        localData = [handles.force - handles.refForce, 0];
    else
        localData = [0, 0];
        handles.flag = 0;
    end
    handles.data = [handles.data; localData];
    assignin('base','data', handles.data);
    handles.force = handles.force + (0.1*handles.force);
    set(handles.question, 'String', 'Please barely touch the paddle with your index finger');
    set(handles.description, 'Visible', 'on');
    set(handles.description, 'String', 'Please try to keep your hand as steady as possible, and use the most sensitive part of your index finger');
    set(handles.go, 'Visible', 'on');
    set(handles.nb, 'String', num2str(handles.nbExp));
else
    if handles.flag == 0
        localData = [handles.force - handles.refForce, 0];
    else
        localData = [0, 0];
        handles.flag = 0;
    end
    handles.data = [handles.data; localData];
    assignin('base','data', handles.data);
    set(handles.question, 'String', 'Thank you for your participation ! :)');
    set(handles.nb, 'Visible', 'off');
end
guidata(hObject, handles);

% --- Executes on button press in start.
function start_Callback(hObject, eventdata, handles)
% hObject    handle to start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.start, 'Visible', 'off');
set(handles.question, 'String', 'Please barely touch the paddle with your index finger');
set(handles.description, 'String', 'Please try to keep your hand as steady as possible, and use the most sensitive part of your index finger');
set(handles.go, 'Visible', 'on');
set(handles.nb, 'Visible', 'on');
set(handles.nb, 'String', '1');
setVar(handles.hbh, handles.ForceId, handles.refForce);
guidata(hObject, handles);


% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% hObject    handle to go (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.go, 'Visible', 'off');
set(handles.description, 'Visible', 'off');
set(handles.question, 'String', 'Concentrate on you finger for ...');
set(handles.counter, 'Visible', 'on');
r = rand;
if r < 0.96
    setVar(handles.hbh, handles.ForceId, handles.force);
else
    setVar(handles.hbh, handles.ForceId, handles.refForce);
    handles.flag=1;
end
for i=1:10
    set(handles.counter, 'String', num2str(11-i));
    pause(1);
end
setVar(handles.hbh, handles.ForceId, handles.refForce);
set(handles.counter, 'Visible', 'off');
set(handles.question, 'String', 'Did you feel a force on your finger ?');
set(handles.yes, 'Visible', 'on');
set(handles.no, 'Visible', 'on');
guidata(hObject, handles);
