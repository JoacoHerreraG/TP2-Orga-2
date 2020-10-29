#!/usr/bin/env python3
import re
import statistics
import matplotlib.pyplot as plt
import numpy as np
from termcolor import colored
from libtest import *

if not os.path.exists(TESTINDIR):
    print(colored('ERROR: Debe correr primero el script %s'%(PRIMER_SCRIPT), 'red'))
    exit()


Cant_medidiones = 60 # Cantidad de mediciones por experimento


nombre = ''
Ocultar_nombre = ''
Descubrir_nombre = ''

print(colored('Se determinan archivos a testear...', 'blue'))
imgs = archivos_tests()
imgs.sort()
img0Prim = imgs[0:1]
img1PrimInd1 = len(imgs)/2
img1PrimInd2 = img1PrimInd1 + 1
img1Prim = imgs[int(img1PrimInd1):int(img1PrimInd2)]

nombre = img0Prim[0]
Ocultar_nombre = img1Prim[0]
Descubrir_nombre = img0Prim[0] + ".Ocultar.ASM.bmp"

print(colored('Se realizan mediciones...', 'blue'))

promedioC0 = 453827.4406779661
promedioC1 = 119747.69491525424
promedioC2 = 97274.25423728813
promedioC3 = 99637.01694915254
promedioASM = 23075.86440677966

desvioC0 = 44593.886623025835
desvioC1 = 7860.75684312254
desvioC2 = 20352.13202641079
desvioC3 = 12625.823596886967
desvioASM = 1948.1096359577095

Descubrir_EjeImplemt        = ('C O0', 'C O1', 'C O2', 'C O3','ASM')
Descubrir_distribucion_Barras = np.arange(len(Descubrir_EjeImplemt))
Descubrir_EjeTiempoPromedio = []
Descubrir_EjeTiempoPromedio.append(promedioC0)
Descubrir_EjeTiempoPromedio.append(promedioC1)
Descubrir_EjeTiempoPromedio.append(promedioC2)
Descubrir_EjeTiempoPromedio.append(promedioC3)
Descubrir_EjeTiempoPromedio.append(promedioASM)
Descubrir_EjeTiempoDesvioEs = []
Descubrir_EjeTiempoDesvioEs.append(desvioC0)
Descubrir_EjeTiempoDesvioEs.append(desvioC1)
Descubrir_EjeTiempoDesvioEs.append(desvioC2)
Descubrir_EjeTiempoDesvioEs.append(desvioC3)
Descubrir_EjeTiempoDesvioEs.append(desvioASM)

plt.rcdefaults()
fig, ax = plt.subplots()
plt.barh(Descubrir_distribucion_Barras, Descubrir_EjeTiempoPromedio, xerr=Descubrir_EjeTiempoDesvioEs, align='center')
plt.yticks(Descubrir_distribucion_Barras)
ax.set_yticklabels(Descubrir_EjeImplemt)
ax.invert_yaxis()
for i, v in enumerate(Descubrir_EjeTiempoPromedio):
    ax.text(v+3, i+.25, "{:.2e}".format(v) + "\n" +chr(177) + " " + "{:.2e}".format(Descubrir_EjeTiempoDesvioEs[i],-4))
ax.set_xlim([0,1200000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Descubrir\n' + Descubrir_nombre)
plt.savefig("Descubrir.5implementaciones." + Descubrir_nombre + ".jpg")