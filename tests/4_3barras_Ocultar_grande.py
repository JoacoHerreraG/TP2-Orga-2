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

promedioC0 = 17304694.745762713
promedioC1 = 4242289.254237288
promedioC2 = 3981295.0169491526
promedioC3 = 4002351.1694915253
promedioASM = 962985.0169491526

desvioC0 = 314055.56579911103
desvioC1 = 71502.98291742396
desvioC2 = 57893.1013409976
desvioC3 = 125099.02634563528
desvioASM = 95747.7226307888

Ocultar_EjeImplemt        = ('C O0', 'C O1', 'C O2', 'C O3','ASM')
Ocultar_distribucion_Barras = np.arange(len(Ocultar_EjeImplemt))
Ocultar_EjeTiempoPromedio = []
Ocultar_EjeTiempoPromedio.append(promedioC0)
Ocultar_EjeTiempoPromedio.append(promedioC1)
Ocultar_EjeTiempoPromedio.append(promedioC2)
Ocultar_EjeTiempoPromedio.append(promedioC3)
Ocultar_EjeTiempoPromedio.append(promedioASM)
Ocultar_EjeTiempoDesvioEs = []
Ocultar_EjeTiempoDesvioEs.append(desvioC0)
Ocultar_EjeTiempoDesvioEs.append(desvioC1)
Ocultar_EjeTiempoDesvioEs.append(desvioC2)
Ocultar_EjeTiempoDesvioEs.append(desvioC3)
Ocultar_EjeTiempoDesvioEs.append(desvioASM)

plt.rcdefaults()
fig, ax = plt.subplots()
plt.barh(Ocultar_distribucion_Barras, Ocultar_EjeTiempoPromedio, xerr=Ocultar_EjeTiempoDesvioEs, align='center')
plt.yticks(Ocultar_distribucion_Barras)
ax.set_yticklabels(Ocultar_EjeImplemt)
ax.invert_yaxis()
for i, v in enumerate(Ocultar_EjeTiempoPromedio):
    ax.text(v+3, i+.25, "{:.2e}".format(v) + "\n" +chr(177) + " " + "{:.2e}".format(Ocultar_EjeTiempoDesvioEs[i],-4))
ax.set_xlim([0,30000000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Ocultar\n' + Ocultar_nombre + " en " + nombre)
plt.savefig("Ocultar.5implementaciones." + Ocultar_nombre + ".en." + nombre + ".jpg")