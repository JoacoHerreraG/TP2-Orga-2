#!/usr/bin/env python3
import re
import statistics
import matplotlib.pyplot as plt
import numpy as np
from termcolor import colored
from libtest import *
#from scipy.stats import linregress

if not os.path.exists(TESTINDIR):
    print(colored('ERROR: Debe correr primero el script %s'%(PRIMER_SCRIPT), 'red'))
    exit()

"""
def PolyCoefficients(x, coeffs):
    """ """Returns a polynomial for ``x`` values for the ``coeffs`` provided.

    The coefficients must be in ascending order (``x**0`` to ``x**o``).""" """

    o = len(coeffs)
    print(f'# This is a polynomial of order {ord}.')
    y = []
    for i in range(o):
        y.append += coeffs[i]*x**i
    return y
"""


# Funciones para correr filtros y capturar salidas de pantalla para extraer mediciones...

def alumnos_consola(filtro, implementacion, archivo_in, extra_params, salida_consola):
    salida_consola_a = subprocess.Popen([TP2ALU,filtro,"-i",implementacion,"-o",CATEDRADIR + "/ ", archivo_in,extra_params],stdout=subprocess.PIPE)
    salida_consola_b = salida_consola_a.communicate()[0]
    salida_consola.append(salida_consola_b.decode('utf-8').strip())



Cant_medidiones = 15 # Cantidad de mediciones por experimento


nombre = ''
Ocultar_nombre = ''
Descubrir_nombre = ''

print(colored('Se determinan archivos a testear...', 'blue'))
imgs = archivos_tests()
imgs.sort()
img0Prim = imgs[0:int(len(imgs)/2)]
#img1PrimInd1 = len(imgs)/2
#img1PrimInd2 = img1PrimInd1 + 1
#img1Prim = imgs[int(img1PrimInd1):int(img1PrimInd2)]

#nombre = img0Prim[0]
#Ocultar_nombre = img1Prim[0]
#Descubrir_nombre = img0Prim[0] + ".Ocultar.ASM.bmp"

print(colored('Se realizan mediciones...', 'blue'))

Zigzag_Eje_Tamaños        = (128, 1600, 200, 256, 32, 400, 512, 64, 800 ) #---lexicograficamente---



# Zigzag

Zigzag_EjeTiempoPromedio = []
Zigzag_EjeTiempoDesvioEs = []

# Se ejecuta Zigzag (asm alumnos)

for i in range(len(img0Prim)):
    asm_alumnos_mediciones_Zigzag = []
    asm_alumnos_consola_Zigzag = []
    nombre = img0Prim[0]
    #print('Indice = ' + str(i) + ', Tamaño contenedor img0Prim = ' + str(len(img0Prim)))
    for j in range(Cant_medidiones-1):
        print ('Se ejecuta filtro Zigzag, implementación asm de alumnos sobre imagen ' + str(i) + ' ('+ img0Prim[i] + ") ... " )
        alumnos_consola('Zigzag', 'asm', TESTINDIR + "/" + img0Prim[i], '', asm_alumnos_consola_Zigzag)



    print(colored("\n" + str(Cant_medidiones) + " mediciones de pulsos de reloj de Zigzag asm de alumnos sobre imagen " + nombre + "\n", 'blue'))

    for j in range(len(asm_alumnos_consola_Zigzag)):
        extracciones = re.search('  # de ciclos insumidos totales     : (.+?)\n',asm_alumnos_consola_Zigzag[j])
        asm_alumnos_mediciones_Zigzag.append(float(extracciones.group(1)))
        print (extracciones.group(1))
    print()
    asm_alumnos_promedio_Zigzag = statistics.mean(asm_alumnos_mediciones_Zigzag)
    print("Promedio        = "  + str(asm_alumnos_promedio_Zigzag))
    Zigzag_EjeTiempoPromedio.append(asm_alumnos_promedio_Zigzag)
    asm_alumnos_desvioEs_Zigzag = statistics.stdev(asm_alumnos_mediciones_Zigzag)
    print("Desvío estándar =  " + str(asm_alumnos_desvioEs_Zigzag))
    Zigzag_EjeTiempoDesvioEs.append(asm_alumnos_desvioEs_Zigzag)

    with open('Medicion_Zigzag_alumnos_' + img0Prim[i] + '.py','w') as archivo:
        archivo.write(str(Cant_medidiones) + " mediciones de pulsos de reloj de Zigzag asm de alumnos sobre imagen " + img0Prim[i] + "\n")
        archivo.write(', '.join(map(str,asm_alumnos_mediciones_Zigzag)))
        archivo.write("\nPromedio        = "  + str(asm_alumnos_promedio_Zigzag))
        archivo.write("\nDesvío estándar =  " + str(asm_alumnos_desvioEs_Zigzag))

print()


#m, b, r = linregress(Zigzag_Eje_Tamaños, Zigzag_EjeTiempoPromedio)
# b2, b1, b0 = polynomial_coeff=np.polyfit(Zigzag_Eje_Tamaños,Zigzag_EjeTiempoPromedio,2)
#m, b = linregress(Zigzag_Eje_Tamaños, Zigzag_EjeTiempoPromedio)

# falta agregar desvios


# coeffs = [b0, b1, b2]





"""
Zigzag_Linea_Ajuste = []

for i in range(len(Zigzag_Eje_Tamaños)):
    Zigzag_Linea_Ajuste.append((Zigzag_Eje_Tamaños[i]*b2*b2)+(Zigzag_Eje_Tamaños[i]*b1)+b0)
"""
plt.rcdefaults()
fig, ax = plt.subplots()
ax.scatter(Zigzag_Eje_Tamaños, Zigzag_EjeTiempoPromedio, s=10, c="black", alpha=0.40)#, yerr=Zigzag_EjeTiempoDesvioEs) #, align='center')
#ax.scatter(Zigzag_Eje_Tamaños, Zigzag_Linea_Ajuste, linestyle = "-")
# plt.scatter(Zigzag_Eje_Tamaños, PolyCoefficients(Zigzag_Eje_Tamaños, coeffs))
plt.ylabel('Pulsos de reloj de CPU')
plt.xlabel('Ancho de imagen de entrada en pixeles')

plt.errorbar(Zigzag_Eje_Tamaños, Zigzag_EjeTiempoPromedio, yerr=Zigzag_EjeTiempoDesvioEs, linestyle = "None")
ax.set_yscale('log')
ax.set_xscale('log')
plt.title('Tiempos de ejecución Zigzag_asm.asm\npara distintos tamaños de imagen')
plt.savefig("ZigzagTamVarios.jpg")
