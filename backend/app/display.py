from machine import Pin, SPI
import max7219
import time

# AJUSTE OS PINOS SE NECESSÁRIO
spi = SPI(
    1,
    baudrate=10000000,
    polarity=0,
    phase=0,
    sck=Pin(14),
    mosi=Pin(23)
)

cs = Pin(5, Pin.OUT)

display = max7219.Matrix8x8(spi, cs, 4)

display.brightness(5)


def limpar():
    display.fill(0)
    display.show()


def mostrar(texto):

    texto = str(texto)

    display.fill(0)
    display.text(texto, 0, 0, 1)
    display.show()


def contagem():

    mostrar("3")
    time.sleep(1)

    mostrar("2")
    time.sleep(1)

    mostrar("1")
    time.sleep(1)

    mostrar("GO!")
    time.sleep(1)

    limpar()


def mostrar_resultado(tempo, velocidade):

    mostrar("T:{:.2f}".format(tempo))
    time.sleep(3)

    mostrar("V:{:.2f}".format(velocidade))
    time.sleep(3)

    limpar()