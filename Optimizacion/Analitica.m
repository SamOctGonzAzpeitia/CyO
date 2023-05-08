%% Función analítica de la curva

clc
clear

%Numero de puntos en el eje x
N = 400;

%Altura de la pompa (refiriendose al PUNTO MÁS ALTO de la pompa)
altura = 1.2;

%Pasamos a variables simbólicas para resolver dos ecuaciones(1) y (2)
syms b a x1 x2 y1 y2

%Hallamos kappa que nos es necesario para determinar la curva final. Para
%hallarla tenemos que resolver un sistema de ecuaciones:
x1 = 0;  x2 = 1; y1 = 1; y2 = 1.4;

eqns = [b*cosh((x1+a)/b) - y1 == 0, %(1)
        b*cosh((x2+a)/b)- y2 == 0]; %(2)
vars = [ b a];
[sol_b, sol_a] = solve(eqns,vars);

%Uno de los resultados del sistema de ecuaciones anterior es Kappa:
bb = double(sol_b);

%Realizamos un mallado equidistante entre 0 y 1
x = linspace(0,1,N);

%Calculamos el valor de la curva para una determinada altura en el
%intervalo definido en el vector x
y = bb*cosh((x + double(sol_a))/bb);

% Calculo el volumen 
Vol = 0;
for j = 1:N-1
    Vol = Vol + ( x(j+1) - x(j) ) * ( y(j) + y(j+1) )/2;
end


%Representamos la altura máxima de la curva dentro del intervalo y la
%funcion analítica en el intervalo
yAltura = linspace(altura,altura,N);


plot(x,y)
axis([0 1 0 altura+0.4])
title([ 'y1 = y2 = ' num2str(altura) '  ,  A  =  ' num2str(Area(y)) ' ,  V  =  ' num2str(Vol)]);










