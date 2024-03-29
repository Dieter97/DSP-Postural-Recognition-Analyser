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

% Last Modified by GUIDE v2.5 07-Jan-2018 19:53:37

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

% Settings: method, window 
handles.m = 1;
handles.window = 1;
% Sample frequency
handles.Fs = 250;
handles.initialize = 0;
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
  handles.initialize = 0;
  [num,txt,raw] = xlsread(fullFileName);
  handles.txt = txt;
  handles.raw = raw;
  notes_index = strfind(txt, 'Notes:');
  [m,n] = size(notes_index);
  % search for row index of NOTES
  for i = 1:m
      if cell2mat(notes_index(i,1)) == 1
          row_index = i;
      end
  end
  % search for row index of TRAJECTORIES (sampling frequency is located a row under this)
  tr_index = strfind(txt, 'TRAJECTORIES');
  [m,n] = size(tr_index);
  for i = 1:m
      if cell2mat(tr_index(i,1)) == 1
          sampling_index = i;
      end
  end
  handles.Fs = num(sampling_index-1,1);
  handles.notesIndex = row_index;
  handles.m = num(row_index-2,2);
  handles.window = num(row_index-2,3);
  handles.frequency = num(row_index-2,4);
  handles.wd = num(row_index-2,5);
  handles.fp = num(row_index-2,6);
  handles.lhc = num(row_index-2,7);
  if isnan(handles.m)
      handles.m = 1;
  end
  if isnan(handles.window)
      handles.window = 1;
  end
  if isnan(handles.frequency)
      handles.frequency = -1;
  end
  if isnan(handles.wd)
      handles.wd = 0;
  end
  if isnan(handles.fp)
      handles.fp = 0;
  end
  if isnan(handles.lhc)
      handles.lhc = 0;
  end
  %opens excel to choose data
  num = xlsread(fullFileName,-1);
  [m,n] = size(num);
  while n ~= 1
    disp('Please select one column.');
    num = xlsread(fullFileName,-1);
    [m,n] = size(num);
  end
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
  x1 = 0:1:(m(2)-1);
  %sets the right values on the time abcissa
  x1 = x1.*(1/handles.Fs);
  %data used for tests(sine)
  %x1 = 0:1:1500;
  %x1 = x1.*(1/handles.Fs);
  %data = sin(2*pi*1*x1) + sin(2*pi*15*x1)+sin(2*pi*30*x1) + sin(2*pi*100*x1)+3;
  %zero_padded_data =[data zeros(1,length(data)*floor(get(handles.window_edit,'Value')))];
   
  %calculate fft
  y = fft(data);     
  n = length(data);   
  %make sure that the spectrum is symmetrical around the zero point
  fshift = (-n/2:n/2-1)*(handles.Fs/n);
  
  %initiliazes the options
  if handles.initialize == 0      
      %if the frequency wasn't read from the excel file or if the frequency
      %is higher than the freq bounds of the signal init the frequency
      set(handles.start_frequency_edit, 'min', 0);
      set(handles.start_frequency_edit, 'max', max(fshift));
      if handles.frequency == -1 || handles.frequency > max(fshift)
          handles.frequency = max(fshift);
      end
      set(handles.method, 'Value', handles.m);
      set(handles.windowFunction_popup, 'Value', handles.window);
      set(handles.start_frequency_edit, 'Value', handles.frequency);
      set(handles.start_frequency_field,'String',handles.frequency);
      set(handles.window_edit,'value', handles.wd);
      set(handles.window_field,'String',handles.wd);
      set(handles.filterPlot,'value', handles.fp);
      set(handles.lowHighCheckbox,'value', handles.lhc);
      handles.initialize = 1;
      guidata(hObject, handles);
  else
       %sets default settings to the options
  set(handles.start_frequency_edit, 'min', 0);
  set(handles.start_frequency_edit, 'max', max(fshift));
  set(handles.start_frequency_edit, 'Value',max(fshift));
  set(handles.start_frequency_field,'String',max(fshift));
  set(handles.stop_frequency_edit, 'min', 0);
  set(handles.stop_frequency_edit, 'max', max(fshift));
  set(handles.stop_frequency_edit, 'Value', max(fshift));
  set(handles.stop_frequency_field,'String',max(fshift));
  end
  
  %Calculate the DC component and remove this from the zero_padded_data
  DCOffset = mean(data);
  %Adjust data to desired window length using zero padding
  %Use zeropadded data to calculate fft, but not to plot the data!
  zero_padded_data = [data-DCOffset zeros(1,length(data)*floor(get(handles.window_edit,'Value')))];
  handles.data = data;
  handles.x1 = x1;
  handles.zero_padded_data = zero_padded_data;
  % Save the handles
  guidata(hObject, handles);
 
  replotFrequency(handles);
  
function replotFrequency(handles)
    if handles.m == 1
      %calculate frequency domain
      plot_data = handles.zero_padded_data;

      %TODO switch for WINDOW FUNCTIONS
      windowFunction = get(handles.windowFunction_popup,'value');
      switch windowFunction
        case 1
            % Normal (no window function)
            window_data = plot_data;
        case 2
            %BOXCAR
            hann_data = rectwin(length(plot_data));
            window_data = transpose(hann_data).*plot_data;
        case 3
            %Hann
            hann_data = hann(length(plot_data));
            window_data = transpose(hann_data).*plot_data;
        case 4
            %Blackmann
            blackman_data = blackman(length(plot_data));
            window_data = transpose(blackman_data).*plot_data;
        case 5
            %Hamming
            hamming_data = hamming(length(plot_data));
            window_data = transpose(hamming_data).*plot_data;
        case 6
            %Bartlett
            bartlett_data = bartlett(length(plot_data));
            window_data = transpose(bartlett_data).*plot_data;
      end

      %PLOT FFT WITH WINDOW
      set(handles.axes2_title,'String','Frequency Domain');
      y = fft(window_data); 
      n = length(window_data); 
      %determine the frequency values for the abcissa
      fshift = (-n/2:n/2-1)*(handles.Fs/n);
      %shifts zero frequencies to the middle
      yshift = fftshift(y);
      [d,start] = min(abs(fshift-(-get(handles.start_frequency_edit,'Value'))));
      [d,stop] = min(abs(fshift-get(handles.start_frequency_edit,'Value')));
      %select only the data that is selected by the user
      newF = fshift(start:stop);
      newFdata = yshift(start:stop);
      %plot the new data, the division is needed to get the right amplitude
      %value
      plot(handles.axes2,newF,abs(newFdata./length(handles.data)),'s');
      hold(handles.axes2,'on');
      plot(handles.axes2,newF,abs(newFdata./length(handles.data)),'k');
      hold(handles.axes2,'off');

      %displays grid lines
      grid(handles.axes2,'on');

      cla reset
      %plot time domain without window
      set(handles.axes1_title,'String','Time Domain');
      plot(handles.axes1,handles.x1,handles.data);

      %plot the inverse fft of the selected data
      if get(handles.filterPlot, 'Value') == 1
          %Recalculate the fft of the not zeropadded data
          y = fft(handles.data);
          yshift = fftshift(y);
          n = length(handles.data); 
          fshift = (-n/2:n/2-1)*(handles.Fs/n);
          %Find the frequency on the not zero padded data
          [d,start] = min(abs(fshift-(-get(handles.start_frequency_edit,'Value'))));
          [d,stop] = min(abs(fshift-get(handles.start_frequency_edit,'Value')));

          if get(handles.lowHighCheckbox, 'Value') == 0
              %compose a boxcar function that will be used to select the needed
              %frequency components
              temp = zeros(1, start);
              temp = [temp ones(1,stop-start)];
              temp = [temp zeros(1, length(yshift)-stop)];
              %select the frequencies you need
              newFdata2 = yshift.*temp;
              %fill the vector to the orignal length with zeros
              iNewData = ifft(ifftshift(newFdata2));
              plot(handles.axes1,handles.x1,real(iNewData));
          else
              %compose a boxcar function that will be used to select the needed
              %frequency components
              temp = ones(1, start);
              temp = [temp zeros(1,stop-start)];
              temp = [temp ones(1, length(yshift)-stop)];
              %select the frequencies you need
              newFdata2 = yshift.*temp;
              %fill the vector to the orignal length with zeros
              iNewData = ifft(ifftshift(newFdata2));
              plot(handles.axes1,handles.x1,real(iNewData));
          end
      end
      grid(handles.axes1,'on');
      xlabel(handles.axes2,'Frequency[Hz]');
      ylabel(handles.axes2,'Magnitude');
    end
    if handles.m == 2
        set(handles.axes2_title,'String','Smoothed Time Domain');
        plot(handles.axes1,handles.x1,handles.data);
        grid(handles.axes1,'on');
        plot(handles.axes2,handles.x1,detrend(smooth(handles.data)));
        grid(handles.axes2,'on');
        xlabel(handles.axes2,'Time[s]');
        ylabel(handles.axes2,'x(t)');
    end
    
    xlabel(handles.axes1,'Time[s]');
    ylabel(handles.axes1,'x(t)');
    

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
    end
end
%adds the current data and time to the excel file
toSave(dataRow_index,2) = col1;
toSave(timeRow_index,2) = col2;
%saves the options to the excel file
toSave(handles.notesIndex,2) = num2cell(handles.m);
toSave(handles.notesIndex,3) = num2cell(get(handles.windowFunction_popup,'value'));
toSave(handles.notesIndex,4) = num2cell(get(handles.start_frequency_edit,'value'));
toSave(handles.notesIndex,5) = num2cell(get(handles.window_edit,'value'));
toSave(handles.notesIndex,6) = num2cell(get(handles.filterPlot,'value'));
toSave(handles.notesIndex,7) = num2cell(get(handles.lowHighCheckbox,'value'));

%saves the data to the excel file
for i = 1:length(handles.data)
    toSave(12+i,8) = num2cell(handles.data(i));
end
xlswrite(fullName,toSave);

% --- Executes on button press in method.
function method_Callback(hObject, eventdata, handles)
% hObject    handle to method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.m = get(hObject,'value');
guidata(hObject, handles);
replotFrequency(handles);


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
%disp(val);
replotFrequency(handles);

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
options = {'None','Boxcar','Hann','Blackmann','Hamming','Bartlett'};
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
function method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'FFT','Smoothing'});
handles.method = hObject ;
  guidata(hObject, handles);


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


% --- Executes on slider movement.
function window_edit_Callback(hObject, eventdata, handles)
% hObject    handle to window_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
set(handles.window_field,'String',get(handles.window_edit,'Value'));
initPlot(hObject,handles)

% --- Executes during object creation, after setting all properties.
function window_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to window_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject, 'min', 0);
set(hObject, 'max', 5);
set(hObject, 'Value',0);

% --- Executes on button press in lowHighCheckbox.
function lowHighCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to lowHighCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

replotFrequency(handles);
