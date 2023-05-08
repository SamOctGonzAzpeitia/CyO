%% Funcion que define la restricción de volumen
%%Esta funcion definira la restrccion de volumen del problema planteado.
%%Depende del volumen que queramos que tenga la pompa

function [c,ceq] = V( F,vol )
%V = integral ( F^2 );

%Numero de puntos en los que vamos a evaluar (N)
N = max(size(F));

%Equiespaciado de puntos entre 0 y 1 con N puntos (x) y la distancia entre
%puntos (deltaX)
x = linspace(0,1,N);
deltaX = x(2) - x(1);

%Definimos la función dentro de la integral (int)
int = F.^2;


%Para integrar dealizaremos la regla del trapecio,
%i.e. entre dos puntos muy cercanos a y b, (b-a)=deltaX
%int(f) = (b-a)* ( f(a) + f(b) )/2
ceq = 0;
for j = 1:N-1
    ceq = ceq + deltaX * ( int(j) + int(j+1) )/2;
end

%Con V = vol
%Para poder utilizar la restricción despues, la dejamos represetada de una
%manera adecuada para el programa de matlab:
ceq = ceq - vol;
c = 0;
end

