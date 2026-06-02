# RELATÓRIO PARCIAL – SISTEMA DE MEDIÇÃO DE VELOCIDADE PARA CARRINHOS HOT WHEELS

## 1. Objetivo

O objetivo deste projeto é desenvolver um sistema capaz de comparar o desempenho de carrinhos Hot Wheels em diferentes tipos de pistas, permitindo verificar experimentalmente se um carrinho atinge maior velocidade em uma pista reta ou em uma pista curva.

Para isso, foi desenvolvido um sistema utilizando ESP32, sensores de passagem, servo motor e comunicação sem fio via MQTT, permitindo que os lançamentos sejam controlados remotamente por um aplicativo e que os resultados sejam enviados para visualização posterior.

---

## 2. Materiais Utilizados

* ESP32
* Servo motor
* Dois sensores infravermelhos de passagem
* Pistas Hot Wheels
* Rede Wi-Fi
* Broker MQTT
* Computador para programação
* Aplicativo para envio de comandos
* Cabos e protoboard
* Fonte de alimentação

---

## 3. Metodologia

Inicialmente foi estudada uma forma de realizar o lançamento dos carrinhos sempre nas mesmas condições, evitando interferência humana no experimento.

Foi então desenvolvido um mecanismo de disparo utilizando um servo motor conectado ao ESP32. O servo atua como uma trava mecânica que mantém o carrinho parado até o momento do lançamento.

O ESP32 foi programado utilizando MicroPython, possibilitando o controle dos sensores, do servo motor e da comunicação via rede sem fio.

Para medir a velocidade do carrinho, foram instalados dois sensores em posições conhecidas da pista. Quando o carrinho passa pelo primeiro sensor, o sistema registra o instante de tempo. Em seguida, quando o carrinho passa pelo segundo sensor, um novo instante é registrado.

Sabendo-se a distância entre os sensores e o intervalo de tempo medido, é possível calcular a velocidade média do carrinho através da equação:

Velocidade = Distância ÷ Tempo

Após o cálculo da velocidade em metros por segundo, o valor é convertido para quilômetros por hora para facilitar a interpretação dos resultados.

---

## 4. Desenvolvimento do Software

O software foi dividido em módulos para facilitar a organização do projeto.

### 4.1 Comunicação MQTT

Foi implementada uma comunicação utilizando o protocolo MQTT.

O ESP32 conecta-se à rede Wi-Fi e posteriormente ao broker MQTT configurado no arquivo de ambiente (.env).

Quando o aplicativo envia um comando de lançamento, o ESP32 recebe a mensagem e inicia o processo de disparo do carrinho.

A comunicação MQTT permite que o sistema seja controlado remotamente sem necessidade de conexão física com o dispositivo.

---

### 4.2 Controle do Servo Motor

Foi desenvolvido um módulo responsável pelo controle do servo motor.

O servo permanece inicialmente em posição de trava, impedindo a movimentação do carrinho.

Ao receber um comando de lançamento, o servo gira para liberar o carrinho na pista.

Após a passagem do veículo pelo sensor inicial, o servo retorna à posição original, preparando o sistema para um novo lançamento.

Esse mecanismo garante maior repetibilidade dos testes e reduz erros causados por lançamentos manuais.

---

### 4.3 Sistema de Sensores

O sistema utiliza dois sensores de passagem posicionados ao longo da pista.

Quando o carrinho interrompe o feixe do primeiro sensor, o instante é armazenado em milissegundos.

Ao passar pelo segundo sensor, um novo instante é registrado.

A diferença entre esses dois tempos representa o tempo gasto pelo carrinho para percorrer a distância conhecida entre os sensores.

---

### 4.4 Cálculo da Velocidade

A velocidade média é calculada utilizando a distância fixa entre os sensores, definida em aproximadamente 0,93 metros.

Após a leitura dos tempos, o sistema realiza automaticamente o cálculo da velocidade em metros por segundo.

Em seguida, o valor é convertido para quilômetros por hora utilizando o fator de conversão:

1 m/s = 3,6 km/h

Os resultados são enviados através do MQTT para futura visualização no aplicativo.

---

## 5. Estrutura Atual do Sistema

Atualmente o sistema já possui:

* Conexão Wi-Fi funcional;
* Comunicação MQTT funcional;
* Recebimento de comandos enviados pelo aplicativo;
* Controle do servo motor;
* Leitura dos dois sensores;
* Registro dos tempos de passagem;
* Cálculo automático da velocidade;
* Envio dos resultados através do MQTT;
* Estrutura modular separada em arquivos independentes.

---

## 6. Resultados Obtidos

Os testes iniciais demonstraram que o sistema é capaz de:

* Detectar a passagem do carrinho pelos sensores;
* Registrar os tempos com precisão em milissegundos;
* Acionar o servo motor remotamente;
* Calcular automaticamente a velocidade média do carrinho;
* Enviar os resultados para o sistema de monitoramento.

Os resultados indicam que a plataforma está apta para realizar experimentos comparativos entre diferentes tipos de pista.

---

## 7. Melhorias Futuras

As próximas etapas do projeto incluem:

* Implementação de uma interface gráfica mais completa;
* Armazenamento de histórico de lançamentos;
* Exibição dos resultados em display LED;
* Comparação automática entre pista reta e pista curva;
* Geração de estatísticas dos testes realizados;
* Melhorias mecânicas no sistema de lançamento.

---

## 8. Conclusão

O desenvolvimento do sistema permitiu a integração entre eletrônica, programação e conceitos de Física, proporcionando uma solução capaz de medir automaticamente a velocidade de carrinhos em miniatura.

A utilização do ESP32 associada à comunicação MQTT mostrou-se eficiente para o controle remoto do experimento, enquanto os sensores e o servo motor garantiram a automatização do processo de medição.

Até o momento, o projeto apresenta funcionamento satisfatório e demonstra potencial para auxiliar na análise comparativa entre diferentes configurações de pista, contribuindo para a realização de experimentos de forma mais precisa e confiável.
