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


# Funciones para correr filtros y capturar salidas de pantalla para extraer mediciones...

def catedra_consola(filtro, implementacion, archivo_in, extra_params, salida_consola):
    salida_consola_a = subprocess.Popen([TP2ALU,filtro,"-i",implementacion,"-o",CATEDRADIR + "/ ", archivo_in,extra_params],stdout=subprocess.PIPE)
    salida_consola_b = salida_consola_a.communicate()[0]
    salida_consola.append(salida_consola_b.decode('utf-8').strip())

def alumnos_consola(filtro, implementacion, archivo_in, extra_params, salida_consola):
    salida_consola_a = subprocess.Popen([TP2ALU,filtro,"-i",implementacion,"-o",CATEDRADIR + "/ ", archivo_in,extra_params],stdout=subprocess.PIPE)
    salida_consola_b = salida_consola_a.communicate()[0]
    salida_consola.append(salida_consola_b.decode('utf-8').strip())



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


# Ocultar

c___catedra_consola_Ocultar = []
asm_alumnos_consola_Ocultar = []

c___catedra_mediciones_Ocultar = []
asm_alumnos_mediciones_Ocultar = []

# Se ejecuta Ocultar (asm alumnos)

for i in range(len(img0Prim)):
    #print('Indice = ' + str(i) + ', Tamaño contenedor img0Prim = ' + str(len(img0Prim)) + ', Tamaño contenedor img1Prim = ' + str(len(img1Prim)))
    for j in range(Cant_medidiones-1):
        print ('Se ejecuta filtro Ocultar, implementación asm de alumnos sobre imagen ' + str(i) + ' ('+ img0Prim[i] + ", " + img1Prim[i] + ") ... " )
        alumnos_consola('Ocultar', 'asm', TESTINDIR + "/" + img0Prim[i], TESTINDIR + "/" + img1Prim[i], asm_alumnos_consola_Ocultar)

print('')

# Se ejecuta Ocultar (c cátedra)

for i in range(len(img0Prim)):
    #print('Indice = ' + str(i) + ', Tamaño contenedor img0Prim = ' + str(len(img0Prim)) + ', Tamaño contenedor img1Prim = ' + str(len(img1Prim)))
    for j in range(Cant_medidiones-1):
        print ('Se ejecuta filtro Ocultar, implementación c de cátedra, sobre imagen ' + str(i) + ' (' + img0Prim[i] + ", " + img1Prim[i] + ") ... " )
        catedra_consola('Ocultar', 'c', TESTINDIR + "/" + img0Prim[i], TESTINDIR + "/" + img1Prim[i], c___catedra_consola_Ocultar)


# Descubrir

c___catedra_consola_Descubrir = []
asm_alumnos_consola_Descubrir = []

c___catedra_mediciones_Descubrir = []
asm_alumnos_mediciones_Descubrir = []

# Se ejecuta Descubrir (asm alumnos)

for i in range(len(img0Prim)):
    #print('Indice = ' + str(i) + ', Tamaño contenedor img0Prim = ' + str(len(img0Prim)))
    for j in range(Cant_medidiones-1):
        print ('Se ejecuta filtro Descubrir, implementación asm de alumnos sobre imagen ' + str(i) + ' ('+ img0Prim[i] + ") ... " )
        alumnos_consola('Descubrir', 'asm', CATEDRADIR + "/" + img0Prim[i] + ".Ocultar.ASM.bmp", '', asm_alumnos_consola_Descubrir)

print('')

# Se ejecuta Descubrir (c cátedra)

for i in range(len(img0Prim)):
    #print('Indice = ' + str(i) + ', Tamaño contenedor img0Prim = ' + str(len(img0Prim)))
    for j in range(Cant_medidiones-1):
        print ('Se ejecuta filtro Descubrir, implementación c de cátedra, sobre imagen ' + str(i) + ' (' + img0Prim[i] + ") ... " )
        catedra_consola('Descubrir', 'c', CATEDRADIR + "/" + img0Prim[i] + ".Ocultar.ASM.bmp", '', c___catedra_consola_Descubrir)



# Zigzag

c___catedra_consola_Zigzag = []
asm_alumnos_consola_Zigzag = []

c___catedra_mediciones_Zigzag = []
asm_alumnos_mediciones_Zigzag = []

# Se ejecuta Zigzag (asm alumnos)

for i in range(len(img0Prim)):
    #print('Indice = ' + str(i) + ', Tamaño contenedor img0Prim = ' + str(len(img0Prim)))
    for j in range(Cant_medidiones-1):
        print ('Se ejecuta filtro Zigzag, implementación asm de alumnos sobre imagen ' + str(i) + ' ('+ img0Prim[i] + ") ... " )
        alumnos_consola('Zigzag', 'asm', TESTINDIR + "/" + img0Prim[i], '', asm_alumnos_consola_Zigzag)

print('')

# Se ejecuta Zigzag (c cátedra)

for i in range(len(img0Prim)):
    #print('Indice = ' + str(i) + ', Tamaño contenedor img0Prim = ' + str(len(img0Prim)))
    for j in range(Cant_medidiones-1):
        print ('Se ejecuta filtro Zigzag, implementación c de cátedra, sobre imagen ' + str(i) + ' (' + img0Prim[i] + ") ... " )
        catedra_consola('Zigzag', 'c', TESTINDIR + "/" + img0Prim[i], '', c___catedra_consola_Zigzag)



print(colored('\nSe listan salidas de consola capturadas...\n', 'green'))


print(colored("\nLecturas de consola Ocultar c catedra...\n", 'blue'))
print('\n'.join(c___catedra_consola_Ocultar))
print("\n")

print(colored("\nLecturas de consola Ocultar asm alumnos...\n", 'blue'))
print('\n'.join(asm_alumnos_consola_Ocultar))
print("\n")

print(colored("\nLecturas de consola Descubrir c catedra...\n", 'blue'))
print('\n'.join(c___catedra_consola_Descubrir))
print("\n")

print(colored("\nLecturas de consola Descubrir asm alumnos...\n", 'blue'))
print('\n'.join(asm_alumnos_consola_Descubrir))
print("\n")

print(colored("\nLecturas de consola Zigzag c catedra...\n", 'blue'))
print('\n'.join(c___catedra_consola_Zigzag))
print("\n")

print(colored("\nLecturas de consola Zigzag asm alumnos...\n", 'blue'))
print('\n'.join(asm_alumnos_consola_Zigzag))
print("\n")



print(colored('\nSe extraen mediciones de salidas de consola capturadas y se las lista...\n', 'green'))



print(colored("\n" + str(Cant_medidiones) + " mediciones de pulsos de reloj de Ocultar c de cátedra sobre imágenes " + nombre + ", " + Ocultar_nombre + "\n", 'blue'))

for i in range(len(c___catedra_consola_Ocultar)):
    extracciones = re.search('  # de ciclos insumidos totales     : (.+?)\n',c___catedra_consola_Ocultar[i])
    c___catedra_mediciones_Ocultar.append(float(extracciones.group(1)))
    print (extracciones.group(1))
print()
c___catedra_promedio_Ocultar = statistics.mean(c___catedra_mediciones_Ocultar)
print("Promedio        = "  + str(c___catedra_promedio_Ocultar))
c___catedra_desvioEs_Ocultar = statistics.stdev(c___catedra_mediciones_Ocultar)
print("Desvío estándar =  " + str(c___catedra_desvioEs_Ocultar))

print(colored("\n" + str(Cant_medidiones) + " mediciones de pulsos de reloj de Ocultar asm de alumnos sobre imágenes " + nombre + ", " + Ocultar_nombre + "\n", 'blue'))

for i in range(len(asm_alumnos_consola_Ocultar)):
    extracciones = re.search('  # de ciclos insumidos totales     : (.+?)\n',asm_alumnos_consola_Ocultar[i])
    asm_alumnos_mediciones_Ocultar.append(float(extracciones.group(1)))
    print (extracciones.group(1))
print()
asm_alumnos_promedio_Ocultar = statistics.mean(asm_alumnos_mediciones_Ocultar)
print("Promedio        = "  + str(asm_alumnos_promedio_Ocultar))
asm_alumnos_desvioEs_Ocultar = statistics.stdev(asm_alumnos_mediciones_Ocultar)
print("Desvío estándar =  " + str(asm_alumnos_desvioEs_Ocultar))



print(colored("\n" + str(Cant_medidiones) + " mediciones de pulsos de reloj de Descubrir c de cátedra sobre imagen " + Descubrir_nombre + "\n", 'blue'))

for i in range(len(c___catedra_consola_Descubrir)):
    extracciones = re.search('  # de ciclos insumidos totales     : (.+?)\n',c___catedra_consola_Descubrir[i])
    c___catedra_mediciones_Descubrir.append(float(extracciones.group(1)))
    print (extracciones.group(1))
print()
c___catedra_promedio_Descubrir = statistics.mean(c___catedra_mediciones_Descubrir)
print("Promedio        = "  + str(c___catedra_promedio_Descubrir))
c___catedra_desvioEs_Descubrir = statistics.stdev(c___catedra_mediciones_Descubrir)
print("Desvío estándar =  " + str(c___catedra_desvioEs_Descubrir))

print(colored("\n" + str(Cant_medidiones) + " mediciones de pulsos de reloj de Descubrir asm de alumnos sobre imagen " + Descubrir_nombre + "\n", 'blue'))

for i in range(len(asm_alumnos_consola_Descubrir)):
    extracciones = re.search('  # de ciclos insumidos totales     : (.+?)\n',asm_alumnos_consola_Descubrir[i])
    asm_alumnos_mediciones_Descubrir.append(float(extracciones.group(1)))
    print (extracciones.group(1))
print()
asm_alumnos_promedio_Descubrir = statistics.mean(asm_alumnos_mediciones_Descubrir)
print("Promedio        = "  + str(asm_alumnos_promedio_Descubrir))
asm_alumnos_desvioEs_Descubrir = statistics.stdev(asm_alumnos_mediciones_Descubrir)
print("Desvío estándar =  " + str(asm_alumnos_desvioEs_Descubrir))




print(colored("\n" + str(Cant_medidiones) + " mediciones de pulsos de reloj de Zigzag c de cátedra sobre imagen " + nombre + "\n", 'blue'))

for i in range(len(c___catedra_consola_Zigzag)):
    extracciones = re.search('  # de ciclos insumidos totales     : (.+?)\n',c___catedra_consola_Zigzag[i])
    c___catedra_mediciones_Zigzag.append(float(extracciones.group(1)))
    print (extracciones.group(1))
print()
c___catedra_promedio_Zigzag = statistics.mean(c___catedra_mediciones_Zigzag)
print("Promedio        = "  + str(c___catedra_promedio_Zigzag))
c___catedra_desvioEs_Zigzag = statistics.stdev(c___catedra_mediciones_Zigzag)
print("Desvío estándar =  " + str(c___catedra_desvioEs_Zigzag))

print(colored("\n" + str(Cant_medidiones) + " mediciones de pulsos de reloj de Zigzag asm de alumnos sobre imagen " + nombre + "\n", 'blue'))

for i in range(len(asm_alumnos_consola_Zigzag)):
    extracciones = re.search('  # de ciclos insumidos totales     : (.+?)\n',asm_alumnos_consola_Zigzag[i])
    asm_alumnos_mediciones_Zigzag.append(float(extracciones.group(1)))
    print (extracciones.group(1))
print()
asm_alumnos_promedio_Zigzag = statistics.mean(asm_alumnos_mediciones_Zigzag)
print("Promedio        = "  + str(asm_alumnos_promedio_Zigzag))
asm_alumnos_desvioEs_Zigzag = statistics.stdev(asm_alumnos_mediciones_Zigzag)
print("Desvío estándar =  " + str(asm_alumnos_desvioEs_Zigzag))

print()



with open('Medicion_Ocultar_catedra_' + Ocultar_nombre + "_en_" + nombre + '.py','w') as archivo:
    archivo.write(str(Cant_medidiones) + " mediciones de pulsos de reloj de Ocultar c de cátedra sobre imagen " + nombre + "\n")
    archivo.write(', '.join(map(str,c___catedra_mediciones_Ocultar)))
    archivo.write("\nPromedio        = "  + str(c___catedra_promedio_Ocultar))
    archivo.write("\nDesvío estándar =  " + str(c___catedra_desvioEs_Ocultar))

with open('Medicion_Ocultar_alumnos_' + Ocultar_nombre + "_en_" + nombre + '.py','w') as archivo:
    archivo.write(str(Cant_medidiones) + " mediciones de pulsos de reloj de Ocultar asm de alumnos sobre imagen " + nombre + "\n")
    archivo.write(', '.join(map(str,asm_alumnos_mediciones_Ocultar)))
    archivo.write("\nPromedio        = "  + str(asm_alumnos_promedio_Ocultar))
    archivo.write("\nDesvío estándar =  " + str(asm_alumnos_desvioEs_Ocultar))


with open('Medicion_Descubrir_catedra_' + Descubrir_nombre + '.py','w') as archivo:
    archivo.write(str(Cant_medidiones) + " mediciones de pulsos de reloj de Descubrir c de cátedra sobre imagen " + nombre + "\n")
    archivo.write(', '.join(map(str,c___catedra_mediciones_Descubrir)))
    archivo.write("\nPromedio        = "  + str(c___catedra_promedio_Descubrir))
    archivo.write("\nDesvío estándar =  " + str(c___catedra_desvioEs_Descubrir))

with open('Medicion_Descubrir_alumnos_' + Descubrir_nombre + '.py','w') as archivo:
    archivo.write(str(Cant_medidiones) + " mediciones de pulsos de reloj de Descubrir asm de alumnos sobre imagen " + nombre + "\n")
    archivo.write(', '.join(map(str,asm_alumnos_mediciones_Descubrir)))
    archivo.write("\nPromedio        = "  + str(asm_alumnos_promedio_Descubrir))
    archivo.write("\nDesvío estándar =  " + str(asm_alumnos_desvioEs_Descubrir))


with open('Medicion_Zigzag_catedra_' + nombre + '.py','w') as archivo:
    archivo.write(str(Cant_medidiones) + " mediciones de pulsos de reloj de Zigzag c de cátedra sobre imagen " + nombre + "\n")
    archivo.write(', '.join(map(str,c___catedra_mediciones_Zigzag)))
    archivo.write("\nPromedio        = "  + str(c___catedra_promedio_Zigzag))
    archivo.write("\nDesvío estándar =  " + str(c___catedra_desvioEs_Zigzag))

with open('Medicion_Zigzag_alumnos_' + nombre + '.py','w') as archivo:
    archivo.write(str(Cant_medidiones) + " mediciones de pulsos de reloj de Zigzag asm de alumnos sobre imagen " + nombre + "\n")
    archivo.write(', '.join(map(str,asm_alumnos_mediciones_Zigzag)))
    archivo.write("\nPromedio        = "  + str(asm_alumnos_promedio_Zigzag))
    archivo.write("\nDesvío estándar =  " + str(asm_alumnos_desvioEs_Zigzag))




Ocultar_EjeImplemt        = ('C','ASM\nsin\noptimizar')
Ocultar_distribucion_Barras = np.arange(len(Ocultar_EjeImplemt))
Ocultar_EjeTiempoPromedio = []
Ocultar_EjeTiempoPromedio.append(c___catedra_promedio_Ocultar)
Ocultar_EjeTiempoPromedio.append(asm_alumnos_promedio_Ocultar)
Ocultar_EjeTiempoDesvioEs = []
Ocultar_EjeTiempoDesvioEs.append(c___catedra_desvioEs_Ocultar)
Ocultar_EjeTiempoDesvioEs.append(asm_alumnos_desvioEs_Ocultar)

plt.rcdefaults()
fig, ax = plt.subplots()
plt.barh(Ocultar_distribucion_Barras, Ocultar_EjeTiempoPromedio, xerr=Ocultar_EjeTiempoDesvioEs, align='center')
plt.yticks(Ocultar_distribucion_Barras)
ax.set_yticklabels(Ocultar_EjeImplemt)
ax.invert_yaxis()
for i, v in enumerate(Ocultar_EjeTiempoPromedio):
    ax.text(v+3, i+.25, "{:.2e}".format(v) + "\n" +chr(177) + " " + "{:.2e}".format(Ocultar_EjeTiempoDesvioEs[i],-4)) #str(round(v,-4)) + "\n" +chr(177) + " " + str(round(Ocultar_EjeTiempoDesvioEs[i],-4))
ax.set_xlim([0,38000000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Ocultar\n' + Ocultar_nombre + " en " + nombre)
plt.savefig("Ocultar." + Ocultar_nombre + ".en." + nombre + ".svg")





Descubrir_EjeImplemt        = ('C','ASM\nsin\noptimizar')
Descubrir_distribucion_Barras = np.arange(len(Descubrir_EjeImplemt))
Descubrir_EjeTiempoPromedio = []
Descubrir_EjeTiempoPromedio.append(c___catedra_promedio_Descubrir)
Descubrir_EjeTiempoPromedio.append(asm_alumnos_promedio_Descubrir)
Descubrir_EjeTiempoDesvioEs = []
Descubrir_EjeTiempoDesvioEs.append(c___catedra_desvioEs_Descubrir)
Descubrir_EjeTiempoDesvioEs.append(asm_alumnos_desvioEs_Descubrir)

plt.rcdefaults()
fig, ax = plt.subplots()
plt.barh(Descubrir_distribucion_Barras, Descubrir_EjeTiempoPromedio, xerr=Descubrir_EjeTiempoDesvioEs, align='center')
plt.yticks(Descubrir_distribucion_Barras)
ax.set_yticklabels(Descubrir_EjeImplemt)
ax.invert_yaxis()
for i, v in enumerate(Descubrir_EjeTiempoPromedio):
    ax.text(v+3, i+.25, "{:.2e}".format(v,-4) + "\n" +chr(177) + " " + "{:.2e}".format(Descubrir_EjeTiempoDesvioEs[i],-4)) #str(round(v,-4)) + "\n" +chr(177) + " " + str(round(Descubrir_EjeTiempoDesvioEs[i],-4))
ax.set_xlim([0,38000000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Descubrir\n' + Descubrir_nombre)
plt.savefig("Descubrir." + Descubrir_nombre + ".svg")




Zigzag_EjeImplemt        = ('C','ASM\nsin\noptimizar')
Zigzag_distribucion_Barras = np.arange(len(Zigzag_EjeImplemt))
Zigzag_EjeTiempoPromedio = []
Zigzag_EjeTiempoPromedio.append(c___catedra_promedio_Zigzag)
Zigzag_EjeTiempoPromedio.append(asm_alumnos_promedio_Zigzag)
Zigzag_EjeTiempoDesvioEs = []
Zigzag_EjeTiempoDesvioEs.append(c___catedra_desvioEs_Zigzag)
Zigzag_EjeTiempoDesvioEs.append(asm_alumnos_desvioEs_Zigzag)

plt.rcdefaults()
fig, ax = plt.subplots()
plt.barh(Zigzag_distribucion_Barras, Zigzag_EjeTiempoPromedio, xerr=Zigzag_EjeTiempoDesvioEs, align='center')
plt.yticks(Zigzag_distribucion_Barras)
ax.set_yticklabels(Zigzag_EjeImplemt)
ax.invert_yaxis()
for i, v in enumerate(Zigzag_EjeTiempoPromedio):
    ax.text(v+3, i+.25, "{:.2e}".format(v) + "\n" +chr(177) + " " + "{:.2e}".format(Zigzag_EjeTiempoDesvioEs[i])) #str(round(v,-4)) + "\n" +chr(177) + " " + str(round(Zigzag_EjeTiempoDesvioEs[i],-4))
ax.set_xlim([0,38000000])
plt.xlabel('Pulsos de reloj de CPU')
plt.title('Tiempos de ejecución Zigzag\n' + nombre)
plt.savefig("Zigzag." + nombre + ".svg")
