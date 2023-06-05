# SCMU Project

#### Project members:
- Rémi Bourdais <r.bourdais@campus.fct.unl.pt>(mailto:r.bourdais@campus.fct.unl.pt)
- Louis CHATARD <l.chatard@campus.fct.unl.pt>(mailto:l.chatard@campus.fct.unl.pt)

#### Project supervisors:
Carmen Pires Morgado
Nuno Manuel Ribeiro Preguiça

## Project description

This project is made in the context of the course "Sistemas de Computação Móvel e Ubíqua" of the Master in Computer Science at the Nova FCT university.

## Build the project localy

### Build the application

To build the application, you need to have the following tools installed on your computer:
- [Flutter](https://flutter.dev/docs/get-started/install)
  
Then, you can create a flutter project and replace the `lib` folder with the one in this repository.
and also replace the `pubspec.yaml` file with the one in this repository.

You can then run the application on your device with the following command:
```bash
flutter run
```

### Build the server

To build the server, you need to have the following tools installed on your computer:
- [Python 3](https://www.python.org/downloads/)
- [pip](https://pip.pypa.io/en/stable/installing/)
- [Flask](https://flask.palletsprojects.com/en/1.1.x/installation/)

Then, you can run the server with the following command:
```bash
python3 CreateDB.py
python3 app.py
```

## Build the esp32

To build the esp32, you need to have the following tools installed on your computer:
- [Visual Studio Code](https://code.visualstudio.com/)
- [PlatformIO](https://platformio.org/install/ide?install=vscode)

Then, you can open the `ESP` folder with Visual Studio Code and run the application on your device.

You can also use other IDEs, but you will need to install the dependencies yourself.

## Final configuration

Replace all the IP addresses in the code with the IP address of your server.



