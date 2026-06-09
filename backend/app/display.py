from machine import Pin
import neopixel
import time

# ==========================
# CONFIGURAÇÃO
# ==========================

PINO_DISPLAY = 5
NUM_LEDS = 48

np = neopixel.NeoPixel(
    Pin(PINO_DISPLAY),
    NUM_LEDS
)


# ==========================
# FUNÇÕES BÁSICAS
# ==========================

def limpar():

    for i in range(NUM_LEDS):
        np[i] = (0, 0, 0)

    np.write()


def preencher(cor):

    for i in range(NUM_LEDS):
        np[i] = cor

    np.write()


# ==========================
# TESTE
# ==========================

def teste():

    preencher((255, 0, 0))
    time.sleep(1)

    preencher((0, 255, 0))
    time.sleep(1)

    preencher((0, 0, 255))
    time.sleep(1)

    limpar()


# ==========================
# CONTAGEM
# ==========================

def contagem():

    # 3 = vermelho
    preencher((255, 0, 0))
    print("3")
    time.sleep(1)

    # 2 = amarelo
    preencher((255, 255, 0))
    print("2")
    time.sleep(1)

    # 1 = azul
    preencher((0, 0, 255))
    print("1")
    time.sleep(1)

    # GO = verde
    preencher((0, 255, 0))
    print("GO!")
    time.sleep(1)

    limpar()


# ==========================
# RESULTADO
# ==========================

def mostrar_resultado(
    tempo,
    velocidade
):

    print("----------------")
    print("TEMPO:", tempo)
    print("VELOCIDADE:", velocidade)
    print("----------------")

    # verde = resultado recebido
    preencher((0, 255, 0))
    time.sleep(2)

    limpar()