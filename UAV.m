model = 'UAVTrimh';
load_system(model);

Vt=10;
W=3.5;
XCG=0.33;
MASA = 2.5;

param = [MASA, XCG];

% Definir las variables de estado y los controles que se van a trimar
X0 = [Vt, 0, 0, 0, 0];
U0 = [0.5, 0];

% Definir las condiciones de equilibrio
Y0 = [Vt, 0, 0, 0, 0, 0, 0, 0];


[X, U, Y, DX]=trim('UAVTrimh',X0,[0,0],param,X0);


% Mostrar los resultados
disp(['Vt trimado: ', num2str(Y(1))]);
disp(['Ángulo de ataque trimado: ', num2str(Y(2))]);
disp(['Ángulo de asiento trimado: ', num2str(Y(3))]);
disp(['Velocidad angular de cabeceo trimada: ', num2str(Y(4))]);
disp(['Altura trimada: ', num2str(Y(5))]);
disp(['Acelerador trimado: ', num2str(U(1))]);
disp(['Deflexión del timón de profundidad trimada: ', num2str(U(2))]);

[A,B,C,D]=linmod('UAVTrimh',X,U)


% Cerrar el modelo de Simulink
close_system(model);


