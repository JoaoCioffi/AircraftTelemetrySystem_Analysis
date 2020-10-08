close all
clear all
clc
%%
fprintf('\n')
fprintf('\t -------------------------------------------------------------')
fprintf('\n')
fprintf('\t /////////////////////////////////////////////////////////////')
fprintf('\n')
fprintf('\t\t\t\t .::. FLIGHT MONITORING PARAMETERS .::.')
fprintf('\n')
fprintf('\t /////////////////////////////////////////////////////////////')
fprintf('\n')
%
DATA = load('DATA_Real.txt');
%
Time_seconds = DATA(:,1); %tempo (s)
Time_hours = Time_seconds./3600;
%
Alt = DATA(:,2); %altitude (ft)
%
VCA = DATA(:,3); %velocidade (m/s)
Limit_VCA = find(0<=VCA & VCA<=20); %excluindo ruídos de velocidade acima do limite operacional (20m/s)
VCA_Remastered = VCA(Limit_VCA,1); %Valores de velocidade refinados (excluídos de ruídos)
VCA_Remastered_Ascending = sortrows(VCA_Remastered);
Size_VCA_Remastered_Ascending = size(VCA_Remastered_Ascending);
Dive_Average_Speed = (1/10).*( VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-0),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-1),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-2),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-3),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-4),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-5),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-6),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-7),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-8),1) + VCA_Remastered_Ascending((Size_VCA_Remastered_Ascending(1,1)-9),1) ); %velocidade de mergulho: considerada a média aritmética entre as 10 maiores velocidades atingidas em voo
%
%Velocidade Média de Subida:
max_alt = max(Alt); %altitude máxima atingida [ft]
Find_max_alt = find(Alt==max_alt); %posição do elemento max(alt)
Find_time_Vm_ascent = find(Time_hours==Time_hours(Find_max_alt,1)); %posição do instante de tempo em que se atinge max(alt)
Time_Vm_ascent = Time_hours(Find_time_Vm_ascent,1); %tempo em que se atinge max(alt) [s]
%
Vm_ascent_ms = (max_alt-Alt(1,1))/Time_Vm_ascent; %Velocidade média de subida [m/s]
Vm_ascent_knots = 1.94384*Vm_ascent_ms; %Velocidade média de subida [knots]
Vm_ascent_units = [Vm_ascent_ms Vm_ascent_knots]; %Matriz unidade Vm_subida
%
fprintf('\t -------------------------------------------------------------')
fprintf('\n')
fprintf ('Velocidade média de subida (considerando até o instante em que se atinge Alt. Max):')
Vm_ascent_units
fprintf('\t [m/s] ; [knots]')
fprintf('\n')
%
SizeAlt = size(Alt);
SizeTime = size(Time_hours);
%
figure(1)
hold on; grid on; grid minor;
plot(Time_hours,Alt,'-b','LineWidth',0.5);
legend('Aircraft Trajectory')
ylabel('Altitude [ft]','FontSize',8,'FontWeight','bold','Color','k')
xlabel('Time [h]','FontSize',8,'FontWeight','bold','Color','k')
title({'Average Ascent Speed: [m/s] ; [knots]'; [Vm_ascent_ms Vm_ascent_knots]},'FontSize',8,'FontWeight','bold','Color','r')
valuearrowvelocity = VCA(Find_max_alt,1);
text(Time_hours(Find_max_alt,1),Alt(Find_max_alt,1),'\leftarrow V_{inst} = 9.96 m/s','Color','r','FontSize',8)
%
%%
%Coordenadas GPS (m):
XGPS = DATA(:,4);
YGPS = DATA(:,5);
ZGPS = DATA(:,6);
%
Delimit_ZGPS = find(ZGPS>0);
XGPS_Remastered = XGPS(Delimit_ZGPS,1);
YGPS_Remastered = YGPS(Delimit_ZGPS,1);
ZGPS_Remastered = ZGPS(Delimit_ZGPS,1);
%
%Runway coordinates:
Find_Runway_Coord = find(ZGPS==0);
xr = XGPS(Find_Runway_Coord,1);
yr = YGPS(Find_Runway_Coord,1);
zr = ZGPS(Find_Runway_Coord,1);
%
j=1:1:71;
xr_remastered = xr(j,1);
yr_remastered = yr(j,1);
zr_remastered = zr(j,1);
%
Runway_coord = [xr_remastered yr_remastered zr_remastered];
%
%Target: Estimated Position:
%
Xtarget_vertical = [20 20 20];
Ytarget_vertical = [50 60 70];
Ztarget_vertical = [0 0 0];
%
Xtarget_horizontal = [10 20 30];
Ytarget_horizontal = [60 60 60];
Ztarget_horizontal = [0 0 0];
%
% Raio entorno do alvo:
Target_Center_3D = [20 60 0]; %x,y,z: centro do alvo
xcenter = Target_Center_3D(1,1);
ycenter = Target_Center_3D(1,2);
zcenter = Target_Center_3D(1,3);
R = sqrt(((XGPS_Remastered-Target_Center_3D(1,1)).^2) + ((YGPS_Remastered-Target_Center_3D(1,2)).^2) + ((ZGPS_Remastered-Target_Center_3D(1,3)).^2));
R_max = max(R);%raio máximo entorno do alvo
Find_R_max = find(R==R_max);
Xline = [xcenter XGPS_Remastered(Find_R_max,1)];
Yline = [ycenter YGPS_Remastered(Find_R_max,1)]; 
Zline = [zcenter ZGPS_Remastered(Find_R_max,1)];
%
cplot = @(r,x0,y0) plot(x0 + r*cos(linspace(0,2*pi)),y0 + r*sin(linspace(0,2*pi)),'-');
%
figure(2)
subplot(2,2,[1 2])
plot3(XGPS_Remastered,YGPS_Remastered,ZGPS_Remastered,'LineWidth',0.125,'Color','k','Marker','>','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',3)
grid on; hold on;
plot3(xr_remastered,yr_remastered,zr_remastered,'-.','LineWidth',2,'Color','red')
hold on;
stem3(XGPS_Remastered,YGPS_Remastered,ZGPS_Remastered,'Color',[.5 0 .5])
hold on;
plot3(Xline,Yline,Zline,'-.','LineWidth',1.5,'Color','c');
xlabel('X [m]','FontSize',8,'FontWeight','bold','Color','k')
ylabel('Y [m]','FontSize',8,'FontWeight','bold','Color','k')
zlabel('Altitude [m]','FontSize',8,'FontWeight','bold','Color','k')
text(xr_remastered(1,1),yr_remastered(1,1),zr_remastered(1,1),'\rightarrow Runway Threshold','Color','b','FontWeight','bold','FontSize',8)
title({'_{.::.} Flight Supervisory - Isometric View _{.::.}';'Average Dive Speed:'; [Dive_Average_Speed] ; '[m/s]'},'FontSize',8,'FontWeight','bold','Color','k')
legend('Aircraft Trajectory','Runway','Altitude Stem','Max. Trajectory Radius: 246.632m')
subplot(2,2,4)
bar(Time_hours,XGPS)
grid on; grid minor;
ylabel('XGPS [m]','FontSize',8,'FontWeight','bold','Color','k')
xlabel('Time [h]','FontSize',8,'FontWeight','bold','Color','k')
subplot(2,2,3)
bar(Time_hours,YGPS)
grid on; grid minor;
ylabel('YGPS [m]','FontSize',8,'FontWeight','bold','Color','k')
xlabel('Time [h]','FontSize',8,'FontWeight','bold','Color','k')
%
figure(3)
subplot(2,2,[1 2])
hold on; grid on;
plot(XGPS_Remastered,YGPS_Remastered,'LineWidth',0.125,'Color','k','Marker','>','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',3);
plot(xr_remastered,yr_remastered,'-.','LineWidth',2,'Color','red')
plot(Xtarget_vertical,Ytarget_vertical,'-h','LineWidth',1.25,'Color',[1 .65 .5]);
plot(Xtarget_horizontal,Ytarget_horizontal,'-h','LineWidth',1.25,'Color',[1 .65 .5]);
plot(Xline,Yline,'-.','LineWidth',1.5,'Color','c');
ylabel('YGPS [m]','FontSize',8,'FontWeight','bold','Color','k')
xlabel('XGPS [m]','FontSize',8,'FontWeight','bold','Color','k')
title('_{.::.} Flight Supervisory - Top View _{.::.}','FontSize',8,'FontWeight','bold','Color','k')
text(xr_remastered(1,1),yr_remastered(1,1),'\rightarrow Runway Threshold','Color','b','FontWeight','bold','FontSize',8)
text(XGPS_Remastered(Find_R_max,1),YGPS_Remastered(Find_R_max,1),'\rightarrow Max. Trajectory Radius: 246.632m','Color','k','FontWeight','bold','FontSize',8);
legend('Aircraft Trajectory','Runway','Target')
axis equal
subplot(2,2,[3 4])
hold on; grid on;
title('Jr DSX9 Transmitter Range','FontSize',8,'FontWeight','bold','Color','k')
plot(XGPS_Remastered,YGPS_Remastered,'LineWidth',0.125,'Color','k','Marker','>','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',3);
plot(xr_remastered,yr_remastered,'-.','LineWidth',2,'Color','red')
cplot(0.25*1800,xcenter,ycenter);
cplot(0.5*1800,xcenter,ycenter);
cplot(0.75*1800,xcenter,ycenter);
cplot(1800,xcenter,ycenter);
text(1816.376,-54.1631,'1800m','Color','k','FontWeight','bold','FontSize',6.5)
text(1367.282,-25.6223,'1350m','Color','k','FontWeight','bold','FontSize',6.5)
text(912.7593,-53.9332,'900m','Color','k','FontWeight','bold','FontSize',6.5)
text(466.3797,3.0334,'450m','Color','k','FontWeight','bold','FontSize',6.5)
ylabel('YGPS [m]','FontSize',8,'FontWeight','bold','Color','k')
xlabel('XGPS [m]','FontSize',8,'FontWeight','bold','Color','k')
axis equal
legend('Aircraft Trajectory','Runway')
%
%%
%Análise direcional:
MagHead = DATA(:,7); %Proa Magnética (°)
MagHeadReal = (pi/180).*MagHead;
r = ones(size(MagHeadReal));
%
figure(4)
subplot(2,1,1)
polar(MagHeadReal,r,'-.r')
title('Magnetic Head Analysis','FontSize',8,'FontWeight','bold','Color','k')
text(1,0,'           \rightarrow True North','Color','b','FontWeight','bold','FontSize',8)
subplot(2,1,2)
hold on; grid on; grid minor;
bar(Time_hours,MagHead)
ylabel('Mag. Head [degrees]','FontSize',8,'FontWeight','bold','Color','k')
xlabel('Time [h]','FontSize',8,'FontWeight','bold','Color','k')
%
Theta = DATA(:,8);
Phi = DATA(:,9);

figure(5)
hold on; grid on; grid minor;
plot(Time_hours,Theta,'-b','LineWidth',0.5);
ylabel('\theta [degrees]','FontSize',8,'FontWeight','bold','Color','k')
xlabel('Time [h]','FontSize',8,'FontWeight','bold','Color','k')
title('Pitch Analysis','FontSize',8,'FontWeight','bold','Color','r')
%
figure(6)
hold on; grid on; grid minor;
plot(Time_hours,Phi,'-b','LineWidth',0.5);
ylabel('\Phi [degrees]','FontSize',8,'FontWeight','bold','Color','k')
xlabel('Time [h]','FontSize',8,'FontWeight','bold','Color','k')
title('Roll Analysis','FontSize',8,'FontWeight','bold','Color','r')
%


figure(7)
subplot(2,2,[1 2])
plot3(XGPS_Remastered,YGPS_Remastered,ZGPS_Remastered,'LineWidth',0.125,'Color','k','Marker','>','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',3)
grid on; hold on; box on;
plot3(xr_remastered,yr_remastered,zr_remastered,'-.','LineWidth',2,'Color','red')
hold on;
stem3(XGPS_Remastered,YGPS_Remastered,ZGPS_Remastered,'Color',[.5 0 .5])
hold on;
plot3(Xline,Yline,Zline,'-.','LineWidth',1.5,'Color','c');
xlabel('X_{GPS} (m)','FontSize',10,'FontWeight','bold','Color','k')
ylabel('Y_{GPS} (m)','FontSize',10,'FontWeight','bold','Color','k')
zlabel('Altitude (m)','FontSize',10,'FontWeight','bold','Color','k')
text(xr_remastered(1,1),yr_remastered(1,1),zr_remastered(1,1),'\rightarrow Runway Threshold','Color','b','FontWeight','bold','FontSize',10)
title({'_{.::.} Flight Supervisory - Isometric View _{.::.}';'Average Dive Speed:'; [Dive_Average_Speed] ; '(m/s)'},'FontSize',10,'FontWeight','bold','Color','k')
legend('Aircraft Trajectory','Runway','Altitude Stem','Max. Trajectory Radius: 246.632m')
subplot(2,2,[3 4])
hold on; grid on; box on;
axis equal;
plot(XGPS_Remastered,YGPS_Remastered,'LineWidth',0.125,'Color','k','Marker','>','MarkerEdgeColor','k','MarkerFaceColor','g','MarkerSize',3);
plot(xr_remastered,yr_remastered,'-.','LineWidth',2,'Color','red')
plot(Xtarget_vertical,Ytarget_vertical,'-h','LineWidth',1.25,'Color',[1 .65 .5]);
plot(Xtarget_horizontal,Ytarget_horizontal,'-h','LineWidth',1.25,'Color',[1 .65 .5]);
plot(Xline,Yline,'-.','LineWidth',1.5,'Color','c');
ylabel('Y_{GPS} (m)','FontSize',10,'FontWeight','bold','Color','k')
xlabel('X_{GPS} (m)','FontSize',10,'FontWeight','bold','Color','k')
title('_{.::.} Flight Supervisory - Top View _{.::.}','FontSize',10,'FontWeight','bold','Color','k')
text(xr_remastered(1,1),yr_remastered(1,1),'\rightarrow Runway Threshold','Color','b','FontWeight','bold','FontSize',10)
text(XGPS_Remastered(Find_R_max,1),YGPS_Remastered(Find_R_max,1),'\rightarrow Max. Trajectory Radius: 246.632m','Color','k','FontWeight','bold','FontSize',10);
legend('Aircraft Trajectory','Runway','Target')