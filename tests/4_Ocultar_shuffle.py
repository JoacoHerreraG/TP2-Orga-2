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


nombre = ''
Ocultar_nombre = ''
Descubrir_nombre = ''


imgs = archivos_tests()
imgs.sort()
img0Prim = imgs[0:1]
img1PrimInd1 = len(imgs)/2
img1PrimInd2 = img1PrimInd1 + 1
img1Prim = imgs[int(img1PrimInd1):int(img1PrimInd2)]

nombre = img0Prim[0]
Ocultar_nombre = img1Prim[0]
Descubrir_nombre = img0Prim[0] + ".Ocultar.ASM.bmp"


promedioASM = 50703.898305084746
promedioASMSust = 65278.96610169492
desvioASM = 8535.58679213278
desvioASMSust = 9774.93146279192

Ocultar_EjeImplemt        = ('ASM', 'ASM\nimitación\nshuffle')
Ocultar_distribucion_Barras = np.arange(len(Ocultar_EjeImplemt))
Ocultar_EjeTiempoPromedio = []
Ocultar_EjeTiempoPromedio.append(promedioASM)
Ocultar_EjeTiempoPromedio.append(promedioASMSust)
Ocultar_EjeTiempoDesvioEs = []
Ocultar_EjeTiempoDesvioEs.append(desvioASM)
Ocultar_EjeTiempoDesvioEs.append(desvioASMSust)

plt.rcdefaults()
fig, ax = plt.subplots()
plt.barh(Ocultar_distribucion_Barras, Ocultar_EjeTiempoPromedio, xerr=Ocultar_EjeTiempoDesvioEs, align='center')
plt.yticks(Ocultar_distribucion_Barras)
ax.set_yticklabels(Ocultar_EjeImplemt)
ax.invert_yaxis()
for i, v in enumerate(Ocultar_EjeTiempoPromedio):
    ax.text(v+3, i+.25, "{:.2e}".format(v) + "\n" +chr(177) + " " + "{:.2e}".format(Ocultar_EjeTiempoDesvioEs[i],-4))
ax.set_xlim([0,100000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Ocultar\n' + Ocultar_nombre + " en " + nombre)
plt.savefig("Ocultar.sustit." + Ocultar_nombre + ".en." + nombre + ".svg")
