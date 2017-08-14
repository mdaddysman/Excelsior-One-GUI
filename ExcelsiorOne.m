function ExcelsiorOne()
%check to see if the port settings are set
if exist('ports.mat', 'file') == 2
    ports = load('ports.mat');
    LoadGUI(ports.ports);
else
    SelectPorts();
end
end

function LoadGUI(ports)
fh = figure('Name','Spectra-Physics Excelsior One Control','NumberTitle','off');
set(fh,'Resize','off','Position',[50 50 600 300],'MenuBar','none','ToolBar','none');
ah = axes;
set(ah,'Visible','off','Position',[0 0 1 1],'Xlim',[0 600],'Ylim',[0 300]);
mh = uimenu(fh,'Label','Options');
moh(1) = uimenu(mh,'Label','Options');
moh(2) = uimenu(mh,'Label','Save Powers');



%Open the COM ports
%Get the wavelength, min and max powers for each laser
for m=1:4
    pn = char(ports(m));
    if(strcmp(pn,'COM0') ~= 1)
        obj = OpenPort(pn);
        r = WritePort(obj,'?WAVE');
        wl = str2double(r(6:end));
        WritePort(obj,'LD=0'); %start with laser off
        if(m == 3)
            MinPwr = 50;
        else
            r = WritePort(obj,'?MINLP');
            MinPwr = str2double(r(7:end));
        end
        r = WritePort(obj,'?MAXLP');
        MaxPwr = str2double(r(7:end));
        r = WritePort(obj,'?SP');
        Pwr = str2double(r(4:end));
    else
        wl = 0; %change to read from COM
        %obj = serial('COM1');
        MinPwr = 0; MaxPwr = 100; Pwr = 100;
    end
    nh = uicontrol('Style','text','String',{[pn ':'],[num2str(wl) ' nm']},'Position',[5+150*(m-1) 255 140 40],'FontSize',10,'FontWeight','bold');
    bh = uicontrol('Style','togglebutton','String','Laser Off','Position',[25+150*(m-1) 240 100 20],'FontSize',10,'FontWeight','bold','BackgroundColor',[0.8 0.8 0.8],'Callback',{@LaserOnOff,m,obj});
    cpth(m) = uicontrol('Style','text','String',['Power: ' num2str(Pwr) ' mW'],'Position',[5+150*(m-1) 215 140 20],'FontSize',10,'FontWeight','bold');
    pth = uicontrol('Style','text','String',[num2str(Pwr) ' mW'],'Position',[25+150*(m-1) 72 60 20],'FontSize',10);
    sph = uicontrol('Style','slider','Position',[90+150*(m-1) 30 30 180],'Min',MinPwr,'Max',MaxPwr,'Value',Pwr,'BackgroundColor',[0.8 0.8 0.8],'Callback',{@ChangePower,pth,obj});
    mapth = uicontrol('Style','text','String',[num2str(MaxPwr) ' mW'],'Position',[25+150*(m-1) 190 60 20],'FontSize',10);
    mipth = uicontrol('Style','text','String',[num2str(MinPwr) ' mW'],'Position',[25+150*(m-1) 25 60 20],'FontSize',10);
    tth(m) = uicontrol('Style','text','String','Temp: 25 C','Position',[5+150*(m-1) 2 140 20],'FontSize',10,'FontWeight','bold');
    if(strcmp(pn,'COM0') == 1)
        set(nh,'Enable','off');
        set(bh,'Enable','off');
        set(pth,'Enable','off');
        set(cpth,'Enable','off');
        set(sph,'Enable','off');
        set(mapth,'Enable','off');
        set(mipth,'Enable','off');
        set(tth(m),'Enable','off');
    end
    rh.sph(m) = sph;
    rh.wl(m) = wl;
    
    rh.obj(m) = obj;

end
rh.pn = ports;
set(moh(1),'Callback',{@OptionsBox,rh});
set(fh,'CloseRequestFcn',{@CloseGUI,fh,rh});
moh(3) = uimenu(mh,'Label','Select Ports','Callback',{@SelectNewPorts,fh,rh});
moh(3).Separator = 'on';
moh(4) = uimenu(mh,'Label','Exit','Callback',{@CloseGUI,fh,rh}); 
moh(4).Separator = 'on';
for m=1:3
    line([1+150*(m) 3+150*(m)], [0 300], 'Parent', ah,'Color',[0 0 0]);
end

while(ishghandle(fh))
    for m=1:4
        if(strcmp(char(ports(m)),'COM0') ~= 1)
            %update temperature
            r = WritePort(rh.obj(m),'?DT');
            if(str2double(r(end-3:end)) > 50)
                set(tth(m),'ForegroundColor','r');
            else
                set(tth(m),'ForegroundColor','k');
            end
            set(tth(m),'String',['Temp: ' r(end-3:end) ' C']);
            r = WritePort(rh.obj(m),'?P');
            set(cpth(m),'String',['Power: ' num2str(r(3:end)) ' mW']);
        end
    end
    pause(2);
end
    
end

function ChangePower(src,~,pth,obj)
val = get(src,'Value');
val = round(val*10)/10;
set(pth,'String',[num2str(val) ' mW']);
set(src,'Value',val);
WritePort(obj,['SP=' num2str(val)]);
end

function LaserOnOff(src,~,num,obj)
onoff = get(src,'Value');

if(onoff == 1) %if off turn on
    switch num
        case 1
            set(src,'String','Laser On','BackgroundColor',[0.63 0 1],'ForegroundColor','w');
        case 2
            set(src,'String','Laser On','BackgroundColor','c','ForegroundColor','k');
        case 3
            set(src,'String','Laser On','BackgroundColor','g','ForegroundColor','k');
        case 4
            set(src,'String','Laser On','BackgroundColor','r','ForegroundColor','w');
    end
    WritePort(obj,'LD=1');
else
    set(src,'String','Laser Off','BackgroundColor',[0.8 0.8 0.8],'ForegroundColor','k');
    WritePort(obj,'LD=0');
end
end

function CloseGUI(~,~,fh,rh)
%put a test if you want to save powers later
choice = questdlg('Do you want to exit?','Confirm Exit','Yes','No','No');
switch choice
    case 'Yes'
        for m=1:4
            if(strcmp(char(rh.pn(m)),'COM0') ~= 1)
                WritePort(rh.obj(m),'LD=0');
                ClosePort(rh.obj(m));
            end
        end
        delete(fh);
    case 'No'
        return
end
end

function SelectNewPorts(~,~,fh,rh)
choice = questdlg({'Do you want to select new ports?','(Lasers will be turned off)'},'Confirm Port Selection','Yes','No','No');
switch choice
    case 'Yes'
        for m=1:4
            if(strcmp(char(rh.pn(m)),'COM0') ~= 1)
                WritePort(rh.obj(m),'LD=0');
                ClosePort(rh.obj(m));
            end
        end
        delete(fh);
        SelectPorts();
    case 'No'
        return
end
end

function OptionsBox(~,~,rh)
fh = figure('Name','Options','NumberTitle','off');
set(fh,'Resize','off','Position',[100 350 600 300],'MenuBar','none','ToolBar','none','CloseRequestFcn',{@CloseOptions,fh});
ah = axes;
set(ah,'Visible','off','Position',[0 0 1 1],'Xlim',[0 600],'Ylim',[0 300]);


for m=1:4
    pn = char(rh.pn(m));
    if(strcmp(pn,'COM0') ~= 1)
        r = WritePort(rh.obj(m),'?C');
        current = str2double(r(3:end)); %get current
        r = WritePort(rh.obj(m),'?HH');
        hours = str2double(r(4:end)); %get run hours
        r = WritePort(rh.obj(m),'?CDRH');
        cdrh = str2double(r(end)); %get cdrh setting
        if(m ~= 3)
            r = WritePort(rh.obj(m),'?PM');
            dm = str2double(r(end)); %get digitial modulation setting
        else
            dm = 0;%always zero and off for dpss
        end
        r = WritePort(rh.obj(m),'?DST');
        settemp = str2double(r(5:end)); %get cdrh setting        
    else
        %all zeros
        current = 0; hours = 0; cdrh = 0; dm = 0; settemp = 0;
    end
    
    nh = uicontrol('Style','text','String',{[pn ':'],[num2str(rh.wl(m)) ' nm'],['Run Hours: ' num2str(hours)],['Current: ' num2str(current) ' mA' ],['Set Temp: ' num2str(settemp) 'C']},'Position',[5+150*(m-1) 195 140 100],'FontSize',10,'FontWeight','bold');
    cdrhbh = uicontrol('Style','checkbox','String','Five Second Delay','Position',[5+150*(m-1) 155 140 40],'FontSize',10,'Value',cdrh,'Callback',{@SetCDRH,rh.obj(m)});
    dmbh = uicontrol('Style','checkbox','String','Digital Modulation','Position',[5+150*(m-1) 105 140 40],'FontSize',10,'Value',dm,'Callback',{@SetDM,rh.obj(m)});
    
    if(strcmp(pn,'COM0') == 1)
        set(nh,'Enable','off');
        set(cdrhbh,'Enable','off');
        set(dmbh,'Enable','off');
    end
    if(m == 3) %DPSS laser
        set(dmbh,'Enable','off');
    end
end
for m=1:3
    line([1+150*(m) 3+150*(m)], [40 300], 'Parent', ah,'Color',[0 0 0]);
end
uicontrol('Style','pushbutton','String','Close','Position',[250 3 100 30],'BackgroundColor',[0.8 0.8 0.8],'FontSize',10,'FontWeight','bold','Callback',{@CloseOptions,fh});
end

function SetCDRH(src,~,obj)
value = get(src,'Value');
if(value == 0)
    WritePort(obj,'CDRH=0');
else
    WritePort(obj,'CDRH=1');
end
end

function SetDM(src,~,obj)
value = get(src,'Value');
if(value == 1)
    WritePort(obj,'PM=1');
else
    WritePort(obj,'PM=0');
end
end

function CloseOptions(~,~,fh)
delete(fh);
end

function SelectPorts()
fh = figure('Name','Select COM Ports','NumberTitle','off');
scsz = get(0,'ScreenSize');
set(fh,'Resize','off','Position',[50 scsz(4)-200 600 150],'MenuBar','none','ToolBar','none','CloseRequestFcn',@QuitPortSelection);
%get com port strings
coms = instrhwinfo('serial');
comstrings = [{''};coms.AvailableSerialPorts];

nh(1) = uicontrol('Style','text','String','405 nm DD','Position',[20 130 130 18],'FontSize',12,'HorizontalAlignment','left');
nh(2) = uicontrol('Style','text','String','488 nm DD','Position',[20 100 130 18],'FontSize',12,'HorizontalAlignment','left');
nh(3) = uicontrol('Style','text','String','561 nm DPSS','Position',[20 70 130 18],'FontSize',12,'HorizontalAlignment','left');
nh(4) = uicontrol('Style','text','String','643 nm DD','Position',[20 40 130 18],'FontSize',12,'HorizontalAlignment','left');

ph(1) = uicontrol('Style','popup','String',comstrings,'Position',[155 130 100 20],'FontSize',12);
ph(2) = uicontrol('Style','popup','String',comstrings,'Position',[155 100 100 20],'FontSize',12);
ph(3) = uicontrol('Style','popup','String',comstrings,'Position',[155 70 100 20],'FontSize',12);
ph(4) = uicontrol('Style','popup','String',comstrings,'Position',[155 40 100 20],'FontSize',12);

qh(1) = uicontrol('Style','text','String','Select a Port','Position',[275 130 310 18],'FontSize',12,'HorizontalAlignment','left');
qh(2) = uicontrol('Style','text','String','Select a Port','Position',[275 100 310 18],'FontSize',12,'HorizontalAlignment','left');
qh(3) = uicontrol('Style','text','String','Select a Port','Position',[275 70 310 18],'FontSize',12,'HorizontalAlignment','left');
qh(4) = uicontrol('Style','text','String','Select a Port','Position',[275 40 310 18],'FontSize',12,'HorizontalAlignment','left');

uicontrol('Style','checkbox','Position',[2 128 20 20],'Value',1,'Callback',{@ToggleLaser,1,nh,ph,qh});
uicontrol('Style','checkbox','Position',[2 98 20 20],'Value',1,'Callback',{@ToggleLaser,2,nh,ph,qh});
uicontrol('Style','checkbox','Position',[2 68 20 20],'Value',1,'Callback',{@ToggleLaser,3,nh,ph,qh});
uicontrol('Style','checkbox','Position',[2 38 20 20],'Value',1,'Callback',{@ToggleLaser,4,nh,ph,qh});

uicontrol('Style','pushbutton','String','Confirm','Position',[523 2 75 40],'Callback',{@ConfirmPorts,ph,fh});

for m=1:4
    set(ph(m),'Callback',{@PortDropDown,qh(m)});
end

end

function PortDropDown(src,~,th)
value = get(src,'Value');
if(value == 1)
    set(th,'String','Select a Port');
    return;
end
ports = get(src,'String');
pn = char(ports(value));
obj = OpenPort(pn);
response = WritePort(obj,'?WAVE');
ClosePort(obj);
if(strcmp(response,''))
    set(th,'String','Nothing on Port.');
else
    set(th,'String',['Wavelength: ' response(6:end) ' nm']);
end
end

function ConfirmPorts(~,~,ph,fh)
%check to make sure ports are selected on all active lasers
failed = 0; 
laserstring = '';
for m=1:4
    if(strcmp(get(ph(m),'Enable'),'on') == 1)
        portvalue(m) = get(ph(m),'Value');
        if(portvalue(m) == 1)
            failed = 1;
            laserstring = [laserstring 'Laser ' num2str(m) ' '];
        end
    else
        portvalue(m) = 0; %laser is disabled 
    end
end
if(failed)
    errordlg(['The following laser port(s) are not set: ' laserstring],'Error');
    return;
end
%also need to confirm the selected lasers are valid. 
%confirm that the same lasers are not selected 
if(length(nonzeros(portvalue)') ~= length(unique(nonzeros(portvalue)')))
    errordlg('Lasers cannot have the same port.');
    return;
end
comstrs = get(ph(1),'String');
for m=1:4
    portset = get(ph(m),'Value');
    if(portset == 1)
        ports(m) = cellstr('COM0');
    else
        ports(m) = comstrs(portset);
    end
end
delete(fh); %close window
save('ports.mat','ports');
if exist('settings.mat', 'file') == 2
    delete('settings.mat');
end
LoadGUI(ports); %load the GUI once ports are selected            
end

function ToggleLaser(src,~,number,nh,ph,qh)
onoff = get(src,'Value');

if(onoff == 0)
    set(nh(number),'Enable','off');
    set(ph(number),'Enable','off');
    set(qh(number),'Enable','off');
else
    set(nh(number),'Enable','on');
    set(ph(number),'Enable','on');
    set(qh(number),'Enable','on');
end
end

function QuitPortSelection(src,~)
choice = questdlg({'Do you want to exit?','Changes will not be saved!'},'Confirm Exit','Yes','No','No');
switch choice
    case 'Yes'
        %close ports?
        delete(src);
    case 'No'
        return
end
end

function response = WritePort(obj,string)
response = query(obj,string','%s\n','%s');
end

function obj = OpenPort(port)
obj = serial(port,'BaudRate',9600,'Parity','none','DataBits',8,'StopBits',1,'FlowControl','none','Terminator','CR/LF'); 
fopen(obj);
end

function ClosePort(obj)
fclose(obj);
delete(obj);
end
