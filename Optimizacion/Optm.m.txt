%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  OPTIMIZACIÓN   %%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clc, clear
format long

%%%%%%%%%%%%% Datos %%%%%%%%%%%%%
N=10; %Numero de puntos en que se discretiza
a=1;  %Valor del radio de las cc
epsilon = 0;
L=1; %Distancia entre los aros
%Condiciones de contorno: F0=F(z=0); F1=F(z=1)
F0 = a + epsilon;
F1 = a - epsilon;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DISCRETIZACIONES
%Discretizacion equiespaciada
z=zeros(N,1);
z=linspace(0,1,N);
dz=z(2)-z(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                    MÉTODOS                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%       Gradiente     %%%%%%%%%%%%%%%%%

%Funciones de partida (A descomentar la que se quiera probar)
z0=ones(1,N-2); 
%z0=zeros(1,N-2);
%z0=sin(z)

%%%%%%%%%%%%%%%% Sin restricción %%%%%%%%%%%%%%%%%%%
% BFGS equiespaciada Opciones por defecto: BFGS
options = optimoptions('fminunc','Algorithm', 'quasi-newton','Display','off');
tic
[F,A_min,exitflag,output,grad,hessian] = fminunc(@(F) A(F,F0,F1,dz,N),z0,options);
toc
fprintf('valor del BFGS=%d, criterio de salida %d\n',A_min,exitflag)

%%%%%%%%%%%%%%% Con restricción %%%%%%%%%%%%%%%%%%%%%
% definir restricción
%[Vcatenoide]=Vol(F,L,F0,F1);
[Vcatenoide]=1.1;

%INTERIOR POINT
 options = optimoptions('fmincon','Algorithm','interior-point','Display','off'); 
 tic
 [F2,amin2,exitflag2,output2,grad2,hessian2] = fmincon(@(F2)A(F2,F0,F1,dz,N),z0,[],[],[],[],[],[], @(F2)mycon(F2,L,Vcatenoide,F0,F1),options);
 toc
 fprintf('valor del funcional con Interior Point=%d, criterio de salida %d\n',amin2,exitflag2)

%%%%%%%%%%%%%%       Heurístico     %%%%%%%%%%%%%%%%%
Nvars=N-2;
ub = 1.5*ones(Nvars,1); lb = 0.4*ub/1.5;
options = optimoptions("ga","Display","off");
tic
[F3,A_min_3,exitflag_3,output_3] = ga(@(F3) A(F3,F0,F1,dz,N),Nvars,[],[],[],[],lb,ub,[],options);
toc
fprintf('valor del algoritmo genetico=%d, criterio de salida %d\n',A_min_3,exitflag_3)

%%%%%%%%%%%%%%         Con restricción      %%%%%%%%%%%%%% 
%[Vcatenoide_2]=Vol(F3,L,F0,F1);
[Vcatenoide_2]=1.1;
options = optimoptions('ga','Display', 'off');
tic
[F4,amin4,exitflag4,output4] = ga(@(F4)A(F4,F0,F1,dz,N),Nvars,[],[],[],[],lb,ub,@(F4)mycon(F4,L,Vcatenoide_2,F0,F1),options);
toc
fprintf('valor del funcional con algoritmo genetico=%d, criterio de salida %d\n',amin4,exitflag4)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Gráficas                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Radios=[F0 F F1];
Radios2=[F0 F2 F1];
Radios3=[F0 F3 F1];
Radios4=[F0 F4 F1];

%Solucion analitica
syms b a z1 z2 f0 f1
z1=0; z2=1; f0=F0; f1=F1;
ecs = [a*cosh((z1+b)/a)-f0==0,
       a*cosh((z2+b)/a)-f1==0] ;
variables = [a b];
[sol_a,sol_b] = vpasolve (ecs,variables);

F_a=F_analitica(sol_a,sol_b,z);
Radios_analiticos=[F_a];



%BFGS sin restricciones
figure(1)
plot(Radios,z,-Radios,z);
title('BFGS sin restricciones')
ylabel('Eje z')
xlabel('Radio')

%Interior point con restriccion
figure(2)
plot (Radios2,z,-Radios2,z);
title('Interior point con restricciones')
ylabel('Eje z')
xlabel('Radio')

%Heurístico sin restricciones
figure(3)
plot (Radios3,z,-Radios3,z);
title('Algoritmo genético sin restricciones')
ylabel('Eje z')
xlabel('Radio')

%Heuristico con restricciones
figure(4)
plot (Radios4,z,-Radios4,z);
title('Algoritmo genético con restricciones')
ylabel('Eje z')
xlabel('Radio')

%Comparativa
figure(5)
plot(Radios,z,'g',Radios3,z,'*')
title('BFGS y algoritmo genético sin restricciones')
ylabel('Eje z')
xlabel('Radio')
legend('BFGS','Algoritmo genético')

figure (6)
plot(Radios2,z,'g',Radios4,z,'*')
title('Interior point y algoritmo genético con restricciones')
ylabel('Eje z')
xlabel('Radio')
legend('Interior point','Algoritmo genético')

figure (7)
plot(Radios_analiticos,z,'g',Radios,z,'r')
title('Solución analítica y solución dada por el método BFGS')
ylabel('Eje z')
xlabel('Radio')
legend('Solución analítica','BFGS')

figure (8)
plot(Radios_analiticos,z,'g',Radios,z,'r')
title('Solución analítica y solución dada por el método del algoritmo genético')
ylabel('Eje z')
xlabel('Radio')
legend('Solución analítica','Algoritmo genético')





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                  Funciones                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function Area = A (F, F0, F1, dz, N)
F_cc= [F0 F F1]; %La funcion con las cc incluidas 

for i =1:N-1
    dF(i)=F_cc(i+1)-F_cc(i);
    A(i)=F_cc(i)*sqrt(1+(dF(i)/dz)^2)*dz;
end
%Al discretizar la integral pasa a ser un sumatorio
Area=sum(A);
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
% function Vol=Vol(F,L,F1,F2)
% F_=[F1 F F2];
% N=size(F_,2);
% delta_z=L/(N-1);
% dV=zeros(N-1,1);
% for i=1:N-1
%     dV(i)=delta_z*((F_(i+1)+F_(i))/2)^2;
% end
% Vol=sum(dV);
% end

function F_analitica=F_analitica(valor_a,valor_b,z)
 F_analitica = valor_a*cosh((z+valor_b)/valor_a);
end
  



