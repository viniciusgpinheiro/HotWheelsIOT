from machine import Pin, PWM
from time import sleep
from umqtt import MQTTClient
from servo import lancar
import machine
import network
import onewire
import ds18x20
import ubinascii
import ujson
import json
import time
import math
import os


# --- utilitarias --- 
def velocidade(dist, temp1, temp2):
    dif_ms = time.ticks_diff(temp2, temp1)
    dif_segundos = dif_ms / 1000

    if dif_segundos <= 0:
        return 0
    
    velocidade_ms = dist / dif_segundos
    velocidade_kmh = velocidade_ms * 3.6
    return velocidade_kmh


def servo_motor():
    global servo, servo_etapa, servo_tempo

    if servo_etapa == 0:
        return
    
    if servo_etapa == 1:
        servo.duty(26)
        if time.ticks_diff(time.ticks_ms(), servo_tempo) > 500:
            servo_etapa = 2
            servo_tempo = time.ticks_ms()

    elif servo_etapa == 2:
        servo.duty(123)
        if time.ticks_diff(time.ticks_ms(), servo_tempo) > 500:
            servo_etapa = 0


# --- umqtt ---

# v1
def cbTrataMsg(topic, msg):
    global servo_etapa, servo_tempo

    print(f'Msg recebida no tópico: {topic.decode("utf-8")}')
    data = json.loads(msg.decode('utf-8'))

    if data.get("fire") and servo_etapa == 0:
        servo_etapa = 1
        servo_tempo = time.ticks_ms()

# v2
def cbTrataMsg(topic, msg):
    comando = msg.decode()
    print("Mensagem recebida:")
    print(comando)

    if comando == "LIBERAR":
        print("Iniciando lançamento")
        lancar()


def carregar_config():
    conf = {}
    try:
        with open(".env", "r") as f:
            for linha in f:
                linha = linha.strip()
                if "=" in linha and not linha.startswith("#"):
                    chave, valor = linha.split("=", 1)
                    conf[chave.strip()] = valor.strip()
        return conf
    except Exception as e:
        print("Erro ao ler .env:", e)
        return None


# --- Pegando informações .env ---
config = carregar_config()
if config:
    WIFI_SSID = config.get('WIFI_SSID')
    WIFI_PWD  = config.get('WIFI_PWD')
    MQTT_SERVER = config.get('MQTT_SERVER')
    MQTT_PORT   = int(config.get('MQTT_PORT', 8883))
    MQTT_USER   = config.get('MQTT_USER').encode()
    MQTT_PWD    = config.get('MQTT_PWD').encode()
    TOPIC_PUB   = config.get('MQTT_TOPIC').encode()
else:
    print(".env não encontrado ou vazio!")


# --- Conectando com a Rede ---
rede = network.WLAN(network.STA_IF)
rede.active(True)
rede.connect(WIFI_SSID, WIFI_PWD)
while not rede.isconnected():
    print(".", end="")
    sleep(0.5)
print("\nConectado em", rede.ifconfig()[0])


# --- Configurando MQTT ---
print("Inicializando conexão com o broker...")
client_id = ubinascii.hexlify(machine.unique_id())

try:
    client = MQTTClient(
        client_id,
        MQTT_SERVER,
        port=MQTT_PORT,
        user=MQTT_USER,
        password=MQTT_PWD,
        ssl=True,
        ssl_params={'server_hostname': MQTT_SERVER}
    )
    client.set_callback(cbTrataMsg)
    client.connect()
    client.subscribe(TOPIC_PUB)
    print("MQTT Conectado!")
except OSError as e:
    print("Erro ao conectar no MQTT:", e)
    sleep(2)
    machine.reset()


# --- Loop ---
servo = PWM(Pin(22, Pin.OUT))
servo.freq(50)
servo_etapa = 0
servo_tempo = 0

sensor1 = Pin(18, Pin.IN)
sensor2 = Pin(4, Pin.IN)
tempo1, tempo2 = 0, 0
distancia = 0.93
raio = 0.12

while True:
    try:
        client.check_msg()
        servo_motor()

        if (tempo1 != 0 and tempo2 != 0) or (
            tempo1 != 0 and (time.ticks_diff(time.ticks_ms(), tempo1)/1000) > (2 * math.pi * math.sqrt(raio / 9.8)) + 2):

            msg_json = {
                "sensor1" : tempo1,
                "sensor2" : tempo2,
                "distancia" : distancia,
                "velocidade" : velocidade(distancia, tempo1, tempo2)
            }
            print(f"Publicando: {msg_json}")
            client.publish(TOPIC_PUB, ujson.dumps(msg_json))
            tempo1, tempo2 = 0, 0

        if sensor1.value() == 0 and tempo1 == 0:
            tempo1 = time.ticks_ms() 
            print("Sensor 1 ativado!")

        if sensor2.value() == 0 and tempo2 == 0:
            tempo2 = time.ticks_ms() 
            print("Sensor 2 ativado!")
        
        
    except OSError as e:
        print("Erro de conexão detectado:", e)
        sleep(5)
        machine.reset()
        