clc,clear
format long
%%%%%%%%%%%%%%%  Datos   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 20;
eps = 0;a=1;
F0 = a - eps;
F1 = a + eps;
L = 1;

%%%%%%%%%%%%%%%   Métodos   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%**************   Sin restricciones   *************************************
% ----------   Método Gradiente    ----------------------------------------
x0=ones(1,N-2);
% BFGS equiespaciada Opciones por defecto: BFGS
options = optimoptions('fminunc','Algorithm', 'quasi-newton','Display','off');
tic
[F,amin,exitflag,output,grad,hessian] = fminunc(@(F) A(F,L,F0,F1),x0,options);
toc
fprintf('valor del BFGS=%d, criterio de salida %d\n',amin,exitflag)

% BFGS con distribicion cosenoidal
tic
[F2,amin2,exitflag2,output2,grad2,hessian2] = fminunc(@(F2)A2(F2,F0,F1),x0,options); %obtiene los valores de F que hacen Area minimo
toc
fprintf('valor del BFGS Cosenoidal=%d, criterio de salida %d\n',amin2,exitflag2)

% BFGS con distribicion seno
tic
[F3,amin3,exitflag3,output3,grad3,hessian3] = fminunc(@(F3)A3(F3,F0,F1),x0,options); %obtiene los valores de F que hacen Area minimo
toc
fprintf('valor del BFGS Senoidal=%d, criterio de salida %d\n',amin3,exitflag3)

% --------------------------   Metodos Heuristicos   ----------------------
Nvars=N-2;%NO COMENTAR
ub = 1.5*ones(Nvars,1); lb = 0.4*ub/1.5;%NO COMENTAR
%Algoritmo genetico
options = optimoptions('ga','Display', 'off');
tic
[F4,amin4,exitflag4,output4,population,score] = ga(@(F4)A(F4,L,F0,F1),Nvars,[],[],[],[],lb,ub,[],options);
toc
fprintf('valor del funcional con algoritmo genetico=%d, criterio de salida %d\n',amin4,exitflag4)
% --------------------------   Metodos Directos   ----------------------
% Pattern search
options = optimoptions('patternsearch','Display', 'off');
tic
[F5,amin5] = patternsearch(@(F5)A(F5,L,F0,F1),x0,[],[],[],[],lb,ub,[],options);
toc
fprintf('valor del funcional con pattern search=%d, criterio de salida %d\n',amin5)

%***********************  CON RESTRICCIÓN DE VOLUMEN **********************
[Vcatenoide]=Vol(F,L,F0,F1);
% ----------   Método Gradiente    ----------------------------------------
%INTERIOR POINT
options = optimoptions('fmincon','Algorithm','interior-point','Display','off'); 
tic
[F6,amin6,exitflag6,output6,grad6,hessian6] = fmincon(@(F6)A(F6,L,F0,F1),x0,[],[],[],[],[],[], @(F6)mycon(F6,L,Vcatenoide,F0,F1),options);
toc
fprintf('valor del funcional con Interior Point=%d, criterio de salida %d\n',amin6,exitflag6)
%SQP

options = optimoptions('fmincon','Algorithm', 'sqp','Display', 'off');
tic
[F7,amin7,exitflag7,output7,grad7,hessian7] = fmincon(@(F7)A(F7,L,F0,F1),x0,[],[],[],[],[],[],@(F7) mycon(F7,L,Vcatenoide,F0,F1),options);
toc
fprintf('valor de SQP resticcion de volumen=%d, criterio de salida %d\n',amin7,exitflag7)
%---------------------MÉTODOS HEURÍSTICOS----------------------------------

% Algoritmo genetico
options = optimoptions('ga','Display', 'off');
tic
[F8,amin8,exitflag8,output8] = ga(@(F8)A(F8,L,F0,F1),Nvars,[],[],[],[],lb,ub,@(F8)mycon(F8,L,Vcatenoide,F0,F1),options);
toc
fprintf('valor del funcional con algoritmo genetico=%d, criterio de salida %d\n',amin8,exitflag8)


%%%%%%%%%%%%%%%%%   Plots   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%****************  Datos   ***********************************************%
Radios=[F0 F F1];Radios2=[F0 F2 F1];Radios3=[F0 F3 F1];
Radios4=[F0 F4 F1];
Radios5=[F0 F5 F1];
Radios6 =[F0 F6 F1];
Radios7 =[F0 F7 F1];
Radios8=[F0 F8 F1];
a=linspace(0,pi,N);b=linspace(0,pi/2,N);px=zeros(N,1);px2=zeros(N,1);x=linspace(0,1,N);z=linspace(0,1,N);
for i=1:N
    px(i)=(1-cos(a(i)))/2;px2(i)=(sin(b(i)));
end

%**************   Sin restricciones   *************************************

% BFGS equiespaciada
figure(1)
plot(Radios,x,'g',-Radios,x,'g'); hold on;
xlim([-1 1]);
figure(2)
plot(x,Radios,'--b');hold on
% BFGS con distribicion cosenoidal
plot(px,Radios2,'*-r');hold on
% BFGS con distribicion seno
plot(px2,Radios3,'o-g');hold on
legend('equiespaciada','tipo coseno','tipo seno')

%Algoritmo genetico
figure(3)
plot(x,Radios4,'o');hold on

% Pattern search

figure(3)
plot(x,Radios5,'o');
legend('GA','pattern search');hold on
%***********************  CON RESTRICCIÓN DE VOLUMEN  *********************

% INTERIOR POINT
figure(4)
plot(x,Radios6,'x'); hold on
title('Area min con restricción de volumen')
xlabel('z');
ylabel('F(z)');
% SQP
figure(4)
plot(x,Radios7,'o-'); hold on
legend('Interior Point','SQP')

% %Algoritmo genetico
figure(4)
plot(x,Radios8,'g*');
legend('IP','SQP', 'GA con restricciones');hold on




%% Funciones
function Area=A(F,L,F0,F1)
F_amp=[F0 F F1];
N=size(F_amp,2);
F_deriv=zeros(N-1,1);
delta_x=L/(N-1);
A=zeros(N-1,1);
for i=1:N-1
     F_deriv(i)=(F_amp(i+1)-F_amp(i))/(delta_x);
    A(i)=delta_x*sqrt(1+F_deriv(i)^2)*(F_amp(i+1)+F_amp(i))/2.0;
end
Area=sum(A);
end
function Area2=A2(F2,F0,F1)
F_amp=[F0 F2 F1];
N=size(F_amp,2);
a=linspace(0,pi,N);
px=zeros(N,1);
for i=1:N
    px(i)=(1-cos(a(i)))/2;
end
delta2=zeros(N,1);
F_deriv=zeros(N-1,1);
% derivada por delante
for i=1:N-1
    delta2(i)=px(i+1)-px(i);
end
for i=1:N-1
    F_deriv(i)=(F_amp(i+1)-F_amp(i))/delta2(i);
end
A2=0;
for i=1:N-1
    integrando=sqrt(1+F_deriv(i)^2)*(F_amp(i+1)+F_amp(i))/2.0;
    A2=A2+integrando*delta2(i);
end
Area2=A2;
end
function Area3=A3(F3,F0,F1)
F_amp=[F0 F3 F1];
N=size(F_amp,2);
b=linspace(0,pi/2,N);
px=zeros(N,1);
for i=1:N
    px(i)=(sin(b(i)));
end
delta3=zeros(N,1);
F_deriv=zeros(N-1,1);
%derivada por delante
for i=1:N-1
    delta3(i)=px(i+1)-px(i);
end
for i=1:N-1
    F_deriv(i)=(F_amp(i+1)-F_amp(i))/delta3(i);
end
%derivada por detras
% for i=2:N
%     delta3(i-1)=px(i)-px(i-1);
% end
% for i=2:N
%     F_deriv(i-1)=(F_amp(i)-F_amp(i-1))/delta3(i-1);
%  end
A3=0;
for i=1:N-1
    integrando=sqrt(1+F_deriv(i)^2)*(F_amp(i+1)+F_amp(i))/2.0;
    A3=A3+integrando*delta3(i);
end
Area3=A3;
end

%Funciones de volumen
function [c,ceq]=mycon(F,L,V,F1,F2)
V0=V;
ceq=[];
c=[];
F_=[F1 F F2];
N=size(F_,2);
delta_z=L/(N-1);
dV=zeros(N-1,1);
for i=1:N-1
    dV(i)=delta_z*((F_(i+1)+F_(i))/2)^2;
end
Vol=sum(dV);
ceq=V0-Vol;
end
function Vol=Vol(F,L,F1,F2)
F_=[F1 F F2];
N=size(F_,2);
delta_z=L/(N-1);
dV=zeros(N-1,1);
for i=1:N-1
    dV(i)=delta_z*((F_(i+1)+F_(i))/2)^2;
end
Vol=sum(dV);
end


