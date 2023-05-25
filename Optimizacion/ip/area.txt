clc,clear
format long
%%%%%%%%%%%%%%%  Datos   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N = 20;
eps = 0;
a = 1;
F0 = a - eps;
F1 = a + eps;
L = 1;
%Definimos el punto más alto de la pompa
altura =1.2;
%Volumen que queremos que tenga la pompa
vol = 0.8;
%Definimos en número máximo de iteraciones y evaluaciones
MaxEval = 100000000; MaxIter = 10000000;

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

options = optimoptions('fmincon','Algorithm', 'interior-point','Display', 'off');
tic
[F7,amin7,exitflag7,output7,grad7,hessian7] = fmincon(@(F7)A(F7,L,F0,F1),x0,[],[],[],[],[],[],@(F7) mycon(F7,L,Vcatenoide,F0,F1),options);
toc
fprintf('valor de interior point resticcion de volumen=%d, criterio de salida %d\n',amin7,exitflag7)

%%%%%%%%%%%%%%%%%   Plots   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%****************  Datos   ***********************************************%
Radios=[F0 F F1];Radios2=[F0 F2 F1];Radios3=[F0 F3 F1];


Radios6 =[F0 F6 F1];
Radios7 =[F0 F7 F1];

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
plot(x,Radios6,'--b');hold on
% BFGS con distribicion cosenoidal
plot(px,Radios6,'*-r');hold on
% BFGS con distribicion seno
plot(px2,Radios6,'o-g');hold on
title('Interior-Point')
legend('equiespaciada','tipo coseno','tipo seno')

%Algoritmo genetico
figure(3)
plot(x,Radios6,'o');hold on

% Pattern search

figure(3)
plot(x,Radios6,'o');
legend('GA','pattern search');hold on
%***********************  CON RESTRICCIÓN DE VOLUMEN  *********************
y1 = 1; y2 = 1;
y0 =sin(linspace(pi,2*pi,N))+altura;    
yLow = linspace(0,0,N);  yLow(1) = 1; yLow(end) = y2;
yUp = linspace(y1,y2,N);
y0 = altura*y0; yUp = altura*yUp; yLow = altura*yLow;
% INTERIOR POINT
figure(4)
plot(x,Radios6,'x'); hold on
title('Area min con restricción de volumen')
xlabel('z');
ylabel('F(z)');


%Ahora empieza la optimización
options = optimoptions('fmincon');
%Elijo el algoritmo de optimizacion
%Pueden ser interior-point ; sqp ; active-set
options = optimoptions(options,'Algorithm', 'interior-point');
%Defino el resto de opciones necesarias para que funcione
options = optimoptions(options,'Display', 'final-detailed');
options = optimoptions(options,'MaxFunctionEvaluations', MaxEval);
options = optimoptions(options,'MaxIterations', MaxIter);
options = optimoptions(options,'PlotFcn', { @optimplotx });
%Defino las funciones a optimizar y sus valores iniciales
    tic
    [y,Areasol,exitflag,output,lambda,grad,hessian] = fmincon(@Area,y0,[],[],[],[],yLow,yUp,@(F)V(F,vol),options);
    tiempo = toc;
%Enseño el número de iteraciones    
Niteraciones = output.iterations;
Nevaluaciones = output.funcCount;

figure
x = linspace(0,1,N);
yAltura = linspace(altura,altura,N);
%Mostramos la función encontrada
plot(x,y)
axis([0 1 0 altura+0.1])
title([ 'Geometría de la pompa. ','A = ' num2str(Areasol)]);
xlabel('Separación entre aros'); ylabel('Altura relativa')




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


