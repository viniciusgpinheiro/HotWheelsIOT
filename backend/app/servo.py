from machine import Pin, PWM
import time

# =====================================
# CONFIGURAÇÕES
# =====================================

PINO_SERVO = 13
PINO_SENSOR = 18

# sensor já usado no seu projeto
sensor = Pin(PINO_SENSOR, Pin.IN)

# inicia PWM do servo
servo = PWM(Pin(PINO_SERVO))
servo.freq(50)


# =====================================
# FUNÇÃO DE ÂNGULO
# =====================================

def mover_servo(angulo):

    # Conversão para SG90
    duty = int((angulo / 180 * 75) + 40)

    servo.duty(duty)

    time.sleep_ms(500)


# =====================================
# POSIÇÕES
# =====================================

def fechar():

    print("Trava fechada")
    mover_servo(0)


def abrir():

    print("Soltando carrinho")
    mover_servo(90)


# inicia fechado
fechar()


# =====================================
# LANÇAMENTO
# =====================================

def lancar():

    abrir()

    print("Esperando carro passar...")

    while True:

        if sensor.value() == 0:

            print("Carro detectado!")

            time.sleep_ms(300)

            fechar()

            break