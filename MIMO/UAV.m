

Vt=10;
W=3.5;
XCG=0.33;
MASA = 2.5;


% Definir las variables de estado y los controles que se van a trimar
X0 = [10; 0; 0; 0; 1000];
U0 = [.38; 0];
Y0 = [];
IX = [];

%[x,u,y,dx] = trim('ctrl_nivel_no_lineal',xo,uo,yo,ix)


[XV, UV, Y, DX]=trim('UAVTrimh',X0,U0,Y0,IX);


[A,B,C,D]=linmod('UAVTrimh',XV,UV);

disp(eig(A));


% Definir las matrices de peso para el controlador LQR
Q=[10 0 0 0 0 ;...
    0 1 0 0 0 ;...
    0 0 10 0 0 ;...
    0 0 0 1 0 ;
    0 0 0 0 10];
R=10;

% Calcular los polos deseados para el controlador por pole placement
omega_n = 2;
zeta = 0.7;

s1 = -1.35 + 0.1i;
s2 = -1.35 - 0.1i;
s3 = -0.9 + 1.2i;
s4 = -0.9 - 1.2i;
s5 = -1.2;

% Diseñar el controlador por pole placement
K_pp = place(A, B, [s1, s2, s3, s4, s5]);

% Diseñar el controlador por LQR
[J,S,P]=lqr(A,B,Q,R);
K_lqr = lqr(A, B, Q, R);

Acl = A-(B*K_lqr);
Acpp = A-(B*K_pp);

% Definir las condiciones iniciales y la perturbación
X0 = [10; 0; 0; 0; 1000];
X_pert = X0 + [-1; 0; 0; 0.05; 0];
T_sim = 2;

% Simular el sistema con el controlador por pole placemen
sys_pp = ss(A-B*K_pp, B, C, D);
[y_pp, t_pp, x_pp] = initial(sys_pp, X_pert, T_sim);

% Simular el sistema con el controlador por LQR
sys_lqr = ss(A-B*K_lqr, B, C, D);
[y_lqr, t_lqr, x_lqr] = initial(sys_lqr, X_pert, T_sim);

% Mostrar ambas graficas de controladores
subplot(211)
plot(t_pp, y_pp(:,1), 'b', t_lqr, y_lqr(:,1), 'r--')
xlabel('Tiempo (s)')
ylabel('Velocidad (m/s)')
legend('Pole placement');


% Tracking

Ct= [1 0 0 0 0];
At=[A zeros(5,1);-Ct 0];
Bt=[B;0 0];
Qt=blkdiag(100,1,10,1,10,1);
Rt=10;
Jt=lqr(At,Bt,Qt,Rt);
J1=Jt(1:5);
J2=Jt(6);

% Observabilidad
AO=1.1*A;
OB=obsv(AO,C);
rank(OB)
PO=[-2.34543426890766 + 1.99584255582137i,...
    -2.34543426890766 - 1.99584255582137i,...
    -4.80729260185337 + 0.00000000000000i,...
    -10.3324443158795 + 10.3836668184825i,...
    -10.3324443158795 - 10.3836668184825i];
L=place(A',C',PO);
L=L'; 



