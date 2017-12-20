function varargout = gui(varargin)
% GUI MATLAB code for gui.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help gui

% Last Modified by GUIDE v2.5 19-Dec-2017 22:20:54

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @gui_OpeningFcn, ...
                   'gui_OutputFcn',  @gui_OutputFcn, ...
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

% --- Executes just before gui is made visible.
function gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to gui (see VARARGIN)

% Choose default command line output for gui
handles.output = hObject;

% Settings: method, window and noise
handles.method = 1;
handles.window = 1;
handles.noise = 1;
% Sample frequency
handles.Fs = 250;
% Update handles structure
guidata(hObject, handles);

% This sets up the initial plot - only do when we are invisible
% so window can get raised using gui.

if strcmp(get(hObject,'Visible'),'off')
    plot(rand(5));
end

% UIWAIT makes gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = gui_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure1)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
                     ['Close ' get(handles.figure1,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)


% --- Executes on button press in load_Btn.
function load_Btn_Callback(hObject, eventdata, handles)
  % hObject    handle to load_Btn (see GCBO)
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  [baseName, folder] = uigetfile('*.xlsx', 'Select an excel file');
  fullFileName = fullfile(folder, baseName);
  % Open xlsx file and save data in num (only numbers), txt (only strings)
  % and raw (raw data)
  [num,txt,raw] = xlsread(fullFileName);
  handles.txt = txt;
  handles.raw = raw;
  notes_index = strfind(txt, 'Notes:');
  [m,n] = size(notes_index);
  % search for row index of NOTES
  for i = 1:m
      if cell2mat(notes_index(i,1)) == 1
          row_index = i;
      end;
  end;
  % search for row index of TRAJECTORIES (sampling frequency is located a row under this)
  tr_index = strfind(txt, 'TRAJECTORIES');
  [m,n] = size(tr_index);
  for i = 1:m
      if cell2mat(tr_index(i,1)) == 1
          sampling_index = i;
      end;
  end;
  handles.Fs = num(sampling_index-1,1);
  handles.notesIndex = row_index;
  handles.method = num(row_index-2,2);
  handles.window = num(row_index-2,3);
  handles.noise = num(row_index-2,4);
  if isnan(handles.method)
      handles.method = 1;
  end;
  if isnan(handles.window)
      handles.window = 1;
  end;
  if isnan(handles.noise)
      handles.noise = 1;
  end;
  num = xlsread(fullFileName,-1);
  [m,n] = size(num);
  while n>1
    num = xlsread(fullFileName,-1);
    [m,n] = size(num);
  end;
  handles.num = num;
  handles.data = transpose(handles.num(:,1));
  % Save the handles
  guidata(hObject, handles);
  % plot the data
  initPlot(hObject,handles);

%Calculates the time values, frequency values of the FFT plot and
% initiliazes the sliders
function initPlot(hObject,handles)
  cla reset;
  data = handles.data;
  m = size(data);
  %x1 = 0:1:(m(2)-1);
  %x1 = x1.*(1/handles.Fs);
  
  %data used for tests(sine)
  x1 = 0:1:1500;x1 = x1.*(1/handles.Fs);
  data = sin(2*pi*1*x1) + sin(2*pi*15*x1);
  handles.data = data;
  handles.x1 = x1;

  %calculate borders
  y = fft(data);     
  n = length(data);                         
  fshift = (-n/2:n/2-1)*(handles.Fs/n);

  set(handles.start_frequency_edit, 'min', min(fshift));
  set(handles.start_frequency_edit, 'max', 0);
  set(handles.start_frequency_edit, 'Value',min(fshift));
  set(handles.start_frequency_field,'String',min(fshift));
  set(handles.stop_frequency_edit, 'min', 0);
  set(handles.stop_frequency_edit, 'max', max(fshift));
  set(handles.stop_frequency_edit, 'Value', max(fshift));
  set(handles.stop_frequency_field,'String',max(fshift));
 % Save the handles
  guidata(hObject, handles);
  
  replotFrequency(handles);
  
function replotFrequency(handles)
  %calculate frequency domain
  set(handles.axes2_title,'String','Frequency Domain');
  y = fft(handles.data); 
  n = length(handles.data); 
  fshift = (-n/2:n/2-1)*(handles.Fs/n);
  yshift = fftshift(y);
  [d,start] = min(abs(fshift-get(handles.start_frequency_edit,'Value')));
  [d,stop] = min(abs(fshift-get(handles.stop_frequency_edit,'Value')));
  newF = fshift(start:stop);
  newFdata = yshift(start:stop);
  
  cla reset
  %plot time domain
  set(handles.axes1_title,'String','Time Domain');
  plot(handles.axes1,handles.x1,handles.data);
  
  %plot the inverse fft of the selected data
  if get(handles.filterPlot, 'Value') == 1
      iNewData = ifft(ifftshift(newFdata));
      m = length(iNewData);
      numberOfCopies = floor((n-m)/m)+1;
      %iNewData = iNewData(mod(0:n-1, numel(iNewData)) + 1);
	  x2 = handles.x1(start:stop);
      plot(handles.axes1,x2,iNewData);
  end;
  grid(handles.axes1,'on');
  %TODO switch for WINDOW FUNCTIONS
  plot(handles.axes2,newF,abs(newFdata./(length(newFdata)./2)));
  grid(handles.axes2,'on');

% --- Executes on button press in save_Btn.
function save_Btn_Callback(hObject, eventdata, handles)
% hObject    handle to save_Btn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%selects the directory and fileName where to save the file
[fileName,pathName,filterIndex] = uiputfile('*.xlsx');
%puts the filename and path into one string
fullName = strcat(pathName,fileName);
%writes to the given file at the given path
%first selects a part of the raw data , so that not only the text is
%selected

%gets the size of text
[m,n] = size(handles.txt);
toSave = handles.raw(1:m,1:n);
%gets the current date and time
%first gets the date
t = datetime('now');
t.Format = 'dd-MM-yyyy';
col1 = cellstr(t);
%gets the time
t.Format = 'hh:mm:ss';
col2 = cellstr(t);

%finds the index of date and time
date_index = strfind(handles.txt, 'Date:');
time_index = strfind(handles.txt, 'Time:');
%the index gets found by looping through the first column and checking each
%row

for i = 1:m
    if cell2mat(date_index(i,1)) == 1
        dataRow_index = i;
    elseif cell2mat(time_index(i,1)) == 1
        timeRow_index = i;
    end;
end;
%adds the current data and time to the excel file
toSave(dataRow_index,2) = col1;
toSave(timeRow_index,2) = col2;
%saves the options to the excel file
toSave(handles.notesIndex,2) = num2cell(get(handles.options_popup,'value'));
toSave(handles.notesIndex,3) = num2cell(get(handles.windowFunction_popup,'value'));
toSave(handles.notesIndex,4) = num2cell(get(handles.noiseReduction_popup,'value'));
toSave(handles.notesIndex,5) = num2cell(get(handles.start_frequency_edit,'value'));
toSave(handles.notesIndex,6) = num2cell(get(handles.stop_frequency_edit,'value'));
%saves the data to the excel file
xlswrite(fullName,toSave);

% --- Executes on button press in options_popup.
function options_popup_Callback(hObject, eventdata, handles)
% hObject    handle to options_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function start_frequency_edit_Callback(hObject, eventdata, handles)
% hObject    handle to start_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of start_frequency_edit as text
%        str2double(get(hObject,'String')) returns contents of start_frequency_edit as a double
freq = get(hObject,'value');
set(handles.start_frequency_field,'String',freq);
replotFrequency(handles);

% --------------------------------------------------------------------
function file_menu_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function save_menu_Callback(hObject, eventdata, handles)
% hObject    handle to save_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
save_Btn_Callback(hObject, eventdata, handles);

% --------------------------------------------------------------------
function load_menu_Callback(hObject, eventdata, handles)
% hObject    handle to load_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load_Btn_Callback(hObject, eventdata, handles);

% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in windowFunction_popup.
function windowFunction_popup_Callback(hObject, eventdata, handles)
% hObject    handle to windowFunction_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns windowFunction_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from windowFunction_popup
val = get(hObject,'Value');
disp(val);

% --- Executes during object creation, after setting all properties.
function windowFunction_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to windowFunction_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%sets the values of the window popup
options = {'Boxcar','Hann','Blackmann','Hamming','Bartlett'};
set(hObject, 'String', options);

% --- Executes during object creation, after setting all properties.
function axes1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes1


% --- Executes during object creation, after setting all properties.
function axes2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate axes2
plot(rand(5));

% --- Executes on mouse press over axes background.
function axes2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function axes1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to axes1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in noiceReduction_popup.
function noiseReduction_popup_Callback(hObject, eventdata, handles)
% hObject    handle to noiceReduction_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns noiceReduction_popup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from noiceReduction_popup


% --- Executes during object creation, after setting all properties.
function noiseReduction_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to noiceReduction_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function stop_frequency_edit_Callback(hObject, eventdata, handles)
% hObject    handle to stop_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
freq = get(hObject,'value');
set(handles.stop_frequency_field,'String',freq);
replotFrequency(handles);

% --- Executes during object creation, after setting all properties.
function stop_frequency_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stop_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes during object creation, after setting all properties.
function stop_frequency_field_CreateFcn(hObject, eventdata, handles)
% hObject    handle to stop_frequency_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function options_popup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to options_popup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'FFT','Smoothing'});

% --- Executes during object creation, after setting all properties.
function start_frequency_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to start_frequency_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function start_frequency_field_CreateFcn(hObject, eventdata, handles)
%do nothing

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over start_frequency_field.
function start_frequency_field_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to start_frequency_field (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



% --- Executes on button press in filterPlot.
function filterPlot_Callback(hObject, eventdata, handles)
% hObject    handle to filterPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filterPlot
replotFrequency(handles);
