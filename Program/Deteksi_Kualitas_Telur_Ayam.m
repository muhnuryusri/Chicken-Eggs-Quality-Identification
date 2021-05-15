function varargout = Deteksi_Kualitas_Telur_Ayam(varargin)
% DETEKSI_KUALITAS_TELUR_AYAM MATLAB code for Deteksi_Kualitas_Telur_Ayam.fig
%      DETEKSI_KUALITAS_TELUR_AYAM, by itself, creates a new DETEKSI_KUALITAS_TELUR_AYAM or raises the existing
%      singleton*.
%
%      H = DETEKSI_KUALITAS_TELUR_AYAM returns the handle to a new DETEKSI_KUALITAS_TELUR_AYAM or the handle to
%      the existing singleton*.
%
%      DETEKSI_KUALITAS_TELUR_AYAM('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DETEKSI_KUALITAS_TELUR_AYAM.M with the given input arguments.
%
%      DETEKSI_KUALITAS_TELUR_AYAM('Property','Value',...) creates a new DETEKSI_KUALITAS_TELUR_AYAM or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Deteksi_Kualitas_Telur_Ayam_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Deteksi_Kualitas_Telur_Ayam_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Deteksi_Kualitas_Telur_Ayam

% Last Modified by GUIDE v2.5 27-Nov-2020 17:17:03

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Deteksi_Kualitas_Telur_Ayam_OpeningFcn, ...
                   'gui_OutputFcn',  @Deteksi_Kualitas_Telur_Ayam_OutputFcn, ...
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


% --- Executes just before Deteksi_Kualitas_Telur_Ayam is made visible.
function Deteksi_Kualitas_Telur_Ayam_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Deteksi_Kualitas_Telur_Ayam (see VARARGIN)

% Choose default command line output for Deteksi_Kualitas_Telur_Ayam
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Deteksi_Kualitas_Telur_Ayam wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Deteksi_Kualitas_Telur_Ayam_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[nama_file,nama_path] = uigetfile({'*.*'});

if ~isequal(nama_file,0)
    I = imread(fullfile(nama_path,nama_file));
    axes(handles.axes1)
    imshow(I)
    handles.I = I;
    guidata(hObject,handles)
else
    return
end

% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
I = handles.I;

% Ekstraksi Channel red
red = I(:,:,1);
 axes(handles.axes7)
 imshow(red)
 
%ekstraksi Channel Green
green = I(:,:,2);
axes(handles.axes8)
 imshow(green)
 
%ekstraksi Channel Blue
blue = I(:,:,3);
axes(handles.axes9)
imshow(blue)

%Melakukan tresholding k-means terhadap Citra
cform = makecform('srgb2lab');
lab = applycform(I,cform);
axes(handles.axes2)
imshow(lab)

ab = double(lab(:,:,2:3));
nrows = size(ab,1);
ncols = size(ab,2);
ab = reshape(ab,nrows*ncols,2);
     
nColors = 2;
[cluster_idx, ~] = kmeans(ab,nColors,'distance','sqEuclidean', ...
                    'Replicates',3);
     
pixel_labels = reshape(cluster_idx,nrows,ncols);
     
segmented_images = cell(1,3);
rgb_label = repmat(pixel_labels,[1 1 3]);
     
    for k = 1:nColors
        color = I;
        color(rgb_label ~= k) = 0;
        segmented_images{k} = color;
    end
     
area_cluster1 = sum(find(pixel_labels==1));
area_cluster2 = sum(find(pixel_labels==2));
     
[~,cluster_min] = min([area_cluster1,area_cluster2]);
     
segmentasi = (pixel_labels==cluster_min);

%mengkonversi hasil segmentasi k-means ke biner
% segmentasi = im2bw(Img_bw,0.5);

%mengkonversi hasil segmentasi ke dalam tipe double
seg_doub=double(segmentasi);
axes(handles.axes3)
imshow(seg_doub)

% %membangun strel dengan bentuk disk ukuran 5 piksel
% str1 = strel('disk',5);
% str2 = strel('disk',20);
% 
% dilasi=imdilate(segmentasi,str2);
% erosi=imerode(dilasi,str2);
% axes(handles.axes3)
% imshow(erosi)
% 
% %melakukan operasi closing menggunakan strel yang telah dibangun
% closing = imclose(dilasi,str1);
% axes(handles.axes4)
% imshow(closing)

%menutupi bagian objek yang berlubang
filling = imfill(segmentasi,'holes');
axes(handles.axes4)
imshow(filling)

%menghilangkan bagian objek yang tidak diperlukan
bersih = bwareaopen(filling,5000);

%mengkonversi citra ke grayscale
gray = rgb2gray(I);
gray(~bersih) = 0;
axes(handles.axes5)
imshow(gray)

%mengkonversi citra hasil segmentasi ke RGB
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

R(~bersih) = 0;
G(~bersih) = 0;
B(~bersih) = 0;

RGB = cat(3,R,G,B);
axes(handles.axes6)
imshow(RGB)

%fitur bentuk
stats = regionprops(bersih,'Area','Perimeter','Eccentricity');
fitur_area = stats.Area;
fitur_perimeter = stats.Perimeter;
fitur_metric = 4*pi*fitur_area/(fitur_perimeter^2);
fitur_eccentricity = stats.Eccentricity;

set(handles.edit1,'String',fitur_area)
set(handles.edit2,'String',fitur_perimeter)
set(handles.edit3,'String',fitur_metric)
set(handles.edit4,'String',fitur_eccentricity)

%fitur tekstur
pixel_dist = 1;
GLCM = graycomatrix(gray,'Offset',[0 pixel_dist; -pixel_dist pixel_dist; -pixel_dist 0; -pixel_dist -pixel_dist]);
stats = graycoprops(GLCM,{'contrast','correlation','energy','homogeneity'});
fitur_contrast = mean(stats.Contrast);
fitur_correlation = mean(stats.Correlation);
fitur_energy = mean(stats.Energy);
fitur_homogeneity = mean(stats.Homogeneity);

set(handles.edit5,'String',fitur_contrast)
set(handles.edit6,'String',fitur_correlation)
set(handles.edit7,'String',fitur_energy)
set(handles.edit8,'String',fitur_homogeneity)

input = [fitur_area;fitur_perimeter;fitur_metric;fitur_eccentricity;fitur_contrast;fitur_correlation;fitur_energy;fitur_homogeneity];
input2 = [fitur_contrast;fitur_correlation;fitur_energy;fitur_homogeneity];

handles.input = input;
handles.input2 = input2;

guidata(hObject, handles)

% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
    input = handles.input;
    load net
    output1 = round(sim(net,input));

    if output1 == 1
        kelas = 'Besar';
    elseif output1 == 2
        kelas = 'Kecil';
    end
    set(handles.edit9,'String',kelas)

    input2 = handles.input2;
    load nets
    output2 = round(sim(net,input2));

    if output2 == 1
        kelas = 'Bersih';
    elseif output2 == 2
        kelas = 'Kotor';
    end
    set(handles.edit10,'String',kelas)
    
    if output1 == 1 && output2 == 1
        kelas = 'Sangat Baik';
    elseif output1 == 1 && output2 == 2
        kelas = 'Kurang Baik';
    elseif output1 == 2 && output2 == 1
        kelas = 'Baik';
    elseif output1 == 2 && output2 == 2
        kelas = 'Kurang Baik';        
    end
    set(handles.edit11,'String',kelas)    
    
catch
end

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
