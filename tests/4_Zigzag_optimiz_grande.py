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
Zigzag_nombre = ''
Descubrir_nombre = ''

imgs = archivos_tests()
imgs.sort(reverse=True)
img0Prim = imgs[0:1]
img1PrimInd1 = len(imgs)/2
img1PrimInd2 = img1PrimInd1 + 1
img1Prim = imgs[int(img1PrimInd1):int(img1PrimInd2)]

nombre = img0Prim[0]
Zigzag_nombre = img1Prim[0]
Descubrir_nombre = img0Prim[0] + ".Zigzag.ASM.bmp"


promedioASM = 2530000
promedioASMSust = 2010000
desvioASM = 450000
desvioASMSust = 280000

Zigzag_EjeImplemt        = ('ASM\nsin\noptimizar', 'ASM\noptimi-\nzado')
Zigzag_distribucion_Barras = np.arange(len(Zigzag_EjeImplemt))
Zigzag_EjeTiempoPromedio = []
Zigzag_EjeTiempoPromedio.append(promedioASM)
Zigzag_EjeTiempoPromedio.append(promedioASMSust)
Zigzag_EjeTiempoDesvioEs = []
Zigzag_EjeTiempoDesvioEs.append(desvioASM)
Zigzag_EjeTiempoDesvioEs.append(desvioASMSust)

plt.rcdefaults()
fig, ax = plt.subplots()
plt.barh(Zigzag_distribucion_Barras, Zigzag_EjeTiempoPromedio, xerr=Zigzag_EjeTiempoDesvioEs, align='center')
plt.yticks(Zigzag_distribucion_Barras)
ax.set_yticklabels(Zigzag_EjeImplemt)
ax.invert_yaxis()
for i, v in enumerate(Zigzag_EjeTiempoPromedio):
    ax.text(v+3, i+.25, "{:.2e}".format(v) + "\n" +chr(177) + " " + "{:.2e}".format(Zigzag_EjeTiempoDesvioEs[i],-4))
ax.set_xlim([0,3500000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Zigzag\n' + Zigzag_nombre + " en " + nombre)
plt.savefig("Zigzag.optimiz." + Zigzag_nombre + ".en." + nombre + ".svg")
