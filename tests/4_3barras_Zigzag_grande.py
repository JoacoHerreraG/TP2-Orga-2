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

promedioC0 = 13821366.355932204
promedioC1 = 2794700.915254237
promedioC2 = 2562322.406779661
promedioC3 = 2567854.813559322
promedioASM = 1296610.7288135593

desvioC0 = 892447.9557837989
desvioC1 = 304438.11283475865
desvioC2 = 238944.5498574728
desvioC3 = 234844.75523053997
desvioASM = 258301.83835261216

Zigzag_EjeImplemt        = ('C O0', 'C O1', 'C O2', 'C O3','ASM\nsin\noptimizar')
Zigzag_distribucion_Barras = np.arange(len(Zigzag_EjeImplemt))
Zigzag_EjeTiempoPromedio = []
Zigzag_EjeTiempoPromedio.append(promedioC0)
Zigzag_EjeTiempoPromedio.append(promedioC1)
Zigzag_EjeTiempoPromedio.append(promedioC2)
Zigzag_EjeTiempoPromedio.append(promedioC3)
Zigzag_EjeTiempoPromedio.append(promedioASM)
Zigzag_EjeTiempoDesvioEs = []
Zigzag_EjeTiempoDesvioEs.append(desvioC0)
Zigzag_EjeTiempoDesvioEs.append(desvioC1)
Zigzag_EjeTiempoDesvioEs.append(desvioC2)
Zigzag_EjeTiempoDesvioEs.append(desvioC3)
Zigzag_EjeTiempoDesvioEs.append(desvioASM)

plt.rcdefaults()
fig, ax = plt.subplots()
plt.barh(Zigzag_distribucion_Barras, Zigzag_EjeTiempoPromedio, xerr=Zigzag_EjeTiempoDesvioEs, align='center')
plt.yticks(Zigzag_distribucion_Barras)
ax.set_yticklabels(Zigzag_EjeImplemt)
ax.invert_yaxis()
for i, v in enumerate(Zigzag_EjeTiempoPromedio):
    ax.text(v+3, i+.25, "{:.2e}".format(v) + "\n" +chr(177) + " " + "{:.2e}".format(Zigzag_EjeTiempoDesvioEs[i],-4))
ax.set_xlim([0,30000000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Zigzag\n' + nombre)
plt.savefig("Zigzag.5implementaciones." + nombre + ".jpg")
