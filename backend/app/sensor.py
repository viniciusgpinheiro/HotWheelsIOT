from machine import Pin
import time

sensor1 = Pin(18, Pin.IN)
sensor2 = Pin(4, Pin.IN)
# 12 cm de raio
tempo1 = 0
tempo2 = 0
distancia = 0.93

print("--- Aguardando passagem pelos sensores ---")

while tempo1 == 0:
    if sensor1.value() == 0:
        tempo1 = time.ticks_ms() 
        print("Sensor 1 ativado!")

while tempo2 == 0:
    if sensor2.value() == 0:
        tempo2 = time.ticks_ms() 
        print("Sensor 2 ativado!")


dif_ms = time.ticks_diff(tempo2, tempo1)
dif_segundos = dif_ms / 1000

if dif_segundos > 0:
    velocidade_ms = distancia / dif_segundos
    velocidade_kmh = velocidade_ms * 3.6
    print("-" * 40)
    print(f"Distância: {distancia} m")
    print(f"Tempo: {dif_segundos:.3f} s")
    print(f"Velocidade: {velocidade_ms:.2f} m/s")
    print(f"Velocidade: {velocidade_kmh:.2f} km/h") # Sua conversão aqui!
    print("-" * 40)
else:
    print("Erro: Os sensores foram acionados ao mesmo tempo ou na ordem errada.")