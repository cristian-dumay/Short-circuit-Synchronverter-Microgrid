%TRABAJO TESIS
clear all
clc
format long e

Ti=1.5e-4;
Tss=5;
Tof=2*Tss;
KA=Tof;

%name_file='fncterminado_fuentes';
name_file='ClusterMG_1_SG';
name_file_comp='ClusterMG_1_SG/KA';







open_system(name_file);%Open the file in simulink
%load_system(name_file);
set_param(name_file,'FastRestart','off')
set_param(name_file,'SimulationMode','normal')
set_param(name_file,'LoadInitialState','off','InitialState','xo');%Load the new initial state

set_param(name_file,'SaveFormat','Structure');%Change the format of type of data
xo=Simulink.BlockDiagram.getInitialState(name_file);%Get the initial conditions
n=length([xo.signals.values]);%Obtain the size of the system
size_var=[xo.signals.dimensions];%Obtain the number of control and power states
set_param(name_file,'SimulationMode','accelerator')
set_param(name_file,'FastRestart','on')

%set_param(name_file,'SaveOperatingPoint','on','FinalStateName','xss1');%Save the state at the end
sim_test=sim(name_file);
% set_param(name_file,'FastRestart','off')
xoi=[sim_test.xss.signals.values];%State after a simulation

%sizeN=length(sim_test.yout.signals(1).values);

iter=3;
Tss=2;
Tof=1;

K_sweep=linspace(Tof+1/600,(Tof+1/60),iter);
%y=zeros(sizeN,2);
YOUT=zeros(4,iter,2);
YOUT1=zeros(3,iter);
YOUT2=zeros(5,iter);
YOUT3=zeros(5,iter);

for cont=1:iter
    
    %set_param(name_file,'FastRestart','off')
    new_data=mat2cell(xoi,1,size_var);
    [xo.signals.values]=new_data{:};
    set_param(name_file,'LoadInitialState','on','InitialState','xo');%Load the new initial state

    %set_param(name_file_comp,'Gain',num2str(K_sweep(cont)));
    KA=K_sweep(cont)
    %set_param(name_file,'FastRestart','on')
    sim_test=sim(name_file);
    %YOUT(1,cont)=cont;
    %YOUT(2,cont)=K_sweep(cont);
    time_vector=Tss/(Tof-0.05);
    for k=1:29
        y=sim_test.yout.signals(k).values;
        dim=size(y);
        newv=dim/time_vector;
        newv=newv(:,1);
        newv=floor(newv);
        yn=y(newv:end);
        YOUT(1,cont,k)=mean(yn);
        YOUT(2,cont,k)=max(yn);
        YOUT(3,cont,k)=min(yn);
        YOUT(4,cont,k)=((yn(1)-yn(end))/yn(1))*100;
    
    %esta parte es para obtener los valores normalizados de cualquie señal   
        YOUT1(1,cont,k)=(mean(yn)*100/yn(1))-100;
        YOUT1(2,cont,k)=(max(yn)*100/yn(1))-100;
        YOUT1(3,cont,k)=(min(yn)*100/yn(1))-100;
        
    % esta parte toma el mínimo y máximo de cada iteración en cada salida y
    %obtiene su máximo absoluto
       maxabs(1,cont,k)=max(yn);
       minabs(1,cont,k)=min(yn);
       minmax(1,cont,k)=max(abs([maxabs(1,cont,k) minabs(1,cont,k)]));
    end
    
    VRMS_1SC=YOUT(:,:,1:5);
    IRMS_1SC=YOUT(:,:,6:10);
    VRMSN_1SC=YOUT1(:,:,1:5);
    IRMSN_1SC=YOUT1(:,:,6:10);
    VPABS_1SC=minmax(:,:,11:15);
    IPABS_1SC=minmax(:,:,16:20);
    PQ_1SC=YOUT(2:3,:,21:28);
    F_1SC=YOUT(2:3,:,29);
end


