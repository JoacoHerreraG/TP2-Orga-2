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
imgs.sort(reverse=True)
img0Prim = imgs[0:1]
img1PrimInd1 = len(imgs)/2
img1PrimInd2 = img1PrimInd1 + 1
img1Prim = imgs[int(img1PrimInd1):int(img1PrimInd2)]

nombre = img0Prim[0]
Ocultar_nombre = img1Prim[0]
Descubrir_nombre = img0Prim[0] + ".Ocultar.ASM.bmp"

print(colored('Se realizan mediciones...', 'blue'))

promedioC0 = 14443743.406779662
promedioC1 = 3896429.0508474577
promedioC2 = 3163162.118644068
promedioC3 = 3210018.2881355933
promedioASM = 774059.9491525424

desvioC0 = 698539.460935288
desvioC1 = 421339.6556876004
desvioC2 = 206820.09325949205
desvioC3 = 329114.8642949727
desvioASM = 146332.42307269076

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
ax.set_xlim([0,30000000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Descubrir\n' + Descubrir_nombre)
plt.savefig("Descubrir.5implementaciones." + Descubrir_nombre + ".jpg")