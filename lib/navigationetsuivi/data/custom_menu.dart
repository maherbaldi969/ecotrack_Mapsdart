import 'package:flutter/material.dart';
import '../caméra.dart';
import '../DownloadMapPage.dart';
import '../OfflineMapPage.dart';
import '/chat/chat_list_screen.dart';

class CustomMenu extends StatelessWidget {
  final Function sharePositionCallback;

  const CustomMenu({Key? key, required this.sharePositionCallback})
      : super(key: key);

  TextStyle _boldTextStyle() {
    return const TextStyle(fontWeight: FontWeight.bold);
  }

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      offset: const Offset(-60, -180),
      icon: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFF80C000),
          shape: BoxShape.rectangle,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.more_vert, color: Colors.white, size: 30),
      ),
      onSelected: (String value) {
        _handleMenuSelection(context, value, sharePositionCallback);
      },
      itemBuilder: (BuildContext context) {
        return [
          PopupMenuItem<String>(
            value: "Contactez guide",
            height: 50,
            child: Row(
              children: [
                Icon(Icons.support_agent, color: Color(0xFF80C000)),
                const SizedBox(width: 10),
                const Text("Contactez guide"),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "Mode hors-ligne",
            height: 50,
            child: Row(
              children: [
                Icon(Icons.wifi_off, color: Color(0xFF80C000)),
                const SizedBox(width: 10),
                const Text("Mode hors-ligne"),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "Ma Carte",
            height: 50,
            child: Row(
              children: [
                Icon(Icons.map, color: Color(0xFF80C000)),
                const SizedBox(width: 10),
                const Text("Ma Carte"),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "Prendre photo",
            height: 50,
            child: Row(
              children: [
                Icon(Icons.camera_alt, color: Color(0xFF80C000)),
                const SizedBox(width: 10),
                const Text("Prendre photo"),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "Partager ma position",
            height: 50,
            child: Row(
              children: [
                Icon(Icons.share_location, color: Color(0xFF80C000)),
                const SizedBox(width: 10),
                const Text("Partager ma position"),
              ],
            ),
          ),
          PopupMenuItem<String>(
            value: "Fermer",
            height: 50,
            child: SizedBox(
              width: 200,
              child: Row(
                children: [
                  Icon(Icons.close, color: Color(0xFF80C000)),
                  const SizedBox(width: 10),
                  const Text("Fermer"),
                ],
              ),
            ),
          ),
        ];
      },
    );
  }

  void _handleMenuSelection(
      BuildContext context, String value, Function sharePositionCallback) {
    switch (value) {
      case "Mode hors-ligne":
        _showOfflineModeDialog(context);
        break;
      case "Contactez guide":
        _showContactGuideDialog(context);
        break;
      case "Prendre photo":
        _showTakePhotoDialog(context);
        break;
      case "Ma Carte":
        _showMyMapDialog(context);
        break;
      case "Partager ma position":
        sharePositionCallback();
        break;
    }
  }

  void _showOfflineModeDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            "Mode hors-ligne",
            style: _boldTextStyle(),
          ),
          content: Text(
            "Enregistrement des cartes et des itinéraires pour une utilisation hors ligne.",
            style: _boldTextStyle(),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                "Fermer",
                style: _boldTextStyle(),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DownloadMapPage()),
                );
              },
              child: const Text(
                "Enregistrer la carte",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showContactGuideDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Contactez guide"),
          content: const Text(
            "Vous pouvez contacter un guide pour obtenir de l'aide ou des informations supplémentaires.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Fermer"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatListScreen()),
                );
              },
              child: const Text(
                "Contacter",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showTakePhotoDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Prendre photo"),
          content: const Text(
            "Vous pouvez prendre des photos et le partager.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Fermer"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CameraCapturePage()),
                );
              },
              child: const Text(
                "prendre photo",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showMyMapDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ma Carte"),
          content: const Text(
            "Vous pouvez voir la carte téléchargée hors ligne.",
          ),
          actions: <Widget>[
            TextButton(
              child: const Text("Fermer"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF80C000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => OfflineMapPage()),
                );
              },
              child: const Text(
                "voir la carte",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
